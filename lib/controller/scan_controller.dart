import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class ScanController extends GetxController {
  late CameraController cameraController;
  late List<CameraDescription> cameras;
  
  var isCameraInitialized = false.obs;
  var detectionResult = "".obs;
  
  bool isApiCallInProgress = false;
  DateTime lastApiCallTime = DateTime.now();
  final Duration minApiCallInterval = Duration(seconds: 3);
  
  // Add your API key here
  final String apiKey = "your_api_key";
  final String apiEndpoint = "https://api.studio.nebius.ai/v1/chat/completions";
  
  @override
  void onInit() {
    super.onInit();
    initCamera();
  }
  
  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
  
  Future<void> initCamera() async {
    if (await Permission.camera.request().isGranted) {
      cameras = await availableCameras();
      
      cameraController = CameraController(
        cameras[0],
        ResolutionPreset.max,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      
      await cameraController.initialize();
      await cameraController.lockCaptureOrientation(DeviceOrientation.portraitUp);
      
      // Set optimal capture settings
      await Future.wait([
        cameraController.getMaxZoomLevel().then((value) {
          debugPrint('Max zoom level: $value');
        }).catchError((e) {
          debugPrint('Error getting max zoom level: $e');
        }),
        cameraController.setFocusMode(FocusMode.auto),
        cameraController.setExposureMode(ExposureMode.auto),
      ]);
      
      // Set the description of the camera
      final description = cameras[0];
      debugPrint('Camera info - Lens direction: ${description.lensDirection}, Sensor orientation: ${description.sensorOrientation}');
      
      cameraController.startImageStream((CameraImage image) {
        if (!isApiCallInProgress &&
            DateTime.now().difference(lastApiCallTime) > minApiCallInterval) {
          lastApiCallTime = DateTime.now();
          processFrame(image);
        }
      });
      
      isCameraInitialized.value = true;
      update();
    } else {
      debugPrint("Camera permission denied");
    }
  }
  
  Future<void> processFrame(CameraImage cameraImage) async {
    isApiCallInProgress = true;
    try {
      img.Image? convertedImage = convertYUV420ToImage(cameraImage);
      if (convertedImage == null) return;
      
      List<int> jpegBytes = img.encodeJpg(convertedImage);
      String base64Image = base64Encode(jpegBytes);
      
      await sendToQwenAPI(base64Image);
      
    } catch (e) {
      debugPrint("Error processing frame: $e");
      detectionResult.value = "Error: $e";
    } finally {
      isApiCallInProgress = false;
    }
  }
  
  Future<void> sendToQwenAPI(String base64Image) async {
    try {
      final response = await http.post(
        Uri.parse(apiEndpoint),
        headers: {
          "Content-Type": "application/json",
          "Accept": "*/*",
          "Authorization": "Bearer $apiKey",
        },
        body: jsonEncode({
          "model": "Qwen/Qwen2-VL-7B-Instruct",
          "max_tokens": 8192,
          "temperature": 0.6,
          "top_p": 0.95,
          "messages": [
            {
              "role": "system",
              "content": """You are an expert in mental health and visual perception analysis. Your role is to help users distinguish between real perceptions and potential hallucinations. For each image:

Describe the image briefly, and state if there is a person or not.
Keep responses concise, factual, and empathetic. Avoid technical jargon. Focus on helping the user understand what is and isn't real in their environment."""
            },
            {
              "role": "user",
              "content": [
                {
                  "type": "text",
                  "text": "Analyze this image and tell me if you see any people and if you might be hallucinating."
                },
                {
                  "type": "image_url",
                  "image_url": {
                    "url": "data:image/jpeg;base64,$base64Image"
                  }
                }
              ]
            }
          ]
        }),
      );
      
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data["choices"] != null && data["choices"].isNotEmpty) {
          String assistantResponse = data["choices"][0]["message"]["content"] ?? "No response";
          detectionResult.value = assistantResponse;
        } else {
          detectionResult.value = "No detection results";
        }
      } else {
        debugPrint("API call failed with status: ${response.statusCode}");
        detectionResult.value = "API Error: ${response.statusCode}";
      }
    } catch (e) {
      debugPrint("Error calling Qwen API: $e");
      detectionResult.value = "Network Error";
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
      debugPrint("Error converting YUV420 to image: $e");
      return null;
    }
  }
}
