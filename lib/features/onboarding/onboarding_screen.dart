import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../navigation/main_navigation_screen.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/user_profile.dart';
import '../../data/models/drink.dart';
import '../../providers/providers.dart';
import '../dashboard/dashboard_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _ageController = TextEditingController();
  String _sex = 'Male';

  void _saveProfile() {
    if (_nameController.text.isEmpty ||
        _weightController.text.isEmpty ||
        _heightController.text.isEmpty ||
        _ageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compila tutti i campi')),
      );
      return;
    }

    final profile = UserProfile(
      name: _nameController.text,
      sex: _sex,
      weightKg: double.parse(_weightController.text),
      heightCm: double.parse(_heightController.text),
      age: int.parse(_ageController.text),
    );

    ref.read(userProfileNotifierProvider.notifier).saveProfile(profile);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
    );
  }

  Future<void> _importData() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Importazione non supportata su Web.')),
      );
      return;
    }
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/calcool_backup.json');

      if (!await file.exists()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nessun file di backup (calcool_backup.json) trovato nella cartella app.')),
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
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
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Text(
                'Benvenuto in CAlcool',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              _buildNeumorphicTextField(context, 'Nome', _nameController, TextInputType.name),
              const SizedBox(height: 20),
              _buildSexSelector(context),
              const SizedBox(height: 20),
              _buildNeumorphicTextField(context, 'Peso (kg)', _weightController, TextInputType.number),
              const SizedBox(height: 20),
              _buildNeumorphicTextField(context, 'Altezza (cm)', _heightController, TextInputType.number),
              const SizedBox(height: 20),
              _buildNeumorphicTextField(context, 'Età', _ageController, TextInputType.number),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: _saveProfile,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: AppTheme.neumorphicBox(context, radius: 30),
                  child: const Center(
                    child: Text(
                      'INIZIA',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _importData,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: AppTheme.neumorphicBox(context, radius: 30),
                  child: const Center(
                    child: Text(
                      'IMPORTA DA BACKUP',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNeumorphicTextField(BuildContext context, String hint, TextEditingController controller, TextInputType type) {
    return Container(
      decoration: AppTheme.neumorphicBox(context, radius: 15, isPressed: true),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
        ),
      ),
    );
  }

  Widget _buildSexSelector(BuildContext context) {
    return Container(
      decoration: AppTheme.neumorphicBox(context, radius: 15, isPressed: true),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _sex,
          isExpanded: true,
          items: ['Male', 'Female'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _sex = val);
          },
        ),
      ),
    );
  }
}
