import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 0)
class UserProfile extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String sex; // "Male" o "Female"

  @HiveField(2)
  double weightKg;

  @HiveField(3)
  double heightCm;

  @HiveField(4)
  int age;

  UserProfile({
    required this.name,
    required this.sex,
    required this.weightKg,
    required this.heightCm,
    required this.age,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'sex': sex,
        'weightKg': weightKg,
        'heightCm': heightCm,
        'age': age,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'],
      sex: json['sex'],
      weightKg: (json['weightKg'] as num).toDouble(),
      heightCm: (json['heightCm'] as num).toDouble(),
      age: json['age'] as int,
    );
  }
}
