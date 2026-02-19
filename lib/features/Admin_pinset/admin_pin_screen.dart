import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turfzone/features/Admindashboard/admin_screen.dart';
import '../../services/auth_state.dart';

class AdminPinScreen extends StatefulWidget {
  const AdminPinScreen({super.key});

  @override
  State<AdminPinScreen> createState() => _AdminPinScreenState();
}

class _AdminPinScreenState extends State<AdminPinScreen> {
  final _enterPin = TextEditingController();
  final _newPin = TextEditingController();
  final _confirmPin = TextEditingController();
  final _password = TextEditingController();

  bool _hasPin = false;
  bool _isForgotMode = false;

  static const primaryGreen = Color(0xFF1DB954);

  @override
  void initState() {
    super.initState();
    _checkExistingPin();
  }

  Future<void> _checkExistingPin() async {
    final prefs = await SharedPreferences.getInstance();

    final phone = prefs.getString('userPhone'); // current logged user
    final isPartner = AuthState.instance.isOwner;

    if (phone == null) return;

    final savedPin = prefs.getString('admin_pin_$phone');

    setState(() {
      /// NEW PARTNER → force SET PIN
      if (isPartner && savedPin == null) {
        _hasPin = false;
      } else {
        _hasPin = savedPin != null;
      }
    });
  }

  Future<void> _savePin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString('userPhone');

    if (phone == null) return;

    await prefs.setString('admin_pin_$phone', pin);
  }

  Future<void> _validateAndProceed() async {
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString('userPhone');

    if (phone == null) return;

    final savedPin = prefs.getString('admin_pin_$phone');

    /// FIRST TIME SET PIN
    if (!_hasPin || _isForgotMode) {
      if (_newPin.text.length != 4 || _confirmPin.text.length != 4) {
        _showMsg("PIN must be 4 digits");
        return;
      }

      if (_newPin.text != _confirmPin.text) {
        _showMsg("PINs do not match");
        return;
      }

      await _savePin(_newPin.text);
      _goToAdmin();
      return;
    }

    /// ENTER EXISTING PIN
    if (_enterPin.text == savedPin) {
      _goToAdmin();
    } else {
      _showMsg("Incorrect PIN");
    }
  }

  void _goToAdmin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AdminScreen()),
    );
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _startForgotFlow() {
    setState(() {
      _isForgotMode = true;
    });
  }

  bool get _showSetPin => !_hasPin || _isForgotMode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Security"),
        centerTitle: true,
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            Text(
              _showSetPin ? "Set Admin PIN" : "Enter Admin PIN",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 6),

            Text(
              _showSetPin
                  ? "Create a secure PIN for admin access"
                  : "Enter your secure admin PIN",
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 30),

            /// ENTER PIN (only if already set)
            if (!_showSetPin) _pinField("Enter PIN", _enterPin),

            /// PASSWORD FIELD (forgot flow)
            if (_isForgotMode) ...[
              const SizedBox(height: 20),
              _passwordField(),
            ],

            /// NEW + CONFIRM PIN
            if (_showSetPin) ...[
              _pinField("New PIN", _newPin),
              const SizedBox(height: 20),
              _pinField("Confirm PIN", _confirmPin),
            ],

            const SizedBox(height: 30),

            /// CONFIRM BUTTON
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _validateAndProceed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Confirm",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: 14),

            /// FORGOT PIN
            if (_hasPin && !_isForgotMode)
              Center(
                child: TextButton(
                  onPressed: _startForgotFlow,
                  child: const Text(
                    "Forgot PIN?",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// PIN FIELD
  Widget _pinField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 4,
          decoration: InputDecoration(
            counterText: "",
            prefixIcon: const Icon(Icons.lock_outline),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  /// PASSWORD FIELD FOR FORGOT FLOW
  Widget _passwordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "User Login Password",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _password,
          obscureText: true,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.person),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}
