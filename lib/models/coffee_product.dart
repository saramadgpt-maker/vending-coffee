import 'package:flutter/material.dart';

class CoffeeProduct {
  const CoffeeProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.icon,
    required this.color,
    required this.gradientStart,
    required this.gradientEnd,
  });

  final String id;
  final String name;
  final int price;
  final IconData icon;
  final Color color;
  final Color gradientStart;
  final Color gradientEnd;

  LinearGradient get cardGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [gradientStart, gradientEnd],
      );
}
