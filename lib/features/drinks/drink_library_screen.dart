import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../data/models/drink_template.dart';
import '../../data/models/drink.dart';

class DrinkLibraryScreen extends ConsumerStatefulWidget {
  const DrinkLibraryScreen({super.key});

  @override
  ConsumerState<DrinkLibraryScreen> createState() => _DrinkLibraryScreenState();
}

class _DrinkLibraryScreenState extends ConsumerState<DrinkLibraryScreen> {
  String _selectedCategory = 'Tutti';

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'birra':
        return Icons.sports_bar;
      case 'vino':
        return Icons.wine_bar;
      case 'shot':
        return Icons.local_drink;
      case 'cocktail':
        return Icons.local_bar;
      default:
        return Icons.local_cafe;
    }
  }

  int _getTimesConsumed(String name) {
    final box = Hive.box<Drink>('drinksBox');
    return box.values.where((d) => d.name.toLowerCase() == name.toLowerCase()).length;
  }

  void _showDrinkDetails(DrinkTemplate template) {
    final ratingController = TextEditingController(text: template.rating.toString());
    final notesController = TextEditingController(text: template.notes);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            int currentRating = int.tryParse(ratingController.text) ?? template.rating;
            return Padding(
              padding: EdgeInsets.only(
                left: 24.0,
                right: 24.0,
                top: 24.0,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24.0,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_getCategoryIcon(template.category), size: 40, color: AppTheme.primaryColor),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Text(
                            template.name,
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${template.volumeMl.toStringAsFixed(0)} ml  •  ${template.abvPercentage.toStringAsFixed(1)}% Vol',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: AppTheme.neumorphicBox(context, radius: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Text('Bevuto', style: TextStyle(color: Colors.grey)),
                              const SizedBox(height: 5),
                              Text('${_getTimesConsumed(template.name)} volte', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Valutazione Personale', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < currentRating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 32,
                          ),
                          onPressed: () {
                            setModalState(() {
                              currentRating = index + 1;
                              ratingController.text = currentRating.toString();
                            });
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: AppTheme.neumorphicBox(context, radius: 15),
                      child: TextField(
                        controller: notesController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'Aggiungi note personali...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        onPressed: () {
                          template.rating = currentRating;
                          template.notes = notesController.text;
                          ref.read(drinkTemplatesNotifierProvider.notifier).updateTemplate(template);
                          Navigator.pop(ctx);
                        },
                        child: const Text('Salva', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        );
      },
    );
  }

  void _showEditOrDeleteDialog(DrinkTemplate t) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(t.name, style: Theme.of(context).textTheme.titleLarge),
        content: const Text('Cosa desideri fare con questo drink personalizzato?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showEditDrinkTemplateDialog(t);
            },
            child: const Text('Modifica', style: TextStyle(color: AppTheme.primaryColor)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showConfirmDeleteTemplateDialog(t);
            },
            child: const Text('Elimina', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annulla', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  void _showEditDrinkTemplateDialog(DrinkTemplate t) {
    final nameController = TextEditingController(text: t.name);
    final volumeController = TextEditingController(text: t.volumeMl.toStringAsFixed(0));
    final abvController = TextEditingController(text: t.abvPercentage.toStringAsFixed(1));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text('Modifica Drink'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nome')),
              TextField(controller: volumeController, decoration: const InputDecoration(labelText: 'Volume (ml)'), keyboardType: TextInputType.number),
              TextField(controller: abvController, decoration: const InputDecoration(labelText: 'Gradazione (%)'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annulla', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white),
            onPressed: () {
              final vol = double.tryParse(volumeController.text.replaceAll(',', '.')) ?? 0;
              final abv = double.tryParse(abvController.text.replaceAll(',', '.')) ?? 0;
              if (nameController.text.isNotEmpty && vol > 0 && abv > 0) {
                t.name = nameController.text;
                t.volumeMl = vol;
                t.abvPercentage = abv;
                ref.read(drinkTemplatesNotifierProvider.notifier).updateTemplate(t);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Salva'),
          ),
        ],
      ),
    );
  }

  void _showConfirmDeleteTemplateDialog(DrinkTemplate t) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text('Elimina Drink'),
        content: Text('Sei sicuro di voler eliminare permanentemente "${t.name}" dalla tua libreria?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annulla', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              ref.read(drinkTemplatesNotifierProvider.notifier).removeTemplate(t);
              Navigator.pop(ctx);
            },
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
  }

  void _showAddDrinkTemplateDialog() {
    final nameController = TextEditingController();
    final volumeController = TextEditingController();
    final abvController = TextEditingController();
    String category = _selectedCategory;
    if (['Tutti', 'Preferiti', 'I miei drink'].contains(category)) {
      category = 'Cocktail'; // Default
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text('Nuovo Drink', style: Theme.of(context).textTheme.titleLarge),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nome')),
              TextField(controller: volumeController, decoration: const InputDecoration(labelText: 'Volume (ml)'), keyboardType: TextInputType.number),
              TextField(controller: abvController, decoration: const InputDecoration(labelText: 'Gradazione (%)'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annulla', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white),
            onPressed: () {
              final vol = double.tryParse(volumeController.text.replaceAll(',', '.')) ?? 0;
              final abv = double.tryParse(abvController.text.replaceAll(',', '.')) ?? 0;
              if (nameController.text.isNotEmpty && vol > 0 && abv > 0) {
                final newTemplate = DrinkTemplate(
                  name: nameController.text,
                  volumeMl: vol,
                  abvPercentage: abv,
                  category: category,
                  isBuiltIn: false,
                );
                ref.read(drinkTemplatesNotifierProvider.notifier).addTemplate(newTemplate);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Aggiungi'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final templates = ref.watch(drinkTemplatesNotifierProvider);
    
    // Filtriamo
    List<DrinkTemplate> filtered = templates;
    if (_selectedCategory != 'Tutti') {
      if (_selectedCategory == 'Preferiti') {
        filtered = templates.where((t) => t.rating >= 4).toList();
      } else if (_selectedCategory == 'I miei drink') {
        filtered = templates.where((t) => !t.isBuiltIn).toList();
      } else {
        filtered = templates.where((t) => t.category.toLowerCase() == _selectedCategory.toLowerCase()).toList();
      }
    }
    
    // Sort: custom drinks first, then alphabetically
    filtered.sort((a, b) {
      if (a.isBuiltIn == b.isBuiltIn) {
        return a.name.compareTo(b.name);
      }
      return a.isBuiltIn ? 1 : -1;
    });

    final categories = ['Tutti', 'Preferiti', 'I miei drink', 'Cocktail', 'Birra', 'Vino', 'Shot'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Libreria Drink', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              itemCount: categories.length,
              itemBuilder: (ctx, index) {
                final cat = categories[index];
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 10, top: 10, bottom: 10),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: isSelected
                          ? BoxDecoration(
                              color: AppTheme.primaryColor,
                              borderRadius: BorderRadius.circular(20),
                            )
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
            child: ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: filtered.length + 1,
              itemBuilder: (ctx, index) {
                if (index == filtered.length) {
                  String catName = ['Tutti', 'Preferiti', 'I miei drink'].contains(_selectedCategory) ? 'Drink' : _selectedCategory;
                  return GestureDetector(
                    onTap: _showAddDrinkTemplateDialog,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 25, top: 10),
                      padding: const EdgeInsets.all(15),
                      decoration: AppTheme.neumorphicBox(context, radius: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add, color: AppTheme.primaryColor),
                          const SizedBox(width: 10),
                          Text('Inserisci nuovo $catName', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                        ],
                      ),
                    ),
                  );
                }

                final t = filtered[index];
                final timesConsumed = _getTimesConsumed(t.name);
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  decoration: AppTheme.neumorphicBox(context, radius: 15),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(_getCategoryIcon(t.category), color: AppTheme.primaryColor),
                    ),
                    title: Row(
                      children: [
                        Expanded(child: Text(t.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                        if (t.rating > 0)
                          Row(
                            children: [
                              Text(t.rating.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                              const Icon(Icons.star, color: Colors.amber, size: 16),
                            ],
                          ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        Text('${t.volumeMl.toStringAsFixed(0)} ml • ${t.abvPercentage.toStringAsFixed(1)}%'),
                        if (timesConsumed > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text('Bevuto $timesConsumed volte', style: const TextStyle(color: AppTheme.primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
                          )
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () => _showDrinkDetails(t),
                    onLongPress: () {
                      if (t.isBuiltIn) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('I drink predefiniti non possono essere modificati o eliminati.')),
                        );
                        return;
                      }
                      _showEditOrDeleteDialog(t);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
