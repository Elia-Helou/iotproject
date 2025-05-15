import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/mqtt_service.dart';
import '../providers/plant_provider.dart';

class PlantCard extends StatelessWidget {
  final String plantId;
  final Map<String, dynamic>? plantData;
  final MQTTService _mqttService = MQTTService();

  PlantCard({
    super.key,
    required this.plantId,
    this.plantData,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PlantProvider>(
      builder: (context, provider, child) {
        // Try to get data from MQTT service first, then fall back to passed data
        final data = plantId == 'plant1' 
            ? _mqttService.getLastPlant1Data() ?? plantData
            : _mqttService.getLastPlant2Data() ?? plantData;

        if (data == null) {
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: Text('No data available')),
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
                  Colors.green.shade50,
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
                        'Plant $plantId',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.green.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.green.shade700,
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
          'Moisture',
          '${data['moisture']}',
          Icons.water_drop,
          Colors.blue,
        ),
        _buildDataItem(
          'Light',
          '${data['light']}',
          Icons.light_mode,
          Colors.amber,
        ),
        _buildDataItem(
          'Rain',
          data['rain'] == true ? 'Yes' : 'No',
          Icons.grain,
          Colors.grey,
        ),
        _buildDataItem(
          'Pump',
          data['pump'] == true ? 'On' : 'Off',
          Icons.opacity,
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