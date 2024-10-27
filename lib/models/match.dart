class Match {
  final int? id;
  final int tournamentId;
  final int round;
  final int player1Id;
  final int player2Id;
  int? winnerId;

  Match({
    this.id,
    required this.tournamentId,
    required this.round,
    required this.player1Id,
    required this.player2Id,
    this.winnerId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tournament_id': tournamentId,
      'round': round,
      'player1_id': player1Id,
      'player2_id': player2Id,
      'winner_id': winnerId,
    };
  }

  factory Match.fromMap(Map<String, dynamic> map) {
    return Match(
      id: map['id'],
      tournamentId: map['tournament_id'],
      round: map['round'],
      player1Id: map['player1_id'],
      player2Id: map['player2_id'],
      winnerId: map['winner_id'],
    );
  }
}
