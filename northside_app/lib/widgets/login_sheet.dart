// lib/widgets/login_sheet.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginSheet extends StatefulWidget {
  const LoginSheet({super.key});

  @override
  State<LoginSheet> createState() => _LoginSheetState();
}

class _LoginSheetState extends State<LoginSheet> {
  // Controllers to manage the text in the input fields
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    // --- BACKEND INTEGRATION POINT ---
    // Here, you would take the text from the controllers:
    // final email = _emailController.text;
    // final password = _passwordController.text;
    // ...and send it to your backend for authentication.
    
    // For now, we just print and close the sheet.
    print('Logging in...');
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF2F2F7),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              // Scrollable content area
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  children: [
                    const Text(
                      'Link Flex Account',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 32),
                    // Email/Username TextField
                    TextField(
                      controller: _emailController,
                      decoration: _inputDecoration('Email or Username'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    // Password TextField
                    TextField(
                      controller: _passwordController,
                      decoration: _inputDecoration('Password'),
                      obscureText: true,
                    ),
                    const SizedBox(height: 32),
                    // Log In Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 5,
                        shadowColor: Colors.blue.withOpacity(0.4),
                      ),
                      onPressed: _handleLogin,
                      child: const Text('Log In', style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper method for consistent text field styling
  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }
}
