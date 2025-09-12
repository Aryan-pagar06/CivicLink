import 'package:flutter/material.dart'; // Add this import

enum Department {
  roadsAndInfrastructure('Roads & Infrastructure', '🚧', Colors.orange),
  sanitation('Sanitation', '🗑️', Colors.green),
  waterAndSewage('Water & Sewage', '💧', Colors.blue),
  electricity('Electricity', '💡', Colors.yellow),
  publicWorks('Public Works', '🏗️', Colors.purple),
  planningAndDevelopment('Planning & Development', '📋', Colors.brown),
  emergencyServices('Emergency Services', '🚨', Colors.red);

  final String displayName;
  final String emoji;
  final Color color;

  const Department(this.displayName, this.emoji, this.color);
}