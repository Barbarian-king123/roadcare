import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding_screen.dart';
import 'loginscreen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progressController;
  bool _navigated = false;

  // Palette pulled from the RoadCare logo: soft lavender bg, deep navy +
  // brand blue wordmark/accents, green "active" status dot.
  static const Color kBg = Color(0xFFF3F5FC);
  static const Color kBrandDark = Color(0xFF0B1F4D);
  static const Color kBrandBlue = Color(0xFF1E40C9);
  static const Color kSuccessGreen = Color(0xFF16A34A);

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..forward();

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _routeNext();
      }
    });
  }

  Future<void> _routeNext() async {
    if (_navigated) return;
    _navigated = true;

    // Small settle delay so the bar visibly completes before we navigate.
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool("onboardingDone") ?? false;
    final user = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    Widget next;
    if (!onboardingDone) {
      next = const OnboardingScreen();
    } else if (user != null) {
      next = const HomeScreen();
    } else {
      next = const LoginScreen();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => next),
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 5),

            // Logo mark
            Container(
              width: 108,
              height: 108,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: kBrandBlue.withOpacity(0.18),
                    blurRadius: 30,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Center(child: _RoadCareMark()),
            ),

            const SizedBox(height: 22),

            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
                children: [
                  TextSpan(text: "ROAD", style: TextStyle(color: kBrandDark)),
                  TextSpan(text: "CARE", style: TextStyle(color: kBrandBlue)),
                ],
              ),
            ),

            const SizedBox(height: 6),

            Text(
              "Better roads, safer journeys.",
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
            ),

            const Spacer(flex: 7),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Column(
                children: [
                  const Text(
                    "CONNECTING TO AUTHORITIES",
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                      color: kBrandBlue,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedBuilder(
                      animation: _progressController,
                      builder: (context, _) => LinearProgressIndicator(
                        value: _progressController.value,
                        minHeight: 5,
                        backgroundColor: kBrandBlue.withOpacity(0.15),
                        valueColor: const AlwaysStoppedAnimation(kBrandDark),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: kSuccessGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Systems Active",
                        style: TextStyle(fontSize: 13.5, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}

/// Recreated approximation of the RoadCare mark (bar + dashed bar + plus).
/// This is drawn in code so the splash works with zero extra assets.
/// If you have the real logo as a PNG/SVG, swap `_RoadCareMark()` above for
/// `Image.asset('assets/images/logo.png')` for a pixel-exact match — just
/// remember to register the asset path in pubspec.yaml first.
class _RoadCareMark extends StatelessWidget {
  const _RoadCareMark();

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF1E40C9);
    return const SizedBox(
      width: 52,
      height: 52,
      child: CustomPaint(painter: _MarkPainter(color: color)),
    );
  }
}

class _MarkPainter extends CustomPainter {
  final Color color;
  const _MarkPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final barPaint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 7;

    final h = size.height;
    final w = size.width;

    // Left solid bar (full height)
    canvas.drawLine(Offset(w * 0.18, h * 0.08), Offset(w * 0.18, h * 0.92), barPaint);

    // Middle dashed bar (two short segments)
    canvas.drawLine(Offset(w * 0.5, h * 0.08), Offset(w * 0.5, h * 0.38), barPaint);
    canvas.drawLine(Offset(w * 0.5, h * 0.55), Offset(w * 0.5, h * 0.62), barPaint);

    // Plus sign, bottom right
    final plusPaint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 6.5;
    final cx = w * 0.82;
    final cy = h * 0.68;
    canvas.drawLine(Offset(cx - 12, cy), Offset(cx + 12, cy), plusPaint);
    canvas.drawLine(Offset(cx, cy - 12), Offset(cx, cy + 12), plusPaint);
  }

  @override
  bool shouldRepaint(covariant _MarkPainter oldDelegate) => false;
}