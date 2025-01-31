import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:real/controller/chat_controller.dart';

class SupportChatView extends StatelessWidget {
  const SupportChatView({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support Chat'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: GetBuilder<ChatController>(
        init: ChatController(),
        builder: (controller) {
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  reverse: true, // newest messages at the bottom
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) {
                    // Since list is in chronological order, reverse-index it.
                    final message = controller.messages[controller.messages.length - 1 - index];
                    bool isUser = message['sender'] == 'user';
                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isUser ? Colors.blueAccent : Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          message['text'] ?? '',
                          style: TextStyle(
                            color: isUser ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller.textController,
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      child: const Text("Send"),
                      onPressed: () => controller.sendMessage(),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
