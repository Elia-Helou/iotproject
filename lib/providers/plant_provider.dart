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
      'plant1': _plants['plant1']?.toJson() ?? {},
      'plant2': _plants['plant2']?.toJson() ?? {},
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
      
      if (box.isNotEmpty) {
        final plant1Data = box.get('plant1');
        final plant2Data = box.get('plant2');
        
        if (plant1Data != null || plant2Data != null) {
          _plants = {
            if (plant1Data != null) 'plant1': plant1Data,
            if (plant2Data != null) 'plant2': plant2Data,
          };
          notifyListeners();
        } else {
          await fetchPlantData();
        }
      } else {
        await fetchPlantData();
      }
    } catch (e) {
      debugPrint('Error loading initial data: $e');
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
      
      // Save to Hive
      final box = await Hive.openBox<PlantData>('plantData');
      await box.putAll(_plants);
      
      _error = null;
    } catch (e) {
      _error = 'Failed to fetch plant data: $e';
      debugPrint(_error);
      
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

    _plants['plant1'] = PlantData(
      moisture: plant1Data['moisture'].toDouble(),
      light: plant1Data['light'].toDouble(),
      rain: plant1Data['rain'] ?? false,
      pump: plant1Data['pump'] ?? false,
    );

    _plants['plant2'] = PlantData(
      moisture: plant2Data['moisture'].toDouble(),
      light: plant2Data['light'].toDouble(),
      rain: plant2Data['rain'] ?? false,
      pump: plant2Data['pump'] ?? false,
    );

    _environmentData = environmentData;

    _saveToHive();
    notifyListeners();
  }

  Future<void> _saveToHive() async {
    try {
      final box = await Hive.openBox<PlantData>('plantData');
      await box.putAll(_plants);
      
      debugPrint('Saved to Hive:');
      debugPrint('Plant1 data: ${_plants['plant1']?.toJson()}');
      debugPrint('Plant2 data: ${_plants['plant2']?.toJson()}');
    } catch (e) {
      debugPrint('Error saving to Hive: $e');
    }
  }
} 