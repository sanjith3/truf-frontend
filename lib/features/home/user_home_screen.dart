import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:turfzone/booking/booking_screen.dart';
import 'package:turfzone/models/turf.dart';
import 'package:turfzone/features/profile/profile_screen.dart';
import 'package:turfzone/features/Admindashboard/admin_screen.dart';
import '../../turffdetail/turfdetails_screen.dart';
import '../../services/turf_data_service.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Turf> _filteredTurfs = [];
  final TurfDataService _turfService = TurfDataService();
  String _selectedLocation = "Coimbatore";

  final List<String> _tnCities = [
    'Ariyalur', 'Chengalpattu', 'Chennai', 'Coimbatore', 'Cuddalore', 'Dharmapuri', 
    'Dindigul', 'Erode', 'Kallakurichi', 'Kanchipuram', 'Kanyakumari', 'Karur', 
    'Krishnagiri', 'Madurai', 'Mayiladuthurai', 'Nagapattinam', 'Namakkal', 
    'Nilgiris', 'Perambalur', 'Pudukkottai', 'Ramanathapuram', 'Ranipet', 
    'Salem', 'Sivaganga', 'Tenkasi', 'Thanjavur', 'Theni', 'Thoothukudi', 
    'Tiruchirappalli', 'Tirunelveli', 'Tirupathur', 'Tiruppur', 'Tiruvallur', 
    'Tiruvannamalai', 'Tiruvarur', 'Vellore', 'Viluppuram', 'Virudhunagar'
  ];

  void _showLocationPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Select Location",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: ListView.builder(
                  itemCount: _tnCities.length,
                  itemBuilder: (context, index) {
                    final city = _tnCities[index];
                    return ListTile(
                      title: Text(city),
                      trailing: _selectedLocation == city 
                        ? const Icon(Icons.check_circle, color: Color(0xFF1DB954))
                        : null,
                      onTap: () {
                        setState(() {
                          _selectedLocation = city;
                          _applyFilters();
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Filter variables
  RangeValues _priceRange = const RangeValues(0, 2000);
  double _maxPrice = 2000;
  final Map<String, bool> _timeFilters = {
    'Morning': false,
    'Afternoon': false,
    'Evening': false,
    'Night': false,
  };

  // Updated category/sport filters
  final Map<String, bool> _sportFilters = {
    'Cricket': false,
    'Football': false,
    'Badminton': false,
    'Tennis': false,
    'Basketball': false,
    'Volleyball': false,
    'Table Tennis': false,
  };

  List<Turf> get _turfs => _turfService.turfs;

  @override
  void initState() {
    super.initState();
    _filteredTurfs = _turfs;
    _searchController.addListener(_searchTurfs);
    
    if (_turfs.isNotEmpty) {
      _maxPrice = _turfs
          .map((t) => t.price.toDouble())
          .reduce((a, b) => a > b ? a : b);
      _priceRange = RangeValues(0, _maxPrice);
    }
    _applyFilters();
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

    // Apply city filter
    filtered = filtered
        .where((turf) => turf.city.toLowerCase() == _selectedLocation.toLowerCase())
        .toList();

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

    // Apply sport filters if any selected
    final selectedSports = _sportFilters.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
    if (selectedSports.isNotEmpty) {
      filtered = filtered.where((turf) {
        // Check if turf supports any of the selected sports
        return selectedSports.any((sport) => turf.sports.contains(sport));
      }).toList();
    }

    setState(() {
      _filteredTurfs = filtered;
    });
  }

  void _resetFilters() {
    setState(() {
      _priceRange = RangeValues(0, _maxPrice);
      _timeFilters.forEach((key, value) {
        _timeFilters[key] = false;
      });
      _sportFilters.forEach((key, value) {
        _sportFilters[key] = false;
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Reduced Green Top Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.green[700]!, Colors.green[600]!],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
              child: Column(
                children: [
                  // Top Row: Location and Icons
                  Row(
                    children: [
                      // Location
                      InkWell(
                        onTap: _showLocationPicker,
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.location_on_outlined,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        _selectedLocation,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const Icon(
                                        Icons.keyboard_arrow_down,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                  Text(
                                    "Tamil Nadu",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Tournament Icon
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: IconButton(
                          onPressed: () => _showTournamentDialog(context),
                          icon: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.2),
                            ),
                            child: const Icon(
                              Icons.emoji_events_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),

                      // Admin Icon
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AdminScreen(),
                              ),
                            );
                          },
                          icon: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.2),
                            ),
                            child: const Icon(
                              Icons.admin_panel_settings_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),

                      // Profile Icon
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.2),
                          ),
                          child: const Icon(
                            Icons.person_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProfileScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Welcome Text
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Book Your Turf",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "Play your favorite sport anytime",
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Search turfs by name or location...",
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.green[800],
                          size: 22,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.filter_list,
                            color: Colors.green[800],
                            size: 22,
                          ),
                          onPressed: () => _showFilterOptions(context),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 15,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),

            // Show only when filters are active
            if (_isFilterActive())
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${_filteredTurfs.length} turfs found",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.green[800],
                      ),
                    ),
                    TextButton(
                      onPressed: _resetFilters,
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: Text(
                        "Clear Filters",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.green[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Turf Cards
            Expanded(
              child: _filteredTurfs.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 60,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No turfs found",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            "Try adjusting your filters or search",
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        16,
                        20,
                        20,
                      ), // Reduced bottom padding to 20
                      itemCount: _filteredTurfs.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            TurfCard(turf: _filteredTurfs[index]),
                            // Add subtle divider between cards (except last one)
                            if (index < _filteredTurfs.length - 1)
                              const Divider(
                                height: 20,
                                thickness: 0.5,
                                color: Color(0xFFEEEEEE),
                                indent: 20,
                                endIndent: 20,
                              ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isFilterActive() {
    return _priceRange.start > 0 ||
        _priceRange.end < _maxPrice ||
        _timeFilters.values.any((value) => value) ||
        _sportFilters.values.any((value) => value);
  }

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(20),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Filter Options",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Refine your search",
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[100],
                          ),
                          child: const Icon(Icons.close, size: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Sport Category Filter
                          const Text(
                            "Sport Categories",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _sportFilters.keys.map((sport) {
                              final isSelected = _sportFilters[sport]!;
                              return ChoiceChip(
                                label: Text(sport),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _sportFilters[sport] = selected;
                                  });
                                },
                                backgroundColor: Colors.grey[100],
                                selectedColor: Colors.green,
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 25),

                          // Price Range Filter
                          const Text(
                            "Price Range",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          RangeSlider(
                            values: _priceRange,
                            min: 0,
                            max: _maxPrice,
                            divisions: 20,
                            labels: RangeLabels(
                              "₹${_priceRange.start.round()}",
                              "₹${_priceRange.end.round()}",
                            ),
                            activeColor: Colors.green,
                            onChanged: (RangeValues values) {
                              setState(() {
                                _priceRange = values;
                              });
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("₹0"),
                              Text("₹${_maxPrice.toInt()}"),
                            ],
                          ),

                          const SizedBox(height: 25),

                          // Time Slot Filter
                          const Text(
                            "Preferred Time Slots",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _timeFilters.keys.map((timeSlot) {
                              final isSelected = _timeFilters[timeSlot]!;
                              return FilterChip(
                                label: Text(timeSlot),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _timeFilters[timeSlot] = selected;
                                  });
                                },
                                backgroundColor: Colors.grey[100],
                                selectedColor: Colors.green,
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Apply & Clear Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            _resetFilters();
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                          child: const Text(
                            "Clear All",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _applyFilters();
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Apply Filters",
                            style: TextStyle(fontSize: 16),
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

  void _showTournamentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text("Upcoming Tournaments"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTournamentCard(
                  "Inter-College Cricket League",
                  "Dec 15-20, 2023",
                  "Green Field Arena",
                  "₹10,000 Prize",
                ),
                const SizedBox(height: 12),
                _buildTournamentCard(
                  "City Football Championship",
                  "Dec 22-24, 2023",
                  "Elite Football Ground",
                  "₹15,000 Prize",
                ),
                const SizedBox(height: 12),
                _buildTournamentCard(
                  "Badminton Singles Open",
                  "Jan 5-7, 2024",
                  "Shuttle Masters Academy",
                  "₹8,000 Prize",
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close tournament list
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text("🏏", style: TextStyle(fontSize: 32)),
                            SizedBox(width: 10),
                            Text("⚽", style: TextStyle(fontSize: 40)),
                            SizedBox(width: 10),
                            Text("🎾", style: TextStyle(fontSize: 32)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Coming Soon!",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1DB954),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Tournament registration will be available in our upcoming update. Stay tuned for more sports action!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text("🏀", style: TextStyle(fontSize: 24)),
                            SizedBox(width: 15),
                            Text("🏐", style: TextStyle(fontSize: 24)),
                            SizedBox(width: 15),
                            Text("🏸", style: TextStyle(fontSize: 24)),
                          ],
                        ),
                      ],
                    ),
                    actions: [
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "Awesome!",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF1DB954),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Register"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTournamentCard(
    String title,
    String date,
    String venue,
    String prize,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text("Date: $date", style: const TextStyle(fontSize: 12)),
          Text("Venue: $venue", style: const TextStyle(fontSize: 12)),
          Text("Prize: $prize", style: const TextStyle(fontSize: 12)),
        ],
      ),
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
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with error handling
          GestureDetector(
            onTap: _viewTurfDetails,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Container(
                height: 180,
                width: double.infinity,
                color: Colors.grey[100],
                child: Stack(
                  children: [
                    // Image with error handling
                    Image.network(
                      widget.turf.images[_currentImageIndex],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey,
                                  size: 40,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Image not available",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                    ),

                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                          ],
                        ),
                      ),
                    ),

                    // Rating badge with smaller padding
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8, // Reduced from 10
                          vertical: 5, // Reduced from 6
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.turf.rating.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Distance badge
                    Positioned(
                      top: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: _openMapLocation,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.green,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "${widget.turf.distance} km",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
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
            ),
          ),

          // Turf Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and Location
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
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  widget.turf.location,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "₹${widget.turf.price}",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          "/hour",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Sports Available with smaller chips
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Sports Available:",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: widget.turf.sports.map((sport) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: _getSportColor(sport).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _getSportColor(sport).withOpacity(0.2),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getSportIcon(sport),
                                size: 12,
                                color: _getSportColor(sport),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                sport,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _getSportColor(sport),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Book Button
                SizedBox(
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
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 2,
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
        ],
      ),
    );
  }

  Color _getSportColor(String sport) {
    switch (sport.toLowerCase()) {
      case 'cricket':
        return Colors.green;
      case 'football':
        return Colors.blue;
      case 'badminton':
        return Colors.red;
      case 'tennis':
        return Colors.orange;
      case 'basketball':
        return Colors.purple;
      case 'volleyball':
        return Colors.teal;
      case 'table tennis':
        return Colors.pink;
      default:
        return Colors.green;
    }
  }

  IconData _getSportIcon(String sport) {
    switch (sport.toLowerCase()) {
      case 'cricket':
        return Icons.sports_cricket;
      case 'football':
        return Icons.sports_soccer;
      case 'badminton':
        return Icons.sports_tennis;
      case 'tennis':
        return Icons.sports_tennis;
      case 'basketball':
        return Icons.sports_basketball;
      case 'volleyball':
        return Icons.sports_volleyball;
      case 'table tennis':
        return Icons.sports_tennis; // Using same icon for both tennis types
      default:
        return Icons.sports;
    }
  }
}
