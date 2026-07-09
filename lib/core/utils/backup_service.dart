import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/models/user_profile.dart';
import '../../data/models/drink.dart';
import '../../data/models/meal.dart';
import '../../data/models/drink_template.dart';
import '../../providers/providers.dart';
import '../../features/settings/widgets/import_selection_dialog.dart';

class BackupService {
  static Future<void> exportData(BuildContext context) async {
    try {
      final userBox = Hive.box<UserProfile>('userBox');
      final drinksBox = Hive.box<Drink>('drinksBox');
      final mealsBox = Hive.box<Meal>('mealsBox');
      final settingsBox = Hive.box('settingsBox');
      final templatesBox = Hive.box<DrinkTemplate>('drinkTemplatesBox');

      final user = userBox.get('currentUser') ?? (userBox.isNotEmpty ? userBox.getAt(0) : null);
      final drinks = drinksBox.values.toList();
      final meals = mealsBox.values.toList();
      final templates = templatesBox.values.toList();
      final isDarkMode = settingsBox.get('isDarkMode', defaultValue: false);

      final data = {
        'userProfile': user?.toJson(),
        'drinks': drinks.map((d) => d.toJson()).toList(),
        'meals': meals.map((m) => m.toJson()).toList(),
        'drinkTemplates': templates.map((t) => t.toJson()).toList(),
        'settings': {
          'isDarkMode': isDarkMode,
        },
      };

      final jsonStr = jsonEncode(data);
      
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      
      if (selectedDirectory == null) {
        return; // L'utente ha annullato la selezione
      }

      settingsBox.put('lastExportPath', selectedDirectory);
      
      final file = File('$selectedDirectory/calcool_backup.json');
      await file.writeAsString(jsonStr);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup salvato in:\n${file.path}'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore esportazione: $e')),
        );
      }
    }
  }

  static Future<bool> importData(BuildContext context, WidgetRef ref) async {
    try {
      final settingsBox = Hive.box('settingsBox');
      final lastExportPath = settingsBox.get('lastExportPath') as String?;

      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        initialDirectory: lastExportPath,
      );

      if (result == null || result.files.single.path == null) {
        return false; // User cancelled
      }

      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      if (!context.mounted) return false;

      final importResult = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (_) => ImportSelectionDialog(backupData: data),
      );

      if (importResult == null) return false; // User cancelled selection

      bool profileImported = false;

      if (importResult['importProfile'] != null) {
        final profile = importResult['importProfile'] as UserProfile;
        await ref.read(userProfileNotifierProvider.notifier).saveProfile(profile);
        profileImported = true;
      }

      final mergeData = importResult['mergeData'] as bool;

      if (importResult['importDrinks'] != null) {
        final drinks = importResult['importDrinks'] as List<Drink>;
        await ref.read(drinksNotifierProvider.notifier).importDrinks(drinks, merge: mergeData);
      }

      if (importResult['importMeals'] != null) {
        final meals = importResult['importMeals'] as List<Meal>;
        await ref.read(mealsNotifierProvider.notifier).importMeals(meals, merge: mergeData);
      }

      if (importResult['importTemplates'] != null) {
        final templates = importResult['importTemplates'] as List<DrinkTemplate>;
        final notifier = ref.read(drinkTemplatesNotifierProvider.notifier);
        // Evitiamo duplicati o sovrascriviamo se hanno stesso ID
        for (var t in templates) {
          await notifier.addTemplate(t);
        }
      }

      if (importResult['importSettings'] != null) {
        final settings = importResult['importSettings'] as Map<String, dynamic>;
        if (settings.containsKey('isDarkMode')) {
          ref.read(themeModeNotifierProvider.notifier).setThemeMode(settings['isDarkMode'] as bool);
        }
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dati importati con successo!')),
        );
      }

      return profileImported;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore importazione: $e')),
        );
      }
      return false;
    }
  }
}
