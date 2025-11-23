import 'dart:typed_data';
import 'dart:math';
import 'package:image/image.dart' as img;

import 'anti_spoof_engine.dart';

enum BiPlanarOrder { cbCr, crCb }

class FrameUtils {
  /// Convert YUV420 (CameraImage planes) -> RGB (width x height u8)
  /// Android
  static Uint8List yuv420ToRgb({
    required Uint8List y,
    required Uint8List u,
    required Uint8List v,
    required int width,
    required int height,
    required int strideY,
    required int strideU,
    required int strideV,
  }) {
    final out = Uint8List(width * height * 3);
    int clampIndex(int idx, int maxLen) => idx < 0 ? 0 : (idx >= maxLen ? maxLen - 1 : idx);

    int o = 0;
    for (int r = 0; r < height; r++) {
      final yRow = r * strideY;
      final uRow = (r >> 1) * strideU;
      final vRow = (r >> 1) * strideV;

      for (int c = 0; c < width; c++) {
        final yOff = clampIndex(yRow + c, y.length);
        final uOff = clampIndex(uRow + (c >> 1), u.length);
        final vOff = clampIndex(vRow + (c >> 1), v.length);

        final Y = y[yOff].toInt();
        final U = u[uOff].toInt();
        final V = v[vOff].toInt();

        final yVal = Y.toDouble();
        final cb = (U - 128).toDouble();
        final cr = (V - 128).toDouble();

        double rF = yVal + 1.402 * cr;
        double gF = yVal - 0.344136 * cb - 0.714136 * cr;
        double bF = yVal + 1.772 * cb;

        int r8 = rF.isNaN ? 0 : rF.round().clamp(0, 255);
        int g8 = gF.isNaN ? 0 : gF.round().clamp(0, 255);
        int b8 = bF.isNaN ? 0 : bF.round().clamp(0, 255);

        out[o++] = r8;
        out[o++] = g8;
        out[o++] = b8;
      }
    }
    return out;
  }

  /// Resize RGB u8 [H,W,3] -> [h2,w2,3] (bilinear - dùng package image)
  static Uint8List resizeRgb(Uint8List rgb, int w, int h, int w2, int h2) {
    final rowStride = w * 3;

    final im = img.Image.fromBytes(
      width: w,
      height: h,
      bytes: rgb.buffer,
      rowStride: rowStride,
      numChannels: 3,
      order: img.ChannelOrder.rgb,
    );

    final out = img.copyResize(
      im,
      width: w2,
      height: h2,
      interpolation: img.Interpolation.linear,
    );

    return Uint8List.fromList(out.getBytes(order: img.ChannelOrder.rgb));
  }

  static Uint8List cropRgbNorm({
    required Uint8List rgb,
    required int width,
    required int height,
    required RectN r,
  }) {
    final x1 = (r.x1 * width).round().clamp(0, width - 1);
    final y1 = (r.y1 * height).round().clamp(0, height - 1);
    final x2 = (r.x2 * width).round().clamp(x1 + 1, width);
    final y2 = (r.y2 * height).round().clamp(y1 + 1, height);
    final w = x2 - x1, h = y2 - y1;

    final out = Uint8List(w * h * 3);
    int o = 0;
    for (int j = y1; j < y2; j++) {
      final row = j * width * 3;
      for (int i = x1; i < x2; i++) {
        final p = row + i * 3;
        out[o++] = rgb[p];
        out[o++] = rgb[p + 1];
        out[o++] = rgb[p + 2];
      }
    }
    return out;
  }

  /// Mean channel G trên ROI (RGB u8 [H,W,3])
  static double meanGreen(Uint8List rgb) {
    double s = 0;
    for (int i = 1; i < rgb.length; i += 3) s += rgb[i];
    return s / (rgb.length / 3);
  }

  // FrameUtils.dart
  static Uint8List rotateRgb(Uint8List rgb, int w, int h, int deg) {
    const bytesPerPix = 3;
    final normDeg = ((deg % 360) + 360) % 360; // chuẩn hoá về 0/90/180/270

    if (normDeg == 0) return rgb;

    // Xoay 180°
    if (normDeg == 180) {
      final out = Uint8List(w * h * bytesPerPix);
      for (int y = 0; y < h; y++) {
        for (int x = 0; x < w; x++) {
          final src = (y * w + x) * bytesPerPix;
          final x2 = w - 1 - x;
          final y2 = h - 1 - y;
          final dst = (y2 * w + x2) * bytesPerPix;
          out[dst] = rgb[src];
          out[dst + 1] = rgb[src + 1];
          out[dst + 2] = rgb[src + 2];
        }
      }
      return out;
    }

    // Xoay 90° hoặc 270°
    final outW = h; // width sau xoay
    final outH = w; // height sau xoay
    final out = Uint8List(outW * outH * bytesPerPix);

    if (normDeg == 90) {
      // 90° clockwise:
      // x' = h - 1 - y
      // y' = x
      for (int y = 0; y < h; y++) {
        for (int x = 0; x < w; x++) {
          final src = (y * w + x) * bytesPerPix;
          final x2 = h - 1 - y;
          final y2 = x;
          final dst = (y2 * outW + x2) * bytesPerPix;
          out[dst] = rgb[src];
          out[dst + 1] = rgb[src + 1];
          out[dst + 2] = rgb[src + 2];
        }
      }
    } else if (normDeg == 270) {
      // 270° clockwise (90° counter-clockwise):
      // x' = y
      // y' = w - 1 - x
      for (int y = 0; y < h; y++) {
        for (int x = 0; x < w; x++) {
          final src = (y * w + x) * bytesPerPix;
          final x2 = y;
          final y2 = w - 1 - x;
          final dst = (y2 * outW + x2) * bytesPerPix;
          out[dst] = rgb[src];
          out[dst + 1] = rgb[src + 1];
          out[dst + 2] = rgb[src + 2];
        }
      }
    } else {
      // Góc lạ => không xoay
      return rgb;
    }

    return out;
  }

  // IOS
  /// Convert iOS bi-planar YUV420 (NV12/FullRange) -> RGB24
  /// - y: plane 0 data
  /// - uv: plane 1 interleaved chroma
  /// - strideY: bytesPerRow của plane Y
  /// - strideUV: bytesPerRow của plane UV
  /// - uvPixelStride: bytesPerPixel của plane UV (thường = 2)
  static Uint8List yuv420BiPlanarToRgb({
    required Uint8List y,
    required Uint8List uv,
    required int width,
    required int height,
    required int strideY,
    required int strideUV,
    required int uvPixelStride,
    BiPlanarOrder order = BiPlanarOrder.cbCr,
  }) {
    // RGB 8-bit
    final out = Uint8List(width * height * 3);

    // @inline
    int clampIndex(int idx, int maxLen) => idx < 0 ? 0 : (idx >= maxLen ? maxLen - 1 : idx);

    int o = 0;
    for (int r = 0; r < height; r++) {
      final yRowOffset = r * strideY;
      final uvRowOffset = (r >> 1) * strideUV;

      for (int c = 0; c < width; c++) {
        final yOff = clampIndex(yRowOffset + c, y.length);
        final Y = y[yOff].toInt();

        final uvCol = (c >> 1) * uvPixelStride;
        final cbIdx = clampIndex(uvRowOffset + uvCol + (order == BiPlanarOrder.cbCr ? 0 : 1), uv.length);
        final crIdx = clampIndex(uvRowOffset + uvCol + (order == BiPlanarOrder.cbCr ? 1 : 0), uv.length);

        final Cb = uv[cbIdx].toInt();
        final Cr = uv[crIdx].toInt();

        final yVal = Y.toDouble();
        final cb = (Cb - 128).toDouble();
        final cr = (Cr - 128).toDouble();

        double rF = yVal + 1.402 * cr;
        double gF = yVal - 0.344136 * cb - 0.714136 * cr;
        double bF = yVal + 1.772 * cb;

        int r8 = rF.isNaN ? 0 : rF.round().clamp(0, 255);
        int g8 = gF.isNaN ? 0 : gF.round().clamp(0, 255);
        int b8 = bF.isNaN ? 0 : bF.round().clamp(0, 255);

        out[o++] = r8;
        out[o++] = g8;
        out[o++] = b8;
      }
    }
    return out;
  }

  static int _clamp255(double v) {
    if (v < 0.0) return 0;
    if (v > 255.0) return 255;
    return v.toInt();
  }

}
