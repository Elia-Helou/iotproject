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

  Map<String, Map<String, dynamic>> get plants {
    debugPrint('Getting plants data:');
    debugPrint('Plant1 data: ${_plants['plant1']?.toJson()}');
    debugPrint('Plant2 data: ${_plants['plant2']?.toJson()}');
    
    return {
      'plant1': _plants['plant1'] != null ? {
        'moisture': _plants['plant1']!.moisture,
        'light': _plants['plant1']!.light,
        'temperature': _plants['plant1']!.temperature,
        'humidity': _plants['plant1']!.humidity,
        'waterLevel': _plants['plant1']!.waterLevel,
        'airQuality': _plants['plant1']!.airQuality,
        'timestamp': _plants['plant1']!.timestamp.toIso8601String(),
      } : {},
      'plant2': _plants['plant2'] != null ? {
        'moisture': _plants['plant2']!.moisture,
        'light': _plants['plant2']!.light,
        'temperature': _plants['plant2']!.temperature,
        'humidity': _plants['plant2']!.humidity,
        'waterLevel': _plants['plant2']!.waterLevel,
        'airQuality': _plants['plant2']!.airQuality,
        'timestamp': _plants['plant2']!.timestamp.toIso8601String(),
      } : {},
    };
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get environmentData => _environmentData;

  PlantProvider() {
    // Initialize with default environment data
    _environmentData = {
      'temperature': 25.0,
      'humidity': 60.0,
      'gas': 0.0,
      'waterTank': false,
    };
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final box = await Hive.openBox<PlantData>('plantData');
      debugPrint('Loading initial data from Hive');
      debugPrint('Box contents: ${box.values.toList()}');
      
      if (box.isNotEmpty) {
        // Try to get the latest data for each plant
        final plant1Data = box.get('plant1');
        final plant2Data = box.get('plant2');
        
        debugPrint('Found plant1 data: ${plant1Data?.toJson()}');
        debugPrint('Found plant2 data: ${plant2Data?.toJson()}');
        
        if (plant1Data != null || plant2Data != null) {
          _plants = {
            if (plant1Data != null) 'plant1': plant1Data,
            if (plant2Data != null) 'plant2': plant2Data,
          };
          notifyListeners();
        } else {
          // If no data found, fetch from API
          await fetchPlantData();
        }
      } else {
        // If box is empty, fetch from API
        await fetchPlantData();
      }
    } catch (e) {
      debugPrint('Error loading initial data: $e');
      // If error occurs, fetch from API
      await fetchPlantData();
    }
  }

  Future<void> fetchPlantData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('Fetching plant data from API');
      final newData = await _apiService.getPlantData();
      debugPrint('Received new data: $newData');
      
      _plants = newData;
      
      // Update environment data with values from plant data
      if (_plants['plant1'] != null) {
        _environmentData = {
          'temperature': _plants['plant1']!.temperature,
          'humidity': _plants['plant1']!.humidity,
          'gas': _plants['plant1']!.airQuality,
          'waterTank': _plants['plant1']!.waterLevel > 50,
        };
      }
      
      // Save to Hive with timestamps
      final box = await Hive.openBox<PlantData>('plantData');
      
      // Store data with timestamp as part of the key
      for (var entry in newData.entries) {
        final timestamp = entry.value.timestamp.millisecondsSinceEpoch;
        final key = '${entry.key}_$timestamp';
        await box.put(key, entry.value);
      }
      
      _error = null;
    } catch (e) {
      _error = 'Failed to fetch plant data: $e';
      debugPrint(_error);
      
      // Try to load from Hive if fetch fails
      try {
        final box = await Hive.openBox<PlantData>('plantData');
        if (box.isNotEmpty) {
          final plant1Data = box.get('plant1');
          final plant2Data = box.get('plant2');
          
          if (plant1Data != null || plant2Data != null) {
            _plants = {
              if (plant1Data != null) 'plant1': plant1Data,
              if (plant2Data != null) 'plant2': plant2Data,
            };
          }
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
    debugPrint('Updating from MQTT:');
    debugPrint('Plant1 data: $plant1Data');
    debugPrint('Plant2 data: $plant2Data');
    debugPrint('Environment data: $environmentData');
    
    // Extract shared environment values
    double temperature = environmentData['temperature']?.toDouble() ?? 0.0;
    double humidity = environmentData['humidity']?.toDouble() ?? 0.0;
    double airQuality = environmentData['gas']?.toDouble() ?? 0.0;
    double waterLevel = environmentData['waterTank'] == true ? 100.0 : 0.0;

    final now = DateTime.now();

    _plants['plant1'] = PlantData(
      temperature: temperature,
      humidity: humidity,
      moisture: plant1Data['moisture']?.toDouble() ?? 0.0,
      waterLevel: waterLevel,
      airQuality: airQuality,
      light: plant1Data['light']?.toDouble() ?? 0.0,
      timestamp: now,
    );

    _plants['plant2'] = PlantData(
      temperature: temperature,
      humidity: humidity,
      moisture: plant2Data['moisture']?.toDouble() ?? 0.0,
      waterLevel: waterLevel,
      airQuality: airQuality,
      light: plant2Data['light']?.toDouble() ?? 0.0,
      timestamp: now,
    );

    _environmentData = environmentData;

    _saveToHive();
    notifyListeners();
  }

  Future<void> _saveToHive() async {
    try {
      final box = await Hive.openBox<PlantData>('plantData');
      
      // Store historical data
      for (var entry in _plants.entries) {
        final timestamp = entry.value.timestamp.millisecondsSinceEpoch;
        final key = '${entry.key}_$timestamp';
        await box.put(key, entry.value);
      }
      
      // Store latest data
      await box.putAll(_plants);
      
      debugPrint('Saved to Hive:');
      debugPrint('Plant1 data: ${_plants['plant1']?.toJson()}');
      debugPrint('Plant2 data: ${_plants['plant2']?.toJson()}');
    } catch (e) {
      debugPrint('Error saving to Hive: $e');
    }
  }
} 