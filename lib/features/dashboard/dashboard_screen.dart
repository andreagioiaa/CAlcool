import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../data/models/drink.dart';
import '../../data/models/meal.dart';
import '../settings/settings_screen.dart';

import '../../data/models/drink_template.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'birra': return Icons.sports_bar;
      case 'vino': return Icons.wine_bar;
      case 'shot': return Icons.local_drink;
      case 'cocktail': return Icons.local_bar;
      default: return Icons.local_cafe;
    }
  }

  void _showPresetSelectionDialog() {
    String selectedCategory = 'Preferiti';
    final categories = ['Preferiti', 'Cocktail', 'Birra', 'Vino', 'Shot', 'I miei drink'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final templates = ref.read(drinkTemplatesNotifierProvider);
          
          List<DrinkTemplate> filtered = templates;
          if (selectedCategory == 'Preferiti') {
            filtered = templates.where((t) => t.rating >= 4).toList();
            if (filtered.isEmpty) {
              // Fallback to top 6 if no favorites
              filtered = templates.take(6).toList();
            }
          } else if (selectedCategory == 'I miei drink') {
            filtered = templates.where((t) => !t.isBuiltIn).toList();
          } else {
            filtered = templates.where((t) => t.category.toLowerCase() == selectedCategory.toLowerCase()).toList();
          }

          return Padding(
            padding: EdgeInsets.only(
              left: 24.0,
              right: 24.0,
              top: 24.0,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24.0,
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Scegli Bevanda', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (ctx, index) {
                        final cat = categories[index];
                        final isSelected = selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 10, bottom: 10),
                          child: GestureDetector(
                            onTap: () {
                              setModalState(() {
                                selectedCategory = cat;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                              decoration: isSelected
                                  ? BoxDecoration(color: AppTheme.primaryColor, borderRadius: BorderRadius.circular(20))
                                  : AppTheme.neumorphicBox(context, radius: 20),
                              child: Center(
                                child: Text(
                                  cat,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 15,
                        runSpacing: 15,
                        alignment: WrapAlignment.center,
                        children: filtered.map((preset) => _buildPresetButton(preset, ctx)).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(ctx);
                      _showAddDrinkDialog();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: AppTheme.neumorphicBox(context, radius: 20),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.edit, color: AppTheme.primaryColor),
                          SizedBox(width: 10),
                          Text('Personalizzata', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      ),
    );
  }

  Widget _buildPresetButton(DrinkTemplate preset, BuildContext ctx) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(ctx);
        _showAddDrinkDialog(preset: preset);
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.38,
        padding: const EdgeInsets.all(15),
        decoration: AppTheme.neumorphicBox(context, radius: 15),
        child: Column(
          children: [
            Icon(_getCategoryIcon(preset.category), color: AppTheme.primaryColor, size: 30),
            const SizedBox(height: 10),
            Text(preset.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
            Text('${preset.volumeMl.toInt()}ml • ${preset.abvPercentage}%', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  void _showAddDrinkDialog({DrinkTemplate? preset}) {
    final nameController = TextEditingController(text: preset?.name ?? '');
    final volumeController = TextEditingController(text: preset != null ? preset.volumeMl.toString() : '');
    final abvController = TextEditingController(text: preset != null ? preset.abvPercentage.toString() : '');
    final costController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateBuilder) => AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text(preset != null ? 'Conferma Bevanda' : 'Aggiungi Bevanda', style: Theme.of(context).textTheme.titleLarge),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nome (es. Birra)')),
                TextField(controller: volumeController, decoration: const InputDecoration(labelText: 'Volume (ml)'), keyboardType: TextInputType.number),
                TextField(controller: abvController, decoration: const InputDecoration(labelText: 'Gradazione (%)'), keyboardType: TextInputType.number),
                TextField(controller: costController, decoration: const InputDecoration(labelText: 'Costo (€) (Opzionale)'), keyboardType: TextInputType.number),
                const SizedBox(height: 20),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Orario consumazione'),
                  subtitle: Text(selectedTime.format(context)),
                  trailing: const Icon(Icons.access_time, color: AppTheme.primaryColor),
                  onTap: () async {
                    final TimeOfDay? time = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (time != null) {
                      setStateBuilder(() => selectedTime = time);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annulla')),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && volumeController.text.isNotEmpty && abvController.text.isNotEmpty) {
                  final now = DateTime.now();
                  final consumedAt = DateTime(now.year, now.month, now.day, selectedTime.hour, selectedTime.minute);
                  
                  final drink = Drink(
                    name: nameController.text,
                    volumeMl: double.parse(volumeController.text.replaceAll(',', '.')),
                    abvPercentage: double.parse(abvController.text.replaceAll(',', '.')),
                    consumedAt: consumedAt,
                    cost: costController.text.isNotEmpty ? double.parse(costController.text.replaceAll(',', '.')) : 0.0,
                  );
                  ref.read(drinksNotifierProvider.notifier).addDrink(drink);
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Salva'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMealDialog() {
    String selectedMeal = 'Snack';
    TimeOfDay selectedTime = TimeOfDay.now();
    
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateBuilder) => AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text('Aggiungi Pasto', style: Theme.of(context).textTheme.titleLarge),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Cosa hai mangiato? Questo ridurrà l\'assorbimento dell\'alcol per le prossime ore.'),
              const SizedBox(height: 20),
              DropdownButton<String>(
                value: selectedMeal,
                isExpanded: true,
                items: ['Snack', 'Full'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value == 'Snack' 
                        ? 'Spuntino (~300kcal, es. snack)' 
                        : 'Pasto Completo (>600kcal, cena)',
                      style: const TextStyle(fontSize: 13),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setStateBuilder(() => selectedMeal = val);
                },
              ),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Orario consumazione'),
                subtitle: Text(selectedTime.format(context)),
                trailing: const Icon(Icons.access_time, color: AppTheme.primaryColor),
                onTap: () async {
                  final TimeOfDay? time = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );
                  if (time != null) {
                    setStateBuilder(() => selectedTime = time);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annulla')),
            ElevatedButton(
              onPressed: () {
                final now = DateTime.now();
                final consumedAt = DateTime(now.year, now.month, now.day, selectedTime.hour, selectedTime.minute);
                final meal = Meal(
                  mealType: selectedMeal,
                  consumedAt: consumedAt,
                );
                ref.read(mealsNotifierProvider.notifier).addMeal(meal);
                Navigator.pop(ctx);
              },
              child: const Text('Conferma'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProfileNotifierProvider);
    final bacData = ref.watch(bacCalculationProvider);
    final drinks = ref.watch(drinksNotifierProvider);
    final meals = ref.watch(mealsNotifierProvider);
    
    final bac = bacData['bac'] as double;
    final timeTo05 = bacData['timeTo05'] as DateTime?;
    final timeTo00 = bacData['timeTo00'] as DateTime?;

    // Prepara la timeline (oggi)
    final now = DateTime.now();
    final List<dynamic> timelineEvents = [...drinks, ...meals].where((e) {
      final date = e is Drink ? e.consumedAt : (e as Meal).consumedAt;
      return date.year == now.year && date.month == now.month && date.day == now.day;
    }).toList();
    
    timelineEvents.sort((a, b) {
      final dateA = a is Drink ? a.consumedAt : (a as Meal).consumedAt;
      final dateB = b is Drink ? b.consumedAt : (b as Meal).consumedAt;
      // Ordine cronologico crescente (dal più vecchio al più recente nella giornata)
      return dateA.compareTo(dateB);
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Image.asset(
          'assets/logo_CAlcool.png',
          height: 40,
          fit: BoxFit.contain,
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Center(
            child: Text(
              'Ciao ${user?.name ?? ''}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        leadingWidth: 100,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppTheme.primaryColor),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // BAC Display
              Container(
                padding: const EdgeInsets.all(32),
                decoration: AppTheme.neumorphicBox(context, radius: 20),
                child: Column(
                  children: [
                    const Text('BAC Attuale', style: TextStyle(fontSize: 18, color: Colors.grey)),
                    const SizedBox(height: 10),
                    Text(
                      '${bac.toStringAsFixed(3)} g/l',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: bac > 0.5 ? AppTheme.dangerColor : AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              
              // Timers Display
              if (bac > 0.0) ...[
                Row(
                  children: [
                    Expanded(
                      child: _buildTimerBox(
                        context,
                        'Torna a 0.5',
                        timeTo05 != null && bac > 0.5 ? '${timeTo05.hour.toString().padLeft(2, '0')}:${timeTo05.minute.toString().padLeft(2, '0')}' : '--:--',
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildTimerBox(
                        context,
                        'Smaltimento',
                        timeTo00 != null ? '${timeTo00.hour.toString().padLeft(2, '0')}:${timeTo00.minute.toString().padLeft(2, '0')}' : '--:--',
                      ),
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 20),
              if (timelineEvents.isNotEmpty) ...[
                const Text('Timeline di Oggi', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 10),
              ],
              Expanded(
                child: timelineEvents.isEmpty 
                  ? const Center(child: Text('Nessun inserimento oggi', style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                  itemCount: timelineEvents.length,
                  itemBuilder: (ctx, index) {
                    final event = timelineEvents[index];
                    final isDrink = event is Drink;
                    final date = isDrink ? (event as Drink).consumedAt : (event as Meal).consumedAt;
                    final timeStr = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(15),
                      decoration: AppTheme.neumorphicBox(context, radius: 15),
                      child: Row(
                        children: [
                          Icon(isDrink ? Icons.local_bar : Icons.restaurant, color: AppTheme.primaryColor),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(isDrink ? (event as Drink).name : ((event as Meal).mealType == 'Full' ? 'Pasto Completo' : 'Spuntino'), style: const TextStyle(fontWeight: FontWeight.bold)),
                                if (isDrink) Text('${(event as Drink).volumeMl.toInt()}ml - ${(event as Drink).abvPercentage}% ABV', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ),
                          Text(timeStr, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              
              // Bottoni Aggiungi
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _showAddMealDialog,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: AppTheme.neumorphicBox(context, radius: 30),
                        child: const Center(
                          child: Column(
                            children: [
                              Icon(Icons.restaurant, color: AppTheme.primaryColor),
                              SizedBox(height: 5),
                              Text('PASTO', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor, fontSize: 13)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: _showPresetSelectionDialog,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: AppTheme.neumorphicBox(context, radius: 30),
                        child: const Center(
                          child: Column(
                            children: [
                              Icon(Icons.local_bar, color: AppTheme.primaryColor),
                              SizedBox(height: 5),
                              Text('BEVANDA', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimerBox(BuildContext context, String label, String time) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.neumorphicBox(context, radius: 15),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey), textAlign: TextAlign.center),
          const SizedBox(height: 10),
          Text(
            time,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
