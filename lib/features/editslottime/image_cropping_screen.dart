// image_cropping_screen.dart
// Custom crop: image is FIXED, green rect is MOVABLE + RESIZABLE.
// No external crop package needed — pure Dart + dart:ui pixel math.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../../services/api_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
class ImageCroppingScreen extends StatefulWidget {
  final String turfId;
  final Map<String, dynamic> photo;
  final void Function(String newUrl) onSaved;

  const ImageCroppingScreen({
    super.key,
    required this.turfId,
    required this.photo,
    required this.onSaved,
  });

  @override
  State<ImageCroppingScreen> createState() => _ImageCroppingScreenState();
}

// ─────────────────────────────────────────────────────────────────────────────
class _ImageCroppingScreenState extends State<ImageCroppingScreen> {
  // Raw bytes of the original image
  Uint8List? _bytes;
  // Decoded image (for pixel dimensions)
  ui.Image? _decoded;

  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  // The crop rectangle in IMAGE WIDGET COORDINATES (not pixel coords)
  Rect _crop = Rect.zero;
  // Key on the Image widget so we can measure its rendered bounds
  final GlobalKey _imgKey = GlobalKey();

  // Corner handle size
  static const double _handle = 20;

  static const _green = Color(0xFF00C853);
  static const _dark = Color(0xFF121212);
  static const _surface = Color(0xFF1E1E1E);

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  String get _url => widget.photo['url']?.toString() ?? '';

  // ── Load & decode ──────────────────────────────────────────────────────────
  Future<void> _loadImage() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final res = await http.get(Uri.parse(_url));
      if (res.statusCode != 200) throw Exception('HTTP ${res.statusCode}');
      final bytes = res.bodyBytes;
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      if (mounted) {
        setState(() {
          _bytes = bytes;
          _decoded = frame.image;
          _isLoading = false;
        });
        // Wait one frame so the Image widget has rendered and has a size
        WidgetsBinding.instance.addPostFrameCallback((_) => _initCrop());
      }
    } catch (e) {
      if (mounted)
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
    }
  }

  // Place the initial 16:9 crop rect centred in the image widget
  void _initCrop() {
    final box = _imgKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final sz = box.size;
    // Start at 80 % width, locked to 16:9
    final w = sz.width * 0.80;
    final h = w * 9 / 16;
    final l = (sz.width - w) / 2;
    final t = (sz.height - h) / 2;
    setState(() => _crop = Rect.fromLTWH(l, t, w, h));
  }

  // Keep aspect ratio locked at 16:9
  Rect _locked(Rect r) {
    final h = r.width * 9 / 16;
    return Rect.fromLTWH(r.left, r.top, r.width, h);
  }

  // Clamp crop rect inside the image widget bounds
  Rect _clamped(Rect r) {
    final box = _imgKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return r;
    final sz = box.size;
    final l = r.left.clamp(0.0, sz.width - r.width);
    final t = r.top.clamp(0.0, sz.height - r.height);
    return Rect.fromLTWH(l, t, r.width.clamp(80, sz.width), r.height);
  }

  // ── Crop rect gestures ────────────────────────────────────────────────────
  void _onBodyDrag(DragUpdateDetails d) => setState(() {
    _crop = _clamped(_locked(_crop.translate(d.delta.dx, d.delta.dy)));
  });

  void _onCornerDrag(String corner, DragUpdateDetails d) {
    final dx = d.delta.dx;
    final dy = d.delta.dy;
    Rect r = _crop;
    switch (corner) {
      case 'TL':
        r = Rect.fromLTRB(r.left + dx, r.top + dy, r.right, r.bottom);
        break;
      case 'TR':
        r = Rect.fromLTRB(r.left, r.top + dy, r.right + dx, r.bottom);
        break;
      case 'BL':
        r = Rect.fromLTRB(r.left + dx, r.top, r.right, r.bottom + dy);
        break;
      case 'BR':
        r = Rect.fromLTRB(r.left, r.top, r.right + dx, r.bottom + dy);
        break;
    }
    // Enforce minimum size
    if (r.width < 80 || r.height < 40) return;
    setState(() => _crop = _clamped(_locked(r)));
  }

  // ── Crop pixels + upload ──────────────────────────────────────────────────
  Future<void> _cropAndSave() async {
    if (_decoded == null || _bytes == null) return;
    setState(() => _isSaving = true);
    try {
      // Map screen-space cropRect → image pixel coords
      final box = _imgKey.currentContext!.findRenderObject() as RenderBox;
      final wSize = box.size; // displayed image widget size
      final iW = _decoded!.width.toDouble(); // actual pixel width
      final iH = _decoded!.height.toDouble(); // actual pixel height

      // Fit: contain  →  letterboxed
      final scale = (wSize.width / iW).clamp(0.0, wSize.height / iH);
      final drawW = iW * scale;
      final drawH = iH * scale;
      final offsetX = (wSize.width - drawW) / 2; // black bars
      final offsetY = (wSize.height - drawH) / 2;

      // Convert crop rect (widget-local) to image pixel rect
      final pxLeft = ((_crop.left - offsetX) / scale).clamp(0.0, iW);
      final pxTop = ((_crop.top - offsetY) / scale).clamp(0.0, iH);
      final pxWidth = (_crop.width / scale).clamp(1.0, iW - pxLeft);
      final pxHeight = (_crop.height / scale).clamp(1.0, iH - pxTop);

      // Render just that region using dart:ui
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      canvas.drawImageRect(
        _decoded!,
        Rect.fromLTWH(pxLeft, pxTop, pxWidth, pxHeight),
        Rect.fromLTWH(0, 0, pxWidth, pxHeight),
        Paint(),
      );
      final picture = recorder.endRecording();
      final cropped = await picture.toImage(pxWidth.round(), pxHeight.round());
      final bd = await cropped.toByteData(format: ui.ImageByteFormat.png);
      if (bd == null) throw Exception('Encoding failed');

      // Write to tmp file
      final tmp = await getTemporaryDirectory();
      final file = File(
        '${tmp.path}/crop_${widget.photo['id']}_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(bd.buffer.asUint8List());

      // Upload
      final token = await ApiService.getAccessToken();
      if (token == null) throw Exception('Not authenticated');

      final uri = Uri.parse(
        '${ApiService.BASE_URL}/api/turfs/turfs/${widget.turfId}/crop_image/',
      );
      final req = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['image_id'] = widget.photo['id'].toString()
        ..files.add(
          await http.MultipartFile.fromPath(
            'image',
            file.path,
            filename: 'cropped_${widget.photo['id']}.png',
          ),
        );

      final resp = await http.Response.fromStream(await req.send());
      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      try {
        file.deleteSync();
      } catch (_) {}

      if (resp.statusCode == 200 && body['success'] == true) {
        widget.onSaved(body['image_url']?.toString() ?? _url);
        _snack('Photo cropped & saved!');
        if (mounted) Navigator.pop(context);
      } else {
        throw Exception(body['error'] ?? 'Upload failed (${resp.statusCode})');
      }
    } catch (e) {
      _snack('Failed: $e', error: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? Colors.redAccent : _green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── UI ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _dark,
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Crop Photo (16:9)',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        actions: [
          if (!_isLoading && _bytes != null)
            _isSaving
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: _green,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                : TextButton.icon(
                    onPressed: _cropAndSave,
                    icon: const Icon(
                      Icons.check_circle,
                      color: _green,
                      size: 18,
                    ),
                    label: const Text(
                      'Save Crop',
                      style: TextStyle(
                        color: _green,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: _green),
            SizedBox(height: 14),
            Text('Loading image…', style: TextStyle(color: Colors.white60)),
          ],
        ),
      );
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.broken_image_outlined,
              color: Colors.white24,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Could not load image',
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadImage,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // ── Image + crop overlay ─────────────────────────────────────────────
        Expanded(
          child: Container(
            color: Colors.black,
            margin: const EdgeInsets.all(12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LayoutBuilder(
                builder: (_, constraints) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      // Fixed background image
                      Image(
                        key: _imgKey,
                        image: MemoryImage(_bytes!),
                        fit: BoxFit.contain,
                        width: constraints.maxWidth,
                        height: constraints.maxHeight,
                      ),

                      // Dark vignette outside crop area
                      if (_crop != Rect.zero)
                        CustomPaint(
                          painter: _VignettePainter(_crop),
                          size: Size(
                            constraints.maxWidth,
                            constraints.maxHeight,
                          ),
                        ),

                      // Crop rectangle (draggable body + corner handles)
                      if (_crop != Rect.zero)
                        _CropRect(
                          rect: _crop,
                          handleSize: _handle,
                          onBodyDrag: _onBodyDrag,
                          onCornerDrag: _onCornerDrag,
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),

        // ── Bottom panel ─────────────────────────────────────────────────────
        Container(
          decoration: const BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _green.withAlpha(18),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _green.withAlpha(50)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.crop, color: _green, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'How to crop',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const _Tip('🟩', 'Drag the green box to reposition it'),
                    const _Tip(
                      '↔️',
                      'Drag any corner to resize (locks to 16:9)',
                    ),
                    const _Tip('🖼️', 'Image stays fixed — only the box moves'),
                    const _Tip('✅', 'Tap "Save Crop" to crop & upload'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isSaving ? null : _initCrop,
                      icon: const Icon(Icons.restart_alt, size: 18),
                      label: const Text('Reset'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _cropAndSave,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.crop),
                      label: Text(_isSaving ? 'Saving…' : 'Crop & Save'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _green,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: _green.withAlpha(80),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
/// The crop rectangle UI: draggable body, 4 corner handles, green border,
/// rule-of-thirds grid inside.
class _CropRect extends StatelessWidget {
  final Rect rect;
  final double handleSize;
  final void Function(DragUpdateDetails) onBodyDrag;
  final void Function(String corner, DragUpdateDetails) onCornerDrag;

  const _CropRect({
    required this.rect,
    required this.handleSize,
    required this.onBodyDrag,
    required this.onCornerDrag,
  });

  @override
  Widget build(BuildContext context) {
    final h = handleSize;
    return Positioned(
      left: rect.left,
      top: rect.top,
      width: rect.width,
      height: rect.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Body — draggable to move the whole rect
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanUpdate: onBodyDrag,
            child: CustomPaint(
              painter: _RectPainter(),
              size: Size(rect.width, rect.height),
            ),
          ),

          // 4 corner handles
          for (final c in ['TL', 'TR', 'BL', 'BR'])
            Positioned(
              left: c.contains('L') ? -h / 2 : null,
              right: c.contains('R') ? -h / 2 : null,
              top: c.contains('T') ? -h / 2 : null,
              bottom: c.contains('B') ? -h / 2 : null,
              child: GestureDetector(
                onPanUpdate: (d) => onCornerDrag(c, d),
                child: Container(
                  width: h,
                  height: h,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C853),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(80),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
/// Draws the green border, corner brackets, and rule-of-thirds inside the rect.
class _RectPainter extends CustomPainter {
  static const _green = Color(0xFF00C853);

  @override
  void paint(Canvas canvas, Size size) {
    // Green border
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..color = _green
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Rule-of-thirds grid
    final gp = Paint()
      ..color = Colors.white.withAlpha(40)
      ..strokeWidth = 0.8;
    canvas.drawLine(
      Offset(size.width / 3, 0),
      Offset(size.width / 3, size.height),
      gp,
    );
    canvas.drawLine(
      Offset(size.width * 2 / 3, 0),
      Offset(size.width * 2 / 3, size.height),
      gp,
    );
    canvas.drawLine(
      Offset(0, size.height / 3),
      Offset(size.width, size.height / 3),
      gp,
    );
    canvas.drawLine(
      Offset(0, size.height * 2 / 3),
      Offset(size.width, size.height * 2 / 3),
      gp,
    );

    // Corner brackets (thicker green, 22px arm)
    const arm = 22.0;
    final cp = Paint()
      ..color = _green
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(0, arm), Offset.zero, cp);
    canvas.drawLine(Offset.zero, Offset(arm, 0), cp);
    canvas.drawLine(Offset(size.width - arm, 0), Offset(size.width, 0), cp);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, arm), cp);
    canvas.drawLine(Offset(0, size.height - arm), Offset(0, size.height), cp);
    canvas.drawLine(Offset(0, size.height), Offset(arm, size.height), cp);
    canvas.drawLine(
      Offset(size.width - arm, size.height),
      Offset(size.width, size.height),
      cp,
    );
    canvas.drawLine(
      Offset(size.width, size.height - arm),
      Offset(size.width, size.height),
      cp,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => true;
}

// ─────────────────────────────────────────────────────────────────────────────
/// Dims everything OUTSIDE the crop rect.
class _VignettePainter extends CustomPainter {
  final Rect crop;
  _VignettePainter(this.crop);

  @override
  void paint(Canvas canvas, Size size) {
    final full = Rect.fromLTWH(0, 0, size.width, size.height);
    final path = Path()
      ..addRect(full)
      ..addRect(crop)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, Paint()..color = Colors.black.withAlpha(140));
  }

  @override
  bool shouldRepaint(_VignettePainter old) => old.crop != crop;
}

// ─────────────────────────────────────────────────────────────────────────────
class _Tip extends StatelessWidget {
  final String emoji, text;
  const _Tip(this.emoji, this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 13),
          ),
        ),
      ],
    ),
  );
}
