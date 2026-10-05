import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// LUDO GAME — 2 Player (Player vs AI)
// ─────────────────────────────────────────────────────────────────────────────

class LudoGamePage extends StatefulWidget {
  const LudoGamePage({super.key});
  @override
  State<LudoGamePage> createState() => _LudoGamePageState();
}

class _Piece {
  int pos; // -1 = home, 0-51 = board, 52 = finished
  final int playerIdx;
  final int pieceIdx;
  _Piece({required this.pos, required this.playerIdx, required this.pieceIdx});
}

class _LudoGamePageState extends State<LudoGamePage> with TickerProviderStateMixin {
  static const int totalCells = 52;
  // Player 0 = Blue (starts at 0), Player 1 = Red (starts at 26)
  static const List<int> startPos = [0, 26];
  static const List<Color> playerColors = [Color(0xFF3B82F6), const Color(0xFFFF1744)];
  static const List<String> playerEmoji = ['🔵', '🔴'];

  late List<_Piece> pieces;
  int _diceValue = 0;
  bool _diceRolled = false;
  int _currentPlayer = 0;
  bool _gameOver = false;
  String _winner = '';
  String _message = 'Giliran Kamu! Lempar dadu!';
  bool _aiThinking = false;
  int _selectedPiece = -1;

  late AnimationController _diceAnim;
  late AnimationController _moveAnim;

  @override
  void initState() {
    super.initState();
    _diceAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _moveAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _initGame();
  }

  @override
  void dispose() {
    _diceAnim.dispose();
    _moveAnim.dispose();
    super.dispose();
  }

  void _initGame() {
    pieces = [];
    for (int p = 0; p < 2; p++) {
      for (int i = 0; i < 4; i++) {
        pieces.add(_Piece(pos: -1, playerIdx: p, pieceIdx: i));
      }
    }
    _diceValue = 0;
    _diceRolled = false;
    _currentPlayer = 0;
    _gameOver = false;
    _winner = '';
    _selectedPiece = -1;
    _aiThinking = false;
    _message = 'Giliran Kamu! Lempar dadu!';
    setState(() {});
  }

  void _rollDice() {
    if (_diceRolled || _gameOver || _aiThinking) return;
    _diceAnim.forward(from: 0);
    setState(() {
      _diceValue = Random().nextInt(6) + 1;
      _diceRolled = true;
    });

    final myPieces = pieces.where((p) => p.playerIdx == _currentPlayer).toList();
    final canMove = myPieces.any((p) =>
      (p.pos == -1 && _diceValue == 6) ||
      (p.pos >= 0 && p.pos < 52));

    if (!canMove) {
      setState(() => _message = 'Tidak ada gerakan! Giliran ${_currentPlayer == 0 ? "AI" : "Kamu"}...');
      Future.delayed(const Duration(milliseconds: 1000), _endTurn);
    } else {
      if (_currentPlayer == 0) {
        setState(() => _message = 'Dadu: $_diceValue — Pilih pion untuk digerakkan!');
      }
    }
  }

  void _movePiece(int pieceIdx) {
    if (!_diceRolled || _gameOver || _currentPlayer != 0) return;
    final piece = pieces[pieceIdx];
    if (piece.playerIdx != 0) return;

    if (piece.pos == -1) {
      if (_diceValue != 6) {
        setState(() => _message = '❌ Perlu dadu 6 untuk keluar dari rumah!');
        return;
      }
      setState(() { piece.pos = startPos[0]; });
    } else {
      final newPos = piece.pos + _diceValue;
      if (newPos >= 52) {
        setState(() { piece.pos = 52; }); // finished
      } else {
        // Check capture
        final rival = pieces.where((p) => p.playerIdx == 1 && p.pos == newPos).toList();
        for (final r in rival) { r.pos = -1; }
        setState(() { piece.pos = newPos; });
      }
    }

    _checkWin();
    if (!_gameOver) {
      if (_diceValue == 6) {
        setState(() { _diceRolled = false; _message = 'Dapat 6! Lempar lagi!'; });
      } else {
        _endTurn();
      }
    }
  }

  void _endTurn() {
    setState(() {
      _diceRolled = false;
      _currentPlayer = 1 - _currentPlayer;
      _selectedPiece = -1;
    });
    if (_currentPlayer == 1) {
      setState(() => _message = '🤖 AI melempar dadu...');
      _aiThinking = true;
      Future.delayed(const Duration(milliseconds: 800), _aiRoll);
    } else {
      setState(() => _message = 'Giliran Kamu! Lempar dadu!');
    }
  }

  void _aiRoll() {
    if (!mounted) return;
    final dice = Random().nextInt(6) + 1;
    setState(() { _diceValue = dice; _diceRolled = true; });
    Future.delayed(const Duration(milliseconds: 600), () => _aiMove(dice));
  }

  void _aiMove(int dice) {
    if (!mounted) return;
    final myPieces = pieces.where((p) => p.playerIdx == 1).toList();

    // Strategy: prioritize capturing, then moving furthest piece
    _Piece? best;
    int bestScore = -1;

    for (final p in myPieces) {
      if (p.pos == -1 && dice == 6) {
        if (bestScore < 100) { best = p; bestScore = 100; }
      } else if (p.pos >= 0 && p.pos < 52) {
        final newPos = p.pos + dice;
        if (newPos >= 52) {
          best = p; bestScore = 999; break;
        }
        // Check if captures
        final captures = pieces.where((x) => x.playerIdx == 0 && x.pos == newPos).length;
        final score = captures * 50 + newPos;
        if (score > bestScore) { bestScore = score; best = p; }
      }
    }

    if (best != null) {
      if (best.pos == -1) {
        setState(() { best!.pos = startPos[1]; _message = '🤖 AI keluar dari rumah!'; });
      } else {
        final newPos = best.pos + dice;
        if (newPos >= 52) {
          setState(() { best!.pos = 52; _message = '🤖 AI finis sebuah pion!'; });
        } else {
          final captured = pieces.where((p) => p.playerIdx == 0 && p.pos == newPos).toList();
          for (final c in captured) { c.pos = -1; }
          setState(() {
            best!.pos = newPos;
            _message = captured.isNotEmpty ? '🤖 AI menangkap pion kamu!' : '🤖 AI bergerak.';
          });
        }
      }
    } else {
      setState(() => _message = '🤖 AI tidak bisa bergerak.');
    }

    _checkWin();
    if (!_gameOver) {
      if (dice == 6) {
        setState(() { _diceRolled = false; _aiThinking = false; _message = '🤖 AI dapat 6! Lempar lagi...'; });
        Future.delayed(const Duration(milliseconds: 800), _aiRoll);
      } else {
        _aiThinking = false;
        _endTurn();
      }
    } else {
      _aiThinking = false;
    }
  }

  void _checkWin() {
    final p0Done = pieces.where((p) => p.playerIdx == 0).every((p) => p.pos == 52);
    final p1Done = pieces.where((p) => p.playerIdx == 1).every((p) => p.pos == 52);
    if (p0Done) { setState(() { _gameOver = true; _winner = 'player'; }); }
    else if (p1Done) { setState(() { _gameOver = true; _winner = 'ai'; }); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0520),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('🎲 Ludo', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22)),
        actions: [
          TextButton(onPressed: () => setState(_initGame),
            child: const Text('Reset', style: TextStyle(color: Color(0xFFA78BFA)))),
        ],
      ),
      body: _gameOver ? _buildGameOver() : _buildGame(),
    );
  }

  Widget _buildGame() {
    return Column(children: [
      // Status bar
      Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        color: const Color(0xFF0D0520),
        child: Row(children: [
          _playerStatus(0),
          const Spacer(),
          // Dice
          GestureDetector(
            onTap: _currentPlayer == 0 && !_diceRolled ? _rollDice : null,
            child: AnimatedBuilder(
              animation: _diceAnim,
              builder: (_, __) => Transform.rotate(
                angle: _diceAnim.value * pi * 4,
                child: Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFA78BFA), width: 2),
                    boxShadow: [BoxShadow(color: const Color(0xFF7C3AED).withOpacity(0.6), blurRadius: 12)],
                  ),
                  child: Center(child: Text(
                    _diceValue == 0 ? '?' : ['', '⚀','⚁','⚂','⚃','⚄','⚅'][_diceValue],
                    style: const TextStyle(fontSize: 28),
                  )),
                ),
              ),
            ),
          ),
          const Spacer(),
          _playerStatus(1),
        ]),
      ),
      // Message
      Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        color: const Color(0xFF1A0A2E),
        child: Text(_message,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
          textAlign: TextAlign.center),
      ),
      // Board
      Expanded(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _buildBoard(),
        ),
      ),
      // Pieces
      _buildPieceSelector(),
    ]);
  }

  Widget _playerStatus(int playerIdx) {
    final active = _currentPlayer == playerIdx;
    final finished = pieces.where((p) => p.playerIdx == playerIdx && p.pos == 52).length;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: active ? playerColors[playerIdx].withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: active ? playerColors[playerIdx] : Colors.transparent,
          width: 2,
        ),
      ),
      child: Column(children: [
        Text(playerIdx == 0 ? '😎 Kamu' : '🤖 AI',
          style: TextStyle(
            color: playerColors[playerIdx],
            fontWeight: FontWeight.w800, fontSize: 13,
          )),
        Text('$finished/4 finis',
          style: TextStyle(color: playerColors[playerIdx].withOpacity(0.7), fontSize: 10)),
      ]),
    );
  }

  Widget _buildBoard() {
    return LayoutBuilder(builder: (_, constraints) {
      final size = min(constraints.maxWidth, constraints.maxHeight);
      final cell = size / 11;
      return Container(
        width: size, height: size,
        child: Stack(children: [
          // Background grid
          CustomPaint(
            size: Size(size, size),
            painter: _LudoBoardPainter(cell),
          ),
          // Pieces on board
          ...pieces.where((p) => p.pos >= 0 && p.pos < 52).map((p) {
            final boardPos = _getBoardXY(p.pos, cell);
            return AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              left: boardPos.dx + cell * 0.1,
              top: boardPos.dy + cell * 0.1,
              child: GestureDetector(
                onTap: p.playerIdx == 0 && _diceRolled && _currentPlayer == 0
                    ? () => _movePiece(pieces.indexOf(p)) : null,
                child: Container(
                  width: cell * 0.8, height: cell * 0.8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: playerColors[p.playerIdx],
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [BoxShadow(
                      color: playerColors[p.playerIdx].withOpacity(0.7),
                      blurRadius: 8,
                    )],
                  ),
                  child: Center(child: Text(
                    '${p.pieceIdx + 1}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11),
                  )),
                ),
              ),
            );
          }),
        ]),
      );
    });
  }

  Offset _getBoardXY(int pos, double cell) {
    // Map 52 positions around the board
    const path = [
      // Bottom row left to right (row 10, cols 0-4)
      Offset(0,10), Offset(1,10), Offset(2,10), Offset(3,10), Offset(4,10), Offset(5,10),
      // Up right column (col 6, rows 10-6)
      Offset(6,10), Offset(6,9), Offset(6,8), Offset(6,7), Offset(6,6),
      // Right row (row 6, cols 6-10)
      Offset(6,5), Offset(7,5), Offset(8,5), Offset(9,5), Offset(10,5),
      // Actually simplified board
    ];
    // Simplified rectangular path
    final x = pos % 13;
    final y = pos ~/ 13;
    return Offset(x * cell, y * cell);
  }

  Widget _buildPieceSelector() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: const Color(0xFF0D0520),
      child: Column(children: [
        const Text('Pion Kamu (tap untuk gerakkan)',
          style: TextStyle(color: Colors.white54, fontSize: 11)),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(4, (i) {
            final piece = pieces[i]; // player 0 pieces
            final canMove = _currentPlayer == 0 && _diceRolled &&
                ((piece.pos == -1 && _diceValue == 6) || (piece.pos >= 0 && piece.pos < 52));
            return GestureDetector(
              onTap: canMove ? () => _movePiece(i) : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 56, height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: canMove ? const Color(0xFF3B82F6) : const Color(0xFF1E3A5F),
                  border: Border.all(
                    color: canMove ? Colors.white : const Color(0xFF3B82F6).withOpacity(0.4),
                    width: 2,
                  ),
                  boxShadow: canMove ? [BoxShadow(
                    color: const Color(0xFF3B82F6).withOpacity(0.6), blurRadius: 12)] : null,
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('${i + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                  Text(piece.pos == -1 ? '🏠' : piece.pos == 52 ? '🏆' : '${piece.pos}',
                    style: const TextStyle(fontSize: 10)),
                ]),
              ),
            );
          }),
        ),
        if (_currentPlayer == 0 && !_diceRolled)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                foregroundColor: Colors.white,
                minimumSize: const Size(200, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.casino_rounded),
              label: const Text('Lempar Dadu!', style: TextStyle(fontWeight: FontWeight.w800)),
              onPressed: _rollDice,
            ),
          ),
      ]),
    );
  }

  Widget _buildGameOver() {
    final won = _winner == 'player';
    return Center(child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(won ? '🏆' : '😢', style: const TextStyle(fontSize: 80)),
        const SizedBox(height: 16),
        Text(won ? 'KAMU MENANG!' : 'AI MENANG!',
          style: TextStyle(
            color: won ? Color(0xFF00E676) : Color(0xFFFF1744),
            fontSize: 32, fontWeight: FontWeight.w900)),
        const SizedBox(height: 40),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7C3AED),
            foregroundColor: Colors.white,
            minimumSize: const Size(220, 54),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          icon: const Icon(Icons.refresh),
          label: const Text('Main Lagi', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          onPressed: () => setState(_initGame),
        ),
      ]),
    ));
  }
}

class _LudoBoardPainter extends CustomPainter {
  final double cell;
  _LudoBoardPainter(this.cell);

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFF2D1B69);
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(16)), bgPaint);

    final linePaint = Paint()
      ..color = const Color(0xFF4C1D95).withOpacity(0.8)
      ..strokeWidth = 1;

    final cols = (size.width / cell).floor();
    final rows = (size.height / cell).floor();

    for (int i = 0; i <= cols; i++) {
      canvas.drawLine(Offset(i * cell, 0), Offset(i * cell, size.height), linePaint);
    }
    for (int i = 0; i <= rows; i++) {
      canvas.drawLine(Offset(0, i * cell), Offset(size.width, i * cell), linePaint);
    }

    // Home areas
    final bluePaint = Paint()..color = const Color(0xFF3B82F6).withOpacity(0.3);
    final redPaint = Paint()..color = Color(0xFFFF1744).withOpacity(0.3);
    canvas.drawRect(Rect.fromLTWH(0, 0, cell * 4, cell * 4), bluePaint);
    canvas.drawRect(Rect.fromLTWH(size.width - cell * 4, size.height - cell * 4, cell * 4, cell * 4), redPaint);

    // Center
    final centerPaint = Paint()..color = const Color(0xFF7C3AED).withOpacity(0.4);
    canvas.drawRect(Rect.fromLTWH(cell * 4, cell * 4, cell * 3, cell * 3), centerPaint);
  }

  @override
  bool shouldRepaint(_) => false;
}
