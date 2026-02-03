// admin_screen.dart - FINAL POLISHED VERSION
import 'package:flutter/material.dart';
import 'package:turfzone/features/home/user_home_screen.dart';
import 'package:turfzone/features/editslottime/edit_turf_screen.dart';
import 'package:turfzone/my_bookings_screen.dart';
import 'package:turfzone/features/turfslot/slot_management_screen.dart';
import 'package:turfzone/features/Gallery/gallery_screen.dart';
import 'package:turfzone/features/partner/join_partner_screen.dart';

// Turf model for admin
class AdminTurf {
  final String id;
  final String name;
  final String location;
  final double distance;
  final int price;
  final double rating;
  final List<String> images;
  final List<String> amenities;
  final String mapLink;
  final String address;
  final String description;
  final int todayBookings;
  final double todayRevenue;
  final int availableSlots;
  bool isActive;

  AdminTurf({
    required this.id,
    required this.name,
    required this.location,
    required this.distance,
    required this.price,
    required this.rating,
    required this.images,
    required this.amenities,
    required this.mapLink,
    required this.address,
    required this.description,
    required this.todayBookings,
    required this.todayRevenue,
    required this.availableSlots,
    this.isActive = true,
  });
}

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _selectedNavIndex = 0;

  // Admin turfs data - Using high-quality actual turf images
  List<AdminTurf> adminTurfs = [
    AdminTurf(
      id: '1',
      name: "Green Field Arena",
      location: "PN Pudur",
      distance: 2.5,
      price: 500,
      rating: 4.8,
      images: [
        "https://images.unsplash.com/photo-1575361204480-aadea25e6e68?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1770&q=80",
      ],
      amenities: ["Lights", "Parking", "Water"],
      mapLink: "https://maps.app.goo.gl/xyz123",
      address: "123 Sports Complex, PN Pudur, Coimbatore",
      description: "Premium turf with professional-grade facilities",
      todayBookings: 12,
      todayRevenue: 9588,
      availableSlots: 8,
    ),
    AdminTurf(
      id: '2',
      name: "City Sports Turf",
      location: "Gandhipuram",
      distance: 4.2,
      price: 650,
      rating: 4.5,
      images: [
        "https://images.unsplash.com/photo-1546519638-68e109498ffc?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1770&q=80",
      ],
      amenities: ["Cafeteria", "Parking"],
      mapLink: "https://maps.app.goo.gl/abc456",
      address: "45 Main Road, Gandhipuram, Coimbatore",
      description: "City center turf with excellent amenities",
      todayBookings: 8,
      todayRevenue: 5200,
      availableSlots: 12,
    ),
    AdminTurf(
      id: '3',
      name: "Elite Football Ground",
      location: "Race Course",
      distance: 3.1,
      price: 800,
      rating: 4.9,
      images: [
        "https://images.unsplash.com/photo-1511886929837-354d827aae26?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1770&q=80",
      ],
      amenities: ["Flood Lights", "Gym", "Parking", "WiFi", "Showers"],
      mapLink: "https://maps.app.goo.gl/def789",
      address: "Race Course Road, Coimbatore",
      description: "Professional football ground with international standards",
      todayBookings: 15,
      todayRevenue: 12000,
      availableSlots: 5,
    ),
    AdminTurf(
      id: '4',
      name: "Sports Hub Arena",
      location: "Peelamedu",
      distance: 5.3,
      price: 700,
      rating: 4.6,
      images: [
        "https://images.unsplash.com/photo-1531315630201-bb15abeb1653?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1770&q=80",
      ],
      amenities: ["CCTV", "Changing Rooms", "Parking"],
      mapLink: "https://maps.app.goo.gl/ghi789",
      address: "Tech Park Road, Peelamedu, Coimbatore",
      description: "Modern sports facility with advanced amenities",
      todayBookings: 10,
      todayRevenue: 7000,
      availableSlots: 10,
    ),
  ];

  // Business Stats Summary
  double get totalRevenue {
    return adminTurfs.fold(0, (sum, turf) => sum + turf.todayRevenue);
  }

  int get totalBookings {
    return adminTurfs.fold(0, (sum, turf) => sum + turf.todayBookings);
  }

  int get totalAvailableSlots {
    return adminTurfs.fold(0, (sum, turf) => sum + turf.availableSlots);
  }

  double get averageRating {
    if (adminTurfs.isEmpty) return 0;
    return adminTurfs.map((t) => t.rating).reduce((a, b) => a + b) /
        adminTurfs.length;
  }

  // Bottom Navigation Screens
  final List<Widget> _navScreens = [
    Container(), // Placeholder for Dashboard
    Container(), // Placeholder for Reports
    GalleryScreen(),
  ];

  void _toggleTurfStatus(String turfId) {
    setState(() {
      final turf = adminTurfs.firstWhere((t) => t.id == turfId);
      turf.isActive = !turf.isActive;
    });
  }

  void _deleteTurf(String turfId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Turf"),
        content: const Text(
          "Are you sure you want to delete this turf? This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                adminTurfs.removeWhere((t) => t.id == turfId);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Turf deleted successfully"),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _selectedNavIndex == 0
                  ? 'Turf Management Dashboard'
                  : _selectedNavIndex == 1
                  ? 'Reports & Analytics'
                  : 'Gallery',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _selectedNavIndex == 0
                  ? 'Premium Admin Panel • Manage all your turfs'
                  : _selectedNavIndex == 1
                  ? 'View and download reports'
                  : 'Manage turf photos',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF00C853),
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          // Simple + icon for adding new turf
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.add, size: 22),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => JoinPartnerScreen()),
                );
              },
            ),
          ),
        ],
      ),
      body: _buildCurrentScreen(),
      // Remove FAB and replace with top-right icon in app bar
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildCurrentScreen() {
    if (_selectedNavIndex == 0) {
      return _buildDashboard();
    } else if (_selectedNavIndex == 1) {
      return _buildReportsScreen();
    } else {
      return _navScreens[_selectedNavIndex];
    }
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // QUICK INSIGHTS
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Welcome Header
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00C853).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.business,
                        color: Color(0xFF00C853),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Welcome back, Admin!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Managing ${adminTurfs.length} turfs • Today\'s Summary',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Quick Insights Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildInsightCard(
                      'Total Revenue',
                      '₹${totalRevenue.toStringAsFixed(0)}',
                      Icons.trending_up,
                      Colors.green,
                    ),
                    _buildInsightCard(
                      'Total Bookings',
                      '$totalBookings',
                      Icons.event_available,
                      Colors.blue,
                    ),
                    _buildInsightCard(
                      'Avg Rating',
                      '${averageRating.toStringAsFixed(1)}★',
                      Icons.star,
                      Colors.amber,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // TURF MANAGEMENT SECTION
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.stadium,
                        size: 20,
                        color: Color(0xFF00C853),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Your Turfs',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${adminTurfs.where((t) => t.isActive).length} Active',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Turf Cards List
                  Column(
                    children: adminTurfs
                        .map((turf) => _buildTurfCard(turf))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),

          // Add bottom padding for better scrolling
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildTurfCard(AdminTurf turf) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Turf Image and Basic Info
          Stack(
            children: [
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(turf.images[0]),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.5), // Darker at top
                        Colors.black.withOpacity(0.3),
                        Colors.transparent,
                        Colors.black.withOpacity(0.6), // Much darker at bottom
                      ],
                    ),
                  ),
                ),
              ),

              // Status Badge
              Positioned(
                top: 14,
                right: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: turf.isActive ? Colors.green : Colors.grey[700],
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    turf.isActive ? 'ACTIVE' : 'INACTIVE',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              // Quick Action Icons - IMPROVED: Smaller and more subtle
              Positioned(
                top: 14,
                left: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Delete Button
                      _buildQuickActionButton(
                        icon: Icons.delete_outline,
                        color: Colors.red[700]!,
                        onTap: () => _deleteTurf(turf.id),
                      ),
                      const SizedBox(width: 6), // Reduced spacing
                      // View Details Button
                      _buildQuickActionButton(
                        icon: Icons.visibility_outlined,
                        color: Colors.blue[700]!,
                        onTap: () {
                          _showTurfDetails(turf);
                        },
                      ),
                      const SizedBox(width: 6), // Reduced spacing
                      // Toggle Status Button
                      _buildQuickActionButton(
                        icon: turf.isActive
                            ? Icons.toggle_on_rounded
                            : Icons.toggle_off_rounded,
                        color: turf.isActive
                            ? Colors.green[700]!
                            : Colors.grey[700]!,
                        onTap: () => _toggleTurfStatus(turf.id),
                      ),
                    ],
                  ),
                ),
              ),

              // Turf Name Overlay - IMPROVED: Better readability
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      turf.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black87,
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                          Shadow(color: Colors.black54, blurRadius: 20),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 15,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            turf.location,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.9),
                              shadows: const [
                                Shadow(
                                  color: Colors.black87,
                                  blurRadius: 6,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Turf Details
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Price and Rating Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Price per hour',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₹${turf.price}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF00C853),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Rating',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 18,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              turf.rating.toString(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Turf Stats
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildTurfStat(
                        label: 'Bookings',
                        value: '${turf.todayBookings}',
                        icon: Icons.event,
                        color: Colors.blue[700]!,
                      ),
                      Container(height: 35, width: 1, color: Colors.grey[300]),
                      _buildTurfStat(
                        label: 'Revenue',
                        value: '₹${turf.todayRevenue}',
                        icon: Icons.currency_rupee,
                        color: Colors.green[700]!,
                      ),
                      Container(height: 35, width: 1, color: Colors.grey[300]),
                      _buildTurfStat(
                        label: 'Available',
                        value: '${turf.availableSlots}',
                        icon: Icons.schedule,
                        color: Colors.orange[700]!,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Action Buttons
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey[200]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      SlotManagementScreen(turf: turf),
                                ),
                              );
                            },
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(14),
                              bottomLeft: Radius.circular(14),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                border: Border(
                                  right: BorderSide(color: Colors.grey[200]!),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.schedule,
                                    size: 24,
                                    color: Colors.blue[700],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Manage\nSlots',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue[700],
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditTurfScreen(),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                border: Border(
                                  right: BorderSide(color: Colors.grey[200]!),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.edit,
                                    size: 24,
                                    color: Colors.orange[700],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Edit\nTurf',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.orange[700],
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MyBookingsScreen(),
                                ),
                              );
                            },
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(14),
                              bottomRight: Radius.circular(14),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.receipt_long,
                                    size: 24,
                                    color: const Color(0xFF00C853),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'View\nBookings',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF00C853),
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10), // Smaller border radius
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 32, // Smaller width
          height: 32, // Smaller height
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06), // Lighter shadow
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Icon(icon, size: 18, color: color), // Smaller icon
        ),
      ),
    );
  }

  Widget _buildTurfStat({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildInsightCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 30, color: color),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedNavIndex,
          onTap: (index) {
            setState(() {
              _selectedNavIndex = index;
            });
          },
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF00C853),
          unselectedItemColor: Colors.grey[600],
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            height: 1.2,
            color: Colors.grey[600],
          ),
          selectedIconTheme: const IconThemeData(size: 28),
          unselectedIconTheme: IconThemeData(size: 24, color: Colors.grey[700]),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _selectedNavIndex == 0
                      ? const Color(0xFF00C853).withOpacity(0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.dashboard_rounded,
                  size: _selectedNavIndex == 0 ? 26 : 24,
                ),
              ),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _selectedNavIndex == 1
                      ? const Color(0xFF00C853).withOpacity(0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.bar_chart_rounded,
                  size: _selectedNavIndex == 1 ? 26 : 24,
                ),
              ),
              label: 'Reports',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _selectedNavIndex == 2
                      ? const Color(0xFF00C853).withOpacity(0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.photo_library_rounded,
                  size: _selectedNavIndex == 2 ? 26 : 24,
                ),
              ),
              label: 'Gallery',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsScreen() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reports Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.bar_chart, size: 28, color: Color(0xFF00C853)),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reports & Analytics',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Detailed insights and performance metrics',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.download), onPressed: () {}),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Report Cards
          Expanded(
            child: GridView(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              children: [
                _buildReportCard(
                  'Revenue Report',
                  Icons.trending_up,
                  Colors.green,
                  'Monthly revenue breakdown',
                ),
                _buildReportCard(
                  'Booking Analytics',
                  Icons.calendar_today,
                  Colors.blue,
                  'Booking patterns & trends',
                ),
                _buildReportCard(
                  'Turf Performance',
                  Icons.leaderboard,
                  Colors.orange,
                  'Individual turf performance',
                ),
                _buildReportCard(
                  'Customer Insights',
                  Icons.people,
                  Colors.purple,
                  'Customer behavior & feedback',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(
    String title,
    IconData icon,
    Color color,
    String description,
  ) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          // Navigate to detailed report
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'View',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward, size: 16, color: color),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTurfDetails(AdminTurf turf) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.info_outline, color: Color(0xFF00C853)),
            const SizedBox(width: 8),
            Text(
              'Turf Details',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  turf.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  turf.description,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Amenities:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Wrap(
                  spacing: 8,
                  children: turf.amenities
                      .map(
                        (amenity) => Chip(
                          label: Text(amenity),
                          backgroundColor: Colors.grey[100],
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
