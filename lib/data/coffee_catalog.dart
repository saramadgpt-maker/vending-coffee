import 'package:flutter/material.dart';
import 'package:venidng_coffee/models/coffee_product.dart';

const List<CoffeeProduct> coffeeCatalog = [
  CoffeeProduct(
    id: 'espresso',
    name: 'اسپرسو',
    price: 45000,
    icon: Icons.coffee_rounded,
    color: Color(0xFF5D4037),
    gradientStart: Color(0xFF4E342E),
    gradientEnd: Color(0xFF8D6E63),
  ),
  CoffeeProduct(
    id: 'cappuccino',
    name: 'کاپوچینو',
    price: 65000,
    icon: Icons.local_cafe_rounded,
    color: Color(0xFF6D4C41),
    gradientStart: Color(0xFF5D4037),
    gradientEnd: Color(0xFFA1887F),
  ),
  CoffeeProduct(
    id: 'latte',
    name: 'لاته',
    price: 70000,
    icon: Icons.coffee_outlined,
    color: Color(0xFF8D6E63),
    gradientStart: Color(0xFF6D4C41),
    gradientEnd: Color(0xFFD7CCC8),
  ),
  CoffeeProduct(
    id: 'americano',
    name: 'آمریکانو',
    price: 55000,
    icon: Icons.water_drop_rounded,
    color: Color(0xFF4E342E),
    gradientStart: Color(0xFF3E2723),
    gradientEnd: Color(0xFF795548),
  ),
  CoffeeProduct(
    id: 'mocha',
    name: 'موکا',
    price: 75000,
    icon: Icons.emoji_food_beverage_rounded,
    color: Color(0xFF3E2723),
    gradientStart: Color(0xFF3E2723),
    gradientEnd: Color(0xFF5D4037),
  ),
  CoffeeProduct(
    id: 'hot_chocolate',
    name: 'هات‌چاکلت',
    price: 60000,
    icon: Icons.cake_rounded,
    color: Color(0xFF795548),
    gradientStart: Color(0xFF4E342E),
    gradientEnd: Color(0xFF8D6E63),
  ),
];
