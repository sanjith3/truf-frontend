import 'package:flutter/material.dart';

class JoinPartnerScreen extends StatelessWidget {
  const JoinPartnerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Join as Partner"),
        backgroundColor: const Color(0xFF1DB954),
      ),
      body: const Center(
        child: Text(
          "Admin Request Form Coming Next ✅",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
