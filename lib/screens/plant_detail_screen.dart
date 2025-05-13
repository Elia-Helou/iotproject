import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/plant_data.dart';

class PlantDetailScreen extends StatelessWidget {
  final String title;
  final PlantData plantData;

  const PlantDetailScreen({
    super.key,
    required this.title,
    required this.plantData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(context),
            const SizedBox(height: 24),
            _buildChart(context),
            const SizedBox(height: 24),
            _buildDetailedInfo(context),
            const SizedBox(height: 24),
            _buildWaterButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Status',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatusIconValue(
                          context,
                          Icons.thermostat,
                          '${plantData.temperature.toStringAsFixed(1)}°C',
                          _getTemperatureColor(plantData.temperature),
                        ),
                        _buildStatusIconValue(
                          context,
                          Icons.water_drop,
                          '${plantData.humidity.toStringAsFixed(1)}%',
                          _getHumidityColor(plantData.humidity),
                        ),
                        _buildStatusIconValue(
                          context,
                          Icons.grass,
                          '${plantData.moisture.toStringAsFixed(1)}',
                          _getMoistureColor(plantData.moisture),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        Text('Temperature', style: TextStyle(fontSize: 12)),
                        Text('Humidity', style: TextStyle(fontSize: 12)),
                        Text('Moisture', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIconValue(BuildContext context, IconData icon, String value, Color color) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildChart(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sensor Readings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        FlSpot(0, plantData.temperature),
                        FlSpot(1, plantData.humidity),
                        FlSpot(2, plantData.moisture),
                        FlSpot(3, plantData.waterLevel),
                        FlSpot(4, plantData.airQuality),
                        FlSpot(5, plantData.light),
                      ],
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedInfo(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detailed Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Water Level', '${plantData.waterLevel}%', Icons.water),
            _buildInfoRow('Air Quality', '${plantData.airQuality}', Icons.air),
            _buildInfoRow('Light Level', '${plantData.light}', Icons.light_mode),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.green),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          // TODO: Implement watering
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Watering command sent!'),
              backgroundColor: Colors.green,
            ),
          );
        },
        icon: const Icon(Icons.water_drop),
        label: const Text('Water Now'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  Color _getTemperatureColor(double temp) {
    if (temp < 20) return Colors.blue;
    if (temp > 30) return Colors.red;
    return Colors.green;
  }

  Color _getHumidityColor(double humidity) {
    if (humidity < 40) return Colors.orange;
    if (humidity > 80) return Colors.blue;
    return Colors.green;
  }

  Color _getMoistureColor(double moisture) {
    if (moisture < 300) return Colors.red;
    if (moisture > 400) return Colors.blue;
    return Colors.green;
  }
} 