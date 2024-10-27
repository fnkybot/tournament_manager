import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {

  WidgetsFlutterBinding.ensureInitialized();
  runApp(TournamentManagerApp());
}

class TournamentManagerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tournament Manager',
      theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: const Color.fromARGB(255, 51, 122, 81),
          colorScheme: const ColorScheme.light(
            primary: Color.fromARGB(255, 51, 122, 81),
          ),
          appBarTheme: const AppBarTheme(
          backgroundColor:  Color.fromARGB(255, 51, 122, 81),
          titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 51, 122, 81),
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: HomeScreen(),
    );
  }
}
