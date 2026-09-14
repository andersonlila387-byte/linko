import 'package:flutter/material.dart';

class NightGameScreen extends StatefulWidget {
  final String currentDeviceId;
  final String currentDeviceName;

  const NightGameScreen({
    super.key,
    required this.currentDeviceId,
    required this.currentDeviceName,
  });

  @override
  State<NightGameScreen> createState() => _NightGameScreenState();
}

class _NightGameScreenState extends State<NightGameScreen> {
  // Tic Tac Toe Board state
  List<String> _board = List.filled(9, '');
  bool _isXTurn = true;
  String? _winner;
  int _scoresX = 0;
  int _scoresO = 0;

  void _handleTap(int index) {
    if (_board[index] != '' || _winner != null) return;

    setState(() {
      _board[index] = _isXTurn ? 'X' : 'O';
      _isXTurn = !_isXTurn;
      _checkWinner();
    });
  }

  void _checkWinner() {
    const lines = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Columns
      [0, 4, 8], [2, 4, 6], // Diagonals
    ];

    for (var line in lines) {
      final a = _board[line[0]];
      final b = _board[line[1]];
      final c = _board[line[2]];

      if (a.isNotEmpty && a == b && a == c) {
        setState(() {
          _winner = a;
          if (a == 'X') {
            _scoresX++;
          } else {
            _scoresO++;
          }
        });
        return;
      }
    }

    if (!_board.contains('') && _winner == null) {
      setState(() {
        _winner = 'Draw';
      });
    }
  }

  void _resetGame() {
    setState(() {
      _board = List.filled(9, '');
      _isXTurn = true;
      _winner = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color bgBlack = Color(0xFF08080C);
    const Color cardBlack = Color(0xFF111118);
    const Color borderStroke = Color(0xFF22222E);
    const Color accentCyan = Color(0xFF00F0FF);
    const Color accentPink = Color(0xFFFF007A);

    return Scaffold(
      backgroundColor: bgBlack,
      appBar: AppBar(
        backgroundColor: cardBlack,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Row(
          children: [
            Icon(Icons.sports_esports_rounded, color: accentPink, size: 22),
            SizedBox(width: 8),
            Text(
              'NIGHT GAME ARCADE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: accentCyan),
            onPressed: _resetGame,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header Tag Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF007A).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFF007A).withValues(alpha: 0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.nightlight_round, color: Color(0xFFFF007A), size: 16),
                    SizedBox(width: 8),
                    Text(
                      'P2P LIVE MULTIPLAYER • NIGHT TIC-TAC-TOE',
                      style: TextStyle(
                        color: Color(0xFFFF007A),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Scoreboard
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBlack,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderStroke),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text(
                          'YOU (X)',
                          style: TextStyle(color: accentCyan, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$_scoresX',
                          style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                    Container(width: 1, height: 36, color: borderStroke),
                    Column(
                      children: [
                        const Text(
                          'PEER (O)',
                          style: TextStyle(color: accentPink, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$_scoresO',
                          style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Turn & Winner Status Display
              if (_winner != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: _winner == 'Draw'
                        ? Colors.orange.withValues(alpha: 0.2)
                        : accentCyan.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _winner == 'Draw' ? Colors.orangeAccent : accentCyan,
                    ),
                  ),
                  child: Text(
                    _winner == 'Draw' ? 'Game Result: Draw' : 'Winner: Player $_winner!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ] else ...[
                Text(
                  _isXTurn ? 'Current Turn: YOU (X)' : 'Current Turn: PEER (O)',
                  style: TextStyle(
                    color: _isXTurn ? accentCyan : accentPink,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],

              const SizedBox(height: 28),

              // 3x3 Tic Tac Toe Grid
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 340),
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: 9,
                    itemBuilder: (context, index) {
                      final cell = _board[index];
                      return GestureDetector(
                        onTap: () => _handleTap(index),
                        child: Container(
                          decoration: BoxDecoration(
                            color: cardBlack,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: cell.isNotEmpty
                                  ? (cell == 'X' ? accentCyan : accentPink)
                                  : borderStroke,
                              width: cell.isNotEmpty ? 2 : 1,
                            ),
                            boxShadow: cell.isNotEmpty
                                ? [
                                    BoxShadow(
                                      color: (cell == 'X' ? accentCyan : accentPink)
                                          .withValues(alpha: 0.3),
                                      blurRadius: 12,
                                    ),
                                  ]
                                : [],
                          ),
                          child: Center(
                            child: Text(
                              cell,
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: cell == 'X' ? accentCyan : accentPink,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Reset Button
              GestureDetector(
                onTap: _resetGame,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.replay_rounded, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Play Again',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
