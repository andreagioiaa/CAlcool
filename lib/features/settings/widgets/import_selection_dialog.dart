import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/user_profile.dart';
import '../../../../data/models/drink.dart';
import '../../../../data/models/meal.dart';
import '../../../../data/models/drink_template.dart';

class ImportSelectionDialog extends StatefulWidget {
  final Map<String, dynamic> backupData;

  const ImportSelectionDialog({super.key, required this.backupData});

  @override
  State<ImportSelectionDialog> createState() => _ImportSelectionDialogState();
}

class _ImportSelectionDialogState extends State<ImportSelectionDialog> {
  bool _importProfile = false;
  bool _importDrinks = false;
  bool _importMeals = false;
  bool _importTemplates = false;
  bool _importSettings = false;
  bool _mergeData = true;

  UserProfile? _profile;
  List<Drink> _drinks = [];
  List<Meal> _meals = [];
  List<DrinkTemplate> _drinkTemplates = [];
  Map<String, dynamic>? _settings;

  @override
  void initState() {
    super.initState();
    _parseBackupData();
  }

  void _parseBackupData() {
    final data = widget.backupData;

    // Handle both 'userProfile' and legacy 'user' keys
    final profileJson = data['userProfile'] ?? data['user'];
    if (profileJson != null) {
      try {
        _profile = UserProfile.fromJson(profileJson as Map<String, dynamic>);
        _importProfile = true;
      } catch (_) {}
    }

    if (data['drinks'] != null) {
      try {
        final list = data['drinks'] as List;
        _drinks = list.map((item) => Drink.fromJson(item as Map<String, dynamic>)).toList();
        _importDrinks = _drinks.isNotEmpty;
      } catch (_) {}
    }

    if (data['meals'] != null) {
      try {
        final list = data['meals'] as List;
        _meals = list.map((item) => Meal.fromJson(item as Map<String, dynamic>)).toList();
        _importMeals = _meals.isNotEmpty;
      } catch (_) {}
    }

    if (data['drinkTemplates'] != null) {
      try {
        final list = data['drinkTemplates'] as List;
        _drinkTemplates = list.map((item) => DrinkTemplate.fromJson(item as Map<String, dynamic>)).toList();
        _importTemplates = _drinkTemplates.isNotEmpty;
      } catch (_) {}
    }

    if (data['settings'] != null) {
      try {
        _settings = data['settings'] as Map<String, dynamic>;
        _importSettings = true;
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bg = isDarkMode ? AppTheme.darkBackground : AppTheme.lightBackground;
    final textStyle = TextStyle(color: isDarkMode ? AppTheme.darkText : AppTheme.lightText);
    final cardBg = isDarkMode ? AppTheme.darkShadowDark : Colors.white.withOpacity(0.5);

    return Dialog(
      backgroundColor: bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Importazione Dati',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Seleziona quali elementi desideri ripristinare dal file di backup:',
                style: TextStyle(color: Colors.grey, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    if (_profile != null) ...[
                      CheckboxListTile(
                        title: Text('Profilo Utente', style: textStyle.copyWith(fontWeight: FontWeight.bold)),
                        subtitle: Text('${_profile!.name} (${_profile!.sex == "Male" ? "M" : "F"}, ${_profile!.weightKg.toInt()} kg)', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        value: _importProfile,
                        activeColor: AppTheme.primaryColor,
                        checkColor: Colors.white,
                        onChanged: (val) => setState(() => _importProfile = val ?? false),
                      ),
                      if (_drinks.isNotEmpty || _meals.isNotEmpty || _settings != null) const Divider(height: 1),
                    ],
                    if (_drinks.isNotEmpty) ...[
                      CheckboxListTile(
                        title: Text('Cronologia Bevande', style: textStyle.copyWith(fontWeight: FontWeight.bold)),
                        subtitle: Text('${_drinks.length} bevande registrate', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        value: _importDrinks,
                        activeColor: AppTheme.primaryColor,
                        checkColor: Colors.white,
                        onChanged: (val) => setState(() => _importDrinks = val ?? false),
                      ),
                      if (_meals.isNotEmpty || _settings != null) const Divider(height: 1),
                    ],
                    if (_meals.isNotEmpty) ...[
                      CheckboxListTile(
                        title: Text('Cronologia Pasti', style: textStyle.copyWith(fontWeight: FontWeight.bold)),
                        subtitle: Text('${_meals.length} pasti registrati', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        value: _importMeals,
                        activeColor: AppTheme.primaryColor,
                        checkColor: Colors.white,
                        onChanged: (val) => setState(() => _importMeals = val ?? false),
                      ),
                      if (_drinkTemplates.isNotEmpty || _settings != null) const Divider(height: 1),
                    ],
                    if (_drinkTemplates.isNotEmpty) ...[
                      CheckboxListTile(
                        title: Text('Libreria Drink', style: textStyle.copyWith(fontWeight: FontWeight.bold)),
                        subtitle: Text('${_drinkTemplates.length} drink salvati', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        value: _importTemplates,
                        activeColor: AppTheme.primaryColor,
                        checkColor: Colors.white,
                        onChanged: (val) => setState(() => _importTemplates = val ?? false),
                      ),
                      if (_settings != null) const Divider(height: 1),
                    ],
                    if (_settings != null) ...[
                      CheckboxListTile(
                        title: Text('Impostazioni Applicazione', style: textStyle.copyWith(fontWeight: FontWeight.bold)),
                        subtitle: const Text('Tema scuro e altre preferenze', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        value: _importSettings,
                        activeColor: AppTheme.primaryColor,
                        checkColor: Colors.white,
                        onChanged: (val) => setState(() => _importSettings = val ?? false),
                      ),
                    ],
                  ],
                ),
              ),
              if (_drinks.isNotEmpty || _meals.isNotEmpty) ...[
                const SizedBox(height: 15),
                Container(
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: CheckboxListTile(
                    title: Text('Unisci con dati esistenti', style: textStyle.copyWith(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Se deselezionato, la cronologia corrente sul dispositivo verrà sovrascritta.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    value: _mergeData,
                    activeColor: AppTheme.primaryColor,
                    checkColor: Colors.white,
                    onChanged: (val) => setState(() => _mergeData = val ?? false),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, null),
                    child: const Text(
                      'ANNULLA',
                      style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    onPressed: (_importProfile || _importDrinks || _importMeals || _importTemplates || _importSettings)
                        ? () {
                            Navigator.pop(context, {
                              if (_importProfile && _profile != null) 'importProfile': _profile,
                              if (_importDrinks && _drinks.isNotEmpty) 'importDrinks': _drinks,
                              if (_importMeals && _meals.isNotEmpty) 'importMeals': _meals,
                              if (_importTemplates && _drinkTemplates.isNotEmpty) 'importTemplates': _drinkTemplates,
                              if (_importSettings && _settings != null) 'importSettings': _settings,
                              'mergeData': _mergeData,
                            });
                          }
                        : null, // Disabled if nothing is selected
                    child: const Text('IMPORTA', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
