// import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // WINDOWS APP SQLITE
import 'package:sqflite/sqflite.dart'; // MOBILE APP SQLITE
import 'package:path/path.dart';
import '../models/player.dart';
import '../models/tournament.dart';
import '../models/match.dart';
import 'dart:convert';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<void> deleteDatabaseFile() async {
    String path = join(await getDatabasesPath(), 'tournament_manager.db');
    await deleteDatabase(path);
    _database = null;
  }

  Future<Database> _initDatabase() async {
    // sqfliteFfiInit(); // WINDOWS APP SQLITE
    // databaseFactory = databaseFactoryFfi; // WINDOWS APP SQLITE

    // final dbService = DatabaseService();
    // await dbService.deleteDatabaseFile();

    String path = join(await getDatabasesPath(), 'tournament_manager.db');
    return openDatabase(
      path,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE players(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            rank INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE tournaments(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            system TEXT,
            winnerId INTEGER,
            players TEXT,
            FOREIGN KEY (winnerId) REFERENCES players(id)
          )
        ''');
        await db.execute('''
          CREATE TABLE matches(
            id INTEGER PRIMARY KEY,
            tournament_id INTEGER,
            round INTEGER,
            player1_id INTEGER,
            player2_id INTEGER,
            winner_id INTEGER,
            FOREIGN KEY (tournament_id) REFERENCES tournaments(id),
            FOREIGN KEY (player1_id) REFERENCES players(id),
            FOREIGN KEY (player2_id) REFERENCES players(id),
            FOREIGN KEY (winner_id) REFERENCES players(id)
          );
        ''');
      },
      version: 1,
    );
  }

  Future<void> addMatches(List<Match> matches) async {
    final db = await database;

    await db.transaction((txn) async {
      for (var match in matches) {
        await txn.insert(
          'matches',
          {
            'tournament_id': match.tournamentId,
            'round': match.round,
            'player1_id': match.player1Id,
            'player2_id': match.player2Id,
            'winner_id': match.winnerId,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> updateMatchResult(int matchId, int winnerId) async {
    final db = await database;
    await db.update(
      'matches',
      {
        'winner_id': winnerId,
      },
      where: 'id = ?',
      whereArgs: [matchId],
    );
  }

  Future<List<Match>> getMatchesByRound(int tournamentId, int round) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'matches',
      where: 'tournament_id = ? AND round = ?',
      whereArgs: [tournamentId, round],
    );

    return maps.map((map) => Match.fromMap(map)).toList();
  }

  Future<List<Match>> getAllMatches(int tournamentId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'matches',
      where: 'tournament_id = ?',
      whereArgs: [tournamentId],
    );

    return maps.map((map) => Match.fromMap(map)).toList();
  }


  Future<Player?> getPlayerById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'players',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) return Player.fromMap(maps.first);
    return null;
  }

  Future<List<Player>> getPlayersForTournament(int tournamentId) async {
    final db = await database;

    final List<Map<String, dynamic>> tournamentData = await db.query(
      'tournaments',
      where: 'id = ?',
      whereArgs: [tournamentId],
    );

    if (tournamentData.isEmpty) {
      return [];
    }

    final List<int> playerIds = List<int>.from(jsonDecode(tournamentData.first['players']));

    List<Player> players = [];
    for (int id in playerIds) {
      Player? player = await getPlayerById(id);
      if (player != null) {
        players.add(player);
      }
    }

    return players;
  }
  Future<int> getLatestRoundNumber(int tournamentId) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.rawQuery(
      '''
      SELECT MAX(round) as max_round
      FROM matches
      WHERE tournament_id = ?
      ''',
      [tournamentId],
    );

    return results.isNotEmpty && results.first['max_round'] != null ? results.first['max_round'] as int : 1;
  }


  Future<int> insertTournament(Tournament tournament) async {
    final db = await database;
    return await db.insert('tournaments', tournament.toMap());
  }

  Future<List<Tournament>> getTournaments() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tournaments');
    return List.generate(maps.length, (i) {
      return Tournament.fromMap(maps[i]);
    });
  }

  Future<int?> getWinnerIdByTournamentId(int tournamentId) async {
    final db = await database;

    final List<Map<String, dynamic>> tournamentMaps = await db.query(
      'tournaments',
      where: 'id = ?',
      whereArgs: [tournamentId],
    );

    if (tournamentMaps.isNotEmpty) return tournamentMaps.first['winnerId'] as int?;

    return null;
  }

  Future<int> updateTournament(Tournament tournament) async {
    final db = await database;
    return await db.update(
      'tournaments',
      tournament.toMap(),
      where: 'id = ?',
      whereArgs: [tournament.id],
    );
  }

  Future<int> insertPlayer(Player player) async {
    final db = await database;
    return await db.insert('players', player.toMap());
  }

  Future<List<Player>> getPlayers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('players');
    return List.generate(maps.length, (i) {
      return Player.fromMap(maps[i]);
    });
  }

  Future<int> updatePlayer(Player player) async {
    final db = await database;
    return await db.update(
      'players',
      player.toMap(),
      where: 'id = ?',
      whereArgs: [player.id],
    );
  }

  Future<int> deletePlayer(int id) async {
    final db = await database;
    return await db.delete(
      'players',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> inTournamentPlayer(int playerId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tournaments',
      where: 'id IN (SELECT tournament_Id FROM matches WHERE player1_Id = ? OR player2_Id = ?)',
      whereArgs: [playerId, playerId],
    );

    return maps.isNotEmpty;
  }
}
