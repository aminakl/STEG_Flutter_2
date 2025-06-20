import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'STEG LOTO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          primary: Colors.blue,
          secondary: Colors.orange,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: const DemoScreen(),
    );
  }
}

class DemoScreen extends StatelessWidget {
  const DemoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('STEG LOTO Demo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Welcome to STEG LOTO App'),
            const SizedBox(height: 16),
            _buildFeatureCard(
              'Multi-Stage Validation Process',
              'The app implements a comprehensive multi-stage validation process:\n'
              '• Draft → Pending Chef Base → Pending Charge Exploitation → Validated/Rejected\n'
              '• Each stage involves different user roles with specific permissions',
              Icons.check_circle_outline,
              Colors.blue,
            ),
            _buildFeatureCard(
              'In-App Notification System',
              'Real-time notifications for workflow events:\n'
              '• Note creation, validation, and rejection\n'
              '• Assignment notifications\n'
              '• Consignation and deconsignation process updates',
              Icons.notifications_active,
              Colors.orange,
            ),
            _buildFeatureCard(
              'Admin KPI Dashboard',
              'Comprehensive metrics for administrators:\n'
              '• Process metrics (validation time, completion rate)\n'
              '• User activity metrics\n'
              '• Status distribution and trends',
              Icons.dashboard,
              Colors.green,
            ),
            _buildFeatureCard(
              'Role-Based Access Control',
              'Different user roles with specific permissions:\n'
              '• ADMIN: Full access to all features\n'
              '• CHEF_EXPLOITATION: Creates lockout notes\n'
              '• CHEF_DE_BASE: First stage validation\n'
              '• CHARGE_EXPLOITATION: Second stage validation\n'
              '• CHARGE_CONSIGNATION: Performs consignation process',
              Icons.security,
              Colors.purple,
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Demo User Accounts'),
            const SizedBox(height: 16),
            _buildUserCard('ADMIN001', 'admin123', 'ADMIN', 'Full system access'),
            _buildUserCard('CHEF001', 'admin123', 'CHEF_EXPLOITATION', 'Creates notes'),
            _buildUserCard('BASE001', 'admin123', 'CHEF_DE_BASE', 'First validation'),
            _buildUserCard('CHARGEX001', 'admin123', 'CHARGE_EXPLOITATION', 'Second validation'),
            _buildUserCard('CHARGE001', 'admin123', 'CHARGE_CONSIGNATION', 'Performs consignation'),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
    );
  }

  Widget _buildFeatureCard(String title, String description, IconData icon, Color color) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(String matricule, String password, String role, String description) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Text(
            matricule[0],
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(matricule),
        subtitle: Text('$role - $description'),
        trailing: Text(
          'Password: $password',
          style: const TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
