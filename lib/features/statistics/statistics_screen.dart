import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drinks = ref.watch(drinksNotifierProvider);
    final totalCost = drinks.fold<double>(0, (sum, drink) => sum + drink.cost);
    final totalDrinks = drinks.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiche'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: AppTheme.neumorphicBox(context, radius: 20),
                child: Column(
                  children: [
                    const Icon(Icons.pie_chart, size: 60, color: AppTheme.primaryColor),
                    const SizedBox(height: 20),
                    const Text('Spesa Totale', style: TextStyle(fontSize: 18, color: Colors.grey)),
                    const SizedBox(height: 10),
                    Text(
                      '€ ${totalCost.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                    ),
                    const SizedBox(height: 20),
                    Text('Bevande totali: $totalDrinks', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                  ],
                ),
              ),
              const Spacer(),
              const Text(
                'Presto in arrivo: Grafici avanzati e storico temporale.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              )
            ],
          ),
        ),
      ),
    );
  }
}
