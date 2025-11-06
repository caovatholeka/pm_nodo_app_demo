// import 'dart:async';
// import 'dart:typed_data';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'package:flutter/services.dart';
// import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

// class FaceScanPage extends StatefulWidget {
//   const FaceScanPage({super.key});

//   @override
//   State<FaceScanPage> createState() => _FaceScanPageState();
// }

// class _FaceScanPageState extends State<FaceScanPage>
//     with TickerProviderStateMixin {
//   CameraController? _cameraController;
//   late FaceDetector _faceDetector;
//   bool _isDetecting = false;
//   bool _faceDetected = false;
//   bool _initialized = false;

//   late AnimationController _cornerAnimController;
//   late AnimationController _scanLineController;
//   late Animation<double> _cornerAnimation;
//   late Animation<double> _scanLineAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _setFullScreenMode();
//     _initializeCamera();

//     _faceDetector = FaceDetector(
//       options: FaceDetectorOptions(
//         performanceMode: FaceDetectorMode.fast,
//         enableContours: false,
//         enableClassification: false,
//       ),
//     );

//     _cornerAnimController =
//         AnimationController(vsync: this, duration: const Duration(seconds: 2))
//           ..repeat(reverse: true);
//     _cornerAnimation =
//         Tween<double>(begin: 2.5, end: 6).animate(_cornerAnimController);

//     _scanLineController =
//         AnimationController(vsync: this, duration: const Duration(seconds: 3))
//           ..repeat();
//     _scanLineAnimation =
//         Tween<double>(begin: 0, end: 1).animate(_scanLineController);
//   }

//   void _setFullScreenMode() {
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.portraitUp,
//     ]);
//   }

//   Future<void> _initializeCamera() async {
//     final cameras = await availableCameras();
//     final frontCamera = cameras.firstWhere(
//       (camera) => camera.lensDirection == CameraLensDirection.front,
//     );

//     _cameraController = CameraController(
//       frontCamera,
//       ResolutionPreset.high,
//       enableAudio: false,
//     );

//     await _cameraController!.initialize();
//     await _cameraController!.startImageStream(_processCameraImage);
//     setState(() => _initialized = true);
//   }

//   Future<void> _processCameraImage(CameraImage image) async {
//     if (_isDetecting || _faceDetected) return;
//     _isDetecting = true;

//     try {
//       final WriteBuffer allBytes = WriteBuffer();
//       for (final Plane plane in image.planes) {
//         allBytes.putUint8List(plane.bytes);
//       }
//       final bytes = allBytes.done().buffer.asUint8List();

//       final camera = _cameraController!.description;
//       final rotation =
//           InputImageRotationValue.fromRawValue(camera.sensorOrientation) ??
//               InputImageRotation.rotation0deg;

//       final format = InputImageFormatValue.fromRawValue(image.format.raw) ??
//           InputImageFormat.nv21;

//       final metadata = InputImageMetadata(
//         size: Size(image.width.toDouble(), image.height.toDouble()),
//         rotation: rotation,
//         format: format,
//         bytesPerRow: image.planes.first.bytesPerRow,
//       );

//       final inputImage = InputImage.fromBytes(bytes: bytes, metadata: metadata);
//       final faces = await _faceDetector.processImage(inputImage);

//       if (faces.isNotEmpty && !_faceDetected) {
//         setState(() => _faceDetected = true);
//         await Future.delayed(const Duration(milliseconds: 800));
//         _showSuccess();
//       }
//     } catch (e) {
//       debugPrint("❌ Face detect error: $e");
//     } finally {
//       _isDetecting = false;
//     }
//   }

//   void _showSuccess() async {
//     await _cameraController?.stopImageStream();
//     await _cameraController?.dispose();
//     _scanLineController.stop();

//     if (!mounted) return;
//     showDialog(
//       barrierDismissible: false,
//       context: context,
//       builder: (context) => WillPopScope(
//         onWillPop: () async => false,
//         child: AlertDialog(
//           title: const Text("✅ Thành công"),
//           content: const Text("Nhận diện khuôn mặt thành công!"),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 Navigator.pop(context, true);
//               },
//               child: const Text("OK"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _cornerAnimController.dispose();
//     _scanLineController.dispose();
//     _cameraController?.dispose();
//     _faceDetector.close();
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!_initialized) {
//       return const Scaffold(
//         backgroundColor: Colors.black,
//         body: Center(
//           child: CircularProgressIndicator(color: Colors.white),
//         ),
//       );
//     }

//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         alignment: Alignment.center,
//         children: [
//           LayoutBuilder(
//   builder: (context, constraints) {
//     final size = constraints.biggest;
//     final deviceRatio = size.width / size.height;
//     final previewSize = _cameraController!.value.previewSize!;
//     final previewRatio = previewSize.height / previewSize.width;

//     return Transform.scale(
//       scale: previewRatio / deviceRatio,
//       child: Center(
//         child: AspectRatio(
//           aspectRatio: previewRatio,
//           child: CameraPreview(_cameraController!),
//         ),
//       ),
//     );
//   },
// ),

//           AnimatedBuilder(
//             animation: Listenable.merge([_cornerAnimation, _scanLineAnimation]),
//             builder: (context, child) {
//               return CustomPaint(
//                 painter: FaceFramePainter(
//                   strokeWidth: _cornerAnimation.value,
//                   scanProgress: _scanLineAnimation.value,
//                 ),
//                 size: const Size(300, 400),
//               );
//             },
//           ),

//           if (!_faceDetected)
//             Positioned(
//               bottom: 100,
//               child: Column(
//                 children: const [
//                   CircularProgressIndicator(
//                     color: Colors.white,
//                     strokeWidth: 3,
//                   ),
//                   SizedBox(height: 12),
//                   Text(
//                     "Đang nhận diện khuôn mặt...",
//                     style: TextStyle(color: Colors.white70, fontSize: 16),
//                   ),
//                 ],
//               ),
//             ),
//           if (_faceDetected)
//             Container(
//               color: Colors.black.withOpacity(0.5),
//               child: const Center(
//                 child: Icon(Icons.check_circle,
//                     color: Colors.greenAccent, size: 100),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

// class FaceFramePainter extends CustomPainter {
//   final double strokeWidth;
//   final double scanProgress;

//   FaceFramePainter({required this.strokeWidth, required this.scanProgress});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.blueAccent
//       ..strokeWidth = strokeWidth
//       ..style = PaintingStyle.stroke
//       ..strokeCap = StrokeCap.round;

//     final rect = Rect.fromCenter(
//       center: Offset(size.width / 2, size.height / 2),
//       width: size.width,
//       height: size.height,
//     );

//     const cornerLength = 30.0;
//     canvas.drawLine(rect.topLeft, rect.topLeft + const Offset(cornerLength, 0), paint);
//     canvas.drawLine(rect.topLeft, rect.topLeft + const Offset(0, cornerLength), paint);

//     canvas.drawLine(rect.topRight, rect.topRight - const Offset(cornerLength, 0), paint);
//     canvas.drawLine(rect.topRight, rect.topRight + const Offset(0, cornerLength), paint);

//     canvas.drawLine(rect.bottomLeft, rect.bottomLeft + const Offset(cornerLength, 0), paint);
//     canvas.drawLine(rect.bottomLeft, rect.bottomLeft - const Offset(0, cornerLength), paint);

//     canvas.drawLine(rect.bottomRight, rect.bottomRight - const Offset(cornerLength, 0), paint);
//     canvas.drawLine(rect.bottomRight, rect.bottomRight - const Offset(0, cornerLength), paint);

//     final scanY = rect.top + rect.height * scanProgress;
//     final scanPaint = Paint()
//       ..shader = LinearGradient(
//         colors: [
//           Colors.blueAccent.withOpacity(0.1),
//           Colors.cyanAccent,
//           Colors.blueAccent.withOpacity(0.1)
//         ],
//         begin: Alignment.centerLeft,
//         end: Alignment.centerRight,
//       ).createShader(Rect.fromLTWH(rect.left, scanY - 1, rect.width, 2))
//       ..strokeWidth = 3;

//     canvas.drawLine(
//       Offset(rect.left + 5, scanY),
//       Offset(rect.right - 5, scanY),
//       scanPaint,
//     );
//   }

//   @override
//   bool shouldRepaint(FaceFramePainter oldDelegate) =>
//       oldDelegate.strokeWidth != strokeWidth ||
//       oldDelegate.scanProgress != scanProgress;
// }
