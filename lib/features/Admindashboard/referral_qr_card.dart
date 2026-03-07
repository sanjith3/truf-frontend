import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';

/// Renders a scannable QR code for the owner's referral link, with working
/// Share (opens system share sheet with message + image) and Download (saves
/// PNG to the app's documents folder) buttons.
class ReferralQrCard extends StatefulWidget {
  final String referralCode;
  final int referralCount;
  final double referralEarnings;

  const ReferralQrCard({
    super.key,
    required this.referralCode,
    required this.referralCount,
    required this.referralEarnings,
  });

  @override
  State<ReferralQrCard> createState() => _ReferralQrCardState();
}

class _ReferralQrCardState extends State<ReferralQrCard> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isBusy = false;

  static const String _baseUrl = 'https://turfspot.app/join?ref=';

  String get _referralLink => '$_baseUrl${widget.referralCode}';

  String get _shareMessage =>
      '🎉 Book sports turfs near you with TurfSpot!\n\n'
      'Use my referral code *${widget.referralCode}* and get ₹50 off your first booking!\n\n'
      '👉 Download here: $_referralLink';

  Future<File?> _captureQrImage() async {
    final Uint8List? bytes = await _screenshotController.capture(
      pixelRatio: 3.0,
      delay: const Duration(milliseconds: 50),
    );
    if (bytes == null) return null;
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/turfspot_qr_${widget.referralCode}.png');
    await file.writeAsBytes(bytes);
    return file;
  }

  Future<void> _share() async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    try {
      final qrFile = await _captureQrImage();
      final ShareParams params = qrFile != null
          ? ShareParams(
              files: [XFile(qrFile.path, mimeType: 'image/png')],
              text: _shareMessage,
              subject: 'Join TurfSpot — ₹50 off with my code!',
            )
          : ShareParams(
              text: _shareMessage,
              subject: 'Join TurfSpot — ₹50 off with my code!',
            );
      await SharePlus.instance.share(params);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Share failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _download() async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    try {
      final qrFile = await _captureQrImage();
      if (qrFile == null) throw Exception('Could not capture QR image');

      // Save a persistent copy to documents
      final docsDir = await getApplicationDocumentsDirectory();
      final savePath = '${docsDir.path}/turfspot_qr_${widget.referralCode}.png';
      await qrFile.copy(savePath);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('QR code saved! Share it from your Files app.'),
            backgroundColor: Colors.green.shade700,
            action: SnackBarAction(
              label: 'Share',
              textColor: Colors.white,
              onPressed: () => SharePlus.instance.share(
                ShareParams(
                  files: [XFile(savePath, mimeType: 'image/png')],
                  text: _shareMessage,
                ),
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF1DB954);
    const darkGreen = Color(0xFF158040);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: green.withAlpha(50)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: green.withAlpha(12),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.card_giftcard_rounded,
                  color: darkGreen,
                  size: 18,
                ),
                const SizedBox(width: 8),
                const Text(
                  'REFERRAL PROGRAM',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: darkGreen,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: green.withAlpha(25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '₹20 / install',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: darkGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // QR Code — wrapped in Screenshot widget
                Screenshot(
                  controller: _screenshotController,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(8),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: QrImageView(
                      data: _referralLink,
                      version: QrVersions.auto,
                      size: 90,
                      backgroundColor: Colors.white,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Color(0xFF158040),
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Info + buttons
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Referral code pill
                      GestureDetector(
                        onTap: _share,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: green.withAlpha(18),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: green.withAlpha(60)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.tag, size: 13, color: darkGreen),
                              const SizedBox(width: 4),
                              Text(
                                'Code: ${widget.referralCode}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: darkGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${widget.referralCount} referrals · '
                        '₹${widget.referralEarnings.toStringAsFixed(0)} earned',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 12),
                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _isBusy ? null : _share,
                              icon: _isBusy
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.share_rounded, size: 15),
                              label: const Text(
                                'Share',
                                style: TextStyle(fontSize: 12),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: green,
                                side: const BorderSide(color: green),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isBusy ? null : _download,
                              icon: const Icon(
                                Icons.download_rounded,
                                size: 15,
                              ),
                              label: const Text(
                                'Save QR',
                                style: TextStyle(fontSize: 12),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: green,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: Colors.grey.shade300,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
