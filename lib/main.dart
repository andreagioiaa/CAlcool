import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'data/models/user_profile.dart';
import 'data/models/drink.dart';
import 'data/models/meal.dart';
import 'providers/providers.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  
  Hive.registerAdapter(UserProfileAdapter());
  Hive.registerAdapter(DrinkAdapter());
  Hive.registerAdapter(MealAdapter());
  
  await Hive.openBox<UserProfile>('userBox');
  await Hive.openBox<Drink>('drinksBox');
  await Hive.openBox<Meal>('mealsBox');
  await Hive.openBox('settingsBox');

  runApp(const ProviderScope(child: CAlcoolApp()));
}

class CAlcoolApp extends ConsumerWidget {
  const CAlcoolApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeModeNotifierProvider);
    
    return MaterialApp(
      title: 'CAlcool',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}
