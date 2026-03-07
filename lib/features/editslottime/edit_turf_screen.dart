// edit_turf_screen.dart — Live data • Photo management (upload/delete/cover) • No Operating Hours
// Registration + new photos: owners can delete any photo and set any as cover.
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turfzone/features/Admindashboard/admin_turf_model.dart'; // AdminTurf
import '../../services/api_service.dart'; // For BASE_URL
import 'image_cropping_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Chip lists
// ─────────────────────────────────────────────────────────────────────────────
const _kAllSports = [
  'Football',
  'Cricket',
  'Badminton',
  'Tennis',
  'Basketball',
  'Volleyball',
  'Hockey',
  'Rugby',
  'Table Tennis',
  'Squash',
  'Futsal',
];

const _kAllAmenities = [
  'Floodlights',
  'Parking',
  'Water',
  'WiFi',
  'Changing Rooms',
  'Lockers',
  'Showers',
  'Cafeteria',
  'First Aid',
  'CCTV',
  'Equipment Rental',
  'Seating Area',
  'Restrooms',
  'Drinking Water',
  'Power Backup',
  'Music System',
  'Scoreboard',
  'Coach Available',
  'Spectator Stands',
  'Medical Room',
];

// ─────────────────────────────────────────────────────────────────────────────
// Photo model
// ─────────────────────────────────────────────────────────────────────────────
class _TurfPhoto {
  final int id;
  final String url;
  final bool isCover;

  const _TurfPhoto({
    required this.id,
    required this.url,
    required this.isCover,
  });

  factory _TurfPhoto.fromJson(Map<String, dynamic> j) => _TurfPhoto(
    id: j['image_id'] ?? j['id'] ?? 0,
    url: _Api.normalizeUrl((j['image_url'] ?? j['image'] ?? '').toString()),
    isCover: j['is_cover'] ?? false,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// API helpers
// ─────────────────────────────────────────────────────────────────────────────
class _Api {
  static String get base => ApiService.BASE_URL;

  static Future<String?> _token() async {
    final p = await SharedPreferences.getInstance();
    return p.getString('auth_access_token') ?? p.getString('access_token');
  }

  static Future<Map<String, String>> _jsonHeaders() async {
    final t = await _token();
    return {
      'Content-Type': 'application/json',
      if (t != null) 'Authorization': 'Bearer $t',
    };
  }

  /// Ensure URL is always absolute. Django may return relative /media/... paths.
  static String normalizeUrl(String url) {
    if (url.isEmpty) return url;
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    final clean = url.startsWith('/') ? url : '/$url';
    return '$base$clean';
  }

  /// GET /api/turfs/turfs/{id}/fetch_images/ — returns real IDs for all photos
  static Future<List<_TurfPhoto>> fetchImages(String turfId) async {
    final headers = await _jsonHeaders();
    final resp = await http
        .get(
          Uri.parse('$base/api/turfs/turfs/$turfId/fetch_images/'),
          headers: headers,
        )
        .timeout(const Duration(seconds: 15));
    final body = jsonDecode(resp.body) as Map<String, dynamic>;
    if (resp.statusCode == 200 && body['success'] == true) {
      return (body['images'] as List)
          .map((j) => _TurfPhoto.fromJson(j as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// POST multipart — upload image → returns _TurfPhoto with real ID
  static Future<_TurfPhoto> uploadImage(String turfId, File imageFile) async {
    final token = await _token();
    final uri = Uri.parse('$base/api/turfs/turfs/$turfId/upload_image/');
    final req = http.MultipartRequest('POST', uri);
    if (token != null) req.headers['Authorization'] = 'Bearer $token';
    req.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    final streamed = await req.send().timeout(const Duration(seconds: 30));
    final body =
        jsonDecode(await streamed.stream.bytesToString())
            as Map<String, dynamic>;
    if (streamed.statusCode == 201 && body['success'] == true) {
      return _TurfPhoto.fromJson(body);
    }
    throw Exception(body['error'] ?? 'Upload failed');
  }

  /// DELETE /api/turfs/turfs/{id}/delete_image/{imageId}/
  static Future<void> deleteImage(String turfId, int imageId) async {
    final headers = await _jsonHeaders();
    final resp = await http
        .delete(
          Uri.parse('$base/api/turfs/turfs/$turfId/delete_image/$imageId/'),
          headers: headers,
        )
        .timeout(const Duration(seconds: 15));
    final body = jsonDecode(resp.body) as Map<String, dynamic>;
    if (resp.statusCode != 200 || body['success'] != true) {
      throw Exception(body['error'] ?? 'Delete failed');
    }
  }

  /// PATCH /api/turfs/turfs/{id}/set_cover/{imageId}/
  static Future<void> setCover(String turfId, int imageId) async {
    final headers = await _jsonHeaders();
    final resp = await http
        .patch(
          Uri.parse('$base/api/turfs/turfs/$turfId/set_cover/$imageId/'),
          headers: headers,
        )
        .timeout(const Duration(seconds: 15));
    final body = jsonDecode(resp.body) as Map<String, dynamic>;
    if (resp.statusCode != 200 || body['success'] != true) {
      throw Exception(body['error'] ?? 'Set cover failed');
    }
  }

  /// POST multipart /api/turfs/turfs/{id}/crop_image/
  /// Uploads the already-cropped JPEG and replaces the image file on the server.
  static Future<String> cropImage(
    String turfId,
    int imageId,
    File croppedFile,
  ) async {
    final token = await _token();
    final uri = Uri.parse('$base/api/turfs/turfs/$turfId/crop_image/');
    final req = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['image_id'] = imageId.toString()
      ..files.add(
        await http.MultipartFile.fromPath(
          'image',
          croppedFile.path,
          filename:
              'crop_${imageId}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      );
    final streamed = await req.send().timeout(const Duration(seconds: 30));
    final resp = await http.Response.fromStream(streamed);
    final body = jsonDecode(resp.body) as Map<String, dynamic>;
    if (resp.statusCode == 200 && body['success'] == true) {
      return body['image_url']?.toString() ?? '';
    }
    throw Exception(body['error'] ?? 'Crop upload failed');
  }

  /// PATCH /api/turfs/turfs/{id}/update_details/
  static Future<Map<String, dynamic>> updateDetails(
    String turfId,
    Map<String, dynamic> payload,
  ) async {
    final headers = await _jsonHeaders();
    final resp = await http
        .patch(
          Uri.parse('$base/api/turfs/turfs/$turfId/update_details/'),
          headers: headers,
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 20));
    final body = jsonDecode(resp.body) as Map<String, dynamic>;
    if (resp.statusCode == 200 && body['success'] == true) return body;
    throw Exception(body['error'] ?? body['message'] ?? 'Update failed');
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Main Screen
// ─────────────────────────────────────────────────────────────────────────────
class EditTurfScreen extends StatefulWidget {
  final AdminTurf turf;
  const EditTurfScreen({super.key, required this.turf});

  @override
  State<EditTurfScreen> createState() => _EditTurfScreenState();
}

class _EditTurfScreenState extends State<EditTurfScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _mapCtrl;

  late Set<String> _selectedSports;
  late Set<String> _selectedAmenities;

  String? _selectedState;
  String? _selectedCity;
  List<String> _cityList = [];

  final List<_TurfPhoto> _photos = [];

  bool _isSaving = false;

  static const Map<String, List<String>> _statesCities = {
    'Andhra Pradesh': ['Vijayawada', 'Visakhapatnam', 'Guntur', 'Nellore'],
    'Bihar': ['Patna', 'Gaya', 'Bhagalpur'],
    'Delhi': ['New Delhi', 'North Delhi', 'South Delhi', 'East Delhi'],
    'Goa': ['Panaji', 'Margao', 'Vasco da Gama'],
    'Gujarat': ['Ahmedabad', 'Surat', 'Vadodara', 'Rajkot'],
    'Haryana': ['Gurugram', 'Faridabad', 'Panipat', 'Ambala'],
    'Karnataka': ['Bengaluru Urban', 'Mysuru', 'Mangaluru', 'Hubballi'],
    'Kerala': ['Thiruvananthapuram', 'Kochi', 'Kozhikode', 'Thrissur'],
    'Madhya Pradesh': ['Bhopal', 'Indore', 'Gwalior', 'Jabalpur'],
    'Maharashtra': ['Mumbai City', 'Pune', 'Nagpur', 'Nashik', 'Aurangabad'],
    'Punjab': ['Ludhiana', 'Amritsar', 'Jalandhar', 'Patiala'],
    'Rajasthan': ['Jaipur', 'Jodhpur', 'Udaipur', 'Kota'],
    'Tamil Nadu': [
      'Chennai',
      'Coimbatore',
      'Madurai',
      'Tiruchirappalli',
      'Salem',
      'Vellore',
      'Tiruppur',
      'Erode',
      'Thanjavur',
    ],
    'Telangana': ['Hyderabad', 'Warangal', 'Nizamabad', 'Karimnagar'],
    'Uttar Pradesh': [
      'Lucknow',
      'Kanpur Nagar',
      'Agra',
      'Varanasi',
      'Prayagraj',
    ],
    'West Bengal': ['Kolkata', 'Howrah', 'Darjeeling', 'Siliguri'],
  };

  @override
  void initState() {
    super.initState();
    final t = widget.turf;
    _nameCtrl = TextEditingController(text: t.name);
    _priceCtrl = TextEditingController(text: t.price.toString());
    _descCtrl = TextEditingController(text: t.description);
    _mapCtrl = TextEditingController(text: t.mapLink);

    _selectedSports = {};
    _selectedAmenities = Set.from(t.amenities);
    _selectedCity = t.location.isNotEmpty ? t.location : null;

    // Seed immediately with AdminTurf URLs (fast placeholder, id=0)
    for (final rawUrl in t.images) {
      final url = _Api.normalizeUrl(rawUrl);
      if (url.isNotEmpty) {
        _photos.add(_TurfPhoto(id: 0, url: url, isCover: _photos.isEmpty));
      }
    }
    // Then asynchronously load real IDs from backend
    _loadRealImages();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    _mapCtrl.dispose();
    super.dispose();
  }

  void _snack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : const Color(0xFF00C853),
        duration: Duration(seconds: isError ? 3 : 4),
      ),
    );
  }

  /// Fetch real TurfImage IDs from backend and replace the placeholder list.
  Future<void> _loadRealImages() async {
    try {
      final real = await _Api.fetchImages(widget.turf.id);
      if (!mounted || real.isEmpty) return;
      setState(() {
        _photos
          ..clear()
          ..addAll(real);
      });
    } catch (_) {
      // Silent — UI still shows seeded photos from AdminTurf
    }
  }

  // ── Upload ─────────────────────────────────────────────────────────────────
  Future<void> _pickAndUpload() async {
    final picker = ImagePicker();
    final picks = await picker.pickMultiImage(
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );
    if (picks.isEmpty) return;

    int ok = 0;
    for (final pick in picks) {
      try {
        if (mounted) setState(() {});
        final uploaded = await _Api.uploadImage(
          widget.turf.id,
          File(pick.path),
        );
        if (!mounted) return;
        setState(() {
          _photos.removeWhere((p) => p.id == 0 && p.url == uploaded.url);
          _photos.add(uploaded);
          if (uploaded.isCover) {
            for (int i = 0; i < _photos.length; i++) {
              if (_photos[i].id != uploaded.id && _photos[i].isCover) {
                _photos[i] = _TurfPhoto(
                  id: _photos[i].id,
                  url: _photos[i].url,
                  isCover: false,
                );
              }
            }
          }
        });
        ok++;
      } catch (e) {
        _snack(
          'Upload failed: ${e.toString().replaceFirst("Exception: ", "")}',
          isError: true,
        );
      }
    }
    if (ok > 0) _snack('$ok photo${ok > 1 ? 's' : ''} uploaded!');
  }

  // ── Delete — NO RESTRICTIONS, any photo can be deleted ────────────────────
  Future<void> _deletePhoto(_TurfPhoto photo, int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Photo'),
        content: const Text(
          'Are you sure you want to permanently delete this photo?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    // If the photo still has a placeholder id (real IDs not loaded yet),
    // trigger a background reload and try again.
    if (photo.id == 0) {
      _snack('Loading photo data, please try again in a moment…');
      _loadRealImages();
      return;
    }

    try {
      await _Api.deleteImage(widget.turf.id, photo.id);
      if (!mounted) return;
      setState(() {
        _photos.removeAt(index);
        if (photo.isCover && _photos.isNotEmpty) {
          final f = _photos[0];
          _photos[0] = _TurfPhoto(id: f.id, url: f.url, isCover: true);
        }
      });
      _snack('Photo deleted successfully.');
    } catch (e) {
      _snack(
        'Delete failed: ${e.toString().replaceFirst("Exception: ", "")}',
        isError: true,
      );
    }
  }

  // ── Set cover — NO RESTRICTIONS, any photo can be cover ───────────────────
  Future<void> _setCover(_TurfPhoto photo, int index) async {
    if (photo.id == 0) {
      _snack('Loading photo data, please try again in a moment…');
      _loadRealImages();
      return;
    }
    try {
      await _Api.setCover(widget.turf.id, photo.id);
      if (!mounted) return;
      setState(() {
        for (int i = 0; i < _photos.length; i++) {
          _photos[i] = _TurfPhoto(
            id: _photos[i].id,
            url: _photos[i].url,
            isCover: (i == index),
          );
        }
      });
      _snack('Cover photo updated!');
    } catch (e) {
      _snack(
        'Failed: ${e.toString().replaceFirst("Exception: ", "")}',
        isError: true,
      );
    }
  }

  // ── Crop a photo ───────────────────────────────────────────────────────────
  Future<void> _cropPhoto(_TurfPhoto photo, int index) async {
    if (photo.id == 0) {
      _snack('Loading photo data, please try again in a moment…');
      _loadRealImages();
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ImageCroppingScreen(
          turfId: widget.turf.id,
          photo: {'id': photo.id, 'url': photo.url},
          onSaved: (String newUrl) {
            if (!mounted) return;
            setState(() {
              _photos[index] = _TurfPhoto(
                id: photo.id,
                url: newUrl,
                isCover: photo.isCover,
              );
            });
          },
        ),
      ),
    );
  }

  // ── Save turf details ──────────────────────────────────────────────────────
  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      _snack('Turf name cannot be empty', isError: true);
      return;
    }
    final price = int.tryParse(_priceCtrl.text.trim());
    if (price == null || price <= 0) {
      _snack('Enter a valid price per hour', isError: true);
      return;
    }
    setState(() => _isSaving = true);
    try {
      final result = await _Api.updateDetails(widget.turf.id, {
        'name': _nameCtrl.text.trim(),
        'price_per_hour': price,
        'description': _descCtrl.text.trim(),
        'google_maps_share_link': _mapCtrl.text.trim(),
        if (_selectedCity != null) 'city': _selectedCity,
        if (_selectedState != null) 'state': _selectedState,
        'sports': _selectedSports.toList(),
        'amenities': _selectedAmenities.toList(),
      });
      if (!mounted) return;
      _snack(result['message'] ?? 'Changes saved! Admin has been notified.');
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _snack(
        'Error: ${e.toString().replaceFirst("Exception: ", "")}',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Edit Turf Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF00C853),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          _isSaving
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                )
              : Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: ElevatedButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save, size: 18),
                    label: const Text('Save'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withAlpha(50),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: Colors.white.withAlpha(80)),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoBanner(),
            const SizedBox(height: 16),
            _buildBasicInfo(),
            const SizedBox(height: 20),
            _buildDescription(),
            const SizedBox(height: 20),
            _buildSports(),
            const SizedBox(height: 20),
            _buildAmenities(),
            const SizedBox(height: 20),
            _buildLocation(),
            const SizedBox(height: 20),
            _buildPhotoSection(),
            const SizedBox(height: 24),
            _buildSaveButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ─── Section widgets ───────────────────────────────────────────────────────

  Widget _buildInfoBanner() => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.blue.shade50,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.blue.shade100),
    ),
    child: Row(
      children: [
        Icon(Icons.notifications_active, color: Colors.blue.shade700, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Changes go live immediately. Admin will be notified of all edits.',
            style: TextStyle(fontSize: 13, color: Colors.blue.shade800),
          ),
        ),
      ],
    ),
  );

  Widget _buildBasicInfo() => _card(
    title: 'Basic Information',
    icon: Icons.edit,
    children: [
      _field(
        label: 'Turf Name',
        hint: 'Enter turf name',
        ctrl: _nameCtrl,
        icon: Icons.grass,
      ),
      const SizedBox(height: 16),
      _field(
        label: 'Price Per Hour (₹)',
        hint: 'Enter price',
        ctrl: _priceCtrl,
        icon: Icons.currency_rupee,
        type: TextInputType.number,
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(child: _stateDropdown()),
          const SizedBox(width: 12),
          Expanded(child: _cityDropdown()),
        ],
      ),
    ],
  );

  Widget _buildDescription() => _card(
    title: 'Turf Description',
    icon: Icons.description,
    children: [
      Text(
        'Describe your turf facilities and special features',
        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
      ),
      const SizedBox(height: 12),
      _multilineField(
        hint: 'e.g. Premium turf with floodlights, parking…',
        ctrl: _descCtrl,
      ),
    ],
  );

  Widget _buildSports() => _card(
    title: 'Sports Available',
    icon: Icons.sports,
    children: [
      Text(
        'Select all sports available at your turf',
        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
      ),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _kAllSports.map((s) {
          final sel = _selectedSports.contains(s);
          return ChoiceChip(
            label: Text(s, style: const TextStyle(fontSize: 13)),
            selected: sel,
            onSelected: (v) => setState(
              () => v ? _selectedSports.add(s) : _selectedSports.remove(s),
            ),
            selectedColor: const Color(0xFF00C853),
            backgroundColor: Colors.grey[100],
            labelStyle: TextStyle(
              color: sel ? Colors.white : Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          );
        }).toList(),
      ),
    ],
  );

  Widget _buildAmenities() => _card(
    title: 'Amenities',
    icon: Icons.checklist,
    children: [
      Text(
        'Select amenities available at your turf',
        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
      ),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _kAllAmenities.map((a) {
          final sel = _selectedAmenities.contains(a);
          return FilterChip(
            label: Text(a, style: const TextStyle(fontSize: 13)),
            selected: sel,
            onSelected: (v) => setState(
              () =>
                  v ? _selectedAmenities.add(a) : _selectedAmenities.remove(a),
            ),
            selectedColor: const Color(0xFF00C853).withAlpha(40),
            checkmarkColor: const Color(0xFF00C853),
            backgroundColor: Colors.grey[100],
            labelStyle: TextStyle(
              color: sel ? const Color(0xFF00C853) : Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          );
        }).toList(),
      ),
      if (_selectedAmenities.isNotEmpty) ...[
        const SizedBox(height: 10),
        Text(
          'Selected: ${_selectedAmenities.join(', ')}',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    ],
  );

  Widget _buildLocation() => _card(
    title: 'Location Details',
    icon: Icons.location_on,
    children: [
      _field(
        label: 'Google Maps Link',
        hint: 'Paste Google Maps share link',
        ctrl: _mapCtrl,
        icon: Icons.map,
      ),
      const SizedBox(height: 12),
      _mapsHelp(),
    ],
  );

  // ─── PHOTO SECTION ─────────────────────────────────────────────────────────
  Widget _buildPhotoSection() {
    return _card(
      title: 'Turf Photos',
      icon: Icons.photo_library,
      children: [
        // Upload button
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _pickAndUpload,
                icon: const Icon(Icons.add_photo_alternate, size: 20),
                label: const Text(
                  'Add Photos',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C853),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                '${_photos.length} photo${_photos.length != 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${_photos.length} photo${_photos.length != 1 ? 's' : ''} · Tap ★ to set cover · Tap 🗑 to delete',
          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
        ),
        const SizedBox(height: 16),
        _photos.isEmpty
            ? _emptyPhotos()
            : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.85,
                ),
                itemCount: _photos.length,
                itemBuilder: (_, i) => _photoCard(_photos[i], i),
              ),
      ],
    );
  }

  Widget _photoCard(_TurfPhoto photo, int index) {
    return Stack(
      children: [
        // Image
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: photo.isCover
                  ? const Color(0xFF00C853)
                  : Colors.grey[300]!,
              width: photo.isCover ? 2.5 : 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: Image.network(
              photo.url,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (_, child, prog) => prog == null
                  ? child
                  : Container(
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey[200],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image, color: Colors.grey[400], size: 32),
                    const SizedBox(height: 4),
                    Text(
                      'Failed to load',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Cover badge
        if (photo.isCover)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF00C853),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.star, size: 10, color: Colors.white),
                  SizedBox(width: 3),
                  Text(
                    'COVER',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Loading indicator if id=0 (real IDs not yet loaded)
        if (photo.id == 0)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 1.5,
                ),
              ),
            ),
          ),

        // Action buttons
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(11),
                bottomRight: Radius.circular(11),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withAlpha(160)],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Crop button
                _iconBtn(
                  icon: Icons.crop_rounded,
                  color: Colors.lightBlue,
                  tooltip: 'Crop photo',
                  onTap: () => _cropPhoto(photo, index),
                ),
                const SizedBox(width: 6),
                if (!photo.isCover)
                  _iconBtn(
                    icon: Icons.star_border_rounded,
                    color: Colors.amber,
                    tooltip: 'Set as cover',
                    onTap: () => _setCover(photo, index),
                  ),
                if (!photo.isCover) const SizedBox(width: 6),
                _iconBtn(
                  icon: Icons.delete_rounded,
                  color: Colors.red,
                  tooltip: 'Delete',
                  onTap: () => _deletePhoto(photo, index),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _iconBtn({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(220),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 16, color: color),
    ),
  );

  Widget _emptyPhotos() => Container(
    height: 140,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: Colors.grey[50],
      border: Border.all(color: Colors.grey[300]!),
    ),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_library_outlined, size: 40, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(
            'No photos yet',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap "Add Photos" to upload',
            style: TextStyle(fontSize: 12, color: Colors.grey[400]),
          ),
        ],
      ),
    ),
  );

  Widget _buildSaveButton() => SizedBox(
    width: double.infinity,
    height: 56,
    child: ElevatedButton.icon(
      onPressed: _isSaving ? null : _save,
      icon: _isSaving
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : const Icon(Icons.save, size: 20),
      label: Text(
        _isSaving ? 'Saving…' : 'Save Changes',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00C853),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      ),
    ),
  );

  // ─── Reusable builders ─────────────────────────────────────────────────────

  Widget _card({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(13),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF00C853).withAlpha(26),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 24, color: const Color(0xFF00C853)),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ...children,
      ],
    ),
  );

  Widget _field({
    required String label,
    required String hint,
    required TextEditingController ctrl,
    required IconData icon,
    bool enabled = true,
    TextInputType type = TextInputType.text,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey[800],
        ),
      ),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
          color: enabled ? Colors.white : Colors.grey[100],
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Icon(icon, size: 20, color: Colors.grey[500]),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 12, right: 16),
                child: TextField(
                  controller: ctrl,
                  enabled: enabled,
                  keyboardType: type,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: hint,
                    border: InputBorder.none,
                    hintStyle: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _multilineField({
    required String hint,
    required TextEditingController ctrl,
  }) => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey[300]!),
    ),
    child: TextField(
      controller: ctrl,
      maxLines: 5,
      minLines: 3,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        border: InputBorder.none,
        contentPadding: const EdgeInsets.all(16),
        hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
      ),
    ),
  );

  Widget _stateDropdown() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'State',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey[800],
        ),
      ),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
          color: Colors.white,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedState,
            isExpanded: true,
            hint: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                'State',
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              ),
            ),
            icon: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Icon(Icons.arrow_drop_down, color: Colors.grey[500]),
            ),
            items: _statesCities.keys
                .map(
                  (s) => DropdownMenuItem(
                    value: s,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Text(
                        s,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v != null) {
                setState(() {
                  _selectedState = v;
                  _cityList = _statesCities[v] ?? [];
                  _selectedCity = _cityList.isNotEmpty ? _cityList.first : null;
                });
              }
            },
          ),
        ),
      ),
    ],
  );

  Widget _cityDropdown() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'City',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey[800],
        ),
      ),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
          color: _cityList.isEmpty ? Colors.grey[100] : Colors.white,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _cityList.contains(_selectedCity) ? _selectedCity : null,
            isExpanded: true,
            hint: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                _cityList.isEmpty ? 'Select state first' : 'City',
                style: TextStyle(fontSize: 13, color: Colors.grey[400]),
              ),
            ),
            icon: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Icon(Icons.arrow_drop_down, color: Colors.grey[500]),
            ),
            items: _cityList
                .map(
                  (c) => DropdownMenuItem(
                    value: c,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Text(
                        c,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: _cityList.isEmpty
                ? null
                : (v) => setState(() => _selectedCity = v),
          ),
        ),
      ),
    ],
  );

  Widget _mapsHelp() => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.blue[50],
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.blue[100]!),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.help_outline, size: 16, color: Colors.blue[700]),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'How to get Google Maps link',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...[
          (Icons.map, '1. Open Google Maps'),
          (Icons.search, '2. Search for your turf'),
          (Icons.share, '3. Tap Share and copy the link'),
          (Icons.content_paste, '4. Paste the link above'),
        ].map(
          ((IconData icon, String text) pair) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(pair.$1, size: 14, color: Colors.blue[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    pair.$2,
                    style: TextStyle(fontSize: 12, color: Colors.blue[800]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
