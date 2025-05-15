import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/plant_provider.dart';
import '../widgets/plant_card.dart';
import '../widgets/environment_card.dart';
import 'plant_detail_screen.dart';
import 'database_view_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch data when screen loads
    Future.microtask(
      () => context.read<PlantProvider>().fetchPlantData(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Plant Monitor',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.storage, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DatabaseViewScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              context.read<PlantProvider>().fetchPlantData();
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green.shade50,
              Colors.white,
            ],
          ),
        ),
        child: Consumer<PlantProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.green,
                ),
              );
            }

            if (provider.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${provider.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => provider.fetchPlantData(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => provider.fetchPlantData(),
              color: Colors.green,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'My Plants',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      final plantData = provider.plants['plant1'];
                      if (plantData != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlantDetailScreen(
                              title: 'Plant A',
                              plantData: plantData,
                            ),
                          ),
                        );
                      }
                    },
                    child: PlantCard(
                      plantId: 'plant1',
                      plantData: provider.plants['plant1'],
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      final plantData = provider.plants['plant2'];
                      if (plantData != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlantDetailScreen(
                              title: 'Plant B',
                              plantData: plantData,
                            ),
                          ),
                        );
                      }
                    },
                    child: PlantCard(
                      plantId: 'plant2',
                      plantData: provider.plants['plant2'],
                    ),
                  ),
                  const SizedBox(height: 16),
                  EnvironmentCard(
                    environmentData: provider.environmentData,
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement add new plant functionality
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Add new plant functionality coming soon!'),
              backgroundColor: Colors.green,
            ),
          );
        },
        backgroundColor: Colors.green.shade700,
        child: const Icon(Icons.add),
      ),
    );
  }
} 