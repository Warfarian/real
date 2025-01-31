import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:real/controller/medical_info_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class MedicalInfoView extends StatelessWidget {
  const MedicalInfoView({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Information'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: GetBuilder<MedicalInfoController>(
        init: MedicalInfoController(),
        builder: (controller) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildInfoSection(controller),
              const SizedBox(height: 24),
              _buildUsefulLinksSection(controller),
              const SizedBox(height: 24),
              _buildHelplineSection(controller),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoSection(MedicalInfoController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Important Information',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...controller.infoList.map((info) => Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info['title'] ?? '',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  info['content'] ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildUsefulLinksSection(MedicalInfoController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Useful Links',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...controller.usefulLinks.map((link) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(link['title'] ?? ''),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () async {
              final url = link['url'];
              if (url != null) {
                try {
                  await launchUrl(Uri.parse(url));
                } catch (e) {
                  Get.snackbar(
                    'Error',
                    'Could not open link',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              }
            },
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildHelplineSection(MedicalInfoController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Emergency Helplines',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...controller.helplines.map((helpline) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(helpline['name'] ?? ''),
            subtitle: Text(helpline['number'] ?? ''),
            trailing: IconButton(
              icon: const Icon(Icons.phone),
              onPressed: () async {
                final number = helpline['number'];
                if (number != null) {
                  final url = 'tel:${number.replaceAll(RegExp(r'[^\d]'), '')}';
                  try {
                    await launchUrl(Uri.parse(url));
                  } catch (e) {
                    Get.snackbar(
                      'Error',
                      'Could not initiate call',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                }
              },
            ),
          ),
        )).toList(),
      ],
    );
  }
}
