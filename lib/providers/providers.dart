import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/models/user_profile.dart';
import '../data/models/drink.dart';
import '../data/models/meal.dart';
import '../core/utils/bac_calculator_service.dart';

part 'providers.g.dart';

@riverpod
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  bool build() {
    final box = Hive.box('settingsBox');
    return box.get('isDarkMode', defaultValue: false);
  }

  void toggle() {
    state = !state;
    Hive.box('settingsBox').put('isDarkMode', state);
  }
}

@riverpod
class UserProfileNotifier extends _$UserProfileNotifier {
  @override
  UserProfile? build() {
    final box = Hive.box<UserProfile>('userBox');
    if (box.isNotEmpty) {
      return box.getAt(0);
    }
    return null;
  }

  Future<void> saveProfile(UserProfile profile) async {
    final box = Hive.box<UserProfile>('userBox');
    if (box.isEmpty) {
      await box.add(profile);
    } else {
      await box.putAt(0, profile);
    }
    state = profile;
  }
}

@riverpod
class DrinksNotifier extends _$DrinksNotifier {
  @override
  List<Drink> build() {
    final box = Hive.box<Drink>('drinksBox');
    return box.values.toList().cast<Drink>();
  }

  Future<void> addDrink(Drink drink) async {
    final box = Hive.box<Drink>('drinksBox');
    await box.add(drink);
    state = box.values.toList().cast<Drink>();
  }

  Future<void> clearDrinks() async {
    final box = Hive.box<Drink>('drinksBox');
    await box.clear();
    state = [];
  }
}

@riverpod
class MealsNotifier extends _$MealsNotifier {
  @override
  List<Meal> build() {
    final box = Hive.box<Meal>('mealsBox');
    return box.values.toList().cast<Meal>();
  }

  Future<void> addMeal(Meal meal) async {
    final box = Hive.box<Meal>('mealsBox');
    await box.add(meal);
    state = box.values.toList().cast<Meal>();
  }

  Future<void> clearMeals() async {
    final box = Hive.box<Meal>('mealsBox');
    await box.clear();
    state = [];
  }
}

@riverpod
Map<String, dynamic> bacCalculation(BacCalculationRef ref) {
  final user = ref.watch(userProfileNotifierProvider);
  final drinks = ref.watch(drinksNotifierProvider);
  final meals = ref.watch(mealsNotifierProvider);

  if (user == null) {
    return {'bac': 0.0, 'timeTo05': null, 'timeTo00': null};
  }

  final bac = BacCalculatorService.calculateCurrentBAC(user, drinks, meals);
  final timeTo05 = BacCalculatorService.timeToTargetBac(bac, 0.5);
  final timeTo00 = BacCalculatorService.timeToTargetBac(bac, 0.0);

  return {
    'bac': bac,
    'timeTo05': timeTo05,
    'timeTo00': timeTo00,
  };
}
