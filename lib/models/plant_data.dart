import 'package:hive/hive.dart';

part 'plant_data.g.dart';

@HiveType(typeId: 0)
class PlantData {
  @HiveField(0)
  final double temperature;
  @HiveField(1)
  final double humidity;
  @HiveField(2)
  final double moisture;
  @HiveField(3)
  final double waterLevel;
  @HiveField(4)
  final double airQuality;
  @HiveField(5)
  final double light;

  PlantData({
    required this.temperature,
    required this.humidity,
    required this.moisture,
    required this.waterLevel,
    required this.airQuality,
    required this.light,
  });

  factory PlantData.fromJson(Map<String, dynamic> json) {
    return PlantData(
      temperature: json['temperature'].toDouble(),
      humidity: json['humidity'].toDouble(),
      moisture: json['moisture'].toDouble(),
      waterLevel: json['water_level'].toDouble(),
      airQuality: json['air_quality'].toDouble(),
      light: json['light'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'moisture': moisture,
      'water_level': waterLevel,
      'air_quality': airQuality,
      'light': light,
    };
  }

  PlantData copyWith({
    double? temperature,
    double? humidity,
    double? moisture,
    double? waterLevel,
    double? airQuality,
    double? light,
  }) {
    return PlantData(
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      moisture: moisture ?? this.moisture,
      waterLevel: waterLevel ?? this.waterLevel,
      airQuality: airQuality ?? this.airQuality,
      light: light ?? this.light,
    );
  }
} 