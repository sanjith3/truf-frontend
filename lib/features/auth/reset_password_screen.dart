import 'package:flutter/material.dart';

import '../../services/api_service.dart';

/// Screen for setting a new password after OTP verification.
///
/// [phoneNumber] — the verified phone number.
/// [otpToken]    — the short-lived temp token returned from verify_otp.
class ResetPasswordScreen extends StatefulWidget {
  final String phoneNumber;
  final String otpToken;

  const ResetPasswordScreen({
    super.key,
    required this.phoneNumber,
    required this.otpToken,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  final ApiService _api = ApiService();

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    final newPass = _newPasswordController.text.trim();
    final confirmPass = _confirmPasswordController.text.trim();

    if (newPass.isEmpty || confirmPass.isEmpty) {
      _showError('Please fill in all fields');
      return;
    }
    if (newPass.length < 6) {
      _showError('Password must be at least 6 characters');
      return;
    }
    if (newPass != confirmPass) {
      _showError('Passwords do not match');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await _api.post(
        '/api/users/otp/reset_password/',
        body: {
          'phone': widget.phoneNumber,
          'new_password': newPass,
          'otp_token': widget.otpToken,
        },
      );

      if (response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password reset successfully! Please log in.'),
              backgroundColor: Color(0xFF1DB954),
              duration: Duration(seconds: 2),
            ),
          );
          // Pop back to login (remove entire reset stack)
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      } else {
        _showError(response['error'] ?? 'Password reset failed');
      }
    } on ApiException catch (e) {
      // Try to extract readable error from body
      String msg = 'Password reset failed';
      final match = RegExp(r'"error"\s*:\s*"([^"]+)"').firstMatch(e.body);
      if (match != null) msg = match.group(1)!;
      _showError(msg);
    } catch (_) {
      _showError('Cannot connect to server. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'New Password',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              const Text(
                'Create New Password',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your new password must be different from previous passwords.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 40),

              // ── New Password ─────────────────────────────────────────────
              TextField(
                controller: _newPasswordController,
                obscureText: _obscureNew,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: 'New Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNew ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() => _obscureNew = !_obscureNew),
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
              const SizedBox(height: 16),

              // ── Confirm Password ─────────────────────────────────────────
              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirm,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _resetPassword(),
                decoration: InputDecoration(
                  hintText: 'Confirm Password',
                  prefixIcon: const Icon(Icons.lock_reset_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
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
              const SizedBox(height: 40),

              // ── Reset Button ─────────────────────────────────────────────
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
                onPressed: _isLoading ? null : _resetPassword,
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
                    : const Text(
                        'RESET PASSWORD',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
