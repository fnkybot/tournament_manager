class Player {
  final int? id;
  final String name;
  final int? rank;

  Player({this.id, required this.name, required this.rank});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'rank': rank,
    };
  }

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id: map['id'],
      name: map['name'],
      rank: map['rank'],
    );
  }
}
