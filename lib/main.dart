import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tex/flutter_tex.dart';
import 'package:set_theory_calculator/provider/set_provider.dart';
import 'package:set_theory_calculator/screens/home_screen.dart'; // Import for TeX rendering server



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CalculatorProvider()),
      ],
      child: MaterialApp(
        title: 'Set Theory Calculator',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}