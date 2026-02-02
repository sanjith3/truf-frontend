// turf_details_screen.dart
import 'package:flutter/material.dart';
import '../models/turf.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TurfDetailsScreen extends StatefulWidget {
  final Turf turf;
  const TurfDetailsScreen({super.key, required this.turf});

  @override
  State<TurfDetailsScreen> createState() => _TurfDetailsScreenState();
}

class _TurfDetailsScreenState extends State<TurfDetailsScreen> {
  int _currentImageIndex = 0;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isVideoInitialized = false;
  bool _isLoadingVideo = false;

  // Sample turf details - in real app, these would come from the turf model
  final List<String> _turfImages = [
    "https://images.unsplash.com/photo-1531315630201-bb15abeb1653?w=800",
    "https://images.unsplash.com/photo-1529900748604-07564a03e7a6?w=800",
    "https://images.unsplash.com/photo-1546519638-68e109498ffc?w=800",
    "https://images.unsplash.com/photo-1518611012118-696072aa579a?w=800",
    "https://images.unsplash.com/photo-1575361204480-aadea25e6e68?w=800",
  ];

  final String _videoUrl =
      "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4";

  final List<String> _availableGames = [
    "Football",
    "Cricket",
    "Badminton",
    "Volleyball",
    "Basketball",
  ];

  final List<String> _facilities = [
    "Flood Lights",
    "Changing Rooms",
    "Parking (50+ cars)",
    "Cafeteria",
    "First Aid",
    "Water Coolers",
    "WiFi",
    "Security",
  ];

  @override
  void initState() {
    super.initState();
  }

  Future<void> _loadVideo() async {
    if (_isLoadingVideo || _isVideoInitialized) return;
    setState(() => _isLoadingVideo = true);

    _videoController = VideoPlayerController.networkUrl(Uri.parse(_videoUrl));

    await _videoController!.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoController!,
      autoPlay: true,
      looping: true,
      showControls: true,
    );

    setState(() {
      _isVideoInitialized = true;
      _isLoadingVideo = false;
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with back button
          SliverAppBar(
            expandedHeight: 300,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildImageCarousel(),
              title: Text(
                widget.turf.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
              centerTitle: true,
            ),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.share, color: Colors.white),
                ),
                onPressed: () {},
              ),
            ],
          ),

          // Main content
          SliverList(
            delegate: SliverChildListDelegate([
              // Basic Info
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rating and Price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade50,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    size: 18,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.turf.rating.toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    " (128 reviews)",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1DB954).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "₹${widget.turf.price}/hour",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1DB954),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Location
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.red.shade600),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.turf.location,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                "2.5 km from your location • Open 6 AM - 10 PM",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Description
                    const Text(
                      "Description",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Experience world-class sporting facilities at ${widget.turf.name}. Our professionally maintained turf features high-quality artificial grass, professional-grade equipment, and excellent lighting for night games. Perfect for football, cricket, and other sports.",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Video Section
                    const Text(
                      "Turf Preview",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "15-second video tour of the facility",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: _isVideoInitialized
                            ? Chewie(controller: _chewieController!)
                            : Center(
                                child: _isLoadingVideo
                                    ? const CircularProgressIndicator()
                                    : ElevatedButton.icon(
                                        onPressed: _loadVideo,
                                        icon: const Icon(Icons.play_arrow),
                                        label: const Text("Play Turf Video"),
                                      ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Available Games
                    const Text(
                      "Available Games",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _availableGames.map((game) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.shade100),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.sports_soccer,
                                size: 18,
                                color: Colors.blue.shade700,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                game,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 30),

                    // Facilities
                    const Text(
                      "Facilities & Amenities",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 3.5,
                          ),
                      itemCount: _facilities.length,
                      itemBuilder: (context, index) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.green.shade100),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 18,
                                color: Colors.green.shade700,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _facilities[index],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.green.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 30),

                    // Gallery
                    const Text(
                      "Gallery",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Minimum 5 photos uploaded by admin",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _turfImages.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              // Show full screen image viewer
                              _showFullScreenGallery(index);
                            },
                            child: Container(
                              width: 120,
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  image: NetworkImage(_turfImages[index]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: index == 4
                                  ? Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.4),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "+${_turfImages.length - 5}",
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Contact Info
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Contact Information",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 15),
                          _buildContactItem(
                            Icons.phone,
                            "Phone Number",
                            "+91 98765 43210",
                            Colors.blue,
                          ),
                          const SizedBox(height: 12),
                          _buildContactItem(
                            Icons.email,
                            "Email",
                            "contact@${widget.turf.name.toLowerCase().replaceAll(' ', '')}.com",
                            Colors.red,
                          ),
                          const SizedBox(height: 12),
                          _buildContactItem(
                            Icons.access_time,
                            "Operating Hours",
                            "6:00 AM - 10:00 PM (Daily)",
                            Colors.green,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Book Now Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1DB954),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 3,
                        ),
                        child: const Text(
                          "BOOK THIS TURF NOW",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCarousel() {
    return Stack(
      children: [
        PageView.builder(
          itemCount: _turfImages.length,
          onPageChanged: (index) {
            setState(() {
              _currentImageIndex = index;
            });
          },
          itemBuilder: (context, index) {
            return CachedNetworkImage(
              imageUrl: _turfImages[index],

              fit: BoxFit.cover,
              width: double.infinity,
              placeholder: (context, url) => Container(
                color: Colors.grey.shade300,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            );
          },
        ),
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _turfImages.length,
              (index) => Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentImageIndex == index
                      ? Colors.white
                      : Colors.white.withOpacity(0.5),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactItem(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showFullScreenGallery(int initialIndex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return GalleryViewer(images: _turfImages, initialIndex: initialIndex);
      },
    );
  }
}

class GalleryViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const GalleryViewer({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  State<GalleryViewer> createState() => _GalleryViewerState();
}

class _GalleryViewerState extends State<GalleryViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.85,
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                Text(
                  '${_currentIndex + 1}/${widget.images.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.download, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // Image Viewer
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.images.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  panEnabled: true,
                  scaleEnabled: true,
                  maxScale: 3,
                  minScale: 1,
                  child: CachedNetworkImage(
                    imageUrl: widget.images[index],
                    fit: BoxFit.contain,
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error, color: Colors.white),
                  ),
                );
              },
            ),
          ),

          // Thumbnails
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.images.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _currentIndex == index
                            ? Colors.white
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),

                    // ✅ child must be here, NOT inside BoxDecoration
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: widget.images[index],
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Container(color: Colors.grey.shade300),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
