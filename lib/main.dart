import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'data/models/user_profile.dart';
import 'data/models/drink.dart';
import 'data/models/meal.dart';
import 'data/models/drink_template.dart';
import 'providers/providers.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';
import 'core/utils/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  
  Hive.registerAdapter(UserProfileAdapter());
  Hive.registerAdapter(DrinkAdapter());
  Hive.registerAdapter(MealAdapter());
  Hive.registerAdapter(DrinkTemplateAdapter());
  
  await Hive.openBox<UserProfile>('userBox');
  await Hive.openBox<Drink>('drinksBox');
  await Hive.openBox<Meal>('mealsBox');
  await Hive.openBox<DrinkTemplate>('drinkTemplatesBox');
  await Hive.openBox('settingsBox');

  await NotificationService().init();

  runApp(const ProviderScope(child: CAlcoolApp()));
}

class CAlcoolApp extends ConsumerStatefulWidget {
  const CAlcoolApp({super.key});

  @override
  ConsumerState<CAlcoolApp> createState() => _CAlcoolAppState();
}

class _CAlcoolAppState extends ConsumerState<CAlcoolApp> {
  @override
  void initState() {
    super.initState();
    // Inizializza le notifiche ma non chiede permessi in automatico.
    // L'utente li chiederà nelle impostazioni.
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeModeNotifierProvider);

    // Ascolta i cambiamenti del BAC per programmare le notifiche
    ref.listen(bacCalculationProvider, (previous, next) {
      final timeTo05 = next['timeTo05'] as DateTime?;
      final bac = next['bac'] as double;
      final settingsBox = Hive.box('settingsBox');
      final notificationsEnabled = settingsBox.get('notificationsEnabled', defaultValue: false);
      
      if (notificationsEnabled) {
        if (bac > 0.5 && timeTo05 != null && timeTo05.isAfter(DateTime.now())) {
          NotificationService().scheduleSobrietyNotification(timeTo05);
        } else {
          NotificationService().cancelSobrietyNotification();
        }
      }
    });
    
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
