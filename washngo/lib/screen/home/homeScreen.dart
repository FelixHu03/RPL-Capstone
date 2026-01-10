import 'package:flutter/material.dart';
import 'dart:async';
import 'package:washngo/layouts/bgHomeScreen.dart';
import 'package:washngo/screen/home/content/accountScreenContent.dart';
import 'package:washngo/screen/home/historyScreenContent.dart';
import 'package:washngo/screen/home/services/executiveWash.dart';

class Homescreen extends StatefulWidget {
  final String email;
 const Homescreen({super.key, required this.email});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  // 1. Variable untuk menentukan halaman aktif (0=Home, 1=History, 2=Account)
  int _selectedIndex = 0;

  // Controller untuk Promo Banner (Hanya dipakai di Home)
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  // Data Promo
  final List<Map<String, dynamic>> _promoBanners = [
    {
      "color": Colors.white,
      "text": "",
      "image": "assets/spacialPromo/spacialPromo1.png",
    },
    {
      "color": Colors.white,
      "text": "",
      "image": "assets/spacialPromo/spacialPromo2.png",
    },
    {
      "color": Colors.white,
      "text": "",
      "image": "assets/spacialPromo/spacialPromo3.png",
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 2), (Timer timer) {
      // Hanya scroll jika sedang di tab Home (index 0)
      if (_selectedIndex == 0 && _pageController.hasClients) {
        if (_currentPage < _promoBanners.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  // 2. Fungsi saat Footer diklik
  void _onFooterTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyContent;

    switch (_selectedIndex) {
      case 0:
        bodyContent = _buildHomeContent();
        break;
      case 1:
        bodyContent = HistoryScreen(email: widget.email);
        break;
      case 2:
        bodyContent = Accountscreencontent(email: widget.email);
        break;
      default:
        bodyContent = _buildHomeContent();
    }

    // 4. Return Wrapper Utama
    return Bghomescreen(
      currentIndex: _selectedIndex,
      onTap: _onFooterTap,
      child: bodyContent,
    );
  }

  // WIDGET KONTEN HOME
  Widget _buildHomeContent() {
    final List<Map<String, dynamic>> services = [
      {
        'title': 'Executive\nWash',
        'image': 'assets/images/ExecutiveWash.png',
        'page':  Executivewash(email: widget.email),
      },
      {
        'title': 'Fogging\nService',
        'image': 'assets/images/FoggingService.png',
        'page': null,
      },
      {
        'title': 'Undercarriage\nWash',
        'image': 'assets/images/UndercarriageWash.png',
        'page': null,
      },
      {
        'title': 'Express\nWash',
        'image': 'assets/images/ExpressWash.png',
        'page': null,
      },
      {
        'title': 'Complete\nWash',
        'image': 'assets/images/ComplateWash.png',
        'page': null,
      },
      {
        'title': 'Automatic\nWash',
        'image': 'assets/images/OtomaticWash.png',
        'page': null,
      },
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Text(
            'Discover Our Offerings',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Grid Menu
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.only(bottom: 20),
              itemCount: services.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 15,
                mainAxisSpacing: 20,
                childAspectRatio: 0.75,
              ),
              itemBuilder: (context, index) {
                return _buildServiceItem(
                  title: services[index]['title'],
                  imagePath: services[index]['image'],
                  color: index == 0
                      ? const Color(0xFF2E8B99)
                      : Colors.grey[300]!,
                  isPlaceholder: false,
                  onTap: () {
                    final Widget? destinationPage = services[index]['page'];

                    if (destinationPage != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => destinationPage,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Halaman ${services[index]['title']} belum tersedia",
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 25),
          const Text(
            'Special Promo',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 25),

          // Promo Banner
          SizedBox(
            height: 250,
            width: double.infinity,
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: _promoBanners.length,
                  onPageChanged: (int index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return _buildPromoBanner(
                      color: _promoBanners[index]['color'],
                      text: _promoBanners[index]['text'],
                      image: _promoBanners[index]['image'],
                    );
                  },
                ),
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _promoBanners.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 12 : 8,
                        height: 5,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? const Color(0xFF2E8B99)
                              : Colors.grey,
                          borderRadius: BorderRadius.circular(4),
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
    );
  }

  // Widget Item Service
  Widget _buildServiceItem({
    required String title,
    required String imagePath,
    required Color color,
    bool isPlaceholder = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black12, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: isPlaceholder
                    ? const SizedBox()
                    : Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Image.asset(imagePath, fit: BoxFit.contain),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isPlaceholder ? "" : title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  // Widget Banner
  Widget _buildPromoBanner({
    required Color color,
    required String text,
    String? image,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        image: (image != null && image.isNotEmpty)
            ? DecorationImage(image: AssetImage(image), fit: BoxFit.cover)
            : null,
      ),
    );
  }
}
