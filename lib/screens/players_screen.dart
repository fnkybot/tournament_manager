import 'package:flutter/material.dart';
import 'add_player_screen.dart';
import 'edit_player_screen.dart';
import '../models/player.dart';
import '../services/database_service.dart';

class PlayersScreen extends StatefulWidget {
  const PlayersScreen({super.key});

  @override
  _PlayersScreenState createState() => _PlayersScreenState();
}

class _PlayersScreenState extends State<PlayersScreen> {
  late DatabaseService _databaseService;
  bool _showAnimation = false;
  List<Player> _players = [];

  @override
  void initState() {
    super.initState();
    _databaseService = DatabaseService();
    _loadPlayers();
  }

  void _loadPlayers() async {
    final players = await _databaseService.getPlayers();
    setState(() {
      _players = players;
    });
  }

  void _addPlayer() async {
  await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const AddPlayerScreen()),
  );
  _loadPlayers();
}

  void _editPlayer(Player player) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditPlayerScreen(player: player)),
    );

    if (result == true) {
      _showMessage("Zawodnik został zapisany!");
      _loadPlayers();
    }
  }

  void _deletePlayer(int id) async {
    bool inTournamentPlayer = await _databaseService.inTournamentPlayer(id);

    if (inTournamentPlayer) {
      _showMessage("Nie można usunąć zawodnika przypisanego do turnieju!");
      return;
    }
    await _databaseService.deletePlayer(id);
    _showMessage("Zawodnik został usunięty!");
    _loadPlayers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zawodnicy'),
      ),
      body: ListView.builder(
        itemCount: _players.length,
        itemBuilder: (context, index) {
          final player = _players[index];
          return ListTile(
            title: Text(player.name),
            subtitle: Text('Ranking: ${player.rank}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editPlayer(player),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deletePlayer(player.id!),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPlayer,
        child: const Icon(Icons.add),
      ),
    );
  }
  void _showMessage(String text) {
    setState(() {
      _showAnimation = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color.fromARGB(255, 51, 122, 81),
        content: Text(text),
        duration: const Duration(seconds: 3),
      ),
    );

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _showAnimation = false;
      });
    });
  }
}


