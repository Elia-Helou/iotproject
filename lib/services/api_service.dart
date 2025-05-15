import 'dart:math';
import '../models/plant_data.dart';

class ApiService {
  final Random _random = Random();
  
  // Base values for each plant
  final Map<String, Map<String, double>> _baseValues = {
    'plant1': {
      'moisture': 550.0,
      'light': 651.0,
    },
    'plant2': {
      'moisture': 594.0,
      'light': 586.0,
    },
  };

  // Generate random variation within a range
  double _getVariation(double baseValue, double range) {
    return baseValue + (_random.nextDouble() * range * 2 - range);
  }

  // Get plant data with random variations
  Future<Map<String, PlantData>> getPlantData() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

    final plant1Data = PlantData(
      moisture: _getVariation(_baseValues['plant1']!['moisture']!, 10.0),
      light: _getVariation(_baseValues['plant1']!['light']!, 10.0),
      rain: false,
      pump: false,
    );

    final plant2Data = PlantData(
      moisture: _getVariation(_baseValues['plant2']!['moisture']!, 10.0),
      light: _getVariation(_baseValues['plant2']!['light']!, 10.0),
      rain: false,
      pump: false,
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