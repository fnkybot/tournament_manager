import 'package:flutter/material.dart';
import 'package:tournament_manager/models/tournament.dart';
import '../models/player.dart';
import '../services/database_service.dart';

class AddTournamentScreen extends StatefulWidget {
  @override
  _AddTournamentScreenState createState() => _AddTournamentScreenState();
}

class _AddTournamentScreenState extends State<AddTournamentScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tournamentNameController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();

  int _numPlayers = 2;
  List<Player> _allPlayers = [];
  List<Player> _selectedPlayers = [];

  @override
  void initState() {{
    super.initState();
    _fetchPlayers();
  }}

  void _fetchPlayers() async {{
    final players = await _databaseService.getPlayers();
    setState(() {{
      _allPlayers = players;
    }});
  }}

  void _addTournament() async {{
    if (_formKey.currentState!.validate() && _selectedPlayers.length == _numPlayers) {{
      final player = Tournament(
        name: _tournamentNameController.text,
        system: 'pucharowy',
        players: _selectedPlayers.map((player) => player.id!).toList(),
      );
      await _databaseService.insertTournament(player);
      Navigator.pop(context);
    }} else {{
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Wybierz poprawną ilość graczy')));
    }}
  }}

  @override
  Widget build(BuildContext context) {{
    return Scaffold(
      appBar: AppBar(title: const Text('Utwórz turniej')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tworzysz turniej w trybie pucharowym...'),
                const SizedBox(height: 5),
                TextFormField(
                  controller: _tournamentNameController,
                  decoration: const InputDecoration(labelText: 'Nazwa turnieju'),
                  validator: (value) => value == null || value.isEmpty ? 'Wpisz nazwę turnieju' : null,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<int>(
                  value: _numPlayers,
                  items: List.generate(6, (index) => 2 << index)
                      .map((num) => DropdownMenuItem(value: num, child: Text(num.toString())))
                      .toList(),
                  onChanged: (value) => setState(() {{
                    _numPlayers = value ?? 0;
                    _selectedPlayers.clear();
                  }}),
                  decoration: const InputDecoration(labelText: 'Ilość zawodników'),
                ),
                const SizedBox(height: 20),
                const Text('Wybierz zawodników:'),
                ..._allPlayers.map((player) => CheckboxListTile(
                      title: Text(player.name),
                      value: _selectedPlayers.contains(player),
                      onChanged: (isChecked) {{
                        setState(() {{
                          if (isChecked == true && _selectedPlayers.length < _numPlayers) {{
                            _selectedPlayers.add(player);
                          }} else {{
                            _selectedPlayers.remove(player);
                          }}
                        }});
                      }},
                    )),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _addTournament,
                  child: const Text('Utwórz turniej'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }}
}