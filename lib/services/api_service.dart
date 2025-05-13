import 'dart:math';
import '../models/plant_data.dart';

class ApiService {
  final Random _random = Random();
  
  // Base values for each plant
  final Map<String, Map<String, double>> _baseValues = {
    'plant_a': {
      'temperature': 22.0,
      'humidity': 65.0,
      'moisture': 70.0,
      'water_level': 80.0,
      'air_quality': 85.0,
      'light': 75.0,
    },
    'plant_b': {
      'temperature': 23.0,
      'humidity': 60.0,
      'moisture': 65.0,
      'water_level': 75.0,
      'air_quality': 80.0,
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

    return {
      'plant_a': PlantData(
        temperature: _getVariation(_baseValues['plant_a']!['temperature']!, 2.0),
        humidity: _getVariation(_baseValues['plant_a']!['humidity']!, 5.0),
        moisture: _getVariation(_baseValues['plant_a']!['moisture']!, 10.0),
        waterLevel: _getVariation(_baseValues['plant_a']!['water_level']!, 5.0),
        airQuality: _getVariation(_baseValues['plant_a']!['air_quality']!, 5.0),
        light: _getVariation(_baseValues['plant_a']!['light']!, 10.0),
      ),
      'plant_b': PlantData(
        temperature: _getVariation(_baseValues['plant_b']!['temperature']!, 2.0),
        humidity: _getVariation(_baseValues['plant_b']!['humidity']!, 5.0),
        moisture: _getVariation(_baseValues['plant_b']!['moisture']!, 10.0),
        waterLevel: _getVariation(_baseValues['plant_b']!['water_level']!, 5.0),
        airQuality: _getVariation(_baseValues['plant_b']!['air_quality']!, 5.0),
        light: _getVariation(_baseValues['plant_b']!['light']!, 10.0),
      ),
    };
  }
} 