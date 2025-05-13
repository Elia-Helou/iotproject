import 'package:flutter/material.dart';
import '../models/plant_data.dart';

class PlantCard extends StatelessWidget {
  final String title;
  final PlantData? plantData;

  const PlantCard({
    super.key,
    required this.title,
    required this.plantData,
  });

  @override
  Widget build(BuildContext context) {
    if (plantData == null) {
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
                    title,
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
              _buildDataGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataGrid() {
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
          '${plantData!.temperature.toStringAsFixed(1)}°C',
          Icons.thermostat,
          Colors.orange,
        ),
        _buildDataItem(
          'Humidity',
          '${plantData!.humidity.toStringAsFixed(1)}%',
          Icons.water_drop,
          Colors.blue,
        ),
        _buildDataItem(
          'Moisture',
          '${plantData!.moisture.toStringAsFixed(1)}',
          Icons.grass,
          Colors.green,
        ),
        _buildDataItem(
          'Water Level',
          '${plantData!.waterLevel.toStringAsFixed(1)}%',
          Icons.water,
          Colors.lightBlue,
        ),
        _buildDataItem(
          'Air Quality',
          '${plantData!.airQuality.toStringAsFixed(1)}',
          Icons.air,
          Colors.grey,
        ),
        _buildDataItem(
          'Light',
          '${plantData!.light.toStringAsFixed(1)}',
          Icons.light_mode,
          Colors.amber,
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