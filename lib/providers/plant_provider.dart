import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/plant_data.dart';
import '../services/api_service.dart';

class PlantProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  Map<String, PlantData> _plants = {};
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic> _environmentData = {};

  Map<String, PlantData> get plants => _plants;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get environmentData => _environmentData;

  PlantProvider() {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final box = await Hive.openBox<PlantData>('plantData');
      if (box.isNotEmpty) {
        _plants = {
          'plant_a': box.get('plant_a')!,
          'plant_b': box.get('plant_b')!,
        };
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading initial data: $e');
    }
  }

  Future<void> fetchPlantData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newData = await _apiService.getPlantData();
      _plants = newData;
      
      // Save to Hive
      final box = await Hive.openBox<PlantData>('plantData');
      await box.putAll(newData);
      
      _error = null;
    } catch (e) {
      _error = 'Failed to fetch plant data: $e';
      debugPrint(_error);
      
      // Try to load from Hive if fetch fails
      try {
        final box = await Hive.openBox<PlantData>('plantData');
        if (box.isNotEmpty) {
          _plants = {
            'plant_a': box.get('plant_a')!,
            'plant_b': box.get('plant_b')!,
          };
        }
      } catch (e) {
        debugPrint('Error loading from Hive: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void updateFromMqtt(Map<String, dynamic> plant1Data, Map<String, dynamic> plant2Data, Map<String, dynamic> environmentData) {
    // Extract shared environment values
    double temperature = environmentData['temperature']?.toDouble() ?? 0.0;
    double humidity = environmentData['humidity']?.toDouble() ?? 0.0;
    double airQuality = environmentData['gas']?.toDouble() ?? 0.0;
    double waterLevel = environmentData['waterTank'] == true ? 100.0 : 0.0;

    _plants['plant1'] = PlantData(
      temperature: temperature,
      humidity: humidity,
      moisture: plant1Data['moisture']?.toDouble() ?? 0.0,
      waterLevel: waterLevel,
      airQuality: airQuality,
      light: plant1Data['light']?.toDouble() ?? 0.0,
    );

    _plants['plant2'] = PlantData(
      temperature: temperature,
      humidity: humidity,
      moisture: plant2Data['moisture']?.toDouble() ?? 0.0,
      waterLevel: waterLevel,
      airQuality: airQuality,
      light: plant2Data['light']?.toDouble() ?? 0.0,
    );

    _environmentData = environmentData;

    _saveToHive();
    notifyListeners();
  }

  Future<void> _saveToHive() async {
    try {
      final box = await Hive.openBox<PlantData>('plantData');
      await box.putAll(_plants);
    } catch (e) {
      debugPrint('Error saving to Hive: $e');
    }
  }
} 