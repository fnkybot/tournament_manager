import 'package:flutter/material.dart';
import '../models/player.dart';
import '../services/database_service.dart';

class EditPlayerScreen extends StatefulWidget {
  final Player player;

  const EditPlayerScreen({Key? key, required this.player}) : super(key: key);

  @override
  _EditPlayerScreenState createState() => _EditPlayerScreenState();
}

class _EditPlayerScreenState extends State<EditPlayerScreen> {
  late DatabaseService _databaseService;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _databaseService = DatabaseService();
    _nameController = TextEditingController(text: widget.player.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _savePlayer() async {
    final updatedPlayer = Player(
      id: widget.player.id,
      name: _nameController.text,
      rank: widget.player.rank,
    );

    await _databaseService.updatePlayer(updatedPlayer);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edytuj zawodnika'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nazwa zawodnika'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _savePlayer,
              child: const Text('Zapisz'),
            ),
          ],
        ),
      ),
    );
  }
}
