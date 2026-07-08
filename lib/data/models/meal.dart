import 'package:hive/hive.dart';

part 'meal.g.dart';

@HiveType(typeId: 2)
class Meal extends HiveObject {
  @HiveField(0)
  String mealType; // 'Snack' o 'Full'

  @HiveField(1)
  DateTime consumedAt;

  Meal({
    required this.mealType,
    required this.consumedAt,
  });

  Map<String, dynamic> toJson() => {
        'mealType': mealType,
        'consumedAt': consumedAt.toIso8601String(),
      };

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      mealType: json['mealType'],
      consumedAt: DateTime.parse(json['consumedAt']),
    );
  }
}
