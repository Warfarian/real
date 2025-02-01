import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EmergencyAlertController extends GetxController {
  // List of emergency contacts (phone numbers in E.164 format)
  RxList<String> emergencyContacts = <String>[].obs;

  // Controller for adding new contacts
  TextEditingController contactController = TextEditingController();

  // Controller for emergency message (default alert message)
  TextEditingController messageController = TextEditingController(
    text: "Emergency! Please send help immediately.",
  );

  bool isSendingAlert = false;  // Local development server endpoint
  final String backendEndpoint = "http://lcoalhost:3000/alerts";
  
  // API token for authorization
  final String apiToken = 'add your alert token here'; 

  @override
  void onInit() {
    super.onInit();
    loadEmergencyContacts();
  }

  // Load emergency contacts from persistent storage
  Future<void> loadEmergencyContacts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? contacts = prefs.getStringList('emergencyContacts');
    if (contacts != null) {
      emergencyContacts.assignAll(contacts);
    }
  }

  // Save contacts to persistent storage
  Future<void> saveEmergencyContacts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('emergencyContacts', emergencyContacts);
  }

  // Add a new emergency contact after validation.
  void addEmergencyContact(String number) {
    // Validate using a simple E.164 regex (accepts optional '+' at the start)
    RegExp regExp = RegExp(r'^\+?[1-9]\d{1,14}$');
    if (!regExp.hasMatch(number)) {
      Get.snackbar(
        "Invalid Number",
        "Please enter a valid phone number in E.164 format (e.g. +1234567890).",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (emergencyContacts.contains(number)) {
      Get.snackbar(
        "Duplicate",
        "This contact is already added.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    emergencyContacts.add(number);
    saveEmergencyContacts();
    contactController.clear();
    update();
  }

  // Remove an emergency contact.
  void removeEmergencyContact(String number) {
    emergencyContacts.remove(number);
    saveEmergencyContacts();
    update();
  }

  // Method to send an emergency alert
  Future<void> sendEmergencyAlert() async {
    if (emergencyContacts.isEmpty) {
      Get.snackbar(
        "No Contacts",
        "Please add at least one emergency contact before sending an alert.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Confirm with user to prevent accidental triggers
    bool confirmed = await Get.defaultDialog(
      title: "Confirm Emergency Alert",
      middleText:
          "Are you sure you want to send an emergency alert? This action cannot be undone.",
      textConfirm: "Yes, send",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back(result: true);
      },
      onCancel: () {
        Get.back(result: false);
      },
    );

    if (!confirmed) {
      return;
    }

    isSendingAlert = true;
    update();

    try {
      final headers = {
        "Content-Type": "application/json",
        "x-auth-token": apiToken,
      };
      
      print('Sending request to: $backendEndpoint');
      print('Headers: $headers');
      print('Body: ${jsonEncode({
        "message": messageController.text,
        "contacts": emergencyContacts,
      })}');
      
      // Send alert to each contact
      for (final phone in emergencyContacts) {
        final response = await http.post(
          Uri.parse(backendEndpoint),
          headers: headers,
          body: jsonEncode({
            "phone": phone,
            "message": messageController.text,
          }),
        );

        if (response.statusCode != 200) {
          throw Exception('Failed to send alert to $phone: ${response.body}');
        }
      }

      // If we get here, all messages were sent successfully
      Get.snackbar(
        "Success",
        "Emergency alert sent successfully.",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to send emergency alert: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSendingAlert = false;
      update();
    }
  }

  @override
  void onClose() {
    contactController.dispose();
    messageController.dispose();
    super.onClose();
  }
}
