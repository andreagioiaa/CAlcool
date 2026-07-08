import 'package:hive/hive.dart';

part 'drink.g.dart';

@HiveType(typeId: 1)
class Drink extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  double volumeMl;

  @HiveField(2)
  double abvPercentage;

  @HiveField(3)
  DateTime consumedAt;

  @HiveField(4)
  double cost;

  Drink({
    required this.name,
    required this.volumeMl,
    required this.abvPercentage,
    required this.consumedAt,
    this.cost = 0.0,
  });

  // Calcolo grammi alcol: Volume * (ABV/100) * 0.8 (densità etanolo)
  double get alcoholGrams => volumeMl * (abvPercentage / 100) * 0.8;

  Map<String, dynamic> toJson() => {
        'name': name,
        'volumeMl': volumeMl,
        'abvPercentage': abvPercentage,
        'consumedAt': consumedAt.toIso8601String(),
        'cost': cost,
      };

  factory Drink.fromJson(Map<String, dynamic> json) {
    return Drink(
      name: json['name'],
      volumeMl: (json['volumeMl'] as num).toDouble(),
      abvPercentage: (json['abvPercentage'] as num).toDouble(),
      consumedAt: DateTime.parse(json['consumedAt']),
      cost: json.containsKey('cost') ? (json['cost'] as num).toDouble() : 0.0,
    );
  }
}
