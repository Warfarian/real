import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';
import 'dart:math' as math;

class ScanController extends GetxController {
  late Interpreter _interpreter;
  late CameraController cameraController;
  late List<CameraDescription> cameras;
  
  // Standard input size for many image classification models
  final int inputSize = 224;  // Common size for many models
  
  var cameraCount = 0;
  var isCameraInitialized = false.obs;
  var isModelInitialized = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    initTFLite().then((_) => initCamera());
  }
  
  @override
  void dispose() {
    cameraController.dispose();
    if (isModelInitialized.value) {
      _interpreter.close();
    }
    super.dispose();
  }
  
  Future<void> initCamera() async {
    if (await Permission.camera.request().isGranted) {
      cameras = await availableCameras();
      
      cameraController = CameraController(
        cameras[0],
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      
      await cameraController.initialize();
      
      cameraController.startImageStream((CameraImage image) {
        cameraCount++;
        if (cameraCount % 10 == 0) {
          cameraCount = 0;
          if (isModelInitialized.value) {
            runInference(image);
          }
        }
        update();
      });
      
      isCameraInitialized.value = true;
      update();
    } else {
      print("Camera permission denied");
    }
  }
  
  Future<void> initTFLite() async {
    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/model.tflite',
        options: InterpreterOptions()..threads = 4,
      );
      
      print("Model loaded successfully");
      print("Input tensor shape: ${_interpreter.getInputTensor(0).shape}");
      print("Input tensor type: ${_interpreter.getInputTensor(0).type}");
      print("Output tensor shape: ${_interpreter.getOutputTensor(0).shape}");
      print("Output tensor type: ${_interpreter.getOutputTensor(0).type}");
      
      isModelInitialized.value = true;
    } catch (e) {
      print("Error while loading the model: $e");
      isModelInitialized.value = false;
    }
  }
  
  Future<void> runInference(CameraImage cameraImage) async {
    if (!isModelInitialized.value) return;
    
    try {
      img.Image? convertedImage = convertYUV420ToImage(cameraImage);
      if (convertedImage == null) return;
      
      // Resize to standard input size
      img.Image resizedImage = img.copyResize(
        convertedImage,
        width: inputSize,
        height: inputSize,
      );
      
      // Create 4D input tensor array [1, height, width, 3]
      var input = [List.generate(
        inputSize,
        (y) => List.generate(
          inputSize,
          (x) {
            var pixel = resizedImage.getPixel(x, y);
            // Keep values as integers in range 0-255
            return [
              img.getRed(pixel),
              img.getGreen(pixel),
              img.getBlue(pixel),
            ];
          },
        ),
      )];
      
      // Prepare output tensor
      var outputShape = _interpreter.getOutputTensor(0).shape;
      var outputSize = outputShape[1]; // Number of classes
      var output = List.filled(1, List.filled(outputSize, 0));
      
      // Run inference
      _interpreter.run(input, output);
      
      // Print results
      print("Inference completed");
      print("Output size: ${output[0].length}");
      var predictions = List<MapEntry<int, int>>.from(
        output[0].asMap().entries.toList()
      )..sort((a, b) => b.value.compareTo(a.value));
      
      // Print top 5 predictions
      for (var i = 0; i < math.min(5, predictions.length); i++) {
        print("Label ${predictions[i].key}: ${predictions[i].value}");
      }
      
    } catch (e, stackTrace) {
      print("Error during inference: $e");
      print("Stack trace: $stackTrace");
    }
  }
  
  img.Image? convertYUV420ToImage(CameraImage image) {
    try {
      final int width = image.width;
      final int height = image.height;
      
      final img.Image imgImage = img.Image(width, height);
      
      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          final int index = y * width + x;
          final int Y = image.planes[0].bytes[index];
          
          final int uvRow = y >> 1;
          final int uvCol = x >> 1;
          final int uvIndex = uvRow * image.planes[1].bytesPerRow + uvCol;
          final int U = image.planes[1].bytes[uvIndex];
          final int V = image.planes[2].bytes[uvIndex];
          
          final int r = (Y + 1.402 * (V - 128)).round().clamp(0, 255);
          final int g = (Y - 0.344136 * (U - 128) - 0.714136 * (V - 128)).round().clamp(0, 255);
          final int b = (Y + 1.772 * (U - 128)).round().clamp(0, 255);
          
          imgImage.setPixel(x, y, img.getColor(r, g, b));
        }
      }
      return imgImage;
    } catch (e) {
      print("Error converting YUV420 to image: $e");
      return null;
    }
  }
}
