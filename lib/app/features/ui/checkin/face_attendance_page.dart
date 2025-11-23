import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pm_app/app/core/logger/logger.dart';
import 'package:path/path.dart' as p;
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/ui/checkin/bloc/face_scan_cubit.dart';
import 'package:pm_app/app/features/widgets/app_snackbar.dart';
import 'package:pm_app/app/features/widgets/loading_overlay.dart';
import 'widget/camera_cover_preview.dart';
import 'widget/center_face_guide_painter.dart';
import 'widget/face_guide_painter.dart';
import 'widget/mask_with_wave.dart';

class FaceAttendancePage extends StatefulWidget {
  final File? stillImage;
  const FaceAttendancePage({super.key, this.stillImage});

  @override
  State<FaceAttendancePage> createState() => _FaceAttendancePageState();
}

class _FaceAttendancePageState extends State<FaceAttendancePage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  // cubit
  final _cubit = GetIt.I.get<FaceScanCubit>();

  CameraController? _cam;

  bool _scanStarted = false;
  late final AnimationController _scanCtrl;
  late final Animation<double> _scanAnim;

  late final FaceDetector _detector;
  bool _isBusy = false;
  bool _initialized = false;

  // check user trước khung hình ổn định cần N (3) khung
  static const int _stableNeeded = 4;
  int _stableCount = 0;
  bool _isCapturing = false;
  static const double _minCoverage = 0.22;
  static const double _maxCoverage = 0.85;
  static const double _insetPx = 12;

  static const double _yawMax = 12;   // quay trái/phải (Y)
  static const double _pitchMax = 12; // gật (X)
  static const double _rollMax = 12;  // nghiêng (Z)
  bool _canManualCapture = false;

  // hướng trung tâm : dk ban đầu chỉ cần hướng trung tâm
  Rect _guideRect = Rect.zero;


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

    if (widget.stillImage != null) {
      _processStill(widget.stillImage!); // xử lý ảnh tĩnh : mở rộng
    } else {
      _initCamera();
    }

    _scanCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _scanAnim = CurvedAnimation(parent: _scanCtrl, curve: Curves.easeInOut);
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopCamera();
    _cubit.onResetStatus();
    _detector.close();
    _scanCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cam == null || !_cam!.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _cam?.stopImageStream();
      _cam?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    try {
      final cams = await availableCameras();
      final front = cams.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cams.first,
      );
      _cam = CameraController(
        front,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      await _cam!.initialize();
      await _cam!.setZoomLevel(1.0);
      await _cam!.setFlashMode(FlashMode.off);
      await _cam!.lockCaptureOrientation(DeviceOrientation.portraitUp);
      // await _cam!.startImageStream(_processFrame);
      if (mounted) setState(() => _initialized = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể mở camera: $e')),
        );
      }
    }
  }

  Future<void> _stopCamera() async {
    try {
      await _cam?.stopImageStream();
    } catch (_) {}
    try {
      await _cam?.dispose();
    } catch (_) {}
  }

  void _onTapShutter() {
    if (_scanStarted) return;
    setState(() => _scanStarted = true);
    _scanCtrl
      ..duration = const Duration(milliseconds: 2800)
      ..repeat(reverse: false);
    // _scanCtrl.repeat(reverse: true);
  }

  Future<void> _processFrame(CameraImage image) async {
    if (_isBusy || _isCapturing) return;
    _isBusy = true;

    try {
      final bytes = _concatenatePlanes(image.planes);
      final input = InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: _rotationFromSensor(_cam!.description.sensorOrientation),
          format: InputImageFormat.yuv420,
          bytesPerRow: image.planes.first.bytesPerRow,
        ),
      );

      final faces = await _detector.processImage(input);

      bool validNow = false;

      if (faces.length == 1) {
        final f = faces.first;
        validNow = _checkFaceOk(f, image.width, image.height);
      }

      _cubit.updateFaceValid(validNow);

      if (validNow) {
        _stableCount++;
      } else {
        _stableCount = 0;
      }

      _canManualCapture = _stableCount >= _stableNeeded;

      if (_stableCount >= _stableNeeded && !_isCapturing) {
        _isCapturing = true;
        _stableCount = 0;

        await _captureOnceAndReturn();
        return;
      }

      if (mounted) setState(() {});
    } catch (_) {
      _stableCount = 0;
      _canManualCapture = false;
    } finally {
      _isBusy = false;
    }
  }


  Future<void> _captureOnceAndReturn() async {
    try {
      await _cam?.setFlashMode(FlashMode.off);
      await _cam?.stopImageStream();
      await Future.delayed(const Duration(milliseconds: 120));

      final file = await _cam!.takePicture();
      final bytes = await File(file.path).readAsBytes();
      final base64 = base64Encode(bytes);
      logger.d("base64 image ::: $base64");

      final tmpDir = await getTemporaryDirectory();
      final ts = DateTime.now().millisecondsSinceEpoch;
      final outPath = p.join(tmpDir.path, 'face_$ts.jpg');
      final outFile = await File(outPath).writeAsBytes(bytes, flush: true);

      // call api check face
      // Comment test
      // _cubit.onChangeFilePath(outFile.path);
      // _cubit.searchFace(outFile);
      if (!mounted) return;
      // Navigator.pop(context, base64);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể chụp ảnh: $e')),
        );
        try {
          await _cam?.startImageStream(_processFrame);
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
          const SnackBar(content: Text('Không phát hiện khuôn mặt trong ảnh')),
        );
        return;
      }
      final bytes = await file.readAsBytes();
      final b64 = _encodeBase64(bytes);
      // if (mounted) Navigator.pop(context, b64);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi xử lý ảnh: $e')),
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

  Uint8List _concatenatePlanes(List<Plane> planes) {
    final WriteBuffer wb = WriteBuffer();
    for (final Plane plane in planes) {
      wb.putUint8List(plane.bytes);
    }
    return wb.done().buffer.asUint8List();
  }

  /// Chuyển YUV420 -> JPEG (cách nhanh, dùng nền tảng iOS/Android encode qua CameraImage)
  Future<Uint8List> _yuvToJpeg(CameraImage image) async{

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

  bool _checkFaceOk(Face f, int imgW, int imgH) {
    final x = (f.headEulerAngleX ?? 0).abs();
    final y = (f.headEulerAngleY ?? 0).abs();
    final z = (f.headEulerAngleZ ?? 0).abs();
    const pitchMax = 12.0, yawMax = 12.0, rollMax = 12.0;
    final okPose = x <= pitchMax && y <= yawMax && z <= rollMax;

    final screen = MediaQuery.of(context).size;
    final guide = computeGuideRect(screen);
    final guideInner = guide.deflate(_insetPx);

    final bbScreen = _mapImageRectToScreen(f.boundingBox, imgW, imgH, screen);

    final inside =
        guideInner.contains(bbScreen.topLeft) && guideInner.contains(bbScreen.bottomRight);

    final aFace = bbScreen.width * bbScreen.height;
    final aGuide = guideInner.width * guideInner.height;
    final coverage = (aGuide > 0) ? (aFace / aGuide) : 0;

    final okCoverage = coverage >= _minCoverage && coverage <= _maxCoverage;

    return okPose && inside && okCoverage;
  }


  @override
  Widget build(BuildContext context) {
    final camReady = _initialized && _cam != null && _cam!.value.isInitialized;
    return BlocListener<FaceScanCubit,FaceScanState>(
        bloc: _cubit,
        listenWhen: (prev,cur) => prev.scanStatus != cur.scanStatus ||
          prev.faceResult != cur.faceResult,
        listener: (context, state) async{
          if(state.scanStatus == LoadStatus.LOADING){
            // LoadingOverlay.show(context,message: "Đang thực hiện xác thực khuôn mặt");
            LoadingOverlay.show(context);
          }else if(state.scanStatus == LoadStatus.SUCCESS){
            LoadingOverlay.hide(context);
            AppSnackBar.showInfo(title: "Thành Công",message:  "Xác thực khuôn mặt thành công!!");
            await Future.delayed(const Duration(seconds: 2));
            if (mounted) Navigator.pop(context, state.fileImgPath ?? "");

          }else if(state.scanStatus == LoadStatus.FAILURE){
            LoadingOverlay.hide(context);
            AppSnackBar.showError(title: "Thất bại",
                message: state.scanMsg ?? "Không tìm thấy thông tin người dùng!");

          }else{
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
              const Center(child: CircularProgressIndicator(color: Colors.white)),

            // if (camReady && !_scanStarted)
            //   IgnorePointer(
            //     child: CustomPaint(
            //       painter: CenteredFaceGuidePainter(),
            //       size: Size.infinite,
            //     ),
            //   ),

            if (camReady && _scanStarted)
              FaceMaskWithWave(
                anim: _scanAnim,
                countdown: const Duration(seconds: 5),
                onCountdownDone: () async {
                  try {
                    if (_cam != null && _cam!.value.isInitialized) {
                      await _cam!.startImageStream(_processFrame);
                    }
                  } catch (_) {}
                },
              ),

            SafeArea(
              child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.35),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              left: 16, right: 16,
              bottom: 125 + MediaQuery.of(context).padding.bottom,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: !_scanStarted ? Text(
                    'Nhấp vào nút này để bắt đầu và đảm bảo máy ảnh của bạn đã được thiết lập và sẵn sàng',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w400),
                  ) : const SizedBox.shrink(),
                ),
              ),
            ),

            if (camReady && !_scanStarted)
              Positioned(
                left: 0, right: 0,
                bottom: 40,
                child: Center(
                  child: GestureDetector(
                    onTap: _onTapShutter,
                    child: Container(
                      width: 76, height: 76,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                        border: Border.all(
                          color: Colors.white,
                          width: 2
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 10, spreadRadius: 1, offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // BlocBuilder<FaceScanCubit, FaceScanState>(
            //   buildWhen: (prev, cur) => prev.isFaceValid != cur.isFaceValid,
            //   builder: (context, state) {
            //     if (state.isFaceValid || !_scanStarted) return const SizedBox.shrink();
            //     return Positioned(
            //       left: 0, right: 0,
            //       bottom: 110 + MediaQuery.of(context).padding.bottom,
            //       child: Center(
            //         child: Container(
            //           padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            //           decoration: BoxDecoration(
            //             color: Colors.black.withOpacity(0.45),
            //             borderRadius: BorderRadius.circular(8),
            //           ),
            //           child: const Text(
            //             'Đưa khuôn mặt vào gần khung hình',
            //             style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
            //           ),
            //         ),
            //       ),
            //     );
            //   },
            // ),
          ],
        ),
      ),
    );

  }
}
