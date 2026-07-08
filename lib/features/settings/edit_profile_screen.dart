import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/user_profile.dart';
import '../../providers/providers.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _weightController;
  late final TextEditingController _heightController;
  late final TextEditingController _ageController;
  late String _sex;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userProfileNotifierProvider);
    _nameController = TextEditingController(text: profile?.name ?? '');
    _weightController = TextEditingController(text: profile?.weightKg.toString() ?? '');
    _heightController = TextEditingController(text: profile?.heightCm.toString() ?? '');
    _ageController = TextEditingController(text: profile?.age.toString() ?? '');
    _sex = profile?.sex ?? 'Male';
  }

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
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profilo aggiornato!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifica Profilo'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                      'SALVA',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
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
          labelText: hint,
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
