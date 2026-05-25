import 'package:flutter/material.dart';

class OrderLine {
  const OrderLine({
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.icon,
    required this.gradientStart,
    required this.gradientEnd,
  });

  final String name;
  final int quantity;
  final int unitPrice;
  final IconData icon;
  final Color gradientStart;
  final Color gradientEnd;

  int get lineTotal => unitPrice * quantity;
}
