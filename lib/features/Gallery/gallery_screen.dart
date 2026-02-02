// gallery_screen.dart
import 'package:flutter/material.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<String> galleryImages = [
    'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?q=80&w=2070',
    'https://images.unsplash.com/photo-1575361204480-aadea25e6e68?q=80&w=2071',
    'https://images.unsplash.com/photo-1461896836934-ffe607ba8211?q=80&w=2070',
    'https://images.unsplash.com/photo-1543353074-8b2f3a5d2e4e?q=80&w=2070',
    'https://images.unsplash.com/photo-1517649763962-0c623066013b?q=80&w=2070',
    'https://images.unsplash.com/photo-1519331379826-f10be5486c6f?q=80&w=2070',
  ];
  int selectedCoverIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Manage Gallery',
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
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Upload Section
            Container(
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
                        child: Icon(
                          Icons.photo_library,
                          size: 24,
                          color: Color(0xFF00C853),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Upload Gallery',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'High-quality photos significantly increase your booking rate',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 20),

                  // Upload Area
                  GestureDetector(
                    onTap: () {
                      // Handle image pick
                    },
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
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
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Color(0xFF00C853).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.cloud_upload,
                              size: 40,
                              color: Color(0xFF00C853),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Click to Upload Photos',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Add photos of your turf',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: Icon(Icons.add_photo_alternate, size: 18),
                            label: Text('Select Image'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF00C853),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Set as Cover Image Option
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[100]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.star, size: 20, color: Colors.blue[700]),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cover Image',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue[700],
                                ),
                              ),
                              Text(
                                'Set the first photo as your turf\'s cover image',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: selectedCoverIndex == 0,
                          onChanged: (value) {
                            setState(() {
                              selectedCoverIndex = value ? 0 : -1;
                            });
                          },
                          activeColor: Colors.blue[700],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Image uploaded successfully'),
                            backgroundColor: Color(0xFF00C853),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF00C853),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_upload, size: 20),
                          SizedBox(width: 12),
                          Text(
                            'Upload Image',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Gallery Grid
            Text(
              'Gallery (${galleryImages.length} photos)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
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
              itemCount: galleryImages.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCoverIndex = index;
                    });
                  },
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: NetworkImage(galleryImages[index]),
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
                      if (selectedCoverIndex == index)
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.blue.withOpacity(0.3),
                            border: Border.all(color: Colors.blue, width: 3),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.star,
                              size: 32,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Delete Photo'),
                                content: Text(
                                  'Are you sure you want to delete this photo?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        galleryImages.removeAt(index);
                                      });
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text('Photo deleted'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child: Text('Delete'),
                                  ),
                                ],
                              ),
                            );
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
                              Icons.delete,
                              size: 16,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                      if (index == 0)
                        Positioned(
                          bottom: 8,
                          left: 8,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.8),
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
                    ],
                  ),
                );
              },
            ),

            SizedBox(height: 40),

            // Footer
            Container(
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
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.sports, size: 24, color: Color(0xFF00C853)),
                      SizedBox(width: 8),
                      Text(
                        'TurfSpot',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF00C853),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Premium Sports Booking Platform for T.N & Kerala.',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Divider(),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '© 2026 TurfSpot Logic Systems. All rights reserved.',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              'Privacy Policy',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            height: 12,
                            width: 1,
                            color: Colors.grey[300],
                          ),
                          SizedBox(width: 8),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              'Terms of Service',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
