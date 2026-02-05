// edit_turf_screen.dart
import 'package:flutter/material.dart';

class EditTurfScreen extends StatefulWidget {
  const EditTurfScreen({super.key});

  @override
  State<EditTurfScreen> createState() => _EditTurfScreenState();
}

class _EditTurfScreenState extends State<EditTurfScreen> {
  // Sports Selection
  Map<String, bool> selectedSports = {
    'Football': true,
    'Cricket': true,
    'Badminton': false,
    'Tennis': false,
    'Basketball': false,
    'Volleyball': false,
    'Hockey': false,
    'Rugby': false,
    'Baseball': false,
    'Handball': false,
    'Table Tennis': false,
    'Squash': false,
    'Netball': false,
    'Futsal': false,
  };
  bool showAllSports = false;

  // Controllers
  TextEditingController amenitiesController = TextEditingController(
    text: 'Floodlights, Parking, Water, WiFi, Changing Rooms',
  );
  TextEditingController nameController = TextEditingController(text: 'final');
  TextEditingController priceController = TextEditingController(text: '799.00');
  TextEditingController descriptionController = TextEditingController(
    text:
        'Premium turf facility with world-class amenities. Perfect for football and cricket matches. Floodlights available for night games.',
  );
  TextEditingController phoneController = TextEditingController(
    text: '8856142056',
  );
  TextEditingController emailController = TextEditingController(
    text: 'contact@finalturf.com',
  );
  TextEditingController mapLinkController = TextEditingController(
    text: 'https://maps.google.com/?q=final+turf+coimbatore',
  );
  TextEditingController operatingHoursController = TextEditingController(
    text: '6:00 AM - 10:00 PM',
  );
  TextEditingController changeReasonController = TextEditingController();

  // Location Selection
  String? selectedState;
  String? selectedCity;
  List<String> cityList = [];

  // Operating Hours
  String selectedOpenTime = '06:00';
  String selectedCloseTime = '22:00';

  // Photos
  List<String> existingPhotos = [
    'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?q=80&w=2070',
    'https://images.unsplash.com/photo-1575361204480-aadea25e6e68?q=80&w=2071',
    'https://images.unsplash.com/photo-1461896836934-ffe607ba8211?q=80&w=2070',
    'https://images.unsplash.com/photo-1543353074-8b2f3a5d2e4e?q=80&w=2070',
    'https://images.unsplash.com/photo-1517649763962-0c623066013b?q=80&w=2070',
  ];
  int selectedCoverIndex = 0;

  // Time Lists
  final List<String> timeSlots = [
    '05:00',
    '06:00',
    '07:00',
    '08:00',
    '09:00',
    '10:00',
    '11:00',
    '12:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
    '17:00',
    '18:00',
    '19:00',
    '20:00',
    '21:00',
    '22:00',
    '23:00',
    '00:00',
  ];

  // Indian States and Major Cities
  final Map<String, List<String>> indianStatesCities = {
    'Tamil Nadu': [
      'Chennai',
      'Coimbatore',
      'Madurai',
      'Tiruchirappalli',
      'Salem',
      'Tiruppur',
      'Erode',
      'Vellore',
      'Thoothukudi',
      'Dindigul',
    ],
    'Karnataka': [
      'Bengaluru',
      'Mysuru',
      'Hubballi-Dharwad',
      'Mangaluru',
      'Belagavi',
      'Kalaburagi',
      'Davangere',
      'Ballari',
      'Shivamogga',
      'Tumakuru',
    ],
    'Maharashtra': [
      'Mumbai',
      'Pune',
      'Nagpur',
      'Nashik',
      'Aurangabad',
      'Solapur',
      'Amravati',
      'Kolhapur',
      'Navi Mumbai',
      'Thane',
    ],
    'Delhi': ['New Delhi', 'Delhi'],
    'Uttar Pradesh': [
      'Lucknow',
      'Kanpur',
      'Ghaziabad',
      'Agra',
      'Varanasi',
      'Prayagraj',
      'Meerut',
      'Bareilly',
      'Aligarh',
      'Moradabad',
    ],
    'Gujarat': [
      'Ahmedabad',
      'Surat',
      'Vadodara',
      'Rajkot',
      'Bhavnagar',
      'Jamnagar',
      'Junagadh',
      'Gandhinagar',
      'Anand',
      'Navsari',
    ],
    'Rajasthan': [
      'Jaipur',
      'Jodhpur',
      'Udaipur',
      'Kota',
      'Bikaner',
      'Ajmer',
      'Bhilwara',
      'Alwar',
      'Bharatpur',
      'Sikar',
    ],
    'West Bengal': [
      'Kolkata',
      'Asansol',
      'Siliguri',
      'Durgapur',
      'Bardhaman',
      'Malda',
      'Baharampur',
      'Habra',
      'Kharagpur',
      'Shantipur',
    ],
    'Telangana': [
      'Hyderabad',
      'Warangal',
      'Nizamabad',
      'Khammam',
      'Karimnagar',
      'Ramagundam',
      'Mahabubnagar',
      'Adilabad',
      'Suryapet',
      'Miryalaguda',
    ],
    'Andhra Pradesh': [
      'Visakhapatnam',
      'Vijayawada',
      'Guntur',
      'Nellore',
      'Kurnool',
      'Rajahmundry',
      'Tirupati',
      'Kakinada',
      'Kadapa',
      'Anantapur',
    ],
    'Kerala': [
      'Thiruvananthapuram',
      'Kochi',
      'Kozhikode',
      'Kollam',
      'Thrissur',
      'Kannur',
      'Alappuzha',
      'Kottayam',
      'Palakkad',
      'Manjeri',
    ],
    'Punjab': [
      'Ludhiana',
      'Amritsar',
      'Jalandhar',
      'Patiala',
      'Bathinda',
      'Hoshiarpur',
      'Mohali',
      'Batala',
      'Pathankot',
      'Moga',
    ],
    'Haryana': [
      'Faridabad',
      'Gurugram',
      'Panipat',
      'Ambala',
      'Yamunanagar',
      'Rohtak',
      'Hisar',
      'Karnal',
      'Sonipat',
      'Panchkula',
    ],
  };

  // Common amenities
  final List<String> commonAmenities = [
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

  @override
  void initState() {
    super.initState();
    // Set initial state to Tamil Nadu
    selectedState = 'Tamil Nadu';
    updateCityList();
    selectedCity = 'Coimbatore';
  }

  void updateCityList() {
    setState(() {
      cityList = indianStatesCities[selectedState] ?? [];
      selectedCity = cityList.isNotEmpty ? cityList[0] : null;
    });
  }

  void _addCustomSport() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController customSportController = TextEditingController();
        return AlertDialog(
          title: Text('Add Custom Sport'),
          content: TextField(
            controller: customSportController,
            decoration: InputDecoration(
              hintText: 'Enter sport name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (customSportController.text.isNotEmpty) {
                  setState(() {
                    selectedSports[customSportController.text] = false;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Sport added successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _addCustomAmenity() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController customAmenityController = TextEditingController();
        return AlertDialog(
          title: Text('Add Custom Amenity'),
          content: TextField(
            controller: customAmenityController,
            decoration: InputDecoration(
              hintText: 'Enter amenity name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (customAmenityController.text.isNotEmpty) {
                  setState(() {
                    final currentText = amenitiesController.text;
                    amenitiesController.text = currentText.isEmpty
                        ? customAmenityController.text
                        : '$currentText, ${customAmenityController.text}';
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Amenity added successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showSubmitDialog() {
    // Collect changed data
    final changes = <String, String>{};
    if (nameController.text != 'final') changes['name'] = nameController.text;
    if (priceController.text != '799.00')
      changes['price'] = priceController.text;
    if (selectedState != 'Tamil Nadu' || selectedCity != 'Coimbatore') {
      changes['location'] = '$selectedCity, $selectedState';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.verified_user, color: Colors.blue),
            SizedBox(width: 10),
            Flexible(
              child: Text(
                'Submit Changes for Review',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your changes will be reviewed by our team before they go live.',
                style: TextStyle(color: Colors.grey[600]),
              ),
              SizedBox(height: 20),
              Text(
                'Changes Summary:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              ...changes.entries.map(
                (entry) => Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Text(
                    '• ${entry.key}: ${entry.value}',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: changeReasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Reason for changes (optional)',
                  border: OutlineInputBorder(),
                  hintText: 'Why are you making these changes?',
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Note: This helps our team verify the changes faster',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _saveChanges,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: Text('Submit for Review'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Edit Turf Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF00C853),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: _showSubmitDialog,
              icon: Icon(Icons.save, size: 18),
              label: Text('Save'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.white.withOpacity(0.3)),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Basic Information Card
            _buildSectionCard(
              title: 'Basic Information',
              icon: Icons.edit,
              children: [
                _buildTextFieldWithIcon(
                  label: 'Turf Name',
                  hintText: 'Enter turf name',
                  controller: nameController,
                  icon: Icons.grass,
                ),
                SizedBox(height: 16),
                _buildTextFieldWithIcon(
                  label: 'Price Per Hour (₹)',
                  hintText: 'Enter price per hour',
                  controller: priceController,
                  icon: Icons.currency_rupee,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdownField(
                        label: 'State',
                        value: selectedState,
                        items: indianStatesCities.keys.toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedState = value!;
                            updateCityList();
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildDropdownField(
                        label: 'City',
                        value: selectedCity,
                        items: cityList,
                        onChanged: (value) {
                          setState(() {
                            selectedCity = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 20),

            // Contact Information Card
            _buildSectionCard(
              title: 'Contact Information',
              icon: Icons.contact_phone,
              children: [
                _buildTextFieldWithIcon(
                  label: 'Phone Number',
                  hintText: 'Enter phone number',
                  controller: phoneController,
                  icon: Icons.phone,
                  enabled: false, // Phone cannot be edited
                  prefixText: '+91 ',
                ),
                SizedBox(height: 16),
                _buildTextFieldWithIcon(
                  label: 'Email Address',
                  hintText: 'Enter email address',
                  controller: emailController,
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ),

            SizedBox(height: 20),

            // Description Card
            _buildSectionCard(
              title: 'Turf Description',
              icon: Icons.description,
              children: [
                Text(
                  'Describe your turf facilities, amenities, and special features',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                    color: Colors.white,
                  ),
                  child: TextField(
                    controller: descriptionController,
                    maxLines: 5,
                    minLines: 3,
                    style: TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Enter detailed description...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                      hintStyle: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Tip: Include details about facilities, capacity, equipment, and amenities',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),

            SizedBox(height: 20),

            // Features & Sports Card - FIXED VERSION
            _buildSectionCard(
              title: 'Features & Sports',
              icon: Icons.sports,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Available Sports',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                    Flexible(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Flexible(
                            child: TextButton.icon(
                              onPressed: _addCustomSport,
                              icon: Icon(Icons.add, size: 16),
                              label: Flexible(
                                child: Text(
                                  'Add Custom',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor: Color(0xFF00C853),
                                minimumSize: Size.zero,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 4,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 4),
                          Flexible(
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  showAllSports = !showAllSports;
                                });
                              },
                              child: Text(
                                showAllSports ? 'Show Less' : 'Show More',
                                style: TextStyle(
                                  color: Color(0xFF00C853),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: selectedSports.keys
                          .toList()
                          .sublist(0, showAllSports ? selectedSports.length : 5)
                          .asMap()
                          .entries
                          .map((entry) {
                            return ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: constraints.maxWidth * 0.45,
                              ),
                              child: ChoiceChip(
                                label: Text(
                                  entry.value,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(fontSize: 13),
                                ),
                                selected: selectedSports[entry.value] ?? false,
                                onSelected: (selected) {
                                  setState(() {
                                    selectedSports[entry.value] = selected;
                                  });
                                },
                                selectedColor: Color(0xFF00C853),
                                backgroundColor: Colors.grey[100],
                                labelStyle: TextStyle(
                                  color: (selectedSports[entry.value] ?? false)
                                      ? Colors.white
                                      : Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                            );
                          })
                          .toList(),
                    );
                  },
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Amenities',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                    Flexible(
                      child: TextButton.icon(
                        onPressed: _addCustomAmenity,
                        icon: Icon(Icons.add, size: 16),
                        label: Flexible(
                          child: Text(
                            'Add Custom',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: Color(0xFF00C853),
                          minimumSize: Size.zero,
                          padding: EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 4,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: commonAmenities.take(10).map((amenity) {
                        return ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: constraints.maxWidth * 0.45,
                          ),
                          child: FilterChip(
                            label: Text(
                              amenity,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(fontSize: 13),
                            ),
                            selected: amenitiesController.text
                                .toLowerCase()
                                .contains(amenity.toLowerCase()),
                            onSelected: (selected) {
                              setState(() {
                                final currentText = amenitiesController.text;
                                if (selected) {
                                  amenitiesController.text = currentText.isEmpty
                                      ? amenity
                                      : '$currentText, $amenity';
                                } else {
                                  amenitiesController.text = currentText
                                      .replaceAll('$amenity, ', '')
                                      .replaceAll(', $amenity', '')
                                      .replaceAll(amenity, '')
                                      .replaceAll(' ,', ',')
                                      .trim();
                                }
                              });
                            },
                            selectedColor: Color(0xFF00C853).withOpacity(0.2),
                            checkmarkColor: Color(0xFF00C853),
                            backgroundColor: Colors.grey[100],
                            labelStyle: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                SizedBox(height: 12),
                Text(
                  'Selected:',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                    color: Colors.white,
                  ),
                  child: TextField(
                    controller: amenitiesController,
                    maxLines: 3,
                    minLines: 2,
                    style: TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Comma separated amenities...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                      hintStyle: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            // Location Details Card
            _buildSectionCard(
              title: 'Location Details',
              icon: Icons.location_on,
              children: [
                _buildTextFieldWithIcon(
                  label: 'Google Maps Link',
                  hintText: 'Paste Google Maps share link',
                  controller: mapLinkController,
                  icon: Icons.map,
                ),
                SizedBox(height: 12),
                _buildMapsHelpCard(),
              ],
            ),

            SizedBox(height: 20),

            // Operating Hours Card
            _buildSectionCard(
              title: 'Operating Hours',
              icon: Icons.access_time,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildTimeDropdown(
                        label: 'Open Time',
                        value: selectedOpenTime,
                        onChanged: (value) {
                          setState(() {
                            selectedOpenTime = value!;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildTimeDropdown(
                        label: 'Close Time',
                        value: selectedCloseTime,
                        onChanged: (value) {
                          setState(() {
                            selectedCloseTime = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[100]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 18,
                        color: Colors.blue[700],
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Current Hours: $selectedOpenTime to $selectedCloseTime',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue[800],
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            // Photos Gallery Card
            _buildSectionCard(
              title: 'Turf Photos',
              icon: Icons.photo_library,
              children: [
                Text(
                  'Upload at least 5 high-quality photos of your turf',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                SizedBox(height: 16),

                // Upload Button
                GestureDetector(
                  onTap: _addPhoto,
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Color(0xFF00C853),
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                      color: Color(0xFF00C853).withOpacity(0.03),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate,
                          size: 40,
                          color: Color(0xFF00C853),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Add More Photos',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF00C853),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // Existing Photos Grid
                Text(
                  'Existing Photos (${existingPhotos.length})',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: existingPhotos.length,
                  itemBuilder: (context, index) {
                    return _buildPhotoItem(index);
                  },
                ),
                SizedBox(height: 8),
                if (existingPhotos.length < 5)
                  Text(
                    'Add ${5 - existingPhotos.length} more photos (minimum 5 required)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),

            SizedBox(height: 20),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _showSubmitDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF00C853),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                  shadowColor: Color(0xFF00C853).withOpacity(0.3),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.send, size: 20),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Submit for Review',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFF00C853).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 24, color: Color(0xFF00C853)),
              ),
              SizedBox(width: 12),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextFieldWithIcon({
    required String label,
    required String hintText,
    required TextEditingController controller,
    required IconData icon,
    bool enabled = true,
    String? prefixText,
    TextInputType keyboardType = TextInputType.text,
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
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
            color: enabled ? Colors.white : Colors.grey[100],
          ),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 16),
                child: Icon(icon, size: 20, color: Colors.grey[500]),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 12, right: 16),
                  child: TextField(
                    controller: controller,
                    enabled: enabled,
                    keyboardType: keyboardType,
                    style: TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: hintText,
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

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
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
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
            color: Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: Padding(
                padding: EdgeInsets.only(right: 16),
                child: Icon(Icons.arrow_drop_down, color: Colors.grey[500]),
              ),
              items: items
                  .map(
                    (item) => DropdownMenuItem<String>(
                      value: item,
                      child: Padding(
                        padding: EdgeInsets.only(left: 16),
                        child: Text(item, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeDropdown({
    required String label,
    required String value,
    required Function(String?) onChanged,
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
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
            color: Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: Padding(
                padding: EdgeInsets.only(right: 16),
                child: Icon(Icons.access_time, color: Colors.grey[500]),
              ),
              items: timeSlots
                  .map(
                    (time) => DropdownMenuItem<String>(
                      value: time,
                      child: Padding(
                        padding: EdgeInsets.only(left: 16),
                        child: Text(time),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMapsHelpCard() {
    return Container(
      padding: EdgeInsets.all(12),
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
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  "How to get Google Maps link",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[700],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
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
      padding: EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: Colors.blue[600]),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, color: Colors.blue[800]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoItem(int index) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: NetworkImage(existingPhotos[index]),
              fit: BoxFit.cover,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),

        // Cover Image Badge
        if (selectedCoverIndex == index)
          Positioned(
            top: 4,
            left: 4,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.9),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Cover',
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

        // Default Image Badge
        if (index == 0)
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedCoverIndex = 0;
                });
              },
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  selectedCoverIndex == 0 ? Icons.star : Icons.star_border,
                  size: 12,
                  color: selectedCoverIndex == 0 ? Colors.amber : Colors.grey,
                ),
              ),
            ),
          ),

        // Delete Button
        Positioned(
          bottom: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _deletePhoto(index),
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 2,
                  ),
                ],
              ),
              child: Icon(Icons.delete, size: 12, color: Colors.red),
            ),
          ),
        ),

        // Set as Cover Button (for non-default images)
        if (index > 0 && selectedCoverIndex != index)
          Positioned(
            bottom: 4,
            left: 4,
            child: GestureDetector(
              onTap: () => _setAsCover(index),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, size: 10, color: Colors.amber),
                    SizedBox(width: 2),
                    Text(
                      'Cover',
                      style: TextStyle(
                        fontSize: 8,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _addPhoto() {
    // In real app, this would open image picker
    // For demo, we'll add a dummy photo
    setState(() {
      existingPhotos.add(
        'https://images.unsplash.com/photo-1519331379826-f10be5486c6f?q=80&w=2070',
      );
    });
  }

  void _deletePhoto(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Photo'),
        content: Text('Are you sure you want to delete this photo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                existingPhotos.removeAt(index);
                if (selectedCoverIndex == index) {
                  selectedCoverIndex = 0;
                } else if (selectedCoverIndex > index) {
                  selectedCoverIndex--;
                }
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Photo deleted successfully'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _setAsCover(int index) {
    setState(() {
      selectedCoverIndex = index;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Photo set as cover image'),
        backgroundColor: Color(0xFF00C853),
      ),
    );
  }

  void _saveChanges() {
    // Validate minimum photos
    if (existingPhotos.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please add at least 5 photos'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Validate required fields
    if (nameController.text.isEmpty || priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show saving dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00C853)),
            ),
            SizedBox(height: 20),
            Text(
              'Submitting for Review...',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );

    // Simulate API call to submit for review
    // In real app, this would send data to backend with changeReasonController.text
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pop(context); // Close loading dialog

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Changes submitted for review. Our team will verify and update within 24 hours.',
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 4),
        ),
      );

      // Go back
      Navigator.pop(context);
    });
  }
}
