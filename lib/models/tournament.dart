import 'dart:convert';

class Tournament {
  final int? id;
  final String name;
  final String system;
  final int? winnerId;
  final List<int> players;

  Tournament({
    this.id,
    required this.name,
    required this.system,
    this.winnerId,
    required this.players
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'system': system,
      'winnerId': winnerId,
      'players': jsonEncode(players),
    };
  }

  factory Tournament.fromMap(Map<String, dynamic> map) {
    return Tournament(
      id: map['id'],
      name: map['name'],
      system: map['system'],
      winnerId: map['winnerId'],
      players: List<int>.from(jsonDecode(map['players'])),
    );
  }
}
