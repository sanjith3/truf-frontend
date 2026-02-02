import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:turfzone/booking/booking_screen.dart';
import 'package:turfzone/models/turf.dart';
import 'package:turfzone/features/profile/profile_screen.dart';
import 'package:turfzone/features/Admindashboard/admin_screen.dart';

import '../../turffdetail/turfdetails_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Turf> _filteredTurfs = [];

  // Filter variables
  RangeValues _priceRange = const RangeValues(0, 2000);
  double _maxPrice = 2000;
  final Map<String, bool> _timeFilters = {
    'Morning': false,
    'Afternoon': false,
    'Evening': false,
    'Night': false,
  };

  // Define turfs list as a class member
  final List<Turf> _turfs = [
    Turf(
      id: '1',
      name: "Green Field Arena",
      location: "PN Pudur",
      distance: 2.5,
      price: 500,
      rating: 4.8,
      images: [
        "https://images.unsplash.com/photo-1531315630201-bb15abeb1653?w=800",
      ],
      amenities: ["Lights", "Parking", "Water"],
      mapLink: "https://maps.app.goo.gl/xyz123",
      address: "123 Sports Complex, PN Pudur, Coimbatore",
      description: "Premium turf with professional-grade facilities",
    ),
    Turf(
      id: '2',
      name: "City Sports Turf",
      location: "Gandhipuram",
      distance: 4.2,
      price: 650,
      rating: 4.5,
      images: [
        "https://images.unsplash.com/photo-1546519638-68e109498ffc?w=800",
      ],
      amenities: ["Cafeteria", "Parking"],
      mapLink: "https://maps.app.goo.gl/abc456",
      address: "45 Main Road, Gandhipuram, Coimbatore",
      description: "City center turf with excellent amenities",
    ),
    Turf(
      id: '3',
      name: "Elite Football Ground",
      location: "Race Course",
      distance: 3.1,
      price: 800,
      rating: 4.9,
      images: [
        "https://images.unsplash.com/photo-1575361204480-aadea25e6e68?w=800",
      ],
      amenities: ["Flood Lights", "Gym", "Parking", "WiFi", "Showers"],
      mapLink: "https://maps.app.goo.gl/def789",
      address: "Race Course Road, Coimbatore",
      description: "Professional football ground with international standards",
    ),
    Turf(
      id: '4',
      name: "Victory Sports Park",
      location: "Peelamedu",
      distance: 5.7,
      price: 450,
      rating: 4.3,
      images: [
        "https://images.unsplash.com/photo-1599058917212-d750089bc07e?w=800",
      ],
      amenities: ["Flood Lights", "Parking", "Water"],
      mapLink: "https://maps.app.goo.gl/ghi012",
      address: "Peelamedu Industrial Estate, Coimbatore",
      description: "Affordable turf with great facilities",
    ),
    Turf(
      id: '5',
      name: "Premium Sports Arena",
      location: "Singanallur",
      distance: 6.2,
      price: 1200,
      rating: 4.7,
      images: [
        "https://images.unsplash.com/photo-1547347298-4074fc3086f0?w=800",
      ],
      amenities: ["Flood Lights", "Parking", "Water", "Showers", "Cafeteria"],
      mapLink: "https://maps.app.goo.gl/jkl345",
      address: "Singanallur Industrial Area, Coimbatore",
      description: "Luxury turf with premium facilities",
    ),
    Turf(
      id: '6',
      name: "Budget Sports Ground",
      location: "Sitra",
      distance: 7.1,
      price: 350,
      rating: 4.0,
      images: [
        "https://images.unsplash.com/photo-1560272564-c83b66b1ad12?w=800",
      ],
      amenities: ["Parking"],
      mapLink: "https://maps.app.goo.gl/mno678",
      address: "Sitra Main Road, Coimbatore",
      description: "Affordable ground for casual play",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _filteredTurfs = _turfs;
    _searchController.addListener(_searchTurfs);
    // Find max price from turfs
    _maxPrice = _turfs
        .map((t) => t.price.toDouble())
        .reduce((a, b) => a > b ? a : b);
    _priceRange = RangeValues(0, _maxPrice);
  }

  void _searchTurfs() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredTurfs = _turfs;
      } else {
        _filteredTurfs = _turfs
            .where(
              (turf) =>
                  turf.name.toLowerCase().contains(query) ||
                  turf.location.toLowerCase().contains(query),
            )
            .toList();
      }
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<Turf> filtered = _turfs;

    // Apply search filter if any
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered
          .where(
            (turf) =>
                turf.name.toLowerCase().contains(query) ||
                turf.location.toLowerCase().contains(query),
          )
          .toList();
    }

    // Apply price range filter
    filtered = filtered
        .where(
          (turf) =>
              turf.price >= _priceRange.start && turf.price <= _priceRange.end,
        )
        .toList();

    // Apply time filters if any selected
    final selectedTimes = _timeFilters.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
    if (selectedTimes.isNotEmpty) {
      filtered = filtered.where((turf) {
        if (selectedTimes.contains('Morning')) {
          return true;
        }
        if (selectedTimes.contains('Afternoon')) {
          return turf.price >= 400;
        }
        if (selectedTimes.contains('Evening')) {
          return turf.price >= 600;
        }
        if (selectedTimes.contains('Night')) {
          return turf.price >= 700 && turf.amenities.contains('Flood Lights');
        }
        return true;
      }).toList();
    }

    setState(() {
      _filteredTurfs = filtered;
    });

    // Show feedback snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Filters applied successfully',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        backgroundColor: const Color(0xFF1DB954),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _priceRange = RangeValues(0, _maxPrice);
      _timeFilters.forEach((key, value) {
        _timeFilters[key] = false;
      });
      _applyFilters();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.location_on, color: Colors.white),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Coimbatore, Tamil Nadu")),
                );
              },
            ),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Coimbatore",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "Tamil Nadu",
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Switch to Admin Button
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminScreen()),
                );
              },
              icon: const Icon(Icons.switch_account, size: 18, color: Colors.white),
              label: const Text(
                "Admin",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[700],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                elevation: 2,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
        backgroundColor: const Color(0xFF1DB954),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Welcome Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: const Color(0xFF1DB954),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.shade300.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Book Your Turf",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Play your favorite sport anytime, anywhere",
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
                const SizedBox(height: 15),

                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search turfs by name or location...",
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey.shade600,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Turf Count & Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Available Turfs (${_filteredTurfs.length})",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Row(
                  children: [
                    if (_isFilterActive())
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: TextButton(
                          onPressed: _resetFilters,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            backgroundColor: Colors.grey.shade100,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.clear,
                                size: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Clear",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    IconButton(
                      onPressed: () => _showFilterOptions(context),
                      icon: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: _isFilterActive()
                              ? Colors.orange.shade100
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _isFilterActive()
                                ? Colors.orange.shade300
                                : Colors.transparent,
                          ),
                        ),
                        child: Icon(
                          Icons.filter_list,
                          color: _isFilterActive()
                              ? Colors.orange.shade800
                              : const Color(0xFF1DB954),
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Turf List
          Expanded(
            child: _filteredTurfs.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 60, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          "No turfs found",
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        Text(
                          "Try adjusting your filters or search",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    itemCount: _filteredTurfs.length,
                    itemBuilder: (context, index) {
                      return TurfCard(turf: _filteredTurfs[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  bool _isFilterActive() {
    return _priceRange.start > 0 ||
        _priceRange.end < _maxPrice ||
        _timeFilters.values.any((value) => value);
  }

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Filter Turfs",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, size: 24),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Price Range Filter
                          _buildFilterSection(
                            title: "Price Range",
                            icon: Icons.attach_money,
                            child: Column(
                              children: [
                                // Selected Range Display
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF1DB954,
                                    ).withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.05,
                                              ),
                                              blurRadius: 4,
                                              offset: const Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          "₹${_priceRange.start.round()} - ₹${_priceRange.end.round()}",
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF1DB954),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        "selected",
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                RangeSlider(
                                  values: _priceRange,
                                  min: 0,
                                  max: _maxPrice,
                                  divisions: 20,
                                  labels: RangeLabels(
                                    "₹${_priceRange.start.round()}",
                                    "₹${_priceRange.end.round()}",
                                  ),
                                  activeColor: const Color(0xFF1DB954),
                                  inactiveColor: Colors.grey.shade300,
                                  onChanged: (RangeValues values) {
                                    setState(() {
                                      _priceRange = values;
                                    });
                                  },
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "₹0",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    Text(
                                      "₹${_maxPrice.toInt()}",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 25),

                          // Divider
                          const Divider(height: 1, color: Colors.grey),

                          const SizedBox(height: 25),

                          // Time Slot Availability Filter - IMPROVED UI
                          _buildFilterSection(
                            title: "Preferred Time Slots",
                            icon: Icons.access_time,
                            child: Column(
                              children: [
                                const SizedBox(height: 8),
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 12,
                                        mainAxisSpacing: 12,
                                        childAspectRatio: 3.5,
                                      ),
                                  itemCount: _timeFilters.length,
                                  itemBuilder: (context, index) {
                                    final entry = _timeFilters.entries
                                        .elementAt(index);
                                    final isSelected = entry.value;

                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _timeFilters[entry.key] = !isSelected;
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color:
                                              Colors.white, // Changed to white
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: isSelected
                                                ? const Color(0xFF1DB954)
                                                : Colors.grey.shade300,
                                            width: isSelected ? 2 : 1.5,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.05,
                                              ),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              _getTimeSlotIcon(entry.key),
                                              size: 18,
                                              color: isSelected
                                                  ? const Color(0xFF1DB954)
                                                  : Colors.grey.shade700,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                entry.key,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: isSelected
                                                      ? const Color(0xFF1DB954)
                                                      : Colors.grey.shade800,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (isSelected)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  right: 8.0,
                                                ),
                                                child: Icon(
                                                  Icons.check_circle,
                                                  size: 18,
                                                  color: const Color(
                                                    0xFF1DB954,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Select preferred playing times",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),

                  // Apply & Clear Buttons
                  Row(
                    children: [
                      // Clear All Button
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _resetFilters();
                            });
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          child: const Text(
                            "Clear All",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Apply Filters Button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _applyFilters();
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1DB954),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Apply Filters",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  IconData _getTimeSlotIcon(String timeSlot) {
    switch (timeSlot) {
      case 'Morning':
        return Icons.wb_sunny;
      case 'Afternoon':
        return Icons.brightness_5;
      case 'Evening':
        return Icons.nights_stay;
      case 'Night':
        return Icons.nightlight_round;
      default:
        return Icons.access_time;
    }
  }

  Widget _buildFilterSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF1DB954), size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class TurfCard extends StatefulWidget {
  final Turf turf;
  const TurfCard({super.key, required this.turf});

  @override
  State<TurfCard> createState() => _TurfCardState();
}

class _TurfCardState extends State<TurfCard> {
  int _currentImageIndex = 0;

  Future<void> _openMapLocation() async {
    final Uri uri = Uri.parse(widget.turf.mapLink);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open Google Maps")),
      );
    }
  }

  void _viewTurfDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TurfDetailsScreen(turf: widget.turf)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Carousel - Clickable for details
          GestureDetector(
            onTap: _viewTurfDetails,
            child: Stack(
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    image: DecorationImage(
                      image: NetworkImage(
                        widget.turf.images[_currentImageIndex],
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Image Indicators
                if (widget.turf.images.length > 1)
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        widget.turf.images.length,
                        (index) => Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentImageIndex == index
                                ? const Color(0xFF1DB954)
                                : Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ),
                  ),

                // Rating Badge
                Positioned(
                  top: 15,
                  left: 15,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          widget.turf.rating.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Distance Badge with Map Navigation
                Positioned(
                  top: 15,
                  right: 15,
                  child: GestureDetector(
                    onTap: _openMapLocation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: Color(0xFF1DB954),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${widget.turf.distance} km",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Turf Details - Clickable for details
          GestureDetector(
            onTap: _viewTurfDetails,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.turf.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    widget.turf.location,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                                // View More Button
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    "View More",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "₹${widget.turf.price}",
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1DB954),
                            ),
                          ),
                          const Text(
                            "/hour",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // Amenities
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.turf.amenities.map((amenity) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.green.shade100),
                        ),
                        child: Text(
                          amenity,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Book Button (not clickable for details)
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookingScreen(turf: widget.turf),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1DB954),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_month, size: 20),
                    SizedBox(width: 10),
                    Text(
                      "Book Now",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
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