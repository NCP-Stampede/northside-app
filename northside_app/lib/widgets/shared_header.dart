// lib/widgets/shared_header.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../presentation/app_shell/app_shell_controller.dart';

class SharedHeader extends StatelessWidget {
  const SharedHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    // Find the AppShellController to handle page changes
    final AppShellController appShellController = Get.find();

    return Padding(
      // Use SafeArea padding to avoid the status bar
      padding: EdgeInsets.fromLTRB(24.0, MediaQuery.of(context).padding.top + 16, 24.0, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          // Wrap the icon in a GestureDetector to make it tappable
          GestureDetector(
            onTap: () {
              // Navigate to the Profile page (index 4)
              appShellController.changePage(4);
            },
            child: CircleAvatar(
              radius: 22,
              backgroundColor: Colors.grey.shade300,
              child: const Icon(Icons.person, color: Colors.black, size: 28),
            ),
          ),
        ],
      ),
    );
  }
}
