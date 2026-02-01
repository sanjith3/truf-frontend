import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:turfzone/features/splash/splash_screen.dart';

void main() {
  runApp(const TurfZoneApp());
}

class TurfZoneApp extends StatelessWidget {
  const TurfZoneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "TurfZone",
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        primaryColor: const Color(0xFF1DB954),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const SplashScreen(),
    );
  }
}

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("TurfZone"),
        backgroundColor: const Color(0xFF1DB954),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Select Your Role",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1DB954),
                minimumSize: const Size(double.infinity, 55),
              ),
              onPressed: () {},
              child: const Text("Continue as User/Admin"),
            ),

            const SizedBox(height: 15),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 55),
              ),
              onPressed: () {},
              child: const Text("Super Admin Login"),
            ),
          ],
        ),
      ),
    );
  }
}
