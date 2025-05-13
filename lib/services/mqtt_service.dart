import 'dart:async';
import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:provider/provider.dart';
import '../providers/plant_provider.dart';

class MqttService {
  MqttServerClient? _client;
  final String _broker = 'YOUR_RASPBERRY_PI_IP'; // Replace with your Raspberry Pi's IP
  final int _port = 1883;
  final String _clientIdentifier = 'flutter_client';
  final String _topic = 'plant_data'; // The topic your Raspberry Pi is publishing to
  PlantProvider? _plantProvider;

  void setPlantProvider(PlantProvider provider) {
    _plantProvider = provider;
  }

  Future<void> connect() async {
    _client = MqttServerClient(_broker, _clientIdentifier);
    _client!.port = _port;
    _client!.keepAlivePeriod = 60;
    _client!.onDisconnected = onDisconnected;
    _client!.onConnected = onConnected;
    _client!.onSubscribed = onSubscribed;

    final connMess = MqttConnectMessage()
        .withClientIdentifier(_clientIdentifier)
        .withWillQos(MqttQos.atLeastOnce);
    _client!.connectionMessage = connMess;

    try {
      await _client!.connect();
    } catch (e) {
      print('Exception: $e');
      _client!.disconnect();
    }
  }

  void onConnected() {
    print('Connected to MQTT broker');
    subscribeToTopic();
  }

  void onDisconnected() {
    print('Disconnected from MQTT broker');
  }

  void onSubscribed(String topic) {
    print('Subscribed to topic: $topic');
  }

  void subscribeToTopic() {
    _client!.subscribe(_topic, MqttQos.atLeastOnce);
    _client!.updates?.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
      final message = messages[0].payload as MqttPublishMessage;
      final payload = MqttPublishPayload.bytesToStringAsString(message.payload.message);
      processMessage(payload);
    });
  }

  void processMessage(String payload) {
    try {
      final Map<String, dynamic> data = json.decode(payload);
      
      // Extract plant data
      final plant1Data = data['plant1'];
      final plant2Data = data['plant2'];
      final environmentData = data['environment'];

      // Update the PlantProvider with the new data
      _plantProvider?.updateFromMqtt(plant1Data, plant2Data, environmentData);
    } catch (e) {
      print('Error processing message: $e');
    }
  }

  void disconnect() {
    _client?.disconnect();
  }
} 