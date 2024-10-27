import 'package:flutter/material.dart';
import '../models/player.dart';
import '../services/database_service.dart';

class AddPlayerScreen extends StatefulWidget {
  const AddPlayerScreen({super.key});

  @override
  _AddPlayerScreenState createState() => _AddPlayerScreenState();
}

class _AddPlayerScreenState extends State<AddPlayerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  late DatabaseService _databaseService;

  @override
  void initState() {
    super.initState();
    _databaseService = DatabaseService();
  }

  void _savePlayer() async {
    if (_formKey.currentState!.validate()) {
      final player = Player(
        name: _nameController.text,
        rank: 0,
      );
      await _databaseService.insertPlayer(player);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dodaj zawodnika')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nazwa zawodnika'),
                validator: (value) => value!.isEmpty ? 'Podaj nazwę' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _savePlayer,
                child: const Text('Dodaj'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
