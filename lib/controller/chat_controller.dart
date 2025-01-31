import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatController extends GetxController {
  // This list stores messages as maps with keys: 'sender' and 'text'
  RxList<Map<String, String>> messages = <Map<String, String>>[].obs;
  final TextEditingController textController = TextEditingController();
  
  bool isApiCallInProgress = false;
  final String apiKey = "YOUR_API_KEY";
  final String chatApiEndpoint = "https://api.studio.nebius.ai/v1/chat/completions";

  void sendMessage() async {
    String text = textController.text.trim();
    if (text.isEmpty || isApiCallInProgress) return;
    
    // Add the user's message to the chat list and clear input.
    messages.add({'sender': 'user', 'text': text});
    textController.clear();
    update();
    
    isApiCallInProgress = true;

    try {
      final response = await http.post(
        Uri.parse(chatApiEndpoint),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiKey",
        },
        body: jsonEncode({
          "model": "meta-llama/Llama-3.3-70B-Instruct",
          "max_tokens": 8192,
          "temperature": 0.6,
          "top_p": 0.95,
          "messages": [
            {
              "role": "system",
              "content": """You are a supportive and empathetic mental health companion. Your role is to:
1. Listen carefully and respond with understanding
2. Provide emotional support and validation
3. Help users process their thoughts and feelings
4. Suggest healthy coping strategies when appropriate
5. Encourage professional help-seeking when needed

Keep responses warm, supportive, and focused on the user's well-being. Avoid clinical language unless necessary."""
            },
            {
              "role": "user",
              "content": text
            }
          ]
        }),
      );
      
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data["choices"] != null && data["choices"].isNotEmpty) {
          String botResponse = data["choices"][0]["message"]["content"] ?? "No response";
          messages.add({'sender': 'bot', 'text': botResponse});
        } else {
          messages.add({'sender': 'bot', 'text': "No response received"});
        }
      } else {
        messages.add({
          'sender': 'bot',
          'text': "API error: ${response.statusCode}"
        });
      }
    } catch (e) {
      messages.add({
        'sender': 'bot',
        'text': "Network error: $e"
      });
    } finally {
      isApiCallInProgress = false;
      update();
    }
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }
}
