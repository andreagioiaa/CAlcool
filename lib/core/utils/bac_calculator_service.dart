import '../../data/models/user_profile.dart';
import '../../data/models/drink.dart';
import '../../data/models/meal.dart';

class BacCalculatorService {
  static const double metabolismRate = 0.15; // g/l per ora

  /// Calcola la Total Body Water (TBW) usando la Formula di Watson
  static double calculateTBW(UserProfile user) {
    if (user.sex.toLowerCase() == 'male' || user.sex.toLowerCase() == 'uomo') {
      return 2.447 - (0.09156 * user.age) + (0.1074 * user.heightCm) + (0.3362 * user.weightKg);
    } else {
      return -2.097 + (0.1069 * user.heightCm) + (0.2466 * user.weightKg);
    }
  }

  /// Calcola il BAC attuale considerando le bevande e l'effetto ritardante dei pasti
  static double calculateCurrentBAC(UserProfile user, List<Drink> drinks, List<Meal> meals) {
    if (drinks.isEmpty) return 0.0;
    
    double tbw = calculateTBW(user);
    if (tbw <= 0) return 0.0;
    
    double totalBac = 0.0;
    DateTime now = DateTime.now();

    for (var drink in drinks) {
      if (drink.consumedAt.isAfter(now)) continue; 

      // Trova il miglior fattore protettivo (pasto) per questa bevanda
      double absorptionFactor = 1.0;
      for (var meal in meals) {
        if (meal.consumedAt.isAfter(now)) continue;
        
        // Calcola la distanza temporale in ore (assoluta) tra bevanda e pasto
        final durationHours = drink.consumedAt.difference(meal.consumedAt).inMinutes.abs() / 60.0;
        
        // Se il pasto avviene entro le 3 ore (prima o dopo) dalla bevuta
        if (meal.mealType == 'Full' && durationHours <= 3.0) {
          if (0.75 < absorptionFactor) absorptionFactor = 0.75;
        } else if (meal.mealType == 'Snack' && durationHours <= 1.0) {
          // Se lo spuntino avviene entro 1 ora
          if (0.90 < absorptionFactor) absorptionFactor = 0.90;
        }
      }

      double drinkBac = (drink.alcoholGrams * absorptionFactor * 0.806) / tbw;
      
      double hoursSinceConsumed = now.difference(drink.consumedAt).inMinutes / 60.0;
      double currentDrinkBac = drinkBac - (metabolismRate * hoursSinceConsumed);
      
      if (currentDrinkBac > 0) {
        totalBac += currentDrinkBac;
      }
    }
    return totalBac;
  }

  /// Stima quando il BAC scenderà a un determinato target
  static DateTime? timeToTargetBac(double currentBac, double targetBac) {
    if (currentBac <= targetBac) return DateTime.now();
    double bacToBurn = currentBac - targetBac;
    double hoursNeeded = bacToBurn / metabolismRate;
    return DateTime.now().add(Duration(minutes: (hoursNeeded * 60).round()));
  }
}
