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
        if (plantData != null && key.toString().split('_').length > 2) {
          contents.add(MapEntry(key.toString(), plantData));
        }
      }
      
      // Sort by timestamp in descending order (newest first)
      contents.sort((a, b) => b.value.timestamp.compareTo(a.value.timestamp));
      
      // Group by date and timestamp
      final grouped = <String, List<MapEntry<String, PlantData>>>{};
      for (var entry in contents) {
        final date = _dateFormat.format(entry.value.timestamp);
        if (!grouped.containsKey(date)) {
          grouped[date] = [];
        }
        grouped[date]!.add(entry);
      }
      
      setState(() {
        _groupedData = grouped;
      });
    } catch (e) {
      debugPrint('Error loading database contents: $e');
    }
  }

  Future<void> _refreshAndStoreData() async {
    // First fetch new data
    await context.read<PlantProvider>().fetchPlantData();
    // Then reload database contents
    await _loadDatabaseContents();
  }

  String _getPlantName(String key) {
    // Extract plant name from the key (e.g., "plant_a_1234567890" -> "Plant A")
    final plantId = key.split('_')[0] + '_' + key.split('_')[1];
    return plantId == 'plant_a' ? 'Plant A' : 'Plant B';
  }

  Future<void> _deleteEntriesByTimestamp(DateTime timestamp) async {
    try {
      final box = await Hive.openBox<PlantData>('plantData');
      final keysToDelete = <String>[];
      
      // Find all keys that match this timestamp
      for (var key in box.keys) {
        final plantData = box.get(key);
        if (plantData != null && 
            plantData.timestamp.millisecondsSinceEpoch == timestamp.millisecondsSinceEpoch) {
          keysToDelete.add(key.toString());
        }
      }
      
      // Delete all matching entries
      await box.deleteAll(keysToDelete);
      await _loadDatabaseContents(); // Reload the view
      
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
                final date = _groupedData.keys.elementAt(index);
                final entries = _groupedData[date]!;
                
                // Group entries by timestamp
                final entriesByTimestamp = <DateTime, List<MapEntry<String, PlantData>>>{};
                for (var entry in entries) {
                  final timestamp = entry.value.timestamp;
                  if (!entriesByTimestamp.containsKey(timestamp)) {
                    entriesByTimestamp[timestamp] = [];
                  }
                  entriesByTimestamp[timestamp]!.add(entry);
                }
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        date,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ...entriesByTimestamp.entries.map((timestampEntry) {
                      final timestamp = timestampEntry.key;
                      final plantEntries = timestampEntry.value;
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _timeFormat.format(timestamp),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Delete Entries'),
                                          content: Text('Delete entries from ${_timeFormat.format(timestamp)}?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () async {
                                                Navigator.pop(context);
                                                await _deleteEntriesByTimestamp(timestamp);
                                              },
                                              child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            ...plantEntries.map((entry) {
                              final plantData = entry.value;
                              
                              return Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _getPlantName(entry.key),
                                      style: Theme.of(context).textTheme.titleLarge,
                                    ),
                                    const SizedBox(height: 8),
                                    _buildDataRow('Temperature', '${plantData.temperature}°C'),
                                    _buildDataRow('Humidity', '${plantData.humidity}%'),
                                    _buildDataRow('Moisture', plantData.moisture.toString()),
                                    _buildDataRow('Water Level', '${plantData.waterLevel}%'),
                                    _buildDataRow('Air Quality', plantData.airQuality.toString()),
                                    _buildDataRow('Light', plantData.light.toString()),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
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
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _clearAllData() async {
    try {
      final box = await Hive.openBox<PlantData>('plantData');
      await box.clear();
      await _loadDatabaseContents(); // Reload the view
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All data has been deleted'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error clearing database: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error deleting data'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
} 