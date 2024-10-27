import 'package:flutter/material.dart';
import '../models/tournament.dart';
import '../services/database_service.dart';
import 'add_tournament_screen.dart';
import 'tournament_screen.dart';

class TournamentsScreen extends StatefulWidget {
  const TournamentsScreen({super.key});

  @override
  _TournamentsScreenState createState() => _TournamentsScreenState();
}

class _TournamentsScreenState extends State<TournamentsScreen> {
  late DatabaseService _databaseService;
  List<Tournament> _tournaments = [];

  @override
  void initState() {
    super.initState();
    _databaseService = DatabaseService();
    _loadTournaments();
  }

  void _loadTournaments() async {
    final tournaments = await _databaseService.getTournaments();
    setState(() {
      _tournaments = tournaments;
    });
  }

  void _addTournament() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddTournamentScreen()),
    );
    _loadTournaments();
  }

  void _viewTournamentDetails(Tournament tournament) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TournamentScreen(tournament: tournament),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Turnieje'),
      ),
      body: ListView.builder(
        itemCount: _tournaments.length,
        itemBuilder: (context, index) {
          final tournament = _tournaments[index];
          return ListTile(
            title: Row(
              children: [
                Expanded(
                  child: Text(tournament.name),
                ),
                Text(
                  tournament.winnerId != null ? "Zakończony" : "W trakcie",
                  style: TextStyle(
                    color: tournament.winnerId != null ? const Color.fromARGB(255, 51, 122, 81) : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            subtitle: Text('System: ${tournament.system} - ${tournament.players.length} zawodników'),
            onTap: () => _viewTournamentDetails(tournament),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTournament,
        child: const Icon(Icons.add),
      ),
    );
  }
}
