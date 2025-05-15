import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/environment_card.dart';
import '../widgets/plant_card.dart';
import '../providers/plant_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Monitor'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {}); // Trigger a rebuild to refresh the data
            },
          ),
        ],
      ),
      body: Consumer<PlantProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                EnvironmentCard(),
                const SizedBox(height: 16),
                PlantCard(plantId: 'plant1'),
                const SizedBox(height: 16),
                PlantCard(plantId: 'plant2'),
              ],
            ),
          );
        },
      ),
    );
  }
} 