import 'dart:math';
import '../models/plant_data.dart';

class ApiService {
  final Random _random = Random();
  
  // Base values for each plant
  final Map<String, Map<String, double>> _baseValues = {
    'plant1': {
      'temperature': 22.0,
      'humidity': 65.0,
      'moisture': 70.0,
      'waterLevel': 80.0,
      'airQuality': 85.0,
      'light': 75.0,
    },
    'plant2': {
      'temperature': 23.0,
      'humidity': 60.0,
      'moisture': 65.0,
      'waterLevel': 75.0,
      'airQuality': 80.0,
      'light': 70.0,
    },
  };

  // Generate random variation within a range
  double _getVariation(double baseValue, double range) {
    return baseValue + (_random.nextDouble() * range * 2 - range);
  }

  // Get plant data with random variations
  Future<Map<String, PlantData>> getPlantData() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

    final now = DateTime.now();

    final plant1Data = PlantData(
      temperature: _getVariation(_baseValues['plant1']!['temperature']!, 2.0),
      humidity: _getVariation(_baseValues['plant1']!['humidity']!, 5.0),
      moisture: _getVariation(_baseValues['plant1']!['moisture']!, 10.0),
      waterLevel: _getVariation(_baseValues['plant1']!['waterLevel']!, 5.0),
      airQuality: _getVariation(_baseValues['plant1']!['airQuality']!, 5.0),
      light: _getVariation(_baseValues['plant1']!['light']!, 10.0),
      timestamp: now,
    );

    final plant2Data = PlantData(
      temperature: _getVariation(_baseValues['plant2']!['temperature']!, 2.0),
      humidity: _getVariation(_baseValues['plant2']!['humidity']!, 5.0),
      moisture: _getVariation(_baseValues['plant2']!['moisture']!, 10.0),
      waterLevel: _getVariation(_baseValues['plant2']!['waterLevel']!, 5.0),
      airQuality: _getVariation(_baseValues['plant2']!['airQuality']!, 5.0),
      light: _getVariation(_baseValues['plant2']!['light']!, 10.0),
      timestamp: now,
    );

    print('Generated plant data:');
    print('Plant1: ${plant1Data.toJson()}');
    print('Plant2: ${plant2Data.toJson()}');

    return {
      'plant1': plant1Data,
      'plant2': plant2Data,
    };
  }
} 