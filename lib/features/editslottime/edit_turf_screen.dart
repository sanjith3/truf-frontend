// edit_turf_screen.dart
import 'package:flutter/material.dart';

class EditTurfScreen extends StatefulWidget {
  const EditTurfScreen({super.key});

  @override
  State<EditTurfScreen> createState() => _EditTurfScreenState();
}

class _EditTurfScreenState extends State<EditTurfScreen> {
  // Sports Selection
  List<bool> selectedSports = [true, true, false, false, false];
  List<String> sports = [
    'Football',
    'Cricket',
    'Badminton',
    'Tennis',
    'Basketball',
  ];

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

  // Operating Hours
  String selectedCity = 'Coimbatore';
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
  ];

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
              onPressed: () {
                _saveChanges();
              },
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
                _buildDropdownField(
                  label: 'City',
                  value: selectedCity,
                  items: [
                    'Coimbatore',
                    'Chennai',
                    'Bangalore',
                    'Hyderabad',
                    'Mumbai',
                    'Delhi',
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedCity = value!;
                    });
                  },
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
                    style: TextStyle(fontSize: 15),
                    decoration: InputDecoration(
                      hintText: 'Enter detailed description...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
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

            // Features & Sports Card
            _buildSectionCard(
              title: 'Features & Sports',
              icon: Icons.sports,
              children: [
                Text(
                  'Available Sports',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: sports.asMap().entries.map((entry) {
                    return ChoiceChip(
                      label: Text(entry.value),
                      selected: selectedSports[entry.key],
                      onSelected: (selected) {
                        setState(() {
                          selectedSports[entry.key] = selected;
                        });
                      },
                      selectedColor: Color(0xFF00C853),
                      backgroundColor: Colors.grey[100],
                      labelStyle: TextStyle(
                        color: selectedSports[entry.key]
                            ? Colors.white
                            : Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 24),
                Text(
                  'Amenities',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'e.g. Floodlights, Parking, Water',
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
                    controller: amenitiesController,
                    maxLines: 3,
                    style: TextStyle(fontSize: 15),
                    decoration: InputDecoration(
                      hintText:
                          'Comma separated (e.g. WiFi, Locker, Floodlight)',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
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
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[100]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: Colors.blue[700],
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Current Hours: $selectedOpenTime to $selectedCloseTime',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue[800],
                            fontWeight: FontWeight.w500,
                          ),
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
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
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

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _saveChanges,
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
                    Icon(Icons.save, size: 20),
                    SizedBox(width: 12),
                    Text(
                      'Save All Changes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
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
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
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
                    style: TextStyle(fontSize: 15),
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
    required String value,
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
                        child: Text(item),
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
      padding: EdgeInsets.all(16),
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
              SizedBox(width: 8),
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
          SizedBox(height: 12),
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
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.blue[600]),
          SizedBox(width: 12),
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
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
        ),

        // Cover Image Badge
        if (selectedCoverIndex == index)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Cover',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

        // Default Image Badge
        if (index == 0)
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedCoverIndex = 0;
                });
              },
              child: Container(
                padding: EdgeInsets.all(6),
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
                  selectedCoverIndex == 0 ? Icons.star : Icons.star_border,
                  size: 16,
                  color: selectedCoverIndex == 0 ? Colors.amber : Colors.grey,
                ),
              ),
            ),
          ),

        // Delete Button
        Positioned(
          bottom: 8,
          right: 8,
          child: GestureDetector(
            onTap: () => _deletePhoto(index),
            child: Container(
              padding: EdgeInsets.all(6),
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
              child: Icon(Icons.delete, size: 16, color: Colors.red),
            ),
          ),
        ),

        // Set as Cover Button (for non-default images)
        if (index > 0 && selectedCoverIndex != index)
          Positioned(
            bottom: 8,
            left: 8,
            child: GestureDetector(
              onTap: () => _setAsCover(index),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, size: 12, color: Colors.amber),
                    SizedBox(width: 4),
                    Text(
                      'Set Cover',
                      style: TextStyle(
                        fontSize: 10,
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
              'Saving Changes...',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );

    // Simulate API call
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Turf details updated successfully'),
          backgroundColor: Color(0xFF00C853),
          duration: Duration(seconds: 3),
        ),
      );
      Navigator.pop(context); // Go back
    });
  }
}
