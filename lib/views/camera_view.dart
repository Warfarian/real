import 'package:flutter/material.dart';
import 'package:real/controller/scan_controller.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';

class CameraView extends StatelessWidget {
  const CameraView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<ScanController>(
        init: ScanController(),
        builder: (controller) {
          if (!controller.isCameraInitialized.value) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          return controller.cameraController.value.isInitialized
              ? Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: Transform.rotate(
                    angle: 90 * 3.1415927 / 180,
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: controller.cameraController.value.previewSize?.height ?? 1,
                        height: controller.cameraController.value.previewSize?.width ?? 1,
                        child: CameraPreview(controller.cameraController),
                      ),
                    ),
                  ),
                )
              : const Center(
                  child: Text("Loading Preview..."),
                );
        },
      ),
    );
  }
}