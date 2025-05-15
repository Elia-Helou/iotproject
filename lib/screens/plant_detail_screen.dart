import 'package:flutter/material.dart';

class PlantDetailScreen extends StatelessWidget {
  final String title;
  final Map<String, dynamic> plantData;

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
                          Icons.grass,
                          '${plantData['moisture']?.toStringAsFixed(1)}',
                          _getMoistureColor(plantData['moisture']?.toDouble() ?? 0),
                        ),
                        _buildStatusIconValue(
                          context,
                          Icons.light_mode,
                          '${plantData['light']?.toStringAsFixed(1)}',
                          _getLightColor(plantData['light']?.toDouble() ?? 0),
                        ),
                        _buildStatusIconValue(
                          context,
                          Icons.water_drop,
                          plantData['rain'] == true ? 'Yes' : 'No',
                          plantData['rain'] == true ? Colors.blue : Colors.grey,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        Text('Moisture', style: TextStyle(fontSize: 12)),
                        Text('Light', style: TextStyle(fontSize: 12)),
                        Text('Rain', style: TextStyle(fontSize: 12)),
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
            _buildInfoRow('Moisture', '${plantData['moisture']?.toStringAsFixed(1)}', Icons.grass),
            _buildInfoRow('Light', '${plantData['light']?.toStringAsFixed(1)}', Icons.light_mode),
            _buildInfoRow('Rain', plantData['rain'] == true ? 'Yes' : 'No', Icons.water_drop),
            _buildInfoRow('Pump', plantData['pump'] == true ? 'On' : 'Off', Icons.water),
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

  Color _getMoistureColor(double moisture) {
    if (moisture < 300) return Colors.red;
    if (moisture > 400) return Colors.blue;
    return Colors.green;
  }

  Color _getLightColor(double light) {
    if (light < 500) return Colors.orange;
    if (light > 700) return Colors.amber;
    return Colors.green;
  }
} 