import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:real/views/camera_view.dart';
import 'package:real/views/support_chat_view.dart';
import 'package:real/views/medical_info_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade200, Colors.deepPurple.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome to Iris',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your Digital Support Companion',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  _buildButton(
                    icon: Icons.camera_alt,
                    label: 'Reality Check',
                    subtitle: 'Use camera to check reality',
                    onPressed: () => Get.to(() => const CameraView()),
                  ),
                  const SizedBox(height: 24),
                  _buildButton(
                    icon: Icons.chat_bubble_outline,
                    label: 'Support Chat',
                    subtitle: 'Talk with our support bot',
                    onPressed: () => Get.to(() => const SupportChatView()),
                  ),
                  const SizedBox(height: 24),
                  _buildButton(
                    icon: Icons.medical_information_outlined,
                    label: 'Medical Info',
                    subtitle: 'Learn about causes and support',
                    onPressed: () => Get.to(() => const MedicalInfoView()),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 100,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.deepPurple.shade700,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Icon(icon, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.deepPurple.shade700.withAlpha(180),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}
