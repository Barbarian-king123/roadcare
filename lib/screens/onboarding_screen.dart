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
            // Top Artwork Header Carousel area (takes upper ~52% of screen)
            Expanded(
              flex: 52,
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

            // Bottom Content area (title, description, dots, button, skip)
            Expanded(
              flex: 48,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
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

                    // Page Indicator (3 Dots)
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
                                ? RoadCareColors.primary
                                : const Color(0xFFD1D5DB),
                            shape: BoxShape.circle,
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 28),

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
                          backgroundColor: RoadCareColors.primary,
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

                    const SizedBox(height: 14),

                    // Skip Button
                    SizedBox(
                      height: 40,
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

                    const SizedBox(height: 12),
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

/// Renders the illustration for each onboarding step
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

  /// Screen 1: Asphalt Road Header with Viewfinder reticle (matching Screenshot 1)
  Widget _buildSpotHeader() {
    return Stack(
      children: [
        // Asphalt background with street perspective
        Positioned.fill(
          child: CustomPaint(
            painter: _AsphaltRoadPainter(),
          ),
        ),
        // Soft bottom gradient fading to white/light bg
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 120,
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
        // Center camera viewfinder badge [ o ]
        Center(
          child: Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Viewfinder corners
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: RoadCareColors.primary,
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
                      color: RoadCareColors.primary,
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

  /// Screen 2: Circular illustration with street light, sign, road pothole & scanning phone (matching Screenshot 2)
  Widget _buildPhotoHeader() {
    return Container(
      color: const Color(0xFFF9F9F9),
      child: Center(
        child: Container(
          width: 290,
          height: 290,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipOval(
            child: CustomPaint(
              painter: _SnapPhotoPainter(),
            ),
          ),
        ),
      ),
    );
  }

  /// Screen 3: Circular map pin illustration
  Widget _buildLocationHeader() {
    return Container(
      color: const Color(0xFFF9F9F9),
      child: Center(
        child: Container(
          width: 290,
          height: 290,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipOval(
            child: CustomPaint(
              painter: _LocationMapPainter(),
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter for realistic asphalt street background on Screen 1
class _AsphaltRoadPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background cityscape / top horizon sky tone
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF8D99AE),
          Color(0xFFB0B9C6),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h * 0.35));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h * 0.35), skyPaint);

    // City building silhouettes
    final bldgPaint = Paint()..color = const Color(0xFF6C757D);
    canvas.drawRect(Rect.fromLTWH(w * 0.05, h * 0.08, w * 0.2, h * 0.27), bldgPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.22, h * 0.04, w * 0.15, h * 0.31), bldgPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.65, h * 0.1, w * 0.28, h * 0.25), bldgPaint);

    // Asphalt road surface
    final asphaltPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF64748B),
          Color(0xFF94A3B8),
          Color(0xFFCBD5E1),
        ],
      ).createShader(Rect.fromLTWH(0, h * 0.25, w, h * 0.75));
    canvas.drawRect(Rect.fromLTWH(0, h * 0.25, w, h * 0.75), asphaltPaint);

    // White lane stripe (right side perspective line)
    final stripePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(w * 0.82, h * 0.28), Offset(w * 0.98, h * 0.95), stripePaint);

    // Pothole in the road surface below center
    final potholePaint = Paint()
      ..color = const Color(0xFF475569)
      ..style = PaintingStyle.fill;
    final potholePath = Path()
      ..moveTo(w * 0.38, h * 0.54)
      ..cubicTo(w * 0.42, h * 0.52, w * 0.58, h * 0.52, w * 0.62, h * 0.55)
      ..cubicTo(w * 0.64, h * 0.59, w * 0.56, h * 0.62, w * 0.44, h * 0.62)
      ..cubicTo(w * 0.35, h * 0.61, w * 0.34, h * 0.56, w * 0.38, h * 0.54);
    canvas.drawPath(potholePath, potholePaint);

    // Inner pothole dark shadow
    final darkShadowPaint = Paint()..color = const Color(0xFF334155);
    final shadowPath = Path()
      ..moveTo(w * 0.41, h * 0.55)
      ..cubicTo(w * 0.45, h * 0.54, w * 0.55, h * 0.54, w * 0.58, h * 0.56)
      ..cubicTo(w * 0.57, h * 0.59, w * 0.46, h * 0.60, w * 0.41, h * 0.58);
    canvas.drawPath(shadowPath, darkShadowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for Screen 2 circular photo scan illustration
class _SnapPhotoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Sky/upper bg
    final sky = Paint()..color = const Color(0xFFF3F4F6);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), sky);

    // Street Light (orange pole + fixture)
    final polePaint = Paint()
      ..color = const Color(0xFFEA580C)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    final polePath = Path()
      ..moveTo(w * 0.42, h * 0.55)
      ..lineTo(w * 0.42, h * 0.22)
      ..cubicTo(w * 0.42, h * 0.16, w * 0.52, h * 0.16, w * 0.55, h * 0.19);
    canvas.drawPath(polePath, polePaint);

    // Light beam fill
    final beamPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.amber.shade200.withValues(alpha: 0.5),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(w * 0.35, h * 0.2, w * 0.25, h * 0.35));
    final beamPath = Path()
      ..moveTo(w * 0.45, h * 0.2)
      ..lineTo(w * 0.32, h * 0.55)
      ..lineTo(w * 0.58, h * 0.55)
      ..close();
    canvas.drawPath(beamPath, beamPaint);

    // Road Sign (orange diamond)
    final signPaint = Paint()..color = const Color(0xFFEA580C);
    final signPath = Path()
      ..moveTo(w * 0.51, h * 0.24)
      ..lineTo(w * 0.55, h * 0.28)
      ..lineTo(w * 0.51, h * 0.32)
      ..lineTo(w * 0.47, h * 0.28)
      ..close();
    canvas.drawPath(signPath, signPaint);

    // Road Asphalt
    final roadPaint = Paint()..color = const Color(0xFF475569);
    canvas.drawRect(Rect.fromLTWH(0, h * 0.55, w, h * 0.45), roadPaint);

    // White lane line
    final lanePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4;
    canvas.drawLine(Offset(w * 0.18, h * 0.72), Offset(w * 0.42, h * 0.72), lanePaint);

    // Pothole in asphalt
    final potholePaint = Paint()..color = const Color(0xFF1E293B);
    final potholePath = Path()
      ..moveTo(w * 0.46, h * 0.72)
      ..cubicTo(w * 0.52, h * 0.68, w * 0.78, h * 0.70, w * 0.82, h * 0.75)
      ..cubicTo(w * 0.84, h * 0.84, w * 0.58, h * 0.92, w * 0.45, h * 0.85)
      ..close();
    canvas.drawPath(potholePath, potholePaint);

    // Smartphone scanning frame overlay (right side)
    final phoneBody = Paint()..color = Colors.white;
    final phoneBorder = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final phoneRect = RRect.fromLTRBR(
      w * 0.56,
      h * 0.28,
      w * 0.88,
      h * 0.62,
      const Radius.circular(12),
    );
    canvas.drawRRect(phoneRect, phoneBody);
    canvas.drawRRect(phoneRect, phoneBorder);

    // Phone screen view
    final screenPaint = Paint()..color = const Color(0xFF334155);
    final screenRect = RRect.fromLTRBR(
      w * 0.59,
      h * 0.32,
      w * 0.85,
      h * 0.58,
      const Radius.circular(6),
    );
    canvas.drawRRect(screenRect, screenPaint);

    // Screen crosshair / viewfinder brackets inside phone
    final reticlePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawRect(
      Rect.fromLTWH(w * 0.67, h * 0.4, w * 0.1, h * 0.1),
      reticlePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for Screen 3 circular map pin illustration
class _LocationMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Map base background
    final mapBg = Paint()..color = const Color(0xFFF1F5F9);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), mapBg);

    // Map roads / grid lines
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, h * 0.45), Offset(w, h * 0.45), roadPaint);
    canvas.drawLine(Offset(w * 0.5, 0), Offset(w * 0.5, h), roadPaint);
    canvas.drawLine(Offset(w * 0.1, h * 0.8), Offset(w * 0.9, h * 0.2), roadPaint);

    // Radar pulse circles
    final pulse1 = Paint()
      ..color = RoadCareColors.primary.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;
    final pulse2 = Paint()
      ..color = RoadCareColors.primary.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final center = Offset(w * 0.5, h * 0.45);
    canvas.drawCircle(center, 64, pulse1);
    canvas.drawCircle(center, 42, pulse2);

    // Map Pin Icon shape
    final pinPaint = Paint()..color = RoadCareColors.primary;
    final pinPath = Path();
    final px = center.dx;
    final py = center.dy;
    pinPath.moveTo(px, py + 12);
    pinPath.cubicTo(
      px - 22,
      py - 12,
      px - 22,
      py - 38,
      px,
      py - 38,
    );
    pinPath.cubicTo(
      px + 22,
      py - 38,
      px + 22,
      py - 12,
      px,
      py + 12,
    );
    pinPath.close();
    canvas.drawPath(pinPath, pinPaint);

    // Pin inner circle
    final pinDot = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(px, py - 24), 8, pinDot);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
