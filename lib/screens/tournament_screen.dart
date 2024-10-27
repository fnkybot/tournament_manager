import 'package:flutter/material.dart';
import '../models/tournament.dart';
import '../models/player.dart';
import '../models/match.dart';
import '../services/database_service.dart';

class TournamentScreen extends StatefulWidget {
  final Tournament tournament;

  const TournamentScreen({required this.tournament});

  @override
  _TournamentScreenState createState() => _TournamentScreenState();
}

class _TournamentScreenState extends State<TournamentScreen> {
  late DatabaseService _databaseService;
  List<Match> _matches = [];
  String winner = "Brak";
  bool _isLoading = true;
  bool _showAnimation = false;
  bool _showWinner = false;

  @override
  void initState() {
    super.initState();
    _databaseService = DatabaseService();
    _loadTournamentData();
  }

  Future<void> _loadTournamentData() async {
    setState(() {
      _isLoading = true;
    });

    winner = await getWinnerName(widget.tournament.id!);

    int currentRound = await _databaseService.getLatestRoundNumber(widget.tournament.id!);

    if(winner == "Brak") _matches = await _databaseService.getMatchesByRound(widget.tournament.id!, currentRound);
    else _matches = await _databaseService.getAllMatches(widget.tournament.id!);

    if (_matches.isEmpty) {
      await _initializeFirstRound();
      _matches = await _databaseService.getMatchesByRound(widget.tournament.id!, 1);
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _initializeFirstRound() async {
    List<Player> players = await _databaseService.getPlayersForTournament(widget.tournament.id!);
    players.shuffle();

    List<Match> firstRoundMatches = [];
    for (int i = 0; i < players.length; i += 2) {
      if (i + 1 < players.length) {
        firstRoundMatches.add(Match(
          tournamentId: widget.tournament.id!,
          round: 1,
          player1Id: players[i].id!,
          player2Id: players[i + 1].id!,
        ));
      }
    }

    await _databaseService.addMatches(firstRoundMatches);
  }

  Future<void> _createNextRound() async {
    int currentRound = await _databaseService.getLatestRoundNumber(widget.tournament.id!);
    final lastRoundMatches = await _databaseService.getMatchesByRound(widget.tournament.id!, currentRound);

    List<Player> winners = [];
    for (var match in lastRoundMatches) {
      if (match.winnerId != null) {
        Player? winner = await _databaseService.getPlayerById(match.winnerId!);
        if (winner != null) winners.add(winner);
      }
    }

    if (winners.length == lastRoundMatches.length) {
      List<Match> nextRoundMatches = [];
      for (int i = 0; i < winners.length; i += 2) {
        if (i + 1 < winners.length) {
          nextRoundMatches.add(Match(
            tournamentId: widget.tournament.id!,
            round: currentRound + 1,
            player1Id: winners[i].id!,
            player2Id: winners[i + 1].id!,
          ));
          _showMessage("Runda zakończona!");
        } else {
          _showMessage("Gratulacje, turniej zakończony!");
          final updatedTournament = Tournament(
            id: widget.tournament.id,
            name: widget.tournament.name,
            system: widget.tournament.system,
            winnerId: winners[0].id,
            players: widget.tournament.players,
          );
          _databaseService.updateTournament(updatedTournament);
          setState(() {
           _showWinner = true;
          });
        }
      }
      await _databaseService.addMatches(nextRoundMatches);
      await _loadTournamentData();

    } else {
      _showMessage("Nie rozstrzygnięto wszystkich meczy!");
      //throw Exception("Brak wyników dla wszystkich meczów.");
    }
  }

  void _updateMatchWinner(Match match) async {
    final player1 = await _databaseService.getPlayerById(match.player1Id);
    final player2 = await _databaseService.getPlayerById(match.player2Id);
    int? selectedWinnerId = match.winnerId;
    selectedWinnerId = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Wybierz zwycięzcę'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(player1?.name ?? "Nieznany gracz"),
                leading: Radio<int>(
                  value: match.player1Id,
                  groupValue: selectedWinnerId,
                  onChanged: (value) {
                    Navigator.pop(context, value);
                  },
                ),
              ),
              ListTile(
                title: Text(player2?.name ?? "Nieznany gracz"),
                leading: Radio<int>(
                  value: match.player2Id,
                  groupValue: selectedWinnerId,
                  onChanged: (value) {
                    Navigator.pop(context, value);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selectedWinnerId != null) {
      await _databaseService.updateMatchResult(match.id!, selectedWinnerId);
      await _loadTournamentData();
    }
  }

  Future<String> getWinnerName(int tournamentId) async {
    final winnerId = await _databaseService.getWinnerIdByTournamentId(tournamentId);
    if (winnerId != null) {
      final winnerPlayer = await _databaseService.getPlayerById(winnerId);
      return winnerPlayer?.name ?? "Brak";
    }
    return "Brak";
  }

  void _showMessage(String text) {
    setState(() {
      _showAnimation = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color.fromARGB(255, 51, 122, 81),
        content: Text(text),
        duration: Duration(seconds: 3),
      ),
    );

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _showAnimation = false;
      });
    });
  }

  List<Widget> _buildMatchWidgets() {
    return _matches.map((match) {
      return FutureBuilder(
        future: Future.wait([
          _databaseService.getPlayerById(match.player1Id),
          _databaseService.getPlayerById(match.player2Id),
          if (match.winnerId != null) _databaseService.getPlayerById(match.winnerId!)
        ]),
        builder: (context, AsyncSnapshot<List<Player?>> snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }

          String player1Name = snapshot.data?[0]?.name ?? "Nieznany gracz";
          String player2Name = snapshot.data?[1]?.name ?? "Nieznany gracz";
          String winnerName = "Nierozstrzygnięty";

          if (match.winnerId != null) {
            final winner = snapshot.data?.firstWhere(
              (player) => player?.id == match.winnerId,
              orElse: () => null,
            );

            winnerName = (winner != null) ? winner.name : "Nierozstrzygnięty";
          }

          return ListTile(
            title: Text("Runda ${match.round}"),
            subtitle: Text("$player1Name vs $player2Name\nZwycięzca: $winnerName"),
            trailing: winner == "Brak"
            ? IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _updateMatchWinner(match),
              )
            : null,

          );
        },
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Szczegóły turnieju: ${widget.tournament.name}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_showWinner)
                      Container(
                        alignment: Alignment.center,
                        child: const Text(
                          'Turniej został zakończony!',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 51, 122, 81)),
                        ),
                      ),
                  Text('System: ${widget.tournament.system}', style: const TextStyle(fontSize: 18)),
                  Text('Liczba zawodników: ${widget.tournament.players.length}', style: const TextStyle(fontSize: 18)),
                  Text('Zwycięzca: ${winner}', style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 20),
                  const Text('Wyniki rund:', style: TextStyle(fontSize: 16)),
                  Expanded(
                    child: ListView(children: _buildMatchWidgets()),
                  ),


                ],
              ),
            ),

      floatingActionButton: winner == "Brak" ? FloatingActionButton(
        onPressed: _createNextRound,
        child: const Icon(Icons.arrow_forward),
      ) : null,

    );
  }
}

