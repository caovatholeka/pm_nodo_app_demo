import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';

class AntiSpoofEngine {
  late final Interpreter _det;
  late final Interpreter _cls;
  bool _loaded = false;

  Future<void> load() async {
    final options = InterpreterOptions()..threads = 2;

    _det = await Interpreter.fromAsset(
      'assets/models/ultraface_320.tflite',
      options: options,
    );

    final detInputShape = _det.getInputTensor(0).shape;
    if (detInputShape.length != 4 ||
        detInputShape[1] != 240 ||
        detInputShape[2] != 320 ||
        detInputShape[3] != 3) {
      _det.resizeInputTensor(0, [1, 240, 320, 3]);
    }
    _det.allocateTensors();

    _cls = await Interpreter.fromAsset(
      'assets/models/antispoof_rgb_80.tflite',
      options: options,
    );

    final clsInputShape = _cls.getInputTensor(0).shape;
    if (clsInputShape.length != 4 ||
        clsInputShape[1] != 80 ||
        clsInputShape[2] != 80 ||
        clsInputShape[3] != 3) {
      _cls.resizeInputTensor(0, [1, 80, 80, 3]);
    }
    _cls.allocateTensors();

    _loaded = true;
  }

  bool get isLoaded => _loaded;

  /// inputRGB320x240: [H,W,3] = [240,320,3], u8 0..255
  /// return: bbox normalized (x1,y1,x2,y2) or null
  /// inputRGB320x240: [H,W,3] = [240,320,3], u8 0..255
  /// return: bbox normalized (x1,y1,x2,y2) or null
  RectN? detectFace(Uint8List rgb320x240) {
    if (!_loaded) return null;

    if (rgb320x240.length != 240 * 320 * 3) {
      return null;
    }

    try {
      // Chuẩn hoá [-1,1]
      final input = Float32List(240 * 320 * 3);
      for (int i = 0; i < rgb320x240.length; i++) {
        input[i] = (rgb320x240[i] - 127.5) / 127.5;
      }

      //  - output 0: [4] = bbox
      //  - output 1: [1] = score
      final outputB = List<double>.filled(4, 0.0);
      final outputS = List<double>.filled(1, 0.0);

      _det.runForMultipleInputs(
        [input],
        {0: outputB, 1: outputS},
      );

      if (outputS[0] < 0.5) return null;

      double x1 = outputB[0].clamp(0.0, 1.0);
      double y1 = outputB[1].clamp(0.0, 1.0);
      double x2 = outputB[2].clamp(0.0, 1.0);
      double y2 = outputB[3].clamp(0.0, 1.0);
      if (x2 <= x1 || y2 <= y1) return null;

      return RectN(x1, y1, x2, y2);
    } catch (e) {
      // debugPrint('[AntiSpoof] detectFace error: $e');
      return null;
    }
  }


  /// faceRgb80: [80,80,3] u8 0..255 -> live probability 0..1
  double liveProb(Uint8List faceRgb80) {
    if (!_loaded) return 0.0;
    if (faceRgb80.length != 80 * 80 * 3) return 0.0;

    try {
      final input = Float32List(80 * 80 * 3);
      for (int i = 0; i < faceRgb80.length; i++) {
        input[i] = (faceRgb80[i] - 127.5) / 127.5;
      }
      final out = List<double>.filled(1, 0.0);

      _cls.run(input, out);

      return out[0].clamp(0.0, 1.0);
    } catch (e) {
      return 0.0;
    }
  }
}

class RectN {
  final double x1, y1, x2, y2; // normalized
  RectN(this.x1, this.y1, this.x2, this.y2);
  double get w => (x2 - x1);
  double get h => (y2 - y1);
  double get cx => (x1 + x2) / 2;
  double get cy => (y1 + y2) / 2;
}
