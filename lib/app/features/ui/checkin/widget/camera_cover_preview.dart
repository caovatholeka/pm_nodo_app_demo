import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraCoverPreview extends StatelessWidget {
  final CameraController controller;
  const CameraCoverPreview({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final ar = controller.value.aspectRatio;
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final deviceRatio = size.width / size.height;
        final previewSize = controller.value.previewSize!;
        final previewRatio = previewSize.height / previewSize.width;

        return Transform.scale(
          scale: previewRatio / deviceRatio,
          child: Center(
            child: AspectRatio(
              aspectRatio: previewRatio,
              child: CameraPreview(controller),
            ),
          ),
        );
      },
    );
    // return LayoutBuilder(
    //   builder: (ctx, cons) {
    //     return FittedBox(
    //       fit: BoxFit.fill,
    //       child: SizedBox(
    //         width: cons.maxWidth,
    //         height: cons.maxWidth / ar,
    //         child: CameraPreview(controller),
    //       ),
    //     );
    //   },
    // );
  }
}