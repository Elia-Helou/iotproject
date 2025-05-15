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
  @HiveField(6)
  final DateTime timestamp;

  PlantData({
    required this.temperature,
    required this.humidity,
    required this.moisture,
    required this.waterLevel,
    required this.airQuality,
    required this.light,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory PlantData.fromJson(Map<String, dynamic> json) {
    return PlantData(
      temperature: json['temperature'].toDouble(),
      humidity: json['humidity'].toDouble(),
      moisture: json['moisture'].toDouble(),
      waterLevel: json['water_level'].toDouble(),
      airQuality: json['air_quality'].toDouble(),
      light: json['light'].toDouble(),
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp']) 
          : DateTime.now(),
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
      'timestamp': timestamp.toIso8601String(),
    };
  }

  PlantData copyWith({
    double? temperature,
    double? humidity,
    double? moisture,
    double? waterLevel,
    double? airQuality,
    double? light,
    DateTime? timestamp,
  }) {
    return PlantData(
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      moisture: moisture ?? this.moisture,
      waterLevel: waterLevel ?? this.waterLevel,
      airQuality: airQuality ?? this.airQuality,
      light: light ?? this.light,
      timestamp: timestamp ?? this.timestamp,
    );
  }
} 