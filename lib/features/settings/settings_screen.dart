import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../core/utils/backup_service.dart';
import '../../core/utils/notification_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'edit_profile_screen.dart';
import '../drinks/drink_library_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  Future<void> _exportData() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Esportazione non supportata su Web.')),
      );
      return;
    }
    await BackupService.exportData(context);
  }

  Future<void> _importData() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Importazione non supportata su Web.')),
      );
      return;
    }
    await BackupService.importData(context, ref);
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
              ValueListenableBuilder(
                valueListenable: Hive.box('settingsBox').listenable(keys: ['notificationsEnabled']),
                builder: (context, box, widget) {
                  final notificationsEnabled = box.get('notificationsEnabled', defaultValue: false);
                  return _buildSettingItem(
                    context,
                    title: 'Notifiche (Sotto 0.5 BAC)',
                    icon: Icons.notifications_active,
                    trailing: Switch(
                      value: notificationsEnabled,
                      onChanged: (val) async {
                        if (val) {
                          final granted = await NotificationService().requestPermissions();
                          box.put('notificationsEnabled', granted);
                          if (!granted && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Permessi per le notifiche non concessi.')),
                            );
                          }
                        } else {
                          box.put('notificationsEnabled', false);
                          await NotificationService().cancelSobrietyNotification();
                        }
                      },
                      activeThumbColor: AppTheme.primaryColor,
                    ),
                  );
                },
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
