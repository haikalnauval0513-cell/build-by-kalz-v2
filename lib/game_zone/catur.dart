import 'dart:math';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CATUR PAGE — Chess vs Simple AI
// ─────────────────────────────────────────────────────────────────────────────

class CaturPage extends StatefulWidget {
  const CaturPage({super.key});
  @override
  State<CaturPage> createState() => _CaturPageState();
}

class _CaturPageState extends State<CaturPage> {
  // Board: 0=empty, uppercase=white, lowercase=black
  // K=King, Q=Queen, R=Rook, B=Bishop, N=Knight, P=Pawn
  late List<List<String>> board;
  List<int>? selected; // [row,col] of selected piece
  List<List<int>> validMoves = [];
  bool whiteTurn = true;
  String statusMsg = 'Giliran Kamu (Putih)';
  bool gameOver = false;
  int whiteCaptures = 0;
  int blackCaptures = 0;

  @override
  void initState() {
    super.initState();
    _initBoard();
  }

  void _initBoard() {
    board = [
      ['r','n','b','q','k','b','n','r'],
      ['p','p','p','p','p','p','p','p'],
      ['','','','','','','',''],
      ['','','','','','','',''],
      ['','','','','','','',''],
      ['','','','','','','',''],
      ['P','P','P','P','P','P','P','P'],
      ['R','N','B','Q','K','B','N','R'],
    ];
    selected = null;
    validMoves = [];
    whiteTurn = true;
    statusMsg = 'Giliran Kamu (Putih)';
    gameOver = false;
    whiteCaptures = 0;
    blackCaptures = 0;
  }

  bool _isWhite(String p) => p.isNotEmpty && p == p.toUpperCase() && p != p.toLowerCase();
  bool _isBlack(String p) => p.isNotEmpty && p == p.toLowerCase();
  bool _isEmpty(String p) => p.isEmpty;

  bool _inBounds(int r, int c) => r >= 0 && r < 8 && c >= 0 && c < 8;

  List<List<int>> _getMoves(int r, int c) {
    final piece = board[r][c];
    if (piece.isEmpty) return [];
    final moves = <List<int>>[];
    final up = piece == piece.toUpperCase();
    final dir = up ? -1 : 1;
    final enemy = up ? _isBlack : _isWhite;
    final ally = up ? _isWhite : _isBlack;

    void addIfValid(int nr, int nc) {
      if (_inBounds(nr, nc) && !ally(board[nr][nc])) moves.add([nr, nc]);
    }

    void slide(List<List<int>> dirs) {
      for (final d in dirs) {
        int nr = r + d[0], nc = c + d[1];
        while (_inBounds(nr, nc)) {
          if (ally(board[nr][nc])) break;
          moves.add([nr, nc]);
          if (enemy(board[nr][nc])) break;
          nr += d[0]; nc += d[1];
        }
      }
    }

    switch (piece.toUpperCase()) {
      case 'P':
        if (_inBounds(r + dir, c) && _isEmpty(board[r + dir][c])) {
          moves.add([r + dir, c]);
          final startRow = up ? 6 : 1;
          if (r == startRow && _isEmpty(board[r + dir * 2][c])) {
            moves.add([r + dir * 2, c]);
          }
        }
        for (final dc in [-1, 1]) {
          if (_inBounds(r + dir, c + dc) && enemy(board[r + dir][c + dc])) {
            moves.add([r + dir, c + dc]);
          }
        }
        break;
      case 'N':
        for (final d in [[-2,-1],[-2,1],[-1,-2],[-1,2],[1,-2],[1,2],[2,-1],[2,1]]) {
          addIfValid(r + d[0], c + d[1]);
        }
        break;
      case 'B':
        slide([[-1,-1],[-1,1],[1,-1],[1,1]]);
        break;
      case 'R':
        slide([[-1,0],[1,0],[0,-1],[0,1]]);
        break;
      case 'Q':
        slide([[-1,-1],[-1,1],[1,-1],[1,1],[-1,0],[1,0],[0,-1],[0,1]]);
        break;
      case 'K':
        for (final d in [[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]]) {
          addIfValid(r + d[0], c + d[1]);
        }
        break;
    }
    return moves;
  }

  void _onTap(int r, int c) {
    if (gameOver || !whiteTurn) return;
    final piece = board[r][c];

    if (selected != null) {
      final isValid = validMoves.any((m) => m[0] == r && m[1] == c);
      if (isValid) {
        _movePiece(selected![0], selected![1], r, c);
        setState(() {
          selected = null;
          validMoves = [];
          whiteTurn = false;
          statusMsg = 'AI sedang berpikir...';
        });
        Future.delayed(const Duration(milliseconds: 600), _aiMove);
        return;
      }
    }

    if (_isWhite(piece)) {
      setState(() {
        selected = [r, c];
        validMoves = _getMoves(r, c);
      });
    } else {
      setState(() { selected = null; validMoves = []; });
    }
  }

  void _movePiece(int fr, int fc, int tr, int tc) {
    final target = board[tr][tc];
    if (target.isNotEmpty) {
      if (_isWhite(board[fr][fc])) blackCaptures++;
      else whiteCaptures++;
      if (target.toLowerCase() == 'k') {
        gameOver = true;
        statusMsg = _isWhite(board[fr][fc]) ? '🎉 Kamu Menang!' : '😔 AI Menang!';
      }
    }
    board[tr][tc] = board[fr][fc];
    board[fr][fc] = '';
    // Pawn promotion
    if (board[tr][tc] == 'P' && tr == 0) board[tr][tc] = 'Q';
    if (board[tr][tc] == 'p' && tr == 7) board[tr][tc] = 'q';
  }

  void _aiMove() {
    if (gameOver) return;
    final rng = Random();
    final allMoves = <List<int>>[];
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        if (_isBlack(board[r][c])) {
          final moves = _getMoves(r, c);
          for (final m in moves) {
            allMoves.add([r, c, m[0], m[1]]);
          }
        }
      }
    }
    if (allMoves.isEmpty) {
      setState(() { gameOver = true; statusMsg = '🎉 Kamu Menang! AI Menyerah.'; });
      return;
    }
    // Prioritize captures
    final captures = allMoves.where((m) => _isWhite(board[m[2]][m[3]])).toList();
    final move = captures.isNotEmpty
        ? captures[rng.nextInt(captures.length)]
        : allMoves[rng.nextInt(allMoves.length)];
    setState(() {
      _movePiece(move[0], move[1], move[2], move[3]);
      whiteTurn = true;
      if (!gameOver) statusMsg = 'Giliran Kamu (Putih)';
    });
  }

  Color _squareColor(int r, int c) {
    final isDark = (r + c) % 2 == 1;
    return isDark ? const Color(0xFF1A3A5C) : const Color(0xFF1E4D7A);
  }

  String _pieceEmoji(String p) {
    const map = {
      'K': '♔', 'Q': '♕', 'R': '♖', 'B': '♗', 'N': '♘', 'P': '♙',
      'k': '♚', 'q': '♛', 'r': '♜', 'b': '♝', 'n': '♞', 'p': '♟',
    };
    return map[p] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF060811),
      appBar: AppBar(
        backgroundColor: Color(0xFF0C0F1E),
        foregroundColor: Colors.white,
        title: const Text('♟ Catur', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => setState(_initBoard),
          ),
        ],
      ),
      body: Column(children: [
        // Status
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10),
          color: Color(0xFF131929),
          child: Text(statusMsg,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
        ),
        // Captures
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('⚔️ Kamu: $whiteCaptures tangkapan',
                style: const TextStyle(color: Color(0xFF4ECDC4), fontSize: 12)),
            Text('🤖 AI: $blackCaptures tangkapan',
                style: const TextStyle(color: const Color(0xFFFF1744), fontSize: 12)),
          ]),
        ),
        // Board
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: 1,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
                  itemCount: 64,
                  itemBuilder: (_, idx) {
                    final r = idx ~/ 8;
                    final c = idx % 8;
                    final isSelected = selected != null && selected![0] == r && selected![1] == c;
                    final isValidMove = validMoves.any((m) => m[0] == r && m[1] == c);
                    final piece = board[r][c];

                    Color bg = _squareColor(r, c);
                    if (isSelected) bg = Color(0xFF00E676).withOpacity(0.7);
                    if (isValidMove) bg = Color(0xFFFFAB00).withOpacity(0.5);

                    return GestureDetector(
                      onTap: () => _onTap(r, c),
                      child: Container(
                        color: bg,
                        child: Stack(children: [
                          if (isValidMove && piece.isEmpty)
                            Center(
                              child: Container(
                                width: 10, height: 10,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFFFFAB00),
                                ),
                              ),
                            ),
                          Center(
                            child: Text(
                              _pieceEmoji(piece),
                              style: TextStyle(
                                fontSize: 22,
                                color: _isWhite(piece) ? Colors.white : const Color(0xFF1A1A2E),
                                shadows: [
                                  Shadow(
                                    color: _isWhite(piece) ? Colors.black54 : Colors.white54,
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ]),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        if (gameOver)
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Main Lagi', style: TextStyle(fontWeight: FontWeight.w700)),
              onPressed: () => setState(_initBoard),
            ),
          ),
        const SizedBox(height: 16),
      ]),
    );
  }
}
