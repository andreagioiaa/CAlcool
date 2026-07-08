import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../onboarding/onboarding_screen.dart';
import '../navigation/main_navigation_screen.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/user_profile.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkInitialState();
  }

  Future<void> _checkInitialState() async {
    await Future.delayed(const Duration(seconds: 2));
    final box = Hive.box<UserProfile>('userBox');
    if (!mounted) return;
    
    if (box.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: AppTheme.neumorphicBox(context, radius: 75),
              child: const Center(
                child: Icon(Icons.water_drop, size: 60, color: AppTheme.primaryColor),
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'CAlcool',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
