import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../onboarding/onboarding_screen.dart';
import '../navigation/main_navigation_screen.dart';
import '../../data/models/user_profile.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward().then((_) {
      _checkInitialState();
    });
  }

  Future<void> _checkInitialState() async {
    final box = Hive.box<UserProfile>('userBox');
    if (!mounted) return;
    
    Widget nextScreen;
    if (box.isNotEmpty) {
      nextScreen = const MainNavigationScreen();
    } else {
      nextScreen = const OnboardingScreen();
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => nextScreen,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Rising beer and foam animation background
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                painter: BeerFoamPainter(progress: _animation.value),
                child: Container(),
              );
            },
          ),
          // App Logo centered with fade and scale animation
          Center(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                final double opacity = (_animation.value * 2).clamp(0.0, 1.0);
                final double scale = 0.85 + (0.15 * opacity);
                return Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: scale,
                    child: Image.asset(
                      'assets/logo_CAlcool.png',
                      width: 220,
                      height: 220,
                      fit: BoxFit.contain,
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

class BeerFoamPainter extends CustomPainter {
  final double progress;

  BeerFoamPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    // 1. Beer Liquid (Golden Amber Body)
    final double beerHeight = size.height * progress;
    final double beerY = size.height - beerHeight;

    final Paint beerPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          const Color(0xFFC77C00), // Deep golden/amber at bottom
          const Color(0xFFEAA115), // Lighter warm beer gold at top
        ],
      ).createShader(Rect.fromLTRB(0, beerY, size.width, size.height));

    final Path beerPath = Path();
    beerPath.moveTo(0, size.height);
    beerPath.lineTo(0, beerY);

    // Beer liquid surface wave animation
    final double waveHeight = 8.0;
    final double waveLength = 40.0;
    for (double x = 0; x <= size.width; x++) {
      double y = beerY + math.sin((x / waveLength) + (progress * 4 * math.pi)) * waveHeight;
      beerPath.lineTo(x, y);
    }
    beerPath.lineTo(size.width, size.height);
    beerPath.close();
    canvas.drawPath(beerPath, beerPaint);

    // 2. Beer Foam (Yellowish-creamy top layer)
    final double foamHeight = 50.0;
    final double foamY = beerY - foamHeight;

    final Paint foamPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          const Color(0xFFF2E6C4), // Foam bottom (cream yellow)
          const Color(0xFFFFFDF0), // Foam top (pure light cream)
        ],
      ).createShader(Rect.fromLTRB(0, foamY, size.width, beerY));

    final Path foamPath = Path();
    foamPath.moveTo(0, beerY);
    foamPath.lineTo(0, foamY);

    // Wavy foam top line
    final double foamWaveHeight = 12.0;
    final double foamWaveLength = 30.0;
    for (double x = 0; x <= size.width; x++) {
      double y = foamY + math.sin((x / foamWaveLength) - (progress * 6 * math.pi)) * foamWaveHeight;
      foamPath.lineTo(x, y);
    }
    foamPath.lineTo(size.width, beerY);

    // Back along the wavy liquid interface
    for (double x = size.width; x >= 0; x--) {
      double y = beerY + math.sin((x / waveLength) + (progress * 4 * math.pi)) * waveHeight;
      foamPath.lineTo(x, y);
    }
    foamPath.close();
    canvas.drawPath(foamPath, foamPaint);

    // 3. Carbonation / Floating Bubbles
    final Paint bubblePaint = Paint()
      ..color = const Color(0xFFFFFDF0).withOpacity(0.35)
      ..style = PaintingStyle.fill;

    final Paint bubbleOutlinePaint = Paint()
      ..color = const Color(0xFFFFFDF0).withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final List<Map<String, double>> bubbles = [
      {'x': 0.1, 'speed': 1.2, 'size': 4},
      {'x': 0.25, 'speed': 1.5, 'size': 6},
      {'x': 0.35, 'speed': 1.0, 'size': 3},
      {'x': 0.5, 'speed': 1.8, 'size': 5},
      {'x': 0.65, 'speed': 1.3, 'size': 7},
      {'x': 0.8, 'speed': 1.6, 'size': 4},
      {'x': 0.9, 'speed': 1.1, 'size': 3},
      {'x': 0.15, 'speed': 1.7, 'size': 5},
      {'x': 0.3, 'speed': 1.4, 'size': 4},
      {'x': 0.45, 'speed': 1.2, 'size': 6},
      {'x': 0.55, 'speed': 1.6, 'size': 3},
      {'x': 0.75, 'speed': 1.3, 'size': 5},
      {'x': 0.85, 'speed': 1.5, 'size': 4},
      {'x': 0.05, 'speed': 1.1, 'size': 3},
      {'x': 0.4, 'speed': 1.9, 'size': 5},
      {'x': 0.7, 'speed': 1.2, 'size': 6},
      {'x': 0.95, 'speed': 1.7, 'size': 4},
      {'x': 0.2, 'speed': 1.3, 'size': 4},
      {'x': 0.6, 'speed': 1.5, 'size': 5},
      {'x': 0.88, 'speed': 1.4, 'size': 3},
    ];

    for (var bubble in bubbles) {
      double relX = bubble['x']!;
      double speed = bubble['speed']!;
      double radius = bubble['size']!;

      double bubbleY = size.height - (progress * speed * size.height * 1.25);
      if (bubbleY < 0) {
        bubbleY = bubbleY % size.height;
      }

      double drift = math.sin((progress * 10) + (relX * 100)) * 6.0;
      double bubbleX = (relX * size.width) + drift;
      bubbleX = bubbleX.clamp(0.0, size.width);

      // Only draw bubbles that are inside the liquid/foam area (below foam top wave)
      if (bubbleY > foamY - 15 && bubbleY < size.height) {
        canvas.drawCircle(Offset(bubbleX, bubbleY), radius, bubblePaint);
        canvas.drawCircle(Offset(bubbleX, bubbleY), radius, bubbleOutlinePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant BeerFoamPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
