import 'package:flutter/material.dart';
import 'players_screen.dart';
import 'tournaments_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tournament Manager'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Witaj ponownie! Wybierz co chcesz zrobić:',
                style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 51, 122, 81),),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PlayersScreen()),
                    );
                  },
                  icon: const Icon(Icons.people),
                  label: const Text('Zarządzaj zawodnikami'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TournamentsScreen()),
                    );
                  },
                  icon: const Icon(Icons.star), // Ikona dla przycisku
                  label: const Text('Zobacz aktywne turnieje'),

                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Wojciech Dębicki & Jędrzej Nowaczyk',
                style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 51, 122, 81),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
