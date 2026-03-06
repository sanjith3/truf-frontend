import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/api_service.dart';

/// Full-featured OTP verification screen.
///
/// [phoneNumber] — the phone number OTP was sent to.
/// [purpose]     — 'registration' or 'reset'.
/// [onVerified]  — called with the temp token when OTP succeeds.
class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String purpose;
  final void Function(String tempToken) onVerified;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.purpose,
    required this.onVerified,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  static const int _otpLength = 6;

  final List<TextEditingController> _controllers = List.generate(
    _otpLength,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    _otpLength,
    (_) => FocusNode(),
  );

  bool _isLoading = false;
  bool _canResend = false;
  int _secondsRemaining = 60;
  Timer? _timer;

  final ApiService _api = ApiService();

  @override
  void initState() {
    super.initState();
    _startTimer();
    // Focus first box after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  // ─── Timer ───────────────────────────────────────────────────────────────

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _secondsRemaining = 60;
      _canResend = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _canResend = true;
          t.cancel();
        }
      });
    });
  }

  // ─── Resend OTP ──────────────────────────────────────────────────────────

  Future<void> _resendOtp() async {
    try {
      await _api.post(
        '/api/users/otp/send_otp/',
        body: {'phone': widget.phoneNumber, 'purpose': widget.purpose},
      );
      _startTimer();
      _clearBoxes();
    } catch (_) {
      _showError('Failed to resend OTP. Please try again.');
    }
  }

  // ─── Verify ──────────────────────────────────────────────────────────────

  String get _enteredCode => _controllers.map((c) => c.text).join();

  Future<void> _verifyOtp() async {
    final code = _enteredCode;
    if (code.length != _otpLength) return;

    setState(() => _isLoading = true);
    try {
      final response = await _api.post(
        '/api/users/otp/verify_otp/',
        body: {
          'phone': widget.phoneNumber,
          'code': code,
          'purpose': widget.purpose,
        },
      );

      if (response['success'] == true) {
        final token = response['token'] as String? ?? '';
        widget.onVerified(token);
      } else {
        _showError(response['error'] ?? 'Invalid OTP. Please try again.');
        _clearBoxes();
      }
    } on ApiException catch (e) {
      final body = e.body;
      String msg = 'Invalid OTP. Please try again.';
      try {
        // Try to parse JSON error body
        final decoded = body.contains('"error"')
            ? RegExp(r'"error":"([^"]+)"').firstMatch(body)?.group(1)
            : null;
        if (decoded != null) msg = decoded;
      } catch (_) {}
      _showError(msg);
      _clearBoxes();
    } catch (_) {
      _showError('Could not connect. Please check your connection.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _clearBoxes() {
    for (final c in _controllers) {
      c.clear();
    }
    if (mounted) _focusNodes[0].requestFocus();
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

  // ─── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final label = widget.purpose == 'registration'
        ? 'Verify to create account'
        : 'Verify to reset password';

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
          'Verify OTP',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // ── Header ──────────────────────────────────────────────────
              const Text(
                'Enter Verification Code',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.phone_android_outlined,
                    size: 16,
                    color: Color(0xFF1DB954),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.phoneNumber,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // ── 6 OTP Boxes ─────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_otpLength, (i) => _buildBox(i)),
              ),

              const SizedBox(height: 32),

              // ── Resend row ──────────────────────────────────────────────
              Center(
                child: _canResend
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Didn't receive code?  ",
                            style: TextStyle(color: Colors.grey),
                          ),
                          GestureDetector(
                            onTap: _resendOtp,
                            child: const Text(
                              'Resend',
                              style: TextStyle(
                                color: Color(0xFF1DB954),
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Text(
                        'Resend code in  $_secondsRemaining s',
                        style: const TextStyle(color: Colors.grey),
                      ),
              ),

              const SizedBox(height: 48),

              // ── Verify button ───────────────────────────────────────────
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
                onPressed: (_isLoading || _enteredCode.length != _otpLength)
                    ? null
                    : _verifyOtp,
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
                        'VERIFY & CONTINUE',
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

  Widget _buildBox(int index) {
    return SizedBox(
      width: 46,
      height: 54,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1DB954), width: 2),
          ),
        ),
        onChanged: (val) {
          if (val.length == 1 && index < _otpLength - 1) {
            _focusNodes[index + 1].requestFocus();
          }
          // Auto-submit when last digit entered
          if (index == _otpLength - 1 && val.length == 1) {
            _verifyOtp();
          }
          setState(() {}); // Refresh button enabled state
        },
        onTap: () {
          // Move cursor to end so backspace works naturally
          _controllers[index].selection = TextSelection.fromPosition(
            TextPosition(offset: _controllers[index].text.length),
          );
        },
      ),
    );
  }
}
