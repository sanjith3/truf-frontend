import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/api_service.dart';
import 'reset_password_screen.dart';

/// WhatsApp OTP verification screen.
///
/// Usage:
///   Navigator.push(context, MaterialPageRoute(
///     builder: (_) => WhatsAppOtpScreen(
///       phone: '9876543210',
///       purpose: 'register', // or 'reset'
///       name: 'John Doe',      // for register flow
///       password: 'secret123', // for register flow
///     ),
///   ));
class WhatsAppOtpScreen extends StatefulWidget {
  final String phone;
  final String purpose; // 'register' or 'reset'
  final String? name;
  final String? password;

  const WhatsAppOtpScreen({
    super.key,
    required this.phone,
    this.purpose = 'register',
    this.name,
    this.password,
  });

  @override
  State<WhatsAppOtpScreen> createState() => _WhatsAppOtpScreenState();
}

class _WhatsAppOtpScreenState extends State<WhatsAppOtpScreen> {
  final _otpController = TextEditingController();
  bool _isSending = false;
  bool _isVerifying = false;
  String _errorMessage = '';

  // Countdown timer
  int _secondsRemaining = 300; // 5 minutes
  int _resendCooldown = 0;
  Timer? _timer;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _sendOtp();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _timer?.cancel();
    _resendTimer?.cancel();
    super.dispose();
  }

  // ─── Send OTP ──────────────────────────────────────────────────────────

  Future<void> _sendOtp() async {
    setState(() {
      _isSending = true;
      _errorMessage = '';
    });

    try {
      final response = await ApiService.sendWhatsAppOtp(widget.phone);
      if (response['success'] == true) {
        _startCountdown();
        _startResendCooldown();
      } else {
        setState(() => _errorMessage = response['error'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Could not send OTP. Check your connection.');
      print('❌ WhatsApp OTP send error: $e');
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _secondsRemaining = 300);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsRemaining <= 1) {
        t.cancel();
        if (mounted) setState(() => _secondsRemaining = 0);
      } else {
        if (mounted) setState(() => _secondsRemaining--);
      }
    });
  }

  void _startResendCooldown() {
    _resendTimer?.cancel();
    setState(() => _resendCooldown = 30);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendCooldown <= 1) {
        t.cancel();
        if (mounted) setState(() => _resendCooldown = 0);
      } else {
        if (mounted) setState(() => _resendCooldown--);
      }
    });
  }

  String get _formattedTime {
    final m = _secondsRemaining ~/ 60;
    final s = _secondsRemaining % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  // ─── Verify OTP ────────────────────────────────────────────────────────

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      setState(() => _errorMessage = 'Please enter the 6-digit OTP');
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = '';
    });

    try {
      final response = await ApiService.verifyWhatsAppOtp(
        widget.phone,
        otp,
        purpose: widget.purpose,
      );

      if (response['success'] == true && response['verified'] == true) {
        if (widget.purpose == 'reset') {
          _handleResetSuccess(response['reset_token'] ?? '');
        } else {
          await _handleRegisterSuccess();
        }
      } else {
        setState(() => _errorMessage = response['error'] ?? 'Verification failed');
      }
    } on ApiException catch (e) {
      String msg = 'Verification failed';
      try {
        final match = RegExp(r'"error"\s*:\s*"([^"]+)"').firstMatch(e.body);
        if (match != null) msg = match.group(1)!;
      } catch (_) {}
      setState(() => _errorMessage = msg);
    } catch (e) {
      setState(() => _errorMessage = 'Connection error. Please try again.');
      print('❌ OTP verify error: $e');
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  // ─── Post-verification flows ───────────────────────────────────────────

  Future<void> _handleRegisterSuccess() async {
    if (!mounted) return;

    // Phone is verified — proceed with backend registration
    try {
      final response = await ApiService().post(
        '/api/users/auth/register/',
        body: {
          'name': widget.name ?? 'User',
          'phone': widget.phone,
          'password': widget.password ?? '',
        },
      );

      if (response['success'] == true) {
        final access =
            response['tokens']?['access'] ?? response['access'] ?? '';
        final refresh =
            response['tokens']?['refresh'] ?? response['refresh'] ?? '';
        await ApiService.saveTokens(access, refresh);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration Successful!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushNamedAndRemoveUntil(
              context, '/home', (route) => false);
        }
      } else {
        setState(() => _errorMessage =
            response['error'] ?? 'Registration failed. Please try again.');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Registration failed. Please try again.');
    }
  }

  void _handleResetSuccess(String resetToken) {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResetPasswordScreen(
          phoneNumber: widget.phone,
          resetToken: resetToken,
        ),
      ),
    );
  }

  // ─── UI ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isExpired = _secondsRemaining <= 0 && !_isSending;

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
          'Verify Phone',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),

              // WhatsApp icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF25D366).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.chat,
                  size: 40,
                  color: Color(0xFF25D366),
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'WhatsApp Verification',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We\'ve sent a 6-digit OTP to\n+91 ${widget.phone} via WhatsApp',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // OTP Input
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 12,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '• • • • • •',
                  hintStyle: TextStyle(
                    fontSize: 28,
                    letterSpacing: 12,
                    color: Colors.grey[300],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFF25D366),
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 16,
                  ),
                ),
                onChanged: (val) {
                  if (val.length == 6) _verifyOtp();
                },
              ),
              const SizedBox(height: 16),

              // Timer
              if (!isExpired)
                Text(
                  'OTP expires in $_formattedTime',
                  style: TextStyle(
                    fontSize: 13,
                    color: _secondsRemaining < 60 ? Colors.red : Colors.grey,
                  ),
                ),
              if (isExpired)
                const Text(
                  'OTP has expired',
                  style: TextStyle(fontSize: 13, color: Colors.red),
                ),
              const SizedBox(height: 8),

              // Error
              if (_errorMessage.isNotEmpty) ...[
                Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
                const SizedBox(height: 8),
              ],

              const SizedBox(height: 24),

              // Verify button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                onPressed: _isVerifying || _isSending ? null : _verifyOtp,
                child: _isVerifying
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'VERIFY OTP',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 16),

              // Resend
              TextButton(
                onPressed: (_resendCooldown > 0 || _isSending)
                    ? null
                    : () => _sendOtp(),
                child: Text(
                  _resendCooldown > 0
                      ? 'Resend OTP in ${_resendCooldown}s'
                      : 'Resend OTP',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _resendCooldown > 0
                        ? Colors.grey
                        : const Color(0xFF25D366),
                  ),
                ),
              ),

              // Loading indicator
              if (_isSending) ...[
                const SizedBox(height: 16),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFF25D366)),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Sending OTP via WhatsApp...',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
