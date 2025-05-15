import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/mqtt_service.dart';
import '../providers/plant_provider.dart';

class EnvironmentCard extends StatelessWidget {
  final Map<String, dynamic>? environmentData;
  final MQTTService _mqttService = MQTTService();

  EnvironmentCard({
    super.key,
    this.environmentData,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PlantProvider>(
      builder: (context, provider, child) {
        // Try to get data from MQTT service first, then fall back to passed data
        final data = _mqttService.getLastEnvironmentData() ?? environmentData;

        if (data == null) {
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Environment',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.blue.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (!_mqttService.isConnected)
                    const Text(
                      'Connecting to MQTT broker...',
                      style: TextStyle(color: Colors.orange),
                    )
                  else
                    const Text(
                      'No data available',
                      style: TextStyle(color: Colors.grey),
                    ),
                ],
              ),
            ),
          );
        }

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade50,
                  Colors.white,
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Environment',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.blue.shade700,
                        size: 16,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDataGrid(data),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDataGrid(Map<String, dynamic> data) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 2.5,
      children: [
        _buildDataItem(
          'Temperature',
          '${data['temperature']?.toStringAsFixed(1)}°C',
          Icons.thermostat,
          Colors.orange,
        ),
        _buildDataItem(
          'Humidity',
          '${data['humidity']?.toStringAsFixed(1)}%',
          Icons.water_drop,
          Colors.blue,
        ),
        _buildDataItem(
          'Air Quality',
          '${data['gas']?.toStringAsFixed(0)}',
          Icons.air,
          Colors.grey,
        ),
        _buildDataItem(
          'Water Tank',
          data['waterTank'] == true ? 'Full' : 'Empty',
          Icons.water,
          Colors.lightBlue,
        ),
      ],
    );
  }

  Widget _buildDataItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: color.withOpacity(0.8),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 