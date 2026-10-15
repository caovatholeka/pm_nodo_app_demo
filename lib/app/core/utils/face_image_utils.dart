import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

import '../logger/logger.dart';
import 'perf_log.dart';

/// Ảnh camera trước chụp ra ~1440x1920, ~700 KB. Nhận diện khuôn mặt chỉ cần ảnh nhỏ:
/// thu về cạnh dài [faceImageMaxSide] px để upload nhanh (~8 lần nhẹ hơn) mà vẫn đủ chi tiết.
const int faceImageMaxSide = 800;
const int faceImageQuality = 85;

/// Nén ảnh [srcPath] ra [dstPath]. Lỗi thì lùi dần về cách chậm hơn, cuối cùng giữ ảnh gốc
/// — chấm công không được hỏng vì bước nén.
Future<File> compressFaceImage(String srcPath, String dstPath) async {
  final stopwatch = Stopwatch()..start();
  final original = await File(srcPath).readAsBytes();
  final output = await compressFaceImageBytes(original);
  final file = await File(dstPath).writeAsBytes(output, flush: true);
  perfLog(
    'face image ${original.lengthInBytes ~/ 1024} KB -> '
    '${output.lengthInBytes ~/ 1024} KB in ${stopwatch.elapsedMilliseconds} ms',
  );
  return file;
}

/// Nén bytes JPEG về cạnh dài tối đa [faceImageMaxSide] px.
@visibleForTesting
Future<Uint8List> compressFaceImageBytes(Uint8List original) async {
  try {
    return await resizeFaceImageWithEngine(original);
  } catch (e) {
    logger.w('Engine resize failed, fallback to pure Dart: $e');
  }
  try {
    return await compute(resizeFaceImageWithDart, original);
  } catch (e) {
    logger.w('Compress face image failed, upload original: $e');
    return original;
  }
}

/// Giải mã bằng bộ giải mã native của Flutter, thu nhỏ ngay lúc giải mã (nhanh hơn nhiều so
/// với giải mã cả ảnh 1440x1920 bằng Dart), rồi nén JPEG ở isolate riêng. Bộ giải mã của
/// Flutter tự xoay theo EXIF nên ảnh luôn đứng thẳng (ảnh iPhone hay chỉ ghi hướng vào EXIF).
@visibleForTesting
Future<Uint8List> resizeFaceImageWithEngine(Uint8List bytes) async {
  final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
  final codec = await ui.instantiateImageCodecWithSize(
    buffer,
    getTargetSize: (int width, int height) {
      final longest = width > height ? width : height;
      if (longest <= faceImageMaxSide) return ui.TargetImageSize();
      // Chỉ truyền 1 chiều để giữ đúng tỉ lệ ảnh
      return width >= height
          ? ui.TargetImageSize(width: faceImageMaxSide)
          : ui.TargetImageSize(height: faceImageMaxSide);
    },
  );
  final frame = await codec.getNextFrame();
  final image = frame.image;
  try {
    final rgba = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (rgba == null) throw StateError('toByteData returned null');
    return await compute(
      _encodeRgbaJpeg,
      _RgbaFrame(rgba.buffer.asUint8List(), image.width, image.height),
    );
  } finally {
    image.dispose();
    codec.dispose();
  }
}

class _RgbaFrame {
  final Uint8List bytes;
  final int width;
  final int height;

  const _RgbaFrame(this.bytes, this.width, this.height);
}

Uint8List _encodeRgbaJpeg(_RgbaFrame frame) {
  final image = img.Image.fromBytes(
    width: frame.width,
    height: frame.height,
    bytes: frame.bytes.buffer,
    numChannels: 4,
    order: img.ChannelOrder.rgba,
  );
  return img.encodeJpg(image, quality: faceImageQuality);
}

/// Cách dự phòng: giải mã + thu nhỏ hoàn toàn bằng Dart (chậm hơn, ~0,5–0,8 s).
@visibleForTesting
Uint8List resizeFaceImageWithDart(Uint8List bytes) {
  final decoded = img.decodeJpg(bytes);
  if (decoded == null) return bytes;
  // Xoay theo EXIF trước khi resize để ảnh gửi đi luôn đứng thẳng
  var image = img.bakeOrientation(decoded);
  final longest = image.width > image.height ? image.width : image.height;
  if (longest > faceImageMaxSide) {
    image = image.width >= image.height
        ? img.copyResize(image, width: faceImageMaxSide, interpolation: img.Interpolation.average)
        : img.copyResize(image, height: faceImageMaxSide, interpolation: img.Interpolation.average);
  }
  return img.encodeJpg(image, quality: faceImageQuality);
}

/// Xoá file tạm, bỏ qua lỗi (file có thể đã bị hệ điều hành dọn).
Future<void> deleteQuietly(String? path) async {
  if (path == null || path.isEmpty) return;
  try {
    final file = File(path);
    if (await file.exists()) await file.delete();
  } catch (_) {}
}
