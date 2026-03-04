import 'package:flutter/material.dart';
import '../../services/api_service.dart';

/// QR scanner screen — scan a turf owner's QR code to earn wallet credit.
/// Requires: mobile_scanner package (or uses a camera-based approach).
class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final _api = ApiService();
  bool _scanning = false;
  bool _success = false;
  String _resultText = '';
  String _rewardAmount = '20';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    try {
      final cfg = await _api.get('/api/growth/config/');
      if (cfg['success'] == true && mounted) {
        // QR reward is tracked via owner qr_scans — amount comes from admin panel
        // show a default; the actual credit is handled server-side
        setState(() => _rewardAmount = '20');
      }
    } catch (_) {}
  }

  Future<void> _processQRCode(String rawValue) async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _scanning = false;
    });

    try {
      // Parse owner_id from QR value: https://turfzone.app/join?owner=X&code=Y
      final uri = Uri.tryParse(rawValue);
      final ownerId = uri?.queryParameters['owner'] ?? '';
      final code = uri?.queryParameters['code'] ?? '';

      if (ownerId.isEmpty && code.isEmpty) {
        setState(() {
          _loading = false;
          _resultText = 'Invalid QR code. Please scan a TurfZone owner QR.';
        });
        return;
      }

      final resp = await _api.postAuth(
        '/api/growth/owner-qr/scan/',
        body: {'owner_id': ownerId, 'referral_code': code},
      );

      setState(() {
        _loading = false;
        if (resp['success'] == true) {
          _success = true;
          _rewardAmount = resp['reward']?.toString() ?? _rewardAmount;
          _resultText = resp['message'] ?? 'Wallet credit added!';
        } else {
          _success = false;
          _resultText = resp['error'] ?? 'Could not process QR. Try again.';
        }
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _success = false;
        _resultText = 'Error processing QR. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Scan Turf QR',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _resultText.isNotEmpty ? _buildResult() : _buildScanner(),
    );
  }

  Widget _buildScanner() {
    return Column(
      children: [
        // Info strip
        Container(
          padding: const EdgeInsets.all(16),
          color: const Color(0xFF1DB954).withOpacity(0.1),
          child: Row(
            children: [
              const Icon(Icons.qr_code, color: Color(0xFF1DB954), size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Scan at the Turf',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Earn ₹$_rewardAmount wallet credit instantly!',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Scanner viewfinder area
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Dark background
              Container(color: const Color(0xFF1A1A1A)),

              // Crosshair frame
              Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF1DB954), width: 3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: _scanning
                      ? const CircularProgressIndicator(
                          color: Color(0xFF1DB954),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.qr_code_scanner,
                              color: Colors.white30,
                              size: 80,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Point camera at QR code',
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                ),
              ),

              // Corner decorations
              ...['tl', 'tr', 'bl', 'br'].map(
                (pos) => Positioned(
                  top: pos.startsWith('t')
                      ? MediaQuery.of(context).size.height / 2 - 140
                      : null,
                  bottom: pos.startsWith('b')
                      ? MediaQuery.of(context).size.height / 2 - 140
                      : null,
                  left: pos.endsWith('l')
                      ? MediaQuery.of(context).size.width / 2 - 140
                      : null,
                  right: pos.endsWith('r')
                      ? MediaQuery.of(context).size.width / 2 - 140
                      : null,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      border: Border(
                        top: pos.startsWith('t')
                            ? const BorderSide(
                                color: Color(0xFF1DB954),
                                width: 4,
                              )
                            : BorderSide.none,
                        bottom: pos.startsWith('b')
                            ? const BorderSide(
                                color: Color(0xFF1DB954),
                                width: 4,
                              )
                            : BorderSide.none,
                        left: pos.endsWith('l')
                            ? const BorderSide(
                                color: Color(0xFF1DB954),
                                width: 4,
                              )
                            : BorderSide.none,
                        right: pos.endsWith('r')
                            ? const BorderSide(
                                color: Color(0xFF1DB954),
                                width: 4,
                              )
                            : BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Manual entry fallback
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text(
                'No QR scanner package detected.\nEnter the owner code manually:',
                style: TextStyle(color: Colors.white54, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              _ManualCodeEntry(onSubmit: _processQRCode),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResult() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_loading)
              const CircularProgressIndicator(color: Color(0xFF1DB954))
            else ...[
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: (_success ? const Color(0xFF1DB954) : Colors.red)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Center(
                  child: Text(
                    _success ? '✅' : '❌',
                    style: const TextStyle(fontSize: 48),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_success) ...[
                Text(
                  '₹$_rewardAmount Added!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Text(
                _resultText,
                style: const TextStyle(color: Colors.white70, fontSize: 15),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => setState(() {
                  _resultText = '';
                  _success = false;
                }),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1DB954),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Scan Another'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Done',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ManualCodeEntry extends StatefulWidget {
  final void Function(String) onSubmit;
  const _ManualCodeEntry({required this.onSubmit});

  @override
  State<_ManualCodeEntry> createState() => _ManualCodeEntryState();
}

class _ManualCodeEntryState extends State<_ManualCodeEntry> {
  final _ctl = TextEditingController();

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _ctl,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter owner code or paste QR link',
              hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.white24),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF1DB954)),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () {
            if (_ctl.text.isNotEmpty) widget.onSubmit(_ctl.text.trim());
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1DB954),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('Go'),
        ),
      ],
    );
  }
}
