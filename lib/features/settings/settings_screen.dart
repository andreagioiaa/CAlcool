import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../data/models/user_profile.dart';
import '../../data/models/drink.dart';
import 'edit_profile_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  Future<void> _exportData() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Esportazione non supportata su Web. Usa un dispositivo iOS/Android.')),
      );
      return;
    }
    try {
      final userBox = Hive.box<UserProfile>('userBox');
      final drinksBox = Hive.box<Drink>('drinksBox');

      final user = userBox.get('currentUser');
      final drinks = drinksBox.values.toList();

      final data = {
        'user': user?.toJson(),
        'drinks': drinks.map((d) => d.toJson()).toList(),
      };

      final jsonStr = jsonEncode(data);
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/calcool_backup.json');
      await file.writeAsString(jsonStr);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dati esportati con successo in: ${file.path}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore esportazione: $e')),
      );
    }
  }

  Future<void> _importData() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Importazione non supportata su Web. Usa un dispositivo iOS/Android.')),
      );
      return;
    }
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/calcool_backup.json');

      if (!await file.exists()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nessun file di backup trovato (calcool_backup.json).')),
        );
        return;
      }

      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      if (data.containsKey('userProfile') && data['userProfile'] != null) {
        final profile = UserProfile.fromJson(data['userProfile']);
        await ref.read(userProfileNotifierProvider.notifier).saveProfile(profile);
      }

      if (data.containsKey('drinks')) {
        final drinksList = data['drinks'] as List;
        final drinksNotifier = ref.read(drinksNotifierProvider.notifier);
        await drinksNotifier.clearDrinks();
        for (var d in drinksList) {
          await drinksNotifier.addDrink(Drink.fromJson(d));
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dati importati con successo')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore importazione: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeModeNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Impostazioni'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSettingItem(
                context,
                title: 'Modifica Profilo',
                icon: Icons.person,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
              ),
              const SizedBox(height: 20),
              _buildSettingItem(
                context,
                title: 'Tema Scuro',
                icon: Icons.dark_mode,
                trailing: Switch(
                  value: isDarkMode,
                  onChanged: (val) => ref.read(themeModeNotifierProvider.notifier).toggle(),
                  activeThumbColor: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 20),
              _buildSettingItem(
                context,
                title: 'Esporta Dati (JSON)',
                icon: Icons.upload_file,
                onTap: _exportData,
              ),
              const SizedBox(height: 20),
              _buildSettingItem(
                context,
                title: 'Importa Dati (JSON)',
                icon: Icons.file_download,
                onTap: _importData,
              ),
              const Spacer(),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'DISCLAIMER MEDICO\nQuesta app fornisce stime matematiche basate sulle formule di Watson e Widmark. Non ha alcuna valenza medico-legale. Non guidare mai dopo aver bevuto.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Un Applicazione disegnata e scritta da Andrea Gioia',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.primaryColor, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem(BuildContext context, {required String title, required IconData icon, Widget? trailing, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: AppTheme.neumorphicBox(context, radius: 15),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryColor),
            const SizedBox(width: 15),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 16))),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }
}
