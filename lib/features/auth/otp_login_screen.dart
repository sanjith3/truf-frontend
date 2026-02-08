import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../home/user_home_screen.dart';

class OtpLoginScreen extends StatefulWidget {
  const OtpLoginScreen({super.key});

  @override
  State<OtpLoginScreen> createState() => _OtpLoginScreenState();
}

class _OtpLoginScreenState extends State<OtpLoginScreen> {
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _agreedToTerms = false;
  bool _isLogin = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _checkExistingUser();
  }

  Future<void> _checkExistingUser() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('userName');
    if (name != null && name.isNotEmpty) {
      setState(() {
        _isLogin = true;
      });
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                Text(
                  _isLogin ? "Welcome Back!" : "Welcome to TurfZone",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isLogin ? "Login to continue" : "Create your account to start booking",
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 40),
                
                // Name Field (only for registration)
                if (!_isLogin)
                  Column(
                    children: [
                      TextField(
                        controller: _nameController,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                          LengthLimitingTextInputFormatter(18),
                        ],
                        decoration: InputDecoration(
                          hintText: "Full Name",
                          prefixIcon: const Icon(Icons.person_outline),
                          counterText: "",
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
                    ],
                  ),
                
                // Phone Field
                TextField(
                  controller: _phoneController,
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
                const SizedBox(height: 16),

                // Password Field
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: _isLogin ? "Password" : "Set Password",
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF1DB954), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Terms and Conditions Checkbox (only for registration)
                if (!_isLogin)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: _agreedToTerms,
                          activeColor: const Color(0xFF1DB954),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _agreedToTerms = value ?? false;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            text: "I agree to the ",
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                              height: 1.4,
                            ),
                            children: [
                              TextSpan(
                                text: "Terms and Conditions",
                                style: const TextStyle(
                                  color: Color(0xFF1DB954),
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => _showTermsDialog("Terms and Conditions"),
                              ),
                              const TextSpan(text: " and "),
                              TextSpan(
                                text: "Privacy Policy",
                                style: const TextStyle(
                                  color: Color(0xFF1DB954),
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => _showTermsDialog("Privacy Policy"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
                    if (_isLogin) {
                      await _handleLogin();
                    } else {
                      await _handleRegistration();
                    }
                  },
                  child: Text(
                    _isLogin ? "Login" : "Register",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 16),

                // Toggle between login and registration
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = !_isLogin;
                      _passwordController.clear();
                      if (!_isLogin) {
                        _phoneController.clear();
                      }
                    });
                  },
                  child: Text(
                    _isLogin ? "Don't have an account? Register" : "Already have an account? Login",
                    style: const TextStyle(
                      color: Color(0xFF1DB954),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (phone.isEmpty || password.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter your phone number and password")),
        );
      }
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    
    // Check if user exists with this phone number
    final savedPassword = prefs.getString('password_$phone');
    
    if (savedPassword == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account not found. Please register first.")),
        );
      }
      return;
    }

    if (savedPassword != password) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Incorrect password")),
        );
      }
      return;
    }

    // Load user data for session
    final name = prefs.getString('name_$phone') ?? "User";
    
    // Set active session data
    await prefs.setString('userName', name);
    await prefs.setString('userPhone', phone);
    await prefs.setBool('isLoggedIn', true); // Mark as logged in
    

    // Check if partner
    String normName = name.trim().toLowerCase();
    String normPhone = phone.trim();
    String partnerKey = "${normName}_$normPhone";
    List<String> partnerKeys = prefs.getStringList('all_partners') ?? [];
    
    if (partnerKeys.contains(partnerKey)) {
      await prefs.setBool('isPartner', true);
      await prefs.setString('registeredTurfName', prefs.getString('turf_${partnerKey}_name') ?? "My Turf");
      await prefs.setString('registeredLocation', prefs.getString('turf_${partnerKey}_location') ?? "Registered Location");
      await prefs.setInt('registeredPrice', prefs.getInt('turf_${partnerKey}_price') ?? 500);
    } else {
      await prefs.setBool('isPartner', false);
    }

    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const UserHomeScreen()),
      );
    }
  }

  Future<void> _handleRegistration() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty) {
      _showError(context, "Please enter your name");
      return;
    }

    if (name.length > 25) {
      _showError(context, "Name must be less than 25 characters");
      return;
    }

    if (phone.length != 10) {
      _showError(context, "Please enter a valid 10-digit phone number");
      return;
    }

    if (password.isEmpty || password.length < 6) {
      _showError(context, "Password must be at least 6 characters");
      return;
    }
    
    if (!_agreedToTerms) {
      _showError(context, "Please agree to the Terms & Privacy Policy");
      return;
    }

    // Save user details
    final prefs = await SharedPreferences.getInstance();
    
    // Check if phone already registered
    final existingPassword = prefs.getString('password_$phone');
    if (existingPassword != null) {
      _showError(context, "This phone number is already registered. Please login.");
      return;
    }

    // Save registration data
    await prefs.setString('name_$phone', name);
    await prefs.setString('password_$phone', password);
    await prefs.setString('userName', name);
    await prefs.setString('userPhone', phone);
    await prefs.setBool('hasShownWelcome', true);
    
    // Save registration date
    final registrationDate = DateTime.now();
    await prefs.setString('registrationDate_$phone', registrationDate.toIso8601String());
    
    // Initialize as non-partner
    await prefs.setBool('isPartner', false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Registration successful! Welcome to TurfZone"),
        backgroundColor: Color(0xFF1DB954),
        duration: Duration(seconds: 2),
      ),
    );

    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const UserHomeScreen()),
      );
    }
  }

  void _showTermsDialog(String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(
            "This is a placeholder for $title.\n\n"
            "By using TurfZone, you agree to our policies regarding booking, cancellations, and usage of our platform.",
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
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
