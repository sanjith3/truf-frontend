import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/api_service.dart';
import '../home/user_home_screen.dart';
import 'forgot_password_screen.dart';

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
  bool _isLoading = false;

  final ApiService _api = ApiService();

  @override
  void initState() {
    super.initState();
    _checkExistingSession();
  }

  /// Check if user already has a valid JWT token
  Future<void> _checkExistingSession() async {
    final hasToken = await ApiService.hasToken();
    if (hasToken) {
      // User has a stored token — try to validate it
      try {
        await _api.getAuth('/api/users/user-profile/me/');
        // Token is valid — go to home
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const UserHomeScreen()),
          );
        }
      } catch (_) {
        // Token expired or invalid — clear and show login
        await ApiService.clearTokens();
      }
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
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
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
                  _isLogin
                      ? "Login to continue"
                      : "Create your account to start booking",
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
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z\s]'),
                          ),
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
                            borderSide: const BorderSide(
                              color: Color(0xFF1DB954),
                              width: 2,
                            ),
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
                      borderSide: const BorderSide(
                        color: Color(0xFF1DB954),
                        width: 2,
                      ),
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
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
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
                      borderSide: const BorderSide(
                        color: Color(0xFF1DB954),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                if (_isLogin)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(
                          color: Color(0xFF1DB954),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 12),

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
                                  ..onTap = () =>
                                      _showTermsDialog("Terms and Conditions"),
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
                                  ..onTap = () =>
                                      _showTermsDialog("Privacy Policy"),
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
                  onPressed: _isLoading
                      ? null
                      : () async {
                          if (_isLogin) {
                            await _handleLogin();
                          } else {
                            await _handleRegistration();
                          }
                        },
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          _isLogin ? "Login" : "Register",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
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
                    _isLogin
                        ? "Don't have an account? Register"
                        : "Already have an account? Login",
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

  // ─── BACKEND LOGIN ───
  Future<void> _handleLogin() async {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (phone.isEmpty || password.isEmpty) {
      _showError(context, "Please enter your phone number and password");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _api.post(
        '/api/users/user-login/login/',
        body: {
          'username': phone, // Backend accepts phone/username/email
          'password': password,
        },
      );

      if (response['success'] == true) {
        // Store JWT tokens
        await ApiService.saveTokens(
          response['tokens']['access'],
          response['tokens']['refresh'],
        );

        // Store user info for display
        final prefs = await SharedPreferences.getInstance();
        final user = response['user'];
        await prefs.setString(
          'userName',
          user['first_name'] ?? user['username'] ?? 'User',
        );
        await prefs.setString('userPhone', user['phone_number'] ?? phone);
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userRole', user['role'] ?? 'user');

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const UserHomeScreen()),
          );
        }
      } else {
        _showError(context, response['error'] ?? 'Login failed');
      }
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        _showError(context, "Invalid phone number or password");
      } else {
        _showError(context, "Server error. Please try again.");
      }
    } catch (e) {
      _showError(context, "Cannot connect to server. Check your connection.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── BACKEND REGISTRATION ───
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

    setState(() => _isLoading = true);

    try {
      final response = await _api.post(
        '/api/users/user-registration/normal_user_register/',
        body: {
          'username': phone, // Use phone as username
          'phone_number': phone,
          'first_name': name,
          'last_name': '',
          'email': '$phone@turfzone.app', // Placeholder email
          'password': password,
          'password_confirm': password,
        },
      );

      if (response['success'] == true) {
        // Store JWT tokens
        await ApiService.saveTokens(
          response['tokens']['access'],
          response['tokens']['refresh'],
        );

        // Store user info
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userName', name);
        await prefs.setString('userPhone', phone);
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userRole', 'user');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Registration successful! Welcome to TurfZone"),
              backgroundColor: Color(0xFF1DB954),
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const UserHomeScreen()),
          );
        }
      } else {
        final errors = response['errors'];
        if (errors != null && errors is Map) {
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            _showError(context, firstError.first.toString());
          } else {
            _showError(context, firstError.toString());
          }
        } else {
          _showError(context, response['error'] ?? 'Registration failed');
        }
      }
    } on ApiException catch (e) {
      _showError(context, "Registration failed: ${e.statusCode}");
    } catch (e) {
      _showError(context, "Cannot connect to server. Check your connection.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
