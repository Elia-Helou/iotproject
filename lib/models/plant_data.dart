import 'package:hive/hive.dart';

part 'plant_data.g.dart';

@HiveType(typeId: 0)
class PlantData {
  @HiveField(0)
  final double moisture;
  @HiveField(1)
  final double light;
  @HiveField(2)
  final bool rain;
  @HiveField(3)
  final bool pump;

  PlantData({
    required this.moisture,
    required this.light,
    required this.rain,
    required this.pump,
  });

  factory PlantData.fromJson(Map<String, dynamic> json) {
    return PlantData(
      moisture: json['moisture'].toDouble(),
      light: json['light'].toDouble(),
      rain: json['rain'] ?? false,
      pump: json['pump'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'moisture': moisture,
      'light': light,
      'rain': rain,
      'pump': pump,
    };
  }

  PlantData copyWith({
    double? moisture,
    double? light,
    bool? rain,
    bool? pump,
  }) {
    return PlantData(
      moisture: moisture ?? this.moisture,
      light: light ?? this.light,
      rain: rain ?? this.rain,
      pump: pump ?? this.pump,
    );
  }
} 