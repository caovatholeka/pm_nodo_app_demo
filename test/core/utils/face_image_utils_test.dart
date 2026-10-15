import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:pm_app/app/core/utils/face_image_utils.dart';

/// Ảnh JPEG [width]x[height]: nửa đầu đỏ, nửa sau xanh — theo chiều dọc (portrait) hoặc
/// chiều ngang (landscape) — để kiểm tra ảnh sau nén vẫn đúng hướng.
Uint8List _jpeg(int width, int height, {bool splitVertical = true, int? exifOrientation}) {
  final image = img.Image(width: width, height: height);
  for (final p in image) {
    final firstHalf = splitVertical ? p.y < height / 2 : p.x < width / 2;
    p.setRgb(firstHalf ? 220 : 20, 20, firstHalf ? 20 : 220);
  }
  if (exifOrientation != null) {
    image.exif.imageIfd.orientation = exifOrientation;
  }
  return img.encodeJpg(image, quality: 90);
}

bool _isRed(img.Pixel p) => p.r > 150 && p.b < 100;
bool _isBlue(img.Pixel p) => p.b > 150 && p.r < 100;

void _expectUprightPortrait(Uint8List out) {
  final decoded = img.bakeOrientation(img.decodeJpg(out)!);
  expect(decoded.width, 600);
  expect(decoded.height, 800);
  expect(_isRed(decoded.getPixel(300, 50)), isTrue, reason: 'đầu ảnh phải đỏ');
  expect(_isBlue(decoded.getPixel(300, 750)), isTrue, reason: 'cuối ảnh phải xanh');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final portrait = _jpeg(1440, 1920);

  group('resizeFaceImageWithEngine (đường chính)', () {
    test('ảnh dọc 1440x1920 -> 600x800, đúng hướng, nhỏ hơn nhiều', () async {
      final out = await resizeFaceImageWithEngine(portrait);
      _expectUprightPortrait(out);
      expect(out.lengthInBytes, lessThan(portrait.lengthInBytes ~/ 3));
    });

    test('ảnh ngang 1920x1440 -> 800x600', () async {
      final out = await resizeFaceImageWithEngine(_jpeg(1920, 1440));
      final decoded = img.decodeJpg(out)!;
      expect(decoded.width, 800);
      expect(decoded.height, 600);
    });

    test('ảnh lưu nằm ngang + EXIF xoay 90 độ (kiểu iPhone) -> ảnh dọc đứng thẳng', () async {
      // Pixel lưu ngang 1920x1440, trái đỏ / phải xanh; EXIF 6 = xoay 90° theo chiều kim đồng hồ
      // khi hiển thị → hiển thị dọc 1440x1920, đỏ ở trên, xanh ở dưới.
      final rotated = _jpeg(1920, 1440, splitVertical: false, exifOrientation: 6);
      final out = await resizeFaceImageWithEngine(rotated);
      final decoded = img.bakeOrientation(img.decodeJpg(out)!);
      expect(decoded.height, greaterThan(decoded.width), reason: 'phải ra ảnh dọc');
      expect(decoded.height, lessThanOrEqualTo(1067));
      expect(_isRed(decoded.getPixel(decoded.width ~/ 2, 20)), isTrue);
      expect(_isBlue(decoded.getPixel(decoded.width ~/ 2, decoded.height - 20)), isTrue);
    });

    test('ảnh nhỏ hơn 800px giữ nguyên kích thước (không phóng to)', () async {
      final out = await resizeFaceImageWithEngine(_jpeg(400, 300));
      final decoded = img.decodeJpg(out)!;
      expect(decoded.width, 400);
      expect(decoded.height, 300);
    });
  });

  group('resizeFaceImageWithDart (đường dự phòng)', () {
    test('ảnh dọc 1440x1920 -> 600x800, đúng hướng', () {
      _expectUprightPortrait(resizeFaceImageWithDart(portrait));
    });
  });

  group('compressFaceImageBytes', () {
    test('ảnh hợp lệ -> nén về 600x800', () async {
      _expectUprightPortrait(await compressFaceImageBytes(portrait));
    });

    test('dữ liệu không phải ảnh -> trả lại nguyên bản, không ném lỗi', () async {
      final junk = Uint8List.fromList(List<int>.generate(1000, (i) => i % 256));
      expect(await compressFaceImageBytes(junk), junk);
    });
  });
}
