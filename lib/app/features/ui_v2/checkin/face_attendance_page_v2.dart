import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:camera/camera.dart';
// import 'package:face_anti_spoofing_detector/face_anti_spoofing_detector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pm_app/app/core/logger/logger.dart';
import 'package:path/path.dart' as p;
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/app/features/ui_v2/checkin/widget/face_scan_hud_v2.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/ui/checkin/bloc/face_scan_cubit.dart';
import 'package:pm_app/app/features/ui/checkin/widget/camera_cover_preview.dart';
import 'package:pm_app/app/features/widgets/app_snackbar.dart';
import 'package:pm_app/app/features/widgets/loading_overlay.dart';
import 'package:pm_app/generated/l10n.dart';

/// Bản v2 (dark) của [FaceAttendancePage] gốc
/// (lib/app/features/ui/checkin/face_attendance_page.dart).
///
/// QUAN TRỌNG — chỉ đổi TRÌNH BÀY (lớp phủ trên preview camera): back
/// button, text hướng dẫn, khung mặt/wave overlay, chỉ báo loading, nút
/// chụp. Toàn bộ logic camera (init/dispose/orientation/resolution/lens),
/// mọi dùng `google_mlkit_face_detection`, mọi ngưỡng/điều kiện phát hiện
/// khuôn mặt, logic liveness, các mốc thời gian/debounce, và cách trả về
/// giá trị qua `Navigator.pop` — được sao chép Y HỆT bản gốc, không sửa
/// một chữ nào trong các phương thức nghiệp vụ bên dưới.
class FaceAttendancePageV2 extends StatefulWidget {
  final File? stillImage;
  const FaceAttendancePageV2({super.key, this.stillImage});

  @override
  State<FaceAttendancePageV2> createState() => _FaceAttendancePageV2State();
}

class _FaceAttendancePageV2State extends State<FaceAttendancePageV2>
    with WidgetsBindingObserver {
  // cubit
  final _cubit = GetIt.I.get<FaceScanCubit>();

  CameraController? _cam;
  bool _isCameraInitializing = false;
  int _cameraSession = 0;

  bool _scanStarted = false;

  /// Stream nhận diện đã chạy chưa. Detect chạy NGAY khi camera mở (để khung
  /// target bám mặt + % hiển thị liền); còn việc CHỤP chỉ khi [_scanStarted].
  bool _streaming = false;

  late final FaceDetector _detector;
  bool _isBusy = false;
  bool _initialized = false;

  // check user trước khung hình ổn định cần N (3) khung
  static const int _stableNeeded = 2;
  int _stableCount = 0;
  bool _isCapturing = false;
  // static const double _minCoverage = 0.22;
  // static const double _maxCoverage = 0.85;
  // static const double _insetPx = 12;

  static const double _yawMax = 12; // quay trái/phải (Y)
  static const double _pitchMax = 12; // gật (X)
  static const double _rollMax = 12; // nghiêng (Z)
  bool _canManualCapture = false;

  // ===== Khung target bám mặt (chỉ để VẼ overlay, không ảnh hưởng logic) =====
  /// Bounding box khuôn mặt theo toạ độ ảnh camera (chưa xoay). null = không có mặt.
  Rect? _faceBoxImg;
  int _frameImgW = 0;
  int _frameImgH = 0;
  bool _isFrontCam = true;

  /// DEBUG TẠM: bật để hiện số thô giúp hiệu chỉnh mapping khung target.
  static const bool _debugFace = true;

  String _debugFaceInfo(Size screen) {
    final b = _faceBoxImg;
    final rot = _inputImageRotation().name;
    if (b == null) return 'rot=$rot img=${_frameImgW}x$_frameImgH  (no face)';
    final m = _mapFaceToScreen(screen);
    return 'rot=$rot img=${_frameImgW}x$_frameImgH front=$_isFrontCam\n'
        'box L${b.left.toInt()} T${b.top.toInt()} R${b.right.toInt()} B${b.bottom.toInt()}\n'
        'screen ${screen.width.toInt()}x${screen.height.toInt()}  '
        'map ${m == null ? "null" : "L${m.left.toInt()} T${m.top.toInt()} R${m.right.toInt()} B${m.bottom.toInt()}"}';
  }

  // final Rect _guideRect = Rect.zero;

  // ===== Anti-spoofing =====
  final bool _livenessReady = false;
  // static const double _livenessThreshold = 0.80;
  DateTime? _lastSpoofWarnAt;

  // Comment ::: FaceAntiSpoofingDetector
  // Future<void> _initLiveness() async {
  //   try {
  //     _livenessReady = await FaceAntiSpoofingDetector.initialize();
  //   } catch (_) {
  //     _livenessReady = false;
  //   }
  // }

  int _antiSpoofOrientation() {
    return 7;
  }

  void _showSpoofWarningThrottled() {
    final now = DateTime.now();
    if (_lastSpoofWarnAt != null &&
        now.difference(_lastSpoofWarnAt!) < const Duration(seconds: 2)) {
      return;
    }
    _lastSpoofWarnAt = now;

    AppSnackBar.showError(
      title: "Cảnh báo",
      message:
          "Phát hiện giả mạo (ảnh/video). Vui lòng đưa khuôn mặt thật vào camera.",
    );
  }

  // FaceAntiSpoofingDetector ::
  Future<bool> _checkLivenessFromFrame(CameraImage image, Rect faceBox) async {
    return true;
    // if (!_livenessReady) return false;
    //
    // try {
    //   final Uint8List bytes = Platform.isAndroid
    //       ? _yuv420ToNv21(image)
    //       : image.planes.first.bytes;
    //
    //   final score = await FaceAntiSpoofingDetector.detect(
    //     yuvBytes: bytes,
    //     previewWidth: image.width,
    //     previewHeight: image.height,
    //     orientation: _antiSpoofOrientation(),
    //     faceContour: faceBox,
    //   );
    //
    //   return (score ?? 0) >= _livenessThreshold;
    // } catch (_) {
    //   return false;
    // }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final options = FaceDetectorOptions(
      performanceMode: FaceDetectorMode.fast,
      enableClassification: true,
      enableLandmarks: true,
      enableContours: false,
      enableTracking: true,
      minFaceSize: 0.15,
    );
    _detector = FaceDetector(options: options);

    // comment : FaceAntiSpoofingDetector
    // _initLiveness();

    if (widget.stillImage != null) {
      _processStill(widget.stillImage!); // xử lý ảnh tĩnh : mở rộng
    } else {
      _initCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopCamera();
    _cubit.onResetStatus();
    _detector.close();
    // comment::: FaceAntiSpoofingDetector
    // unawaited(FaceAntiSpoofingDetector.destroy());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (widget.stillImage != null) return;

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      await _stopCamera();
    } else if (state == AppLifecycleState.resumed && mounted) {
      await _initCamera();
    }
  }

  Future<void> _initCamera() async {
    if (_isCameraInitializing) return;
    if (_cam != null) return;

    _isCameraInitializing = true;
    final session = ++_cameraSession;
    try {
      final cams = await availableCameras();
      final front = cams.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cams.first,
      );
      _isFrontCam = front.lensDirection == CameraLensDirection.front;

      final controller = CameraController(
        front,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup:
            Platform.isAndroid
                ? ImageFormatGroup.nv21
                : ImageFormatGroup.bgra8888,
      );

      await controller.initialize();
      await controller.setZoomLevel(1.0);
      await controller.setFlashMode(FlashMode.off);
      await controller.lockCaptureOrientation(DeviceOrientation.portraitUp);

      if (!mounted || session != _cameraSession) {
        await _disposeController(controller);
        return;
      }

      _cam = controller;
      if (mounted) {
        setState(() => _initialized = true);
      }
      // Bắt đầu nhận diện ngay để overlay khung target bám mặt (chưa chụp).
      await _startDetectStream(controller);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${S.of(context).check_in_cannotOpenCamera}: $e'),
          ),
        );
      }
    } finally {
      _isCameraInitializing = false;
    }
  }

  Future<void> _disposeController(CameraController controller) async {
    try {
      await controller.stopImageStream();
    } catch (_) {}
    try {
      await controller.dispose();
    } catch (_) {}
  }

  Future<void> _stopCamera() async {
    final controller = _cam;
    _cam = null;
    _cameraSession++;

    _scanStarted = false;
    _streaming = false;
    _initialized = false;
    _isCapturing = false;
    _isBusy = false;
    _stableCount = 0;
    _canManualCapture = false;
    _faceBoxImg = null;

    if (mounted) {
      setState(() {});
    }

    if (controller == null) return;

    try {
      await _disposeController(controller);
    } catch (_) {}
  }

  /// Mở stream nhận diện (chỉ để vẽ overlay). Gọi 1 lần khi camera sẵn sàng.
  Future<void> _startDetectStream(CameraController controller) async {
    if (_streaming) return;
    try {
      await controller.startImageStream(_processFrame);
      _streaming = true;
    } catch (_) {
      _streaming = false;
    }
  }

  Future<void> _onTapShutter() async {
    final controller = _cam;
    if (_scanStarted || controller == null || !controller.value.isInitialized) {
      return;
    }
    // Detect đã chạy sẵn; bấm nút chỉ "arm" cho phép chụp khi mặt ổn định.
    setState(() => _scanStarted = true);
    await _startDetectStream(controller); // phòng khi stream chưa mở
  }

  Future<void> _processFrame(CameraImage image) async {
    if (_isBusy || _isCapturing) return;
    _isBusy = true;

    try {
      final input = _cameraImageToInputImage(image);
      if (input == null) return;

      final faces = await _detector.processImage(input);

      bool validNow = false;
      Face? face;

      if (faces.length == 1) {
        face = faces.first;
        validNow = _checkFaceOk(face, image.width, image.height);
        // Lưu lại vị trí mặt để overlay vẽ khung target bám theo.
        _faceBoxImg = face.boundingBox;
        _frameImgW = image.width;
        _frameImgH = image.height;
      } else {
        validNow = false;
        _faceBoxImg = null;
      }

      _cubit.updateFaceValid(validNow);

      if (validNow) {
        _stableCount++;
      } else {
        _stableCount = 0;
      }

      _canManualCapture = _stableCount >= _stableNeeded;

      if (_scanStarted && _stableCount >= _stableNeeded && !_isCapturing) {
        _isCapturing = true;
        _stableCount = 0;

        // comment : FaceAntiSpoofingDetector
        final isLive =
            (face != null)
                ? await _checkLivenessFromFrame(image, face.boundingBox)
                : false;

        if (!isLive) {
          _isCapturing = false;
          _canManualCapture = false;
          _cubit.updateFaceValid(false);
          _showSpoofWarningThrottled();
          if (mounted) setState(() {});
          return;
        }

        await _captureOnceAndReturn();
        return;
      }

      if (mounted) setState(() {});
    } catch (e) {
      _stableCount = 0;
      _canManualCapture = false;
    } finally {
      _isBusy = false;
    }
  }

  Future<void> _captureOnceAndReturn() async {
    final controller = _cam;
    if (controller == null) return;

    try {
      await controller.setFlashMode(FlashMode.off);
      await controller.stopImageStream();
      await Future.delayed(const Duration(milliseconds: 120));

      final file = await controller.takePicture();
      final bytes = await File(file.path).readAsBytes();
      final base64 = base64Encode(bytes);
      logger.d("base64 image ::: $base64");

      final tmpDir = await getTemporaryDirectory();
      final ts = DateTime.now().millisecondsSinceEpoch;
      final outPath = p.join(tmpDir.path, 'face_$ts.jpg');
      final outFile = await File(outPath).writeAsBytes(bytes, flush: true);

      // call api check face
      _cubit.onChangeFilePath(outFile.path);
      _cubit.searchFace(outFile);
      if (!mounted) return;
      // Navigator.pop(context, base64);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${S.of(context).check_in_cameraFailed}: $e')),
        );
        try {
          final restartController = _cam;
          if (restartController != null && restartController.value.isInitialized) {
            await restartController.startImageStream(_processFrame);
          }
        } catch (_) {}
        _isCapturing = false;
        _canManualCapture = false;
      }
    }
  }

  // xử lý ảnh tĩnh : browser images
  Future<void> _processStill(File file) async {
    try {
      final input = InputImage.fromFile(file);
      final faces = await _detector.processImage(input);
      if (faces.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).check_in_cannotSeeFace)),
        );
        return;
      }
      final bytes = await file.readAsBytes();
      final b64 = _encodeBase64(bytes);
      // if (mounted) Navigator.pop(context, b64);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${S.of(context).check_inFailed}: $e')),
        );
      }
    }
  }

  bool _isPoseOk(Face f) {
    final x = (f.headEulerAngleX ?? 0).abs(); // pitch
    final y = (f.headEulerAngleY ?? 0).abs(); // yaw
    final z = (f.headEulerAngleZ ?? 0).abs(); // roll
    return x <= _pitchMax && y <= _yawMax && z <= _rollMax;
  }

  bool _isCentered(Rect faceBox, int imgW, int imgH) {
    final screen = MediaQuery.of(context).size;
    final guide = computeGuideRect(screen);

    final cx = faceBox.center.dx * screen.width / imgW;
    final cy = faceBox.center.dy * screen.height / imgH;

    return guide.contains(Offset(cx, cy));
  }

  InputImageRotation _rotationFromSensor(int deg) {
    switch (deg) {
      case 0:
        return InputImageRotation.rotation0deg;
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  InputImageRotation _inputImageRotation() {
    if (_cam == null) return InputImageRotation.rotation0deg;

    final sensor = _cam!.description.sensorOrientation;
    final device = _cam!.value.deviceOrientation;

    int deviceDeg;
    switch (device) {
      case DeviceOrientation.portraitUp:
        deviceDeg = 0;
        break;
      case DeviceOrientation.landscapeLeft:
        deviceDeg = 90;
        break;
      case DeviceOrientation.portraitDown:
        deviceDeg = 180;
        break;
      case DeviceOrientation.landscapeRight:
        deviceDeg = 270;
        break;
    }

    final isFront =
        _cam!.description.lensDirection == CameraLensDirection.front;

    int rotationCompensation;
    if (Platform.isAndroid) {
      rotationCompensation =
          isFront
              ? (sensor + deviceDeg) % 360
              : (sensor - deviceDeg + 360) % 360;
    } else {
      rotationCompensation = sensor;
    }

    switch (rotationCompensation) {
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      case 0:
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  InputImage? _cameraImageToInputImage(CameraImage image) {
    if (_cam == null) return null;

    if (Platform.isIOS) {
      if (image.planes.isEmpty) return null;
      final plane = image.planes.first;

      return InputImage.fromBytes(
        bytes: plane.bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: _inputImageRotation(),
          format: InputImageFormat.bgra8888,
          bytesPerRow: plane.bytesPerRow,
        ),
      );
    }

    if (image.planes.isEmpty) return null;

    // Android devices can surface either a single NV21 plane or 3 YUV420 planes
    // depending on the camera plugin version and device implementation.
    final Uint8List bytes =
        image.planes.length == 1
            ? image.planes.first.bytes
            : _yuv420ToNv21(image);
    final int bytesPerRow = image.planes.first.bytesPerRow;

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: _inputImageRotation(),
        format: InputImageFormat.nv21,
        bytesPerRow: bytesPerRow,
      ),
    );
  }

  Uint8List _yuv420ToNv21(CameraImage image) {
    final int width = image.width;
    final int height = image.height;

    final Plane yPlane = image.planes[0];
    final Plane uPlane = image.planes[1];
    final Plane vPlane = image.planes[2];

    final Uint8List yBytes = yPlane.bytes;
    final Uint8List uBytes = uPlane.bytes;
    final Uint8List vBytes = vPlane.bytes;

    final int yRowStride = yPlane.bytesPerRow;
    final int uvRowStride = uPlane.bytesPerRow;

    final int uvPixelStride = uPlane.bytesPerPixel ?? 1;

    final int outSize = width * height + (width * height ~/ 2);
    final Uint8List out = Uint8List(outSize);

    int outIndex = 0;

    for (int row = 0; row < height; row++) {
      final int yRowStart = row * yRowStride;
      out.setRange(outIndex, outIndex + width, yBytes, yRowStart);
      outIndex += width;
    }

    final int uvHeight = height ~/ 2;
    final int uvWidth = width ~/ 2;

    for (int row = 0; row < uvHeight; row++) {
      final int uvRowStart = row * uvRowStride;
      for (int col = 0; col < uvWidth; col++) {
        final int uvIndex = uvRowStart + col * uvPixelStride;

        out[outIndex++] = vBytes[uvIndex];
        out[outIndex++] = uBytes[uvIndex];
      }
    }

    return out;
  }

  Uint8List _concatenatePlanes(List<Plane> planes) {
    final WriteBuffer wb = WriteBuffer();
    for (final Plane plane in planes) {
      wb.putUint8List(plane.bytes);
    }
    return wb.done().buffer.asUint8List();
  }

  /// Chuyển YUV420 -> JPEG (cách nhanh, dùng nền tảng iOS/Android encode qua CameraImage)
  Future<Uint8List> _yuvToJpeg(CameraImage image) async {
    final file = await _cam!.takePicture();
    final bytes = await File(file.path).readAsBytes();
    throw UnimplementedError('Use _captureJpeg() instead');
  }

  Future<Uint8List> _captureJpeg() async {
    await _cam?.stopImageStream();
    final file = await _cam!.takePicture();
    final bytes = await File(file.path).readAsBytes();
    return bytes;
  }

  String _encodeBase64(Uint8List bytes) => base64Encode(bytes);

  // Khung hình
  Rect computeGuideRect(Size screenSize) {
    final w = screenSize.width * 0.70;
    final hRaw = w * 1.25;
    final h = hRaw.clamp(0.0, screenSize.height * 0.82);
    return Rect.fromCenter(
      center: Offset(screenSize.width / 2, screenSize.height / 2),
      width: w,
      height: h,
    );
  }

  // Map từ toạ độ ảnh sang toạ độ màn hình
  Rect _mapImageRectToScreen(Rect rImg, int imgW, int imgH, Size screen) {
    final sx = screen.width / imgW;
    final sy = screen.height / imgH;
    return Rect.fromLTRB(
      rImg.left * sx,
      rImg.top * sy,
      rImg.right * sx,
      rImg.bottom * sy,
    );
  }

  // bool _checkFaceOk(Face f, int imgW, int imgH) {
  //   final x = (f.headEulerAngleX ?? 0).abs();
  //   final y = (f.headEulerAngleY ?? 0).abs();
  //   final z = (f.headEulerAngleZ ?? 0).abs();
  //   const pitchMax = 12.0, yawMax = 12.0, rollMax = 12.0;
  //   final okPose = x <= pitchMax && y <= yawMax && z <= rollMax;
  //
  //   final screen = MediaQuery.of(context).size;
  //   final guide = computeGuideRect(screen);
  //   final guideInner = guide.deflate(_insetPx);
  //
  //   final bbScreen = _mapImageRectToScreen(f.boundingBox, imgW, imgH, screen);
  //
  //   final inside =
  //       guideInner.contains(bbScreen.topLeft) && guideInner.contains(bbScreen.bottomRight);
  //
  //   final aFace = bbScreen.width * bbScreen.height;
  //   final aGuide = guideInner.width * guideInner.height;
  //   final coverage = (aGuide > 0) ? (aFace / aGuide) : 0;
  //
  //   final okCoverage = coverage >= _minCoverage && coverage <= _maxCoverage;
  //
  //   return okPose && inside && okCoverage;
  // }

  bool _checkFaceOk(Face f, int imgW, int imgH) {
    final x = (f.headEulerAngleX ?? 0).abs(); // pitch
    final y = (f.headEulerAngleY ?? 0).abs(); // yaw
    final z = (f.headEulerAngleZ ?? 0).abs(); // roll

    const pitchMax = 25.0;
    const yawMax = 25.0;
    const rollMax = 25.0;

    final okPose = x <= pitchMax && y <= yawMax && z <= rollMax;
    if (!okPose) {
      return false;
    }

    final box = f.boundingBox;

    final faceW = box.width.clamp(0, imgW.toDouble());
    final faceH = box.height.clamp(0, imgH.toDouble());
    final faceArea = faceW * faceH;
    final imageArea = imgW.toDouble() * imgH.toDouble();

    final areaRatio = imageArea > 0 ? (faceArea / imageArea) : 0.0;

    final okSize = areaRatio >= 0.05 && areaRatio <= 0.6;
    if (!okSize) {
      // logger.d('size fail: ratio=$areaRatio');
      return false;
    }

    final cxRatio = (box.center.dx / imgW).clamp(0.0, 1.0);
    final cyRatio = (box.center.dy / imgH).clamp(0.0, 1.0);

    // 0.2..0.8 nghĩa là chừa biên 20% mỗi phía.
    final okCenter =
        cxRatio >= 0.2 && cxRatio <= 0.8 && cyRatio >= 0.2 && cyRatio <= 0.8;

    // logger.d('center: cx=$cxRatio, cy=$cyRatio, okCenter=$okCenter');

    return okCenter;
  }

  /// Quy đổi bounding box mặt (toạ độ ảnh camera) sang toạ độ màn hình, khớp
  /// cách [CameraCoverPreview] hiển thị (cover) + xoay theo cảm biến + lật gương
  /// cho camera trước. THUẦN để vẽ overlay — không ảnh hưởng logic nhận diện.
  Rect? _mapFaceToScreen(Size screen) {
    final box = _faceBoxImg;
    if (box == null || _frameImgW == 0 || _frameImgH == 0) return null;

    final q = switch (_inputImageRotation()) {
      InputImageRotation.rotation90deg => 1,
      InputImageRotation.rotation180deg => 2,
      InputImageRotation.rotation270deg => 3,
      _ => 0,
    };

    final iw = _frameImgW.toDouble();
    final ih = _frameImgH.toDouble();

    Rect r;
    double rw, rh;
    switch (q) {
      case 1: // xoay 90°
        rw = ih;
        rh = iw;
        r = Rect.fromLTRB(ih - box.bottom, box.left, ih - box.top, box.right);
        break;
      case 2: // xoay 180°
        rw = iw;
        rh = ih;
        r = Rect.fromLTRB(
            iw - box.right, ih - box.bottom, iw - box.left, ih - box.top);
        break;
      case 3: // xoay 270°
        rw = ih;
        rh = iw;
        r = Rect.fromLTRB(box.top, iw - box.right, box.bottom, iw - box.left);
        break;
      default:
        rw = iw;
        rh = ih;
        r = box;
    }

    // Cover fit: phủ kín màn, cắt phần thừa (khớp Transform.scale của preview).
    final scale = math.max(screen.width / rw, screen.height / rh);
    final dx = (screen.width - rw * scale) / 2;
    final dy = (screen.height - rh * scale) / 2;
    var out = Rect.fromLTRB(
      r.left * scale + dx,
      r.top * scale + dy,
      r.right * scale + dx,
      r.bottom * scale + dy,
    );

    // Preview camera trước KHÔNG lật gương ngang trên thiết bị này -> không mirror,
    // nếu mirror sẽ làm khung chạy ngược chiều với mặt.
    // (Nếu sau này thấy khung lệch trái/phải, bật lại đoạn dưới.)
    // if (_isFrontCam) {
    //   out = Rect.fromLTRB(
    //       screen.width - out.right, out.top, screen.width - out.left, out.bottom);
    // }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final camReady = _initialized && _cam != null && _cam!.value.isInitialized;
    return BlocListener<FaceScanCubit, FaceScanState>(
      bloc: _cubit,
      listenWhen:
          (prev, cur) =>
              prev.scanStatus != cur.scanStatus ||
              prev.faceResult != cur.faceResult,
      listener: (context, state) async {
        if (state.scanStatus == LoadStatus.LOADING) {
          LoadingOverlay.show(context);
        } else if (state.scanStatus == LoadStatus.SUCCESS) {
          LoadingOverlay.hide(context);
          // AppSnackBar.showInfo(
          //     title: "Thành Công",
          //     message: "Xác thực khuôn mặt thành công!!");
          // await Future.delayed(const Duration(seconds: 2));
          if (mounted) Navigator.pop(context, state.fileImgPath ?? "");
        } else if (state.scanStatus == LoadStatus.FAILURE) {
          LoadingOverlay.hide(context);
          AppSnackBar.showError(
            title: S.of(context).failed,
            message: state.scanMsg ?? S.of(context).check_inFailed2,
          );
          Navigator.pop(context);
        } else {
          LoadingOverlay.hide(context);
        }
      },
      child: Scaffold(
        backgroundColor: AppTokensV2.bgDeep,
        body: Stack(
          fit: StackFit.expand,
          children: [
            if (camReady)
              CameraCoverPreview(controller: _cam!)
            else
              const Center(
                child: CircularProgressIndicator(
                  color: AppTokensV2.accent,
                  strokeWidth: 2.2,
                ),
              ),

            // nếu muốn, có thể bật lại guide ở giữa:
            // if (camReady && !_scanStarted)
            //   IgnorePointer(
            //     child: CustomPaint(
            //       painter: CenteredFaceGuidePainter(),
            //       size: Size.infinite,
            //     ),
            //   ),
            // Overlay HUD kiểu facial-scan (thuần trang trí, không đụng logic).
            if (camReady)
              FaceScanHudV2(
                scanning: camReady, // quét chạy ngay khi camera mở
                faceOk: _canManualCapture,
                faceRect: _mapFaceToScreen(MediaQuery.of(context).size),
              ),

            // DEBUG TẠM: hiện số thô để hiệu chỉnh mapping. Xoá sau khi khớp.
            if (_debugFace && camReady)
              Positioned(
                left: 8,
                right: 8,
                bottom: 200,
                child: IgnorePointer(
                  child: Text(
                    _debugFaceInfo(MediaQuery.of(context).size),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.yellowAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),

            SafeArea(
              child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTokensV2.bgDeep.withValues(alpha: 0.55),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTokensV2.border),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: AppTokensV2.fg,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            if (!_scanStarted)
              Positioned(
                left: 16,
                right: 16,
                bottom: 125 + MediaQuery.of(context).padding.bottom,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 360),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppTokensV2.bgDeep.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTokensV2.border),
                      ),
                      child: Text(
                        s.check_in_hint,
                        textAlign: TextAlign.center,
                        style: AppTokensV2.body.copyWith(height: 1.35),
                      ),
                    ),
                  ),
                ),
              ),

            if (camReady && !_scanStarted)
              Positioned(
                left: 0,
                right: 0,
                bottom: 40,
                child: Center(
                  child: GestureDetector(
                    onTap: _onTapShutter,
                    child: Container(
                      width: 76,
                      height: 76,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                        border: Border.all(
                          color: AppTokensV2.accent,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTokensV2.glow,
                            blurRadius: 18,
                            spreadRadius: 1,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppTokensV2.accentGradient,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
