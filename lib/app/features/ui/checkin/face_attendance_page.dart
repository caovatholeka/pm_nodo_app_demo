import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:face_anti_spoofing_detector/face_anti_spoofing_detector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pm_app/app/core/utils/face_image_utils.dart';
import 'package:pm_app/app/core/utils/perf_log.dart';
import 'package:path/path.dart' as p;
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/ui/checkin/bloc/face_scan_cubit.dart';
import 'package:pm_app/app/features/widgets/app_snackbar.dart';
import 'package:pm_app/app/features/widgets/loading_overlay.dart';
import 'package:pm_app/generated/l10n.dart';
import 'widget/camera_cover_preview.dart';
import 'widget/mask_with_wave.dart';

/// Màn xác thực khuôn mặt + chấm công. Thành công thì pop trả về [CheckInOutEntity].
class FaceAttendancePage extends StatefulWidget {
  final File? stillImage;
  // Điểm chấm công + toạ độ dùng để gọi API chấm công ngay sau khi khớp khuôn mặt
  final int locationId;
  final double latitude;
  final double longitude;

  const FaceAttendancePage({
    super.key,
    this.stillImage,
    required this.locationId,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<FaceAttendancePage> createState() => _FaceAttendancePageState();
}

class _FaceAttendancePageState extends State<FaceAttendancePage>
    with WidgetsBindingObserver {
  // cubit
  final _cubit = GetIt.I.get<FaceScanCubit>();

  CameraController? _cam;
  bool _isCameraInitializing = false;
  bool _needsReInit = false;
  int _cameraSession = 0;
  // Lỗi mở camera (vd. bị từ chối quyền) → hiện thông báo + nút thay cho vòng quay
  String? _cameraError;
  bool _cameraPermissionDenied = false;
  bool _openedAppSettings = false;

  bool _scanStarted = false;
  // Lỗi xác thực/chấm công → dừng quét, chờ người dùng bấm "Thử lại" (không tự gửi liên tục)
  bool _awaitingRetry = false;

  // Camera trước được dò 1 lần cho cả phiên app (availableCameras() chậm mỗi lần mở màn)
  static CameraDescription? _frontCamera;

  late final FaceDetector _detector;
  bool _isBusy = false;
  bool _initialized = false;

  // Số khung hình hợp lệ liên tiếp trước khi chụp (2 dễ chụp ảnh nhoè khi đang di chuyển)
  static const int _stableNeeded = 3;
  int _stableCount = 0;
  bool _isCapturing = false;

  // Đo hiệu năng (chỉ in khi build kèm PERF_LOG hoặc bản debug)
  final Stopwatch _openWatch = Stopwatch()..start();
  final Stopwatch _scanWatch = Stopwatch();
  int _frameCount = 0;
  int _mlKitTotalMs = 0;
  int? _firstValidMs;

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

    // Chỉ cần khung mặt + góc nghiêng đầu (có sẵn ở mọi chế độ): tắt landmarks /
    // classification / tracking không dùng tới để mỗi khung hình xử lý nhanh hơn.
    final options = FaceDetectorOptions(
      performanceMode: FaceDetectorMode.fast,
      enableClassification: false,
      enableLandmarks: false,
      enableContours: false,
      enableTracking: false,
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
    // Không setState trong dispose (assert ở bản debug làm bỏ qua bước giải phóng camera)
    _stopCamera(updateUi: false);
    _cubit.onResetStatus();
    _detector.close();
    // comment::: FaceAntiSpoofingDetector
    // unawaited(FaceAntiSpoofingDetector.destroy());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (widget.stillImage != null) return;

    if (state == AppLifecycleState.inactive) {
      // Hộp thoại xin quyền camera của hệ thống (lần đầu mở) cũng làm app "inactive".
      // Nếu đang khởi tạo mà huỷ ở đây thì lúc người dùng bấm "Cho phép" camera bị bỏ
      // → quay tròn mãi. Chỉ đóng camera khi nó đã mở thật.
      if (_cam != null) await _stopCamera();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      await _stopCamera();
    } else if (state == AppLifecycleState.resumed && mounted) {
      // Vừa từ chối quyền thì không tự mở lại (sẽ hỏi quyền lặp lại); chỉ thử lại khi
      // người dùng quay về từ Cài đặt hoặc bấm "Thử lại".
      if (_cameraError != null && !_openedAppSettings) return;
      _openedAppSettings = false;
      await _initCamera();
    }
  }

  Future<void> _initCamera() async {
    if (!mounted) return;
    if (_cam != null && _cam!.value.isInitialized) return;
    if (_isCameraInitializing) {
      // Đang có lần khởi tạo dở (vd. vừa quay lại từ hộp thoại quyền): chạy lại sau khi
      // lần đó xong, nếu nó bị huỷ giữa chừng.
      _needsReInit = true;
      return;
    }

    _isCameraInitializing = true;
    _needsReInit = false;
    if (_cameraError != null) {
      setState(() {
        _cameraError = null;
        _cameraPermissionDenied = false;
      });
    }

    final session = ++_cameraSession;
    CameraController? controller;
    try {
      _frontCamera ??= await _findFrontCamera();

      controller = CameraController(
        _frontCamera!,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup:
            Platform.isAndroid
                ? ImageFormatGroup.nv21
                : ImageFormatGroup.bgra8888,
      );

      // Plugin camera tự xin quyền ở bước này (lần đầu sẽ hiện hộp thoại hệ thống)
      await controller.initialize();
      await controller.setZoomLevel(1.0);
      await controller.setFlashMode(FlashMode.off);
      await controller.lockCaptureOrientation(DeviceOrientation.portraitUp);

      if (!mounted || session != _cameraSession) {
        await _disposeController(controller);
        return;
      }

      _cam = controller;
      perfLog('camera ready ${_openWatch.elapsedMilliseconds} ms after open');
      if (mounted) {
        setState(() => _initialized = true);
        // Tự bắt đầu quét khi camera sẵn sàng (trước đây phải bấm nút chụp)
        _startScan();
      }
    } catch (e) {
      // Khởi tạo hỏng giữa chừng: giải phóng controller để lần mở sau không bị chiếm camera
      if (controller != null && !identical(controller, _cam)) {
        await _disposeController(controller);
      }
      // Lỗi của một lần khởi tạo đã bị huỷ (app ra nền...) thì bỏ qua, lần sau sẽ mở lại
      if (mounted && session == _cameraSession) {
        final denied = e is CameraException && _isPermissionError(e.code);
        setState(() {
          _cameraPermissionDenied = denied;
          _cameraError = denied
              ? 'Ứng dụng chưa được cấp quyền Camera. Vui lòng cho phép trong Cài đặt để chấm công.'
              : '${S.of(context).check_in_cannotOpenCamera}: ${e is CameraException ? (e.description ?? e.code) : e}';
        });
      }
    } finally {
      _isCameraInitializing = false;
      final retry = _needsReInit;
      _needsReInit = false;
      if (retry &&
          mounted &&
          _cam == null &&
          _cameraError == null &&
          WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _initCamera());
      }
    }
  }

  static bool _isPermissionError(String code) =>
      code == 'CameraAccessDenied' ||
      code == 'CameraAccessDeniedWithoutPrompt' ||
      code == 'CameraAccessRestricted';

  Future<void> _disposeController(CameraController controller) async {
    try {
      await controller.stopImageStream();
    } catch (_) {}
    try {
      await controller.dispose();
    } catch (_) {}
  }

  Future<CameraDescription> _findFrontCamera() async {
    final cams = await availableCameras();
    return cams.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cams.first,
    );
  }

  Future<void> _stopCamera({bool updateUi = true}) async {
    final controller = _cam;
    _cam = null;
    // Huỷ lần khởi tạo đang chạy (nếu có): nó sẽ tự giải phóng controller khi xong.
    // Không reset _isCameraInitializing ở đây, tránh 2 lần khởi tạo chạy song song.
    _cameraSession++;

    _scanStarted = false;
    _initialized = false;
    _isCapturing = false;
    _isBusy = false;
    _stableCount = 0;

    if (updateUi && mounted) {
      setState(() {});
    }

    if (controller == null) return;

    try {
      await _disposeController(controller);
    } catch (_) {}
  }

  /// Sau khi xác thực/chấm công lỗi: giữ camera đang mở, dừng quét và chờ bấm "Thử lại"
  /// (tự quét lại ngay sẽ gửi request liên tục khi lỗi không tự hết: sai mặt, ngoài phạm vi...).
  void _resetForRetry() {
    _cubit.onResetStatus();
    if (!mounted) return;
    setState(() {
      _scanStarted = false;
      _awaitingRetry = true;
      _isCapturing = false;
      _stableCount = 0;
    });
  }

  /// Bắt đầu quét khuôn mặt: tự gọi khi camera sẵn sàng, hoặc khi bấm "Thử lại".
  Future<void> _startScan() async {
    final controller = _cam;
    if (_scanStarted || controller == null || !controller.value.isInitialized) {
      return;
    }
    setState(() {
      _scanStarted = true;
      _awaitingRetry = false;
    });
    _scanWatch
      ..reset()
      ..start();
    _frameCount = 0;
    _mlKitTotalMs = 0;
    _firstValidMs = null;

    try {
      await controller.startImageStream(_processFrame);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${S.of(context).check_in_faceScanFailed}: $e')),
      );
      setState(() {
        _scanStarted = false;
        _awaitingRetry = true;
      });
    }
  }

  Future<void> _processFrame(CameraImage image) async {
    if (_isBusy || _isCapturing) return;
    _isBusy = true;

    try {
      final input = _cameraImageToInputImage(image);
      if (input == null) return;

      final frameWatch = Stopwatch()..start();
      final faces = await _detector.processImage(input);
      _frameCount++;
      _mlKitTotalMs += frameWatch.elapsedMilliseconds;

      bool validNow = false;
      Face? face;

      if (faces.length == 1) {
        face = faces.first;
        // Khung mặt ML Kit trả về theo ảnh ĐÃ xoay; frame camera trước xoay 90/270 độ nên
        // phải đổi chiều rộng/cao (trước đây so nhầm trục → mặt ở giữa vẫn lúc nhận lúc không).
        final rotation = input.metadata?.rotation;
        final rotated = rotation == InputImageRotation.rotation90deg ||
            rotation == InputImageRotation.rotation270deg;
        validNow = rotated
            ? _checkFaceOk(face, image.height, image.width)
            : _checkFaceOk(face, image.width, image.height);
      } else {
        validNow = false;
      }

      _cubit.updateFaceValid(validNow);

      if (validNow) {
        _stableCount++;
        _firstValidMs ??= _scanWatch.elapsedMilliseconds;
      } else {
        _stableCount = 0;
      }

      if (_stableCount >= _stableNeeded && !_isCapturing) {
        perfLog(
          'scan -> capture ${_scanWatch.elapsedMilliseconds} ms '
          '(first valid face at ${_firstValidMs} ms, $_frameCount frames, '
          'ML Kit avg ${_frameCount == 0 ? 0 : _mlKitTotalMs ~/ _frameCount} ms/frame)',
        );
        _isCapturing = true;
        _stableCount = 0;

        // comment : FaceAntiSpoofingDetector
        final isLive =
            (face != null)
                ? await _checkLivenessFromFrame(image, face.boundingBox)
                : false;

        if (!isLive) {
          _isCapturing = false;
          _cubit.updateFaceValid(false);
          _showSpoofWarningThrottled();
          return;
        }

        await _captureOnceAndReturn();
        return;
      }
      // Không setState mỗi khung hình: giao diện không phụ thuộc biến đếm, trước đây dựng
      // lại cả màn (preview + mask) 10–20 lần/giây làm camera giật.
    } catch (e) {
      _stableCount = 0;
    } finally {
      _isBusy = false;
    }
  }

  Future<void> _captureOnceAndReturn() async {
    final controller = _cam;
    if (controller == null) return;

    try {
      // Flash đã tắt từ lúc khởi tạo camera, không cần đặt lại mỗi lần chụp
      await controller.stopImageStream();
      await Future.delayed(const Duration(milliseconds: 120));

      final shotWatch = Stopwatch()..start();
      final file = await controller.takePicture();
      perfLog('takePicture ${shotWatch.elapsedMilliseconds} ms');

      // Ảnh gốc ~1440x1920 ~700 KB → nén còn ~50 KB trước khi upload (2 lần: nhận diện
      // + chấm công). Trước đây còn base64 cả ảnh chỉ để ghi log.
      final tmpDir = await getTemporaryDirectory();
      final ts = DateTime.now().millisecondsSinceEpoch;
      final outPath = p.join(tmpDir.path, 'face_$ts.jpg');
      final outFile = await compressFaceImage(file.path, outPath);
      await deleteQuietly(file.path);

      // Xác thực khuôn mặt rồi chấm công luôn tại màn này
      _cubit.onChangeFilePath(outFile.path);
      _cubit.verifyAndCheckIn(
        outFile,
        locationId: widget.locationId,
        latitude: widget.latitude,
        longitude: widget.longitude,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${S.of(context).check_in_cameraFailed}: $e')),
        );
        // Chụp lỗi: chờ bấm "Thử lại" như các lỗi khác
        _resetForRetry();
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

  String _encodeBase64(Uint8List bytes) => base64Encode(bytes);

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
          // Đã chấm công xong → trả kết quả cho màn chấm công
          if (mounted) Navigator.pop(context, state.checkInResult);
        } else if (state.scanStatus == LoadStatus.FAILURE) {
          LoadingOverlay.hide(context);
          AppSnackBar.showError(
            title: S.of(context).failed,
            message: state.scanMsg ?? S.of(context).check_inFailed2,
          );
          // Ở lại màn camera để chụp lại ngay (trước đây đóng màn → phải mở lại,
          // chờ camera khởi động lại từ đầu)
          _resetForRetry();
        } else {
          LoadingOverlay.hide(context);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            if (camReady)
              CameraCoverPreview(controller: _cam!)
            else
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_cameraError == null) ...[
                        const CircularProgressIndicator(color: Colors.white),
                        const SizedBox(height: 16),
                        const Text(
                          'Đang khởi động camera...',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ] else ...[
                        const Icon(Icons.no_photography_outlined,
                            color: Colors.white70, size: 40),
                        const SizedBox(height: 16),
                        Text(
                          _cameraError!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        if (_cameraPermissionDenied) ...[
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: () {
                              _openedAppSettings = true;
                              openAppSettings();
                            },
                            icon: const Icon(Icons.settings_outlined,
                                color: Colors.white70, size: 18),
                            label: const Text(
                              'Mở Cài đặt',
                              style: TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ),
                        ],
                      ],
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: () => _initCamera(),
                        icon: const Icon(Icons.refresh, color: Colors.white70, size: 18),
                        label: const Text(
                          'Thử lại',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
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
            // Chỉ khung (vẽ lại khi trạng thái mặt hợp lệ đổi, không theo từng khung hình)
            if (camReady && _scanStarted)
              BlocBuilder<FaceScanCubit, FaceScanState>(
                bloc: _cubit,
                buildWhen: (prev, cur) => prev.isFaceValid != cur.isFaceValid,
                builder: (context, state) =>
                    FaceMaskWithWave(faceValid: state.isFaceValid),
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
                        color: Colors.black.withValues(alpha: 0.35),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),

            // Lỗi xác thực/chấm công: dừng quét, chờ bấm "Thử lại" (camera vẫn mở sẵn)
            if (camReady && _awaitingRetry)
              Positioned(
                left: 0,
                right: 0,
                bottom: 40 + MediaQuery.of(context).padding.bottom,
                child: Center(
                  child: ElevatedButton.icon(
                    onPressed: _startScan,
                    icon: const Icon(Icons.refresh),
                    label: Text(s.check_in_retry),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 14,
                      ),
                      shape: const StadiumBorder(),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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
