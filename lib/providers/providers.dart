import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../data/models/user_profile.dart';
import '../data/models/drink.dart';
import '../data/models/meal.dart';
import '../data/models/drink_template.dart';
import '../core/utils/bac_calculator_service.dart';
import 'package:flutter/foundation.dart';

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

  void setThemeMode(bool isDarkMode) {
    if (state != isDarkMode) {
      state = isDarkMode;
      Hive.box('settingsBox').put('isDarkMode', state);
    }
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

  Future<void> importDrinks(List<Drink> newDrinks, {bool merge = true}) async {
    final box = Hive.box<Drink>('drinksBox');
    if (!merge) {
      await box.clear();
    }
    for (var drink in newDrinks) {
      final exists = box.values.any((d) =>
          d.name == drink.name &&
          d.consumedAt.isAtSameMomentAs(drink.consumedAt) &&
          d.volumeMl == drink.volumeMl);
      if (!exists) {
        await box.add(drink);
      }
    }
    state = box.values.toList().cast<Drink>();
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

  Future<void> importMeals(List<Meal> newMeals, {bool merge = true}) async {
    final box = Hive.box<Meal>('mealsBox');
    if (!merge) {
      await box.clear();
    }
    for (var meal in newMeals) {
      final exists = box.values.any((m) =>
          m.mealType == meal.mealType &&
          m.consumedAt.isAtSameMomentAs(meal.consumedAt));
      if (!exists) {
        await box.add(meal);
      }
    }
    state = box.values.toList().cast<Meal>();
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

@riverpod
class DrinkTemplatesNotifier extends _$DrinkTemplatesNotifier {
  @override
  List<DrinkTemplate> build() {
    final box = Hive.box<DrinkTemplate>('drinkTemplatesBox');
    if (box.isEmpty) {
      _initDefaultTemplates();
    }
    return box.values.toList().cast<DrinkTemplate>();
  }

  Future<void> _initDefaultTemplates() async {
    final box = Hive.box<DrinkTemplate>('drinkTemplatesBox');
    if (box.isNotEmpty) return;

    final defaultPresets = [
      DrinkTemplate(name: 'Birra Piccola', volumeMl: 330, abvPercentage: 5.0, category: 'Birra', isBuiltIn: true),
      DrinkTemplate(name: 'Birra Media', volumeMl: 500, abvPercentage: 5.0, category: 'Birra', isBuiltIn: true),
      DrinkTemplate(name: 'Calice Vino', volumeMl: 150, abvPercentage: 12.0, category: 'Vino', isBuiltIn: true),
      DrinkTemplate(name: 'Shot Tequila', volumeMl: 40, abvPercentage: 40.0, category: 'Shot', isBuiltIn: true),
      DrinkTemplate(name: 'Shot Jägermeister', volumeMl: 40, abvPercentage: 35.0, category: 'Shot', isBuiltIn: true),
      DrinkTemplate(name: 'Shot Montenegro', volumeMl: 40, abvPercentage: 23.0, category: 'Shot', isBuiltIn: true),
      DrinkTemplate(name: 'Shot Amaro del Capo', volumeMl: 40, abvPercentage: 35.0, category: 'Shot', isBuiltIn: true),
      DrinkTemplate(name: 'Shot Limoncello', volumeMl: 40, abvPercentage: 30.0, category: 'Shot', isBuiltIn: true),
      DrinkTemplate(name: 'Shot Sambuca', volumeMl: 40, abvPercentage: 38.0, category: 'Shot', isBuiltIn: true),
    ];

    for (var preset in defaultPresets) {
      await box.put(preset.id, preset);
    }

    try {
      final String jsonString = await rootBundle.loadString('assets/drinks_presets.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      for (var item in jsonList) {
        final t = DrinkTemplate(
          name: item['name'],
          volumeMl: (item['volumeMl'] as num).toDouble(),
          abvPercentage: (item['abvPercentage'] as num).toDouble(),
          category: 'Cocktail',
          isBuiltIn: true,
        );
        await box.put(t.id, t);
      }
    } catch (e) {
      debugPrint("Errore nel caricamento dei preset: $e");
    }

    state = box.values.toList().cast<DrinkTemplate>();
  }

  Future<void> addTemplate(DrinkTemplate template) async {
    final box = Hive.box<DrinkTemplate>('drinkTemplatesBox');
    await box.put(template.id, template);
    state = box.values.toList().cast<DrinkTemplate>();
  }

  Future<void> updateTemplate(DrinkTemplate template) async {
    await template.save();
    state = Hive.box<DrinkTemplate>('drinkTemplatesBox').values.toList().cast<DrinkTemplate>();
  }

  Future<void> removeTemplate(DrinkTemplate template) async {
    await template.delete();
    state = Hive.box<DrinkTemplate>('drinkTemplatesBox').values.toList().cast<DrinkTemplate>();
  }
}

