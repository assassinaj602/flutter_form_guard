import 'package:flutter/material.dart';
import 'screens/basic_form.dart';
import 'screens/multi_step_form.dart';
import 'screens/custom_storage_form.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Form Guard Demo',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Form Guard Examples')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildNavCard(
            context,
            title: 'Basic Validation & Analytics',
            subtitle:
                'Standard text fields with email, password, and matching rules.',
            icon: Icons.check_circle_outline,
            screen: const BasicFormScreen(),
          ),
          _buildNavCard(
            context,
            title: 'Multi-Step Wizard',
            subtitle: 'Form state persisting across multiple steps.',
            icon: Icons.format_list_numbered,
            screen: const MultiStepFormScreen(),
          ),
          _buildNavCard(
            context,
            title: 'Custom Storage Provider',
            subtitle:
                'Demonstrating custom storage (Mock Hive implementation).',
            icon: Icons.storage,
            screen: const CustomStorageFormScreen(),
          ),
        ],
      ),
    );
  }

  Widget _buildNavCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget screen,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, size: 32, color: Theme.of(context).primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        },
      ),
    );
  }
}
