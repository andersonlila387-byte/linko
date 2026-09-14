import 'dart:async';
import 'package:flutter/material.dart';
import '../auth/auth_screen.dart';

class WelcomeScreen extends StatefulWidget {
  final String currentDeviceId;
  final String currentDeviceName;

  const WelcomeScreen({
    super.key,
    required this.currentDeviceId,
    required this.currentDeviceName,
  });

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _carouselTimer;

  final List<Map<String, dynamic>> _carouselItems = [
    {
      'icon': Icons.chat_bubble_outline_rounded,
      'title': 'Share Instantly.\nDisappear Completely.',
      'subtitle':
          'High-speed direct communication between your devices over local Wi-Fi, with military-grade View Once zero-memory shredding.',
      'tag': 'P2P DIRECT ENCRYPTION',
    },
    {
      'icon': Icons.offline_bolt_rounded,
      'title': 'Offline Direct Speed',
      'subtitle':
          'Direct device-to-device socket transport without internet dependency. Ultra-fast local file and text transfers.',
      'tag': 'ZERO INTERNET NEEDED',
    },
    {
      'icon': Icons.lock_clock_rounded,
      'title': 'View-Once Shredding',
      'subtitle':
          'Zero-memory RAM buffers & multi-pass file byte overwrite on dismissal. Content leaves zero trace.',
      'tag': 'MILITARY GRADE SHREDDING',
    },
    {
      'icon': Icons.verified_user_rounded,
      'title': 'Unique Identity & E2EE',
      'subtitle':
          'Claim your exclusive username with end-to-end encrypted device authorization across cellular & local networks.',
      'tag': 'END-TO-END ENCRYPTED',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _carouselTimer?.cancel();
    _carouselTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        final nextPage = (_currentPage + 1) % _carouselItems.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.fastOutSlowIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color bgBlack = Color(0xFF08080C);
    const Color cardBlack = Color(0xFF111118);
    const Color borderStroke = Color(0xFF22222E);
    const Color accentCyan = Color(0xFF00F0FF);

    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: bgBlack,
      body: Stack(
        children: [
          // Background Glow 1 (Top Right)
          Positioned(
            top: -120,
            right: -100,
            child: Container(
              width: 380,
              height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    accentCyan.withValues(alpha: 0.14),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Background Glow 2 (Bottom Left)
          Positioned(
            bottom: -140,
            left: -100,
            child: Container(
              width: 420,
              height: 420,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.04),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main Responsive Content Body
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 650;

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // 1. Header Bar
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: accentCyan.withValues(alpha: 0.35),
                                          blurRadius: 16,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.hub_rounded,
                                      color: Colors.black,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'LINKO',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 3.5,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: cardBlack,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: borderStroke),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: accentCyan,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'v0.2 E2EE',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          // 2. Middle Interactive Modern App Carousel
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: isMobile ? size.height * 0.42 : 360,
                                  child: PageView.builder(
                                    controller: _pageController,
                                    onPageChanged: (index) {
                                      setState(() {
                                        _currentPage = index;
                                      });
                                    },
                                    itemCount: _carouselItems.length,
                                    itemBuilder: (context, index) {
                                      final item = _carouselItems[index];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: isMobile ? 20 : 36,
                                            vertical: isMobile ? 24 : 32,
                                          ),
                                          decoration: BoxDecoration(
                                            color: cardBlack.withValues(alpha: 0.8),
                                            borderRadius: BorderRadius.circular(28),
                                            border: Border.all(color: borderStroke, width: 1.2),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.4),
                                                blurRadius: 24,
                                                offset: const Offset(0, 10),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              // Animated Badge Icon
                                              Container(
                                                padding: const EdgeInsets.all(16),
                                                decoration: BoxDecoration(
                                                  color: accentCyan.withValues(alpha: 0.1),
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: accentCyan.withValues(alpha: 0.3),
                                                    width: 1.5,
                                                  ),
                                                ),
                                                child: Icon(
                                                  item['icon'] as IconData,
                                                  color: accentCyan,
                                                  size: isMobile ? 32 : 40,
                                                ),
                                              ),
                                              const SizedBox(height: 18),

                                              // Tag label
                                              Text(
                                                item['tag'] as String,
                                                style: const TextStyle(
                                                  color: accentCyan,
                                                  fontSize: 10,
                                                  letterSpacing: 2.0,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                              const SizedBox(height: 10),

                                              // Headline Title
                                              Text(
                                                item['title'] as String,
                                                textAlign: TextAlign.center,
                                                maxLines: 2,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: isMobile ? 24 : 32,
                                                  height: 1.2,
                                                  fontWeight: FontWeight.w900,
                                                  letterSpacing: -0.5,
                                                ),
                                              ),
                                              const SizedBox(height: 12),

                                              // Description Subtitle
                                              Text(
                                                item['subtitle'] as String,
                                                textAlign: TextAlign.center,
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: const Color(0xFF9E9EA8),
                                                  fontSize: isMobile ? 13 : 15,
                                                  height: 1.5,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Page Indicator Dots
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    _carouselItems.length,
                                    (index) => GestureDetector(
                                      onTap: () {
                                        _pageController.animateToPage(
                                          index,
                                          duration: const Duration(milliseconds: 400),
                                          curve: Curves.easeInOut,
                                        );
                                      },
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        margin: const EdgeInsets.symmetric(horizontal: 4),
                                        height: 8,
                                        width: _currentPage == index ? 28 : 8,
                                        decoration: BoxDecoration(
                                          color: _currentPage == index
                                              ? accentCyan
                                              : Colors.white.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // 3. Action Section
                          Column(
                            children: [
                              const SizedBox(height: 16),

                              // Get Started Primary Button
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => AuthScreen(
                                        defaultDeviceId: widget.currentDeviceId,
                                        defaultDeviceName: widget.currentDeviceName,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: isMobile ? double.infinity : 280,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(28),
                                    boxShadow: [
                                      BoxShadow(
                                        color: accentCyan.withValues(alpha: 0.3),
                                        blurRadius: 24,
                                        spreadRadius: 2,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Get Started',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        color: Colors.black,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Device & Platform Info Footer
                              Text(
                                '${widget.currentDeviceName} • Android, Windows & Web Responsive',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFF6B6B78),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
