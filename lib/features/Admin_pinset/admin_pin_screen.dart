import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:turfzone/features/Admindashboard/admin_screen.dart';

/// Secure admin PIN screen.
///
/// FIX: Uses a FIXED storage key ('owner_pin_hash') instead of a
/// phone-based dynamic key. The old dynamic key ('admin_pin_hash_$phone')
/// caused the PIN to always be lost because SharedPreferences.getString
/// could return null on the first frame, making the key resolve to
/// 'admin_pin_hash_default' at save time, then 'admin_pin_hash_9876543210'
/// at read time — two different slots, so the PIN was never found.
///
/// Uses FutureBuilder directly in build() so setup-vs-verify mode is
/// always computed from fresh secure storage, not a cached bool.
class AdminPinScreen extends StatefulWidget {
  /// If true (opened from profile menu), push AdminScreen on top.
  /// If false (opened from badge), replace current route.
  final bool pushOnSuccess;
  const AdminPinScreen({super.key, this.pushOnSuccess = false});

  @override
  State<AdminPinScreen> createState() => _AdminPinScreenState();
}

class _AdminPinScreenState extends State<AdminPinScreen> {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // Fixed, stable key — NOT phone-based.
  static const _pinKey = 'owner_pin_hash';

  static const _primaryGreen = Color(0xFF1DB954);

  final _enterPin = TextEditingController();
  final _newPin = TextEditingController();
  final _confirmPin = TextEditingController();
  final _password = TextEditingController();

  bool _isForgotMode = false;
  bool _isWorking = false;

  @override
  void dispose() {
    _enterPin.dispose();
    _newPin.dispose();
    _confirmPin.dispose();
    _password.dispose();
    super.dispose();
  }

  // ── helpers ────────────────────────────────────────────────────────────────

  /// Read whether a PIN hash is stored.
  Future<bool> _checkHasPin() async {
    final stored = await _storage.read(key: _pinKey);
    debugPrint('[PIN] stored hash present: ${stored != null}');
    return stored != null && stored.isNotEmpty;
  }

  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    return sha256.convert(bytes).toString();
  }

  Future<void> _savePin(String pin) async {
    final hash = _hashPin(pin);
    await _storage.write(key: _pinKey, value: hash);
    debugPrint('[PIN] saved hash: $hash');
  }

  Future<bool> _verifyPin(String enteredPin) async {
    final stored = await _storage.read(key: _pinKey);
    if (stored == null || stored.isEmpty) return false;
    final match = stored == _hashPin(enteredPin);
    debugPrint('[PIN] verify: $match');
    return match;
  }

  // ── action ─────────────────────────────────────────────────────────────────

  Future<void> _handleAction(bool currentlyHasPin) async {
    if (_isWorking) return;
    setState(() => _isWorking = true);

    try {
      final doSetup = !currentlyHasPin || _isForgotMode;

      if (doSetup) {
        // ── SETUP / RESET ──
        if (_newPin.text.length != 4) {
          _showMsg('PIN must be exactly 4 digits');
          return;
        }
        if (_newPin.text != _confirmPin.text) {
          _showMsg('PINs do not match');
          return;
        }
        await _savePin(_newPin.text);
        _goToAdmin();
      } else {
        // ── VERIFY ──
        if (_enterPin.text.length != 4) {
          _showMsg('Enter your 4-digit PIN');
          return;
        }
        final ok = await _verifyPin(_enterPin.text);
        if (ok) {
          _goToAdmin();
        } else {
          _showMsg('Incorrect PIN. Please try again.');
        }
      }
    } catch (e) {
      debugPrint('[PIN] error: $e');
      _showMsg('Something went wrong. Please retry.');
    } finally {
      if (mounted) setState(() => _isWorking = false);
    }
  }

  void _goToAdmin() {
    if (!mounted) return;
    final route = MaterialPageRoute(builder: (_) => const AdminScreen());
    if (widget.pushOnSuccess) {
      Navigator.push(context, route);
    } else {
      Navigator.pushReplacement(context, route);
    }
  }

  void _showMsg(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ── build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // FutureBuilder re-evaluates setup-vs-verify from storage each rebuild.
    return FutureBuilder<bool>(
      future: _checkHasPin(),
      builder: (context, snap) {
        // While storage is being read, show loading
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFF5F7F6),
            body: Center(
              child: CircularProgressIndicator(color: _primaryGreen),
            ),
          );
        }

        final hasPin = snap.data ?? false;
        final showSetup = !hasPin || _isForgotMode;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7F6),
          appBar: AppBar(
            title: Text(showSetup ? 'Set Admin PIN' : 'Enter Admin PIN'),
            centerTitle: true,
            backgroundColor: _primaryGreen,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // Icon header
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: _primaryGreen.withAlpha(18),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      showSetup ? Icons.lock_open_rounded : Icons.lock_rounded,
                      size: 36,
                      color: _primaryGreen,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Center(
                  child: Text(
                    showSetup
                        ? 'Create Your Admin PIN'
                        : 'Welcome back, Partner',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    showSetup
                        ? 'Set a secure 4-digit PIN to protect your dashboard'
                        : 'Enter your 4-digit PIN to access the owner dashboard',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ),

                const SizedBox(height: 32),

                // Verify mode: enter existing PIN
                if (!showSetup) ...[
                  _pinField('Enter PIN', _enterPin, autofocus: true),
                  const SizedBox(height: 20),
                ],

                // Setup / forgot mode: new + confirm
                if (showSetup) ...[
                  if (_isForgotMode) ...[
                    _passwordField(),
                    const SizedBox(height: 16),
                  ],
                  _pinField('New PIN', _newPin, autofocus: true),
                  const SizedBox(height: 16),
                  _pinField('Confirm PIN', _confirmPin),
                  const SizedBox(height: 20),
                ],

                // Action button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isWorking ? null : () => _handleAction(hasPin),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryGreen,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isWorking
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            showSetup ? 'Set PIN & Continue' : 'Verify PIN',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                // Forgot PIN link
                if (hasPin && !_isForgotMode) ...[
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () => setState(() => _isForgotMode = true),
                      child: const Text(
                        'Forgot PIN?',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // ── helpers ─────────────────────────────────────────────────────────────────

  Widget _pinField(
    String label,
    TextEditingController ctrl, {
    bool autofocus = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 4,
          autofocus: autofocus,
          decoration: InputDecoration(
            counterText: '',
            prefixIcon: const Icon(Icons.lock_outline),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _primaryGreen, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _passwordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Login Password (to verify identity)',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _password,
          obscureText: true,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.person_outline),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}
