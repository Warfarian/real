import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/emergency_alert_controller.dart';

class EmergencyAlertView extends StatelessWidget {
  const EmergencyAlertView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Emergency Alert"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: GetBuilder<EmergencyAlertController>(
        init: EmergencyAlertController(),
        builder: (controller) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section for Emergency Contacts
                  Text("Emergency Contacts",
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  // Display added contacts as chips with a delete option.
                  Wrap(
                    spacing: 8,
                    children: controller.emergencyContacts.map((contact) {
                      return Chip(
                        label: Text(contact),
                        onDeleted: () =>
                            controller.removeEmergencyContact(contact),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller.contactController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: "Add Contact (+1234567890)",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => controller.addEmergencyContact(
                        controller.contactController.text.trim()),
                    child: const Text("Add Contact"),
                  ),
                  const SizedBox(height: 24),
                  // Section for composing an emergency message
                  Text("Emergency Message",
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller.messageController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: "Message",
                      hintText: "Enter emergency message",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Send Alert button with extra caution styling (red color)
                  Center(
                    child: ElevatedButton.icon(
                      icon: controller.isSendingAlert
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.warning),
                      label: const Text("Send Emergency Alert"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                      ),
                      onPressed: controller.isSendingAlert
                          ? null
                          : () async {
                              await controller.sendEmergencyAlert();
                            },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
