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
            return const Center(child: CircularProgressIndicator());
          }
          
          return Stack(
            fit: StackFit.expand,
            children: [
              controller.cameraController.value.isInitialized
                  ? _buildCameraPreview(context, controller.cameraController)
                  : const Center(child: Text("Loading Preview...")),
              Positioned(
                top: 50,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.black54,
                  child: Obx(
                    () => Text(
                      controller.detectionResult.value,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 50,
                left: 10,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                  onPressed: () => Get.back(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildCameraPreview(BuildContext context, CameraController cameraController) {
    if (!cameraController.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;
    final previewRatio = cameraController.value.aspectRatio;
    
    // Calculate rotation based on sensor orientation
    int quarterTurns = 2; // Rotate 180 degrees to fix upside down preview
    if (cameraController.description.sensorOrientation == 90 ||
        cameraController.description.sensorOrientation == 270) {
      quarterTurns = 1; // Rotate 90 degrees for side-oriented sensors
    }

    return ClipRect(
      child: Transform.scale(
        scale: 1 / deviceRatio,
        child: Center(
          child: AspectRatio(
            aspectRatio: previewRatio,
            child: RotatedBox(
              quarterTurns: quarterTurns,
              child: CameraPreview(cameraController),
            ),
          ),
        ),
      ),
    );
  }
}
