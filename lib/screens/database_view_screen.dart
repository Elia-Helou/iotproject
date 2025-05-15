import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/plant_data.dart';
import '../providers/plant_provider.dart';
import 'package:provider/provider.dart';

class DatabaseViewScreen extends StatefulWidget {
  const DatabaseViewScreen({super.key});

  @override
  State<DatabaseViewScreen> createState() => _DatabaseViewScreenState();
}

class _DatabaseViewScreenState extends State<DatabaseViewScreen> {
  Map<String, List<MapEntry<String, PlantData>>> _groupedData = {};
  final _dateFormat = DateFormat('MMM dd, yyyy');
  final _timeFormat = DateFormat('HH:mm:ss');

  @override
  void initState() {
    super.initState();
    _loadDatabaseContents();
  }

  Future<void> _loadDatabaseContents() async {
    try {
      final box = await Hive.openBox<PlantData>('plantData');
      final contents = <MapEntry<String, PlantData>>[];
      
      for (var key in box.keys) {
        final plantData = box.get(key);
        if (plantData != null) {
          contents.add(MapEntry(key.toString(), plantData));
        }
      }
      
      // Group by plant
      final grouped = <String, List<MapEntry<String, PlantData>>>{};
      for (var entry in contents) {
        final plantName = _getPlantName(entry.key);
        if (!grouped.containsKey(plantName)) {
          grouped[plantName] = [];
        }
        grouped[plantName]!.add(entry);
      }
      
      setState(() {
        _groupedData = grouped;
      });
    } catch (e) {
      debugPrint('Error loading database contents: $e');
    }
  }

  Future<void> _refreshAndStoreData() async {
    await context.read<PlantProvider>().fetchPlantData();
    await _loadDatabaseContents();
  }

  String _getPlantName(String key) {
    try {
      if (key.startsWith('plant1')) {
        return 'Plant A';
      } else if (key.startsWith('plant2')) {
        return 'Plant B';
      } else {
        return 'Plant Data';
      }
    } catch (e) {
      debugPrint('Error getting plant name: $e');
      return 'Plant Data';
    }
  }

  Future<void> _deleteEntriesByPlant(String plantName) async {
    try {
      final box = await Hive.openBox<PlantData>('plantData');
      final keysToDelete = <String>[];
      
      for (var key in box.keys) {
        if (_getPlantName(key.toString()) == plantName) {
          keysToDelete.add(key.toString());
        }
      }
      
      await box.deleteAll(keysToDelete);
      await _loadDatabaseContents();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selected entries have been deleted'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error deleting entries: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error deleting entries'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _clearAllData() async {
    try {
      final box = await Hive.openBox<PlantData>('plantData');
      await box.clear();
      await _loadDatabaseContents();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All data has been deleted'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error clearing data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error clearing data'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Contents'),
        backgroundColor: Colors.green.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete All Data'),
                  content: const Text('Are you sure you want to delete all data from the database? This action cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _clearAllData();
                      },
                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshAndStoreData,
          ),
        ],
      ),
      body: _groupedData.isEmpty
          ? const Center(child: Text('No data in database'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _groupedData.length,
              itemBuilder: (context, index) {
                final plantName = _groupedData.keys.elementAt(index);
                final entries = _groupedData[plantName]!;
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          plantName,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Entries'),
                                content: Text('Delete all entries for $plantName?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      await _deleteEntriesByPlant(plantName);
                                    },
                                    child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      ...entries.map((entry) {
                        final plantData = entry.value;
                        
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDataRow('Moisture', '${plantData.moisture.toStringAsFixed(1)}'),
                              const SizedBox(height: 8),
                              _buildDataRow('Light', '${plantData.light.toStringAsFixed(1)}'),
                              const SizedBox(height: 8),
                              _buildDataRow('Rain', plantData.rain ? 'Yes' : 'No'),
                              const SizedBox(height: 8),
                              _buildDataRow('Pump', plantData.pump ? 'On' : 'Off'),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
} 