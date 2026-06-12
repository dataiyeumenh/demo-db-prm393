import 'package:flutter/material.dart';
import 'screens/product_list_screen.dart';

void main() {
  runApp(const ShopDemoApp());
}

class ShopDemoApp extends StatelessWidget {
  const ShopDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shop Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.deepPurple, useMaterial3: true),
      home: const ProductListScreen(),
    );
  }
}
