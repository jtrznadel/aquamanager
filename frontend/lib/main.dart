import 'package:flutter/material.dart';
import 'config/theme.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(const AquaManagerApp());
}

class AquaManagerApp extends StatelessWidget {
  const AquaManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AquaManager Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const DashboardScreen(),
    );
  }
}
