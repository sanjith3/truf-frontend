import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/turf_data_service.dart';
import '../../models/turf.dart';

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
  final TextEditingController _customAmenityController =
      TextEditingController();

  // Bank Details Controllers
  final TextEditingController _accountHolderNameController =
      TextEditingController();
  final TextEditingController _accountNumberController =
      TextEditingController();
  final TextEditingController _confirmAccountNumberController =
      TextEditingController(); // New confirmation field
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _ifscCodeController = TextEditingController();
  final TextEditingController _branchNameController = TextEditingController();

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
    'Swimming',
    'Athletics',
    'Boxing',
    'Golf',
  ];
  List<String> selectedSports = [];
  List<String> customSports = [];
  bool showAllSports = false;

  // Amenities
  List<String> availableAmenities = [
    'Flood Lights',
    'Parking',
    'Water',
    'Changing Rooms',
    'Showers',
    'Restrooms',
    'First Aid',
    'Cafeteria',
    'Equipment Rental',
    'WiFi',
    'Lockers',
    'Coach Available',
    'Spectator Seating',
    'Club House',
    'Power Backup',
  ];
  List<String> selectedAmenities = [];
  List<String> customAmenities = [];
  bool showAllAmenities = false;

  // Photos
  List<File> selectedPhotos = [];
  bool isConfirmed = false;

  // Step tracking for better UX
  int _currentStep = 0;
  final List<String> _stepTitles = [
    'Contact Info',
    'Business Details',
    'Location',
    'Bank Details',
    'Photos & Terms',
  ];

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    // Validate bank details
    if (_accountHolderNameController.text.isEmpty ||
        _accountNumberController.text.isEmpty ||
        _confirmAccountNumberController.text.isEmpty ||
        _bankNameController.text.isEmpty ||
        _ifscCodeController.text.isEmpty) {
      _showSnackBar('Please fill all bank details', isError: true);
      return;
    }

    // Validate account number confirmation
    if (_accountNumberController.text != _confirmAccountNumberController.text) {
      _showSnackBar('Account numbers do not match', isError: true);
      return;
    }

    if (!isConfirmed) {
      _showSnackBar('Please confirm the terms and conditions', isError: true);
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const ProcessingDialog(),
    );

    // Create new Turf object
    final newTurf = Turf(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _businessNameController.text.trim(),
      location: _cityController.text.trim(),
      city: _cityController.text.trim(),
      distance: 2.0,
      price: int.tryParse(_priceController.text.trim()) ?? 500,
      rating: 5.0,
      images: [
        "https://images.unsplash.com/photo-1531315630201-bb15abeb1653?w=800",
      ],
      amenities: selectedAmenities,
      sports: [...selectedSports, ...customSports],
      mapLink: _mapsLinkController.text.trim(),
      address: _addressController.text.trim(),
      description: _descriptionController.text.trim(),
    );

    // Save to service
    TurfDataService().addTurf(newTurf);

    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
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
          Navigator.pop(context);
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
        imageQuality: 85,
        // Limit to 6 images
      );

      if (pickedFiles.isNotEmpty && mounted) {
        setState(() {
          selectedPhotos.addAll(
            pickedFiles.map((file) => File(file.path)).toList(),
          );
          if (selectedPhotos.length > 10) {
            selectedPhotos = selectedPhotos.sublist(0, 10);
            _showSnackBar('Maximum 10 photos allowed. Only first 10 selected.');
          }
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
    String sport = _customSportController.text.trim();
    if (sport.isNotEmpty) {
      sport = sport
          .split(' ')
          .map((word) {
            if (word.isEmpty) return '';
            return word[0].toUpperCase() + word.substring(1).toLowerCase();
          })
          .join(' ');

      setState(() {
        customSports.add(sport);
        _customSportController.clear();
      });
    }
  }

  void _addCustomAmenity() {
    String amenity = _customAmenityController.text.trim();
    if (amenity.isNotEmpty) {
      amenity = amenity
          .split(' ')
          .map((word) {
            if (word.isEmpty) return '';
            return word[0].toUpperCase() + word.substring(1).toLowerCase();
          })
          .join(' ');

      setState(() {
        customAmenities.add(amenity);
        _customAmenityController.clear();
      });
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _capitalizeWords(String text) {
    return text
        .split(' ')
        .map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  void _nextStep() {
    if (_currentStep < _stepTitles.length - 1) {
      setState(() {
        _currentStep++;
      });
      _scrollToTop();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _scrollToTop();
    }
  }

  void _scrollToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PrimaryScrollController.of(context)?.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              "Partner Registration",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            const SizedBox(height: 2),
            Text(
              "Complete in 3-5 minutes",
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
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
          child: Column(
            children: [
              // Progress Steps
              _buildProgressSteps(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Show different content based on current step
                      if (_currentStep == 0) _buildStep1ContactInfo(),
                      if (_currentStep == 1) _buildStep2BusinessDetails(),
                      if (_currentStep == 2) _buildStep3Location(),
                      if (_currentStep == 3) _buildStep4BankDetails(),
                      if (_currentStep == 4) _buildStep5PhotosTerms(),

                      const SizedBox(height: 20),

                      // Navigation Buttons
                      _buildNavigationButtons(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSteps() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(_stepTitles.length, (index) {
          bool isActive = index == _currentStep;
          bool isCompleted = index < _currentStep;

          return Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF00C853)
                            : isCompleted
                            ? const Color(0xFF00C853)
                            : Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              )
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: isActive
                                      ? Colors.white
                                      : Colors.grey[600],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                      ),
                    ),
                    if (index < _stepTitles.length - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? const Color(0xFF00C853)
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _stepTitles[index],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive
                        ? const Color(0xFF00C853)
                        : isCompleted
                        ? const Color(0xFF00C853)
                        : Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStep1ContactInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.person_outline,
          title: "Contact Information",
          subtitle: "We'll use this to contact you about your application",
        ),
        const SizedBox(height: 20),
        _buildCompactTextField(
          controller: _fullNameController,
          label: "Full Name",
          hint: "Enter your full name",
          icon: Icons.person,
          isRequired: true,
        ),
        const SizedBox(height: 16),
        _buildCompactTextField(
          controller: _phoneController,
          label: "Phone Number",
          hint: "10-digit mobile number",
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
          isRequired: true,
        ),
        const SizedBox(height: 16),
        _buildCompactTextField(
          controller: _emailController,
          label: "Email Address",
          hint: "Enter official email",
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          isRequired: true,
        ),
      ],
    );
  }

  Widget _buildStep2BusinessDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.business_outlined,
          title: "Business Details",
          subtitle: "Basic information about your turf",
        ),
        const SizedBox(height: 20),
        _buildCompactTextField(
          controller: _businessNameController,
          label: "Turf Name",
          hint: "e.g., Green Field Arena",
          icon: Icons.stadium_outlined,
          isRequired: true,
        ),
        const SizedBox(height: 16),
        _buildCompactTextField(
          controller: _priceController,
          label: "Price Per Hour",
          hint: "Enter price in ₹",
          icon: Icons.currency_rupee_outlined,
          prefixText: "₹ ",
          keyboardType: TextInputType.number,
          isRequired: true,
        ),
        const SizedBox(height: 24),

        // Sports - Compact Version
        _buildCompactSectionTitle("Sports Available"),
        const SizedBox(height: 12),
        _buildSportsGridCompact(),

        const SizedBox(height: 24),

        // Amenities - Compact Version
        _buildCompactSectionTitle("Amenities"),
        const SizedBox(height: 12),
        _buildAmenitiesGridCompact(),

        const SizedBox(height: 16),
        _buildCompactTextField(
          controller: _descriptionController,
          label: "Brief Description (Optional)",
          hint: "Describe your turf in 2-3 lines",
          icon: Icons.description_outlined,
          maxLines: 2,
          isRequired: false,
        ),
      ],
    );
  }

  Widget _buildStep3Location() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.location_on_outlined,
          title: "Location Details",
          subtitle: "Where is your turf located?",
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildCompactTextField(
                controller: _cityController,
                label: "City",
                hint: "e.g., Coimbatore",
                icon: Icons.location_city_outlined,
                isRequired: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCompactTextField(
                controller: _zipCodeController,
                label: "PIN Code",
                hint: "6-digit code",
                icon: Icons.pin_outlined,
                keyboardType: TextInputType.number,
                isRequired: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildCompactTextField(
          controller: _addressController,
          label: "Full Address",
          hint: "Street, area, landmark",
          icon: Icons.home_outlined,
          maxLines: 2,
          isRequired: true,
        ),
        const SizedBox(height: 16),
        _buildCompactTextField(
          controller: _mapsLinkController,
          label: "Google Maps Link",
          hint: "Paste shareable link",
          icon: Icons.map_outlined,
          isRequired: true,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[100]!),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Open Maps → Search your turf → Tap 'Share' → Copy link",
                  style: TextStyle(fontSize: 12, color: Colors.blue[800]),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep4BankDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.account_balance_outlined,
          title: "Bank Details",
          subtitle: "For commission payments",
        ),
        const SizedBox(height: 20),
        _buildCompactTextField(
          controller: _accountHolderNameController,
          label: "Account Holder Name",
          hint: "As per bank records",
          icon: Icons.person_outline,
          isRequired: true,
        ),
        const SizedBox(height: 16),
        _buildCompactTextField(
          controller: _accountNumberController,
          label: "Account Number",
          hint: "Enter account number",
          icon: Icons.credit_card_outlined,
          keyboardType: TextInputType.number,
          isRequired: true,
        ),
        const SizedBox(height: 16),
        _buildCompactTextField(
          controller: _confirmAccountNumberController,
          label: "Confirm Account Number",
          hint: "Re-enter account number",
          icon: Icons.credit_card_outlined,
          keyboardType: TextInputType.number,
          isRequired: true,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildCompactTextField(
                controller: _bankNameController,
                label: "Bank Name",
                hint: "e.g., SBI",
                icon: Icons.business_outlined,
                isRequired: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCompactTextField(
                controller: _ifscCodeController,
                label: "IFSC Code",
                hint: "11 characters",
                icon: Icons.code_outlined,
                isRequired: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildCompactTextField(
          controller: _branchNameController,
          label: "Branch Name (Optional)",
          hint: "Enter branch name",
          icon: Icons.location_city_outlined,
          isRequired: false,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green[100]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 16,
                    color: Colors.green[700],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Payment Information",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                "• We deduct 10% commission from each booking\n• 90% is transferred INSTANTLY to your account\n• Payments processed after each booking",
                style: TextStyle(fontSize: 11, color: Colors.green[800]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep5PhotosTerms() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.photo_library_outlined,
          title: "Photos & Final Steps",
          subtitle: "Almost done! Just need a few more details",
        ),
        const SizedBox(height: 20),

        // Photo Upload - Simplified
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
            color: Colors.white,
          ),
          child: InkWell(
            onTap: _pickImages,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 36,
                    color: const Color(0xFF00C853),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    selectedPhotos.isEmpty
                        ? "Upload Turf Photos"
                        : "${selectedPhotos.length} Photos Selected",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    selectedPhotos.isEmpty
                        ? "Tap to add photos (3-6 recommended)"
                        : "Tap to add/remove photos",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  if (selectedPhotos.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 60,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: selectedPhotos.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Stack(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: FileImage(selectedPhotos[index]),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: -4,
                                  right: -4,
                                  child: IconButton(
                                    icon: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.1,
                                            ),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                      padding: const EdgeInsets.all(2),
                                      child: Icon(
                                        Icons.close,
                                        size: 14,
                                        color: Colors.red,
                                      ),
                                    ),
                                    onPressed: () => _removePhoto(index),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Compact Terms & Conditions
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.verified_outlined,
                      size: 20,
                      color: const Color(0xFF00C853),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Terms & Conditions",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Scrollable Terms
                Container(
                  height: 160,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTermItem("✓ I own/manage this turf facility"),
                        _buildTermItem("✓ Information provided is accurate"),
                        _buildTermItem("✓ Approval process takes 48 hours"),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.account_balance_wallet_outlined,
                                    size: 14,
                                    color: Colors.orange[700],
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Commission Agreement",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.orange[700],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "• 10% commission on each booking\n• 90% transferred INSTANTLY after booking\n• Fixed, non-negotiable structure",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.orange[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Transform.scale(
                      scale: 1.1,
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
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "I have read and agree to all terms and conditions",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        if (_currentStep > 0)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _previousStep,
              icon: const Icon(Icons.arrow_back, size: 16),
              label: const Text("Back"),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey[700],
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                side: BorderSide(color: Colors.grey[400]!),
              ),
            ),
          ),
        if (_currentStep > 0) const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _currentStep == _stepTitles.length - 1
                ? _submitForm
                : _nextStep,
            icon: Icon(
              _currentStep == _stepTitles.length - 1
                  ? Icons.send_outlined
                  : Icons.arrow_forward,
              size: 16,
            ),
            label: Text(
              _currentStep == _stepTitles.length - 1
                  ? "Submit Application"
                  : "Next",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C853),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF00C853).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF00C853)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactSectionTitle(String title) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(width: 8),
        if (title.contains("Sports"))
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF00C853).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${selectedSports.length + customSports.length} selected',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF00C853),
              ),
            ),
          ),
        if (title.contains("Amenities"))
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${selectedAmenities.length + customAmenities.length} selected',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.orange[700],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCompactTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? prefixText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool isRequired = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            if (isRequired)
              Text(
                " *",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.red[400],
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
            color: Colors.white,
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Icon(icon, size: 18, color: Colors.grey[500]),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, right: 12),
                  child: TextFormField(
                    controller: controller,
                    keyboardType: keyboardType,
                    maxLines: maxLines,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: hint,
                      border: InputBorder.none,
                      prefixText: prefixText,
                      hintStyle: TextStyle(
                        fontSize: 13,
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

  Widget _buildSportsGridCompact() {
    List<String> displayedSports = showAllSports
        ? availableSports
        : availableSports.take(6).toList();

    return Column(
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: displayedSports.map((sport) {
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF00C853) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF00C853)
                        : Colors.grey[300]!,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isSelected ? 0.1 : 0.03),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  sport,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.grey[700],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (!showAllSports && availableSports.length > 6) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                showAllSports = true;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.expand_more, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    "Show More (${availableSports.length - 6})",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    Icon(Icons.sports, size: 16, color: Colors.grey[500]),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: TextField(
                          controller: _customSportController,
                          decoration: InputDecoration(
                            hintText: "Add sport...",
                            border: InputBorder.none,
                            hintStyle: const TextStyle(fontSize: 12),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                            isDense: true,
                          ),
                          onSubmitted: (_) => _addCustomSport(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 60,
              child: ElevatedButton(
                onPressed: _addCustomSport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text("Add"),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAmenitiesGridCompact() {
    List<String> displayedAmenities = showAllAmenities
        ? availableAmenities
        : availableAmenities.take(6).toList();

    return Column(
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: displayedAmenities.map((amenity) {
            final isSelected = selectedAmenities.contains(amenity);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    selectedAmenities.remove(amenity);
                  } else {
                    selectedAmenities.add(amenity);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.orange[400] : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? Colors.orange[400]! : Colors.grey[300]!,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isSelected ? 0.1 : 0.03),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  amenity.length > 12
                      ? '${amenity.substring(0, 10)}...'
                      : amenity,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.grey[700],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (!showAllAmenities && availableAmenities.length > 6) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                showAllAmenities = true;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.expand_more, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    "Show More (${availableAmenities.length - 6})",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    Icon(
                      Icons.add_circle_outline,
                      size: 16,
                      color: Colors.grey[500],
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: TextField(
                          controller: _customAmenityController,
                          decoration: InputDecoration(
                            hintText: "Add amenity...",
                            border: InputBorder.none,
                            hintStyle: const TextStyle(fontSize: 12),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                            isDense: true,
                          ),
                          onSubmitted: (_) => _addCustomAmenity(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 60,
              child: ElevatedButton(
                onPressed: _addCustomAmenity,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text("Add"),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTermItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, size: 14, color: Colors.green[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}

// Loading Dialog
class ProcessingDialog extends StatelessWidget {
  const ProcessingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  const Color(0xFF00C853),
                ),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Processing Application",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Please wait...",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

// Review Dialog
class ReviewDialog extends StatelessWidget {
  final VoidCallback onClose;

  const ReviewDialog({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF00C853).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline,
                size: 40,
                color: Color(0xFF00C853),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Application Submitted!",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green[100]!),
              ),
              child: Column(
                children: [
                  Text(
                    "✓ Successfully Submitted",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.green[800],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Our team will review within 48 hours",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.green[700]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "You'll receive email updates on approval status",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onClose,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C853),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "Done",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
