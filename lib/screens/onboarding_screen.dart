import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:roadcare/theme.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController pageController = PageController();
  int currentPage = 0;

  final List<Map<String, String>> pages = [
    {
      "id": "spot",
      "title": "Spot an Issue",
      "subtitle":
          "See a pothole, broken light, or damaged sign? We make it easy to report.",
    },
    {
      "id": "photo",
      "title": "Snap a Photo",
      "subtitle":
          "A picture is worth a thousand words. Attach a photo to help our team locate and assess the issue quickly.",
    },
    {
      "id": "location",
      "title": "Share Your Location",
      "subtitle":
          "Send your precise location so responders and repair crews can reach and fix issues faster.",
    },
  ];

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("onboardingDone", true);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Top Artwork Header Carousel (Upper 54% of screen)
            Expanded(
              flex: 54,
              child: PageView.builder(
                controller: pageController,
                itemCount: pages.length,
                onPageChanged: (index) {
                  setState(() => currentPage = index);
                },
                itemBuilder: (context, index) {
                  return _OnboardingHeaderIllustration(
                    pageId: pages[index]["id"]!,
                  );
                },
              ),
            ),

            // Bottom Content Section (Title, Subtitle, Dots, Button, Skip)
            Expanded(
              flex: 46,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Title
                    Text(
                      pages[currentPage]["title"]!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                        letterSpacing: -0.3,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Subtitle
                    Text(
                      pages[currentPage]["subtitle"]!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF594236),
                        height: 1.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const Spacer(),

                    // 3 Pagination Dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(pages.length, (index) {
                        final isActive = index == currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isActive ? 10 : 8,
                          height: isActive ? 10 : 8,
                          decoration: BoxDecoration(
                            color: isActive
                                ? RoadCareColors.accentOrange
                                : const Color(0xFFD1D5DB),
                            shape: BoxShape.circle,
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 24),

                    // Next / Get Started Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          if (currentPage == pages.length - 1) {
                            _finishOnboarding();
                          } else {
                            pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: RoadCareColors.accentOrange,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              currentPage == pages.length - 1
                                  ? "Get Started"
                                  : "Next",
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            if (currentPage == 0) ...[
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward,
                                size: 20,
                                color: Colors.white,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Skip Link
                    SizedBox(
                      height: 38,
                      child: currentPage < pages.length - 1
                          ? TextButton(
                              onPressed: _finishOnboarding,
                              child: const Text(
                                "Skip",
                                style: TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingHeaderIllustration extends StatelessWidget {
  final String pageId;
  const _OnboardingHeaderIllustration({required this.pageId});

  @override
  Widget build(BuildContext context) {
    if (pageId == "spot") {
      return _buildSpotHeader();
    } else if (pageId == "photo") {
      return _buildPhotoHeader();
    } else {
      return _buildLocationHeader();
    }
  }

  /// Screen 1: High definition street asphalt background with white focus target badge [ o ] (Screenshot 1)
  Widget _buildSpotHeader() {
    return Stack(
      children: [
        // Real Road Photo Background
        Positioned.fill(
          child: Image.asset(
            'assets/images/spot_issue_bg.jpg',
            fit: BoxFit.cover,
            alignment: Alignment.center,
            errorBuilder: (context, error, stackTrace) {
              return Container(color: const Color(0xFF64748B));
            },
          ),
        ),

        // Bottom gradient overlay fading into page background
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 140,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x00F9F9F9),
                  Color(0xFFF9F9F9),
                ],
              ),
            ),
          ),
        ),

        // Center White Circular Camera Focus Reticle Badge [ o ]
        Center(
          child: Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 24,
                  spreadRadius: 2,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Viewfinder corners
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: RoadCareColors.accentOrange,
                        width: 2.5,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  // Center circle target
                  Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      color: RoadCareColors.accentOrange,
                      shape: BoxShape.circle,
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

  /// Screen 2: High definition circular illustration for "Snap a Photo" (Screenshot 2)
  Widget _buildPhotoHeader() {
    return Container(
      color: const Color(0xFFF9F9F9),
      child: Center(
        child: Container(
          width: 280,
          height: 280,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipOval(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Image.asset(
                'assets/images/snap_photo_illus.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.camera_alt_outlined,
                    size: 80,
                    color: RoadCareColors.accentOrange,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Screen 3: High definition circular illustration for "Share Your Location"
  Widget _buildLocationHeader() {
    return Container(
      color: const Color(0xFFF9F9F9),
      child: Center(
        child: Container(
          width: 280,
          height: 280,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipOval(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Image.asset(
                'assets/images/share_location_illus.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.location_on_outlined,
                    size: 80,
                    color: RoadCareColors.primary,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
