import 'dart:async';
import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
// import 'package:provider/provider.dart'; // Removed unused import
import '../providers/plant_provider.dart';
import 'package:hive/hive.dart';

class MQTTService {
  static final MQTTService _instance = MQTTService._internal();
  factory MQTTService() => _instance;
  MQTTService._internal();

  MqttServerClient? _client;
  final String _broker = '192.168.177.10';
  final int _port = 1883;
  final String _clientIdentifier = 'flutter_client_${DateTime.now().millisecondsSinceEpoch}';
  final String _topic = 'plant_system/sensor_data';
  PlantProvider? _plantProvider;
  final Box _box = Hive.box('sensorData');
  bool _isConnected = false;
  StreamController<Map<String, dynamic>>? _messageController;

  void setPlantProvider(PlantProvider provider) {
    _plantProvider = provider;
  }

  Future<void> connect() async {
    if (_isConnected) {
      print('Already connected to MQTT broker');
      return;
    }

    try {
      _client = MqttServerClient(_broker, _clientIdentifier);
      _client!.port = _port;
      _client!.keepAlivePeriod = 60;
      _client!.logging(on: true);
      _client!.secure = false;
      _client!.onDisconnected = _onDisconnected;
      _client!.onConnected = _onConnected;
      _client!.onSubscribed = _onSubscribed;

      final connMess = MqttConnectMessage()
          .withClientIdentifier(_clientIdentifier)
          .withWillQos(MqttQos.exactlyOnce)
          .withWillTopic('plant_system/status')
          .withWillMessage('disconnected');
      _client!.connectionMessage = connMess;

      print('Connecting to MQTT broker at $_broker:$_port...');
      print('Client ID: $_clientIdentifier');
      
      await _client!.connect();
      
      // Wait for connection to be established
      await Future.delayed(const Duration(seconds: 1));
      
      if (_client!.connectionStatus?.state == MqttConnectionState.connected) {
        _isConnected = true;
        print('Connected successfully to MQTT broker');
        print('Subscribing to topic: $_topic');
        _client!.subscribe(_topic, MqttQos.exactlyOnce);
        
        // Initialize message controller if not already done
        _messageController ??= StreamController<Map<String, dynamic>>.broadcast();
        
        // Listen for messages
        _client!.updates?.listen(_onMessage);
      } else {
        print('Failed to connect to MQTT broker. State: ${_client!.connectionStatus?.state}');
        print('Connection status: ${_client!.connectionStatus}');
        _isConnected = false;
        _client!.disconnect();
      }
    } catch (e, stackTrace) {
      print('Exception during MQTT connection: $e');
      print('Stack trace: $stackTrace');
      _isConnected = false;
      _client?.disconnect();
    }
  }

  void _onConnected() {
    print('Connected to MQTT broker');
    _isConnected = true;
  }

  void _onDisconnected() {
    print('Disconnected from MQTT broker');
    _isConnected = false;
  }

  void _onSubscribed(String topic) {
    print('Subscribed to topic: $topic');
  }

  void _onMessage(List<MqttReceivedMessage<MqttMessage>> messages) {
    final message = messages[0].payload as MqttPublishMessage;
    final payload = MqttPublishPayload.bytesToStringAsString(message.payload.message);
    print('Received message: $payload');
    
    try {
      final data = json.decode(payload);
      print('Parsed data: $data');
      
      // Log plant1 data
      if (data['plant1'] != null) {
        print('Plant1 Data:');
        print('  Moisture: ${data['plant1']['moisture']}');
        print('  Light: ${data['plant1']['light']}');
        print('  Rain: ${data['plant1']['rain']}');
        print('  Pump: ${data['plant1']['pump']}');
      }
      
      // Log plant2 data
      if (data['plant2'] != null) {
        print('Plant2 Data:');
        print('  Moisture: ${data['plant2']['moisture']}');
        print('  Light: ${data['plant2']['light']}');
        print('  Rain: ${data['plant2']['rain']}');
        print('  Pump: ${data['plant2']['pump']}');
      }
      
      // Log environment data
      if (data['environment'] != null) {
        print('Environment Data:');
        print('  Temperature: ${data['environment']['temperature']}');
        print('  Humidity: ${data['environment']['humidity']}');
        print('  Gas: ${data['environment']['gas']}');
        print('  Water Tank: ${data['environment']['waterTank']}');
      }

      // Add data to stream if controller exists
      _messageController?.add(data);
    } catch (e, stackTrace) {
      print('Error parsing message: $e');
      print('Stack trace: $stackTrace');
    }
  }

  Map<String, dynamic>? getLastEnvironmentData() {
    final data = _box.get('lastEnvironmentData');
    print('Getting environment data from Hive: $data');
    return data;
  }

  Map<String, dynamic>? getLastPlant1Data() {
    final data = _box.get('lastPlant1Data');
    print('Getting plant1 data from Hive: $data');
    return data;
  }

  Map<String, dynamic>? getLastPlant2Data() {
    final data = _box.get('lastPlant2Data');
    print('Getting plant2 data from Hive: $data');
    return data;
  }

  Stream<Map<String, dynamic>>? get messageStream => _messageController?.stream;

  void disconnect() {
    _isConnected = false;
    _client?.disconnect();
    _messageController?.close();
    _messageController = null;
  }

  bool get isConnected => _isConnected;
} 