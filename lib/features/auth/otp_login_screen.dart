import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'otp_verify_screen.dart';

class OtpLoginScreen extends StatelessWidget {
  const OtpLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final phoneController = TextEditingController();
    final nameController = TextEditingController();
    final emailController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.sports_soccer,
                  size: 80,
                  color: Color(0xFF1DB954),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Welcome to TurfZone",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Create your account to start booking",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 40),
                
                // Name Field
                TextField(
                  controller: nameController,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                    LengthLimitingTextInputFormatter(18),
                  ],
                  decoration: InputDecoration(
                    hintText: "Full Name",
                    prefixIcon: const Icon(Icons.person_outline),
                    counterText: "", // Hide the counter
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF1DB954), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Email Field
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: "Email Address",
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF1DB954), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Phone Field
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  decoration: InputDecoration(
                    hintText: "Mobile Number",
                    prefixIcon: const Icon(Icons.phone_android_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF1DB954), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1DB954),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    final name = nameController.text.trim();
                    final email = emailController.text.trim();
                    final phone = phoneController.text.trim();

                    // Validation Regex for Email
                    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

                    if (name.isEmpty) {
                      _showError(context, "Please enter your name");
                      return;
                    }
                    
                    if (email.isEmpty || !emailRegex.hasMatch(email)) {
                      _showError(context, "Please enter a valid email address");
                      return;
                    }

                    if (phone.length != 10) {
                      _showError(context, "Please enter a valid 10-digit phone number");
                      return;
                    }

                    // Save user details
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('userName', name);
                    await prefs.setString('userEmail', email);
                    await prefs.setString('userPhone', phone);
                    await prefs.setBool('hasShownWelcome', true);

                    // Show demo OTP
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Demo OTP sent: 123456"),
                        backgroundColor: Color(0xFF1DB954),
                        duration: Duration(seconds: 4),
                      ),
                    );

                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const OtpVerifyScreen(),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    "Register & Send OTP",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
