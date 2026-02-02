import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class JoinPartnerScreen extends StatefulWidget {
  const JoinPartnerScreen({super.key});

  @override
  State<JoinPartnerScreen> createState() => _JoinPartnerScreenState();
}

class _JoinPartnerScreenState extends State<JoinPartnerScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // Controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _mapsLinkController = TextEditingController();
  final TextEditingController _customSportController = TextEditingController();

  // Sports
  List<String> availableSports = [
    'Cricket',
    'Football',
    'Badminton',
    'Tennis',
    'Basketball',
    'Volleyball',
    'Hockey',
    'Squash',
    'Table Tennis',
    'Rugby',
    'Baseball',
  ];
  List<String> selectedSports = [];
  List<String> customSports = [];

  // Photos
  List<File> selectedPhotos = [];
  bool isConfirmed = false;

  void _submitForm() {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const ProcessingDialog(),
    );

    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // Close loading dialog
      _showReviewDialog();
    });
  }

  void _showReviewDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ReviewDialog(
        onClose: () {
          Navigator.pop(context);
          Navigator.pop(context); // Go back to previous screen
        },
      ),
    );
  }

  // Image picking
  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 90,
      );

      if (pickedFiles.isNotEmpty && mounted) {
        setState(() {
          selectedPhotos.addAll(
            pickedFiles.map((file) => File(file.path)).toList(),
          );
        });
      }
    } catch (e) {
      _showSnackBar('Error picking images: $e');
    }
  }

  void _removePhoto(int index) {
    setState(() {
      selectedPhotos.removeAt(index);
    });
  }

  void _addCustomSport() {
    if (_customSportController.text.trim().isNotEmpty) {
      setState(() {
        customSports.add(_customSportController.text.trim());
        _customSportController.clear();
      });
    }
  }

  void _removeCustomSport(int index) {
    setState(() {
      customSports.removeAt(index);
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Partner Registration",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        color: Colors.grey[50],
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                _buildHeaderCard(),
                const SizedBox(height: 24),

                // Section 1: Contact Details
                _buildSectionCard(
                  title: "Contact Information",
                  icon: Icons.person_outline,
                  content: Column(
                    children: [
                      _buildModernTextField(
                        controller: _fullNameController,
                        label: "Full Name",
                        hint: "Enter your full name",
                        icon: Icons.person,
                      ),
                      const SizedBox(height: 16),
                      _buildModernTextField(
                        controller: _phoneController,
                        label: "Phone Number",
                        hint: "Enter 10-digit mobile number",
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      _buildModernTextField(
                        controller: _emailController,
                        label: "Email Address",
                        hint: "Enter official email",
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Section 2: Business Details
                _buildSectionCard(
                  title: "Business Details",
                  icon: Icons.business_outlined,
                  content: Column(
                    children: [
                      _buildModernTextField(
                        controller: _businessNameController,
                        label: "Turf Name",
                        hint: "Enter your turf/business name",
                        icon: Icons.stadium_outlined,
                      ),
                      const SizedBox(height: 16),
                      _buildModernTextField(
                        controller: _priceController,
                        label: "Price Per Hour",
                        hint: "Enter price in ₹",
                        icon: Icons.currency_rupee_outlined,
                        prefixText: "₹ ",
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 20),
                      _buildSportsSection(),
                    ],
                  ),
                ),

                // Selected Sports Display Card
                if (selectedSports.isNotEmpty || customSports.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildSelectedSportsCard(),
                ],

                const SizedBox(height: 24),

                // Section 3: Description
                _buildSectionCard(
                  title: "Turf Description",
                  icon: Icons.description_outlined,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Describe your turf facilities, amenities, and special features",
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                          color: Colors.white,
                        ),
                        child: TextFormField(
                          controller: _descriptionController,
                          maxLines: 5,
                          minLines: 3,
                          decoration: const InputDecoration(
                            hintText: "",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16),
                          ),
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Tip: Include details about facilities, capacity, equipment, and amenities",
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Section 4: Location
                _buildSectionCard(
                  title: "Location Details",
                  icon: Icons.location_on_outlined,
                  content: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildModernTextField(
                              controller: _cityController,
                              label: "City",
                              hint: "Enter city",
                              icon: Icons.location_city_outlined,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildModernTextField(
                              controller: _zipCodeController,
                              label: "PIN Code",
                              hint: "6-digit PIN",
                              icon: Icons.pin_outlined,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildModernTextField(
                        controller: _addressController,
                        label: "Full Address",
                        hint: "Enter complete address",
                        icon: Icons.home_outlined,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      _buildModernTextField(
                        controller: _mapsLinkController,
                        label: "Google Maps Link",
                        hint: "Paste Google Maps share link",
                        icon: Icons.map_outlined,
                      ),
                      const SizedBox(height: 12),
                      _buildMapsHelpCard(),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Section 5: Photos
                _buildSectionCard(
                  title: "Turf Photos",
                  icon: Icons.photo_library_outlined,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Upload high-quality photos of your turf",
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 16),
                      _buildPhotoUploadSection(),
                      const SizedBox(height: 12),
                      _buildPhotoGrid(),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Section 6: Confirmation
                _buildConfirmationSection(),

                const SizedBox(height: 32),

                // Submit Button
                _buildSubmitButton(),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper Widgets
  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF00C853).withOpacity(0.1),
            const Color(0xFF00E676).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00C853).withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF00C853).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.handshake_outlined,
              size: 40,
              color: const Color(0xFF00C853),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Become a TurfSpot Partner",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Join India's premier sports platform. Fill in the details below to register your turf business.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF00C853).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF00C853).withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 14,
                  color: const Color(0xFF00C853),
                ),
                const SizedBox(width: 6),
                Text(
                  "Approval within 48 hours",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF00C853),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget content,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C853).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 22, color: const Color(0xFF00C853)),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? prefixText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
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
            color: Colors.white,
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
                  child: TextFormField(
                    controller: controller,
                    keyboardType: keyboardType,
                    maxLines: maxLines,
                    style: const TextStyle(fontSize: 15),
                    decoration: InputDecoration(
                      hintText: hint,
                      border: InputBorder.none,
                      prefixText: prefixText,
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSportsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Available Sports",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(width: 8),
            if (selectedSports.isNotEmpty || customSports.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF00C853).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${selectedSports.length + customSports.length} selected',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF00C853),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.8,
          ),
          itemCount: availableSports.length,
          itemBuilder: (context, index) {
            final sport = availableSports[index];
            final isSelected = selectedSports.contains(sport);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    selectedSports.remove(sport);
                  } else {
                    selectedSports.add(sport);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF00C853) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF00C853)
                        : Colors.grey[300]!,
                    width: isSelected ? 1.5 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF00C853).withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isSelected ? Icons.check_circle : Icons.sports,
                      size: 20,
                      color: isSelected ? Colors.white : Colors.grey[600],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sport,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Icon(
                        Icons.sports,
                        size: 20,
                        color: Colors.grey[500],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12, right: 16),
                        child: TextField(
                          controller: _customSportController,
                          decoration: const InputDecoration(
                            hintText: "Add custom sport...",
                            border: InputBorder.none,
                            hintStyle: TextStyle(fontSize: 14),
                          ),
                          onSubmitted: (_) => _addCustomSport(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: _addCustomSport,
              icon: const Icon(Icons.add, size: 18),
              label: const Text("Add"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                elevation: 1,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSelectedSportsCard() {
    final allSports = [...selectedSports, ...customSports];
    if (allSports.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.green[50]!,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.sports, size: 18, color: const Color(0xFF00C853)),
              const SizedBox(width: 8),
              Text(
                "Selected Sports",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF00C853).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${allSports.length} sports',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF00C853),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: allSports.map((sport) {
              final isCustom = customSports.contains(sport);
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isCustom ? Colors.blue[50] : Colors.green[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isCustom ? Colors.blue[100]! : Colors.green[100]!,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isCustom ? Icons.star_outline : Icons.sports,
                      size: 14,
                      color: isCustom
                          ? Colors.blue[600]
                          : const Color(0xFF00C853),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      sport,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isCustom ? Colors.blue[800] : Colors.green[800],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMapsHelpCard() {
    return Container(
      padding: const EdgeInsets.all(16),
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
              Icon(Icons.help_outline, size: 18, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Text(
                "How to get Google Maps link",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildStepRow("1. Open Google Maps on your device", Icons.map),
          _buildStepRow("2. Search for your turf location", Icons.search),
          _buildStepRow("3. Tap 'Share' and copy the link", Icons.share),
          _buildStepRow(
            "4. Paste the link in the field above",
            Icons.content_paste,
          ),
        ],
      ),
    );
  }

  Widget _buildStepRow(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.blue[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: Colors.blue[800]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoUploadSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickImages,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF00C853),
                width: 2,
                style: BorderStyle.solid,
              ),
              color: const Color(0xFF00C853).withOpacity(0.03),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF00C853).withOpacity(0.03),
                  Colors.white,
                ],
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C853).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.cloud_upload_outlined,
                    size: 40,
                    color: const Color(0xFF00C853),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Click to Upload Photos",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Upload at least 3 high-quality photos showing:\n• Playing area\n• Facilities\n• Parking space",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF00C853),
                        const Color(0xFF00E676),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00C853).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.photo_library, size: 18, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        "Browse Photos",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (selectedPhotos.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange[100]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 20, color: Colors.orange[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Please upload at least 3 photos for better approval chances",
                    style: TextStyle(fontSize: 13, color: Colors.orange[800]),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPhotoGrid() {
    if (selectedPhotos.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Selected Photos",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF00C853).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${selectedPhotos.length}/10',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF00C853),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: selectedPhotos.length,
          itemBuilder: (context, index) {
            return Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: FileImage(selectedPhotos[index]),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () => _removePhoto(index),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.close,
                        size: 14,
                        color: Colors.red[400],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 8),
        if (selectedPhotos.length < 3)
          Text(
            "Add ${3 - selectedPhotos.length} more photos for best results",
            style: TextStyle(
              fontSize: 12,
              color: Colors.orange[600],
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }

  Widget _buildConfirmationSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C853).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.verified_outlined,
                    size: 22,
                    color: const Color(0xFF00C853),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "Terms & Confirmation",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Transform.scale(
                    scale: 1.2,
                    child: Checkbox(
                      value: isConfirmed,
                      onChanged: (value) {
                        setState(() {
                          isConfirmed = value ?? false;
                        });
                      },
                      activeColor: const Color(0xFF00C853),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "I confirm that I own or manage this turf facility and all information provided is accurate and complete.",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "I understand that this application will undergo a verification process by our professional team, and approval may take up to 48 hours.",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (!isConfirmed)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.orange[100]!),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_outlined,
                                  size: 16,
                                  color: Colors.orange[700],
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Please confirm to submit your application",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.orange[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00C853),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
          shadowColor: const Color(0xFF00C853).withOpacity(0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.send_outlined, size: 20),
            SizedBox(width: 12),
            Text(
              "Submit Partner Application",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _businessNameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _cityController.dispose();
    _zipCodeController.dispose();
    _addressController.dispose();
    _mapsLinkController.dispose();
    _customSportController.dispose();
    super.dispose();
  }
}

// Loading Dialog
class ProcessingDialog extends StatelessWidget {
  const ProcessingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  const Color(0xFF00C853),
                ),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Processing Your Application",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Submitting your partner registration...",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

// Review Dialog - Updated with new message
class ReviewDialog extends StatelessWidget {
  final VoidCallback onClose;

  const ReviewDialog({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF00C853).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline,
                size: 48,
                color: Color(0xFF00C853),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Application Submitted Successfully!",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[100]!),
              ),
              child: Column(
                children: [
                  Text(
                    "✓ Application Received",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.green[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Our team will approve soon or within 10 hours",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.green[700]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "You'll receive admin dashboard access after approval. Keep checking your email for notifications.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.email_outlined,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Check your email for updates",
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_outlined,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Approval typically takes 2-10 hours",
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onClose,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C853),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Close",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
