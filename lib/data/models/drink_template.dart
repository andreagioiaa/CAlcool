import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'drink_template.g.dart';

@HiveType(typeId: 3)
class DrinkTemplate extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double volumeMl;

  @HiveField(3)
  double abvPercentage;

  @HiveField(4)
  String category;

  @HiveField(5)
  int rating; // 1 to 5, 0 = non valutato

  @HiveField(6)
  String notes;

  @HiveField(7)
  bool isBuiltIn;

  DrinkTemplate({
    String? id,
    required this.name,
    required this.volumeMl,
    required this.abvPercentage,
    required this.category,
    this.rating = 0,
    this.notes = '',
    this.isBuiltIn = false,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'volumeMl': volumeMl,
        'abvPercentage': abvPercentage,
        'category': category,
        'rating': rating,
        'notes': notes,
        'isBuiltIn': isBuiltIn,
      };

  factory DrinkTemplate.fromJson(Map<String, dynamic> json) {
    return DrinkTemplate(
      id: json['id'],
      name: json['name'],
      volumeMl: (json['volumeMl'] as num).toDouble(),
      abvPercentage: (json['abvPercentage'] as num).toDouble(),
      category: json['category'] ?? 'Altro',
      rating: json['rating'] ?? 0,
      notes: json['notes'] ?? '',
      isBuiltIn: json['isBuiltIn'] ?? false,
    );
  }
}
