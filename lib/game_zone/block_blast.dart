import 'dart:math';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// BLOCK BLAST GAME
// ─────────────────────────────────────────────────────────────────────────────

class BlockBlastPage extends StatefulWidget {
  const BlockBlastPage({super.key});
  @override
  State<BlockBlastPage> createState() => _BlockBlastPageState();
}

class _BlockBlastPageState extends State<BlockBlastPage>
    with TickerProviderStateMixin {
  static const int _rows = 8;
  static const int _cols = 8;
  static const List<Color> _colors = [
    const Color(0xFFFF1744), // red
    Color(0xFF3B82F6), // blue
    const Color(0xFF00E676), // green
    const Color(0xFFFFAB00), // yellow
    Color(0xFFA855F7), // purple
    Color(0xFF06B6D4), // cyan
  ];

  late List<List<int>> _board; // -1 = empty, 0-5 = color index
  int _score = 0;
  int _best = 0;
  bool _gameOver = false;
  Set<String> _selected = {};
  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _shakeAnim = Tween(begin: 0.0, end: 8.0)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeCtrl);
    _newGame();
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _newGame() {
    final rng = Random();
    _board = List.generate(
        _rows, (_) => List.generate(_cols, (_) => rng.nextInt(_colors.length)));
    _score = 0;
    _gameOver = false;
    _selected = {};
    setState(() {});
  }

  // Find all connected cells of same color using flood fill
  Set<String> _findGroup(int row, int col) {
    final color = _board[row][col];
    if (color == -1) return {};
    final visited = <String>{};
    final stack = <List<int>>[
      [row, col]
    ];
    while (stack.isNotEmpty) {
      final curr = stack.removeLast();
      final r = curr[0], c = curr[1];
      final key = '$r,$c';
      if (visited.contains(key)) continue;
      if (r < 0 || r >= _rows || c < 0 || c >= _cols) continue;
      if (_board[r][c] != color) continue;
      visited.add(key);
      stack.addAll([
        [r - 1, c],
        [r + 1, c],
        [r, c - 1],
        [r, c + 1],
      ]);
    }
    return visited;
  }

  void _onTap(int row, int col) {
    if (_gameOver) return;
    if (_board[row][col] == -1) return;

    final group = _findGroup(row, col);
    if (group.length < 2) {
      // Single block — highlight briefly and shake
      setState(() => _selected = group);
      _shakeCtrl.forward(from: 0);
      Future.delayed(const Duration(milliseconds: 300),
          () => setState(() => _selected = {}));
      return;
    }

    // Blast the group
    final points = group.length * group.length * 10;
    for (final key in group) {
      final parts = key.split(',');
      _board[int.parse(parts[0])][int.parse(parts[1])] = -1;
    }

    // Gravity: drop blocks down
    for (int c = 0; c < _cols; c++) {
      final col = <int>[];
      for (int r = _rows - 1; r >= 0; r--) {
        if (_board[r][c] != -1) col.add(_board[r][c]);
      }
      for (int r = _rows - 1; r >= 0; r--) {
        _board[r][c] = r < _rows - col.length ? -1 : col[_rows - 1 - r];
      }
    }

    _score += points;
    if (_score > _best) _best = _score;
    _selected = {};

    // Check game over: no group of 2+
    bool hasMove = false;
    outer:
    for (int r = 0; r < _rows; r++) {
      for (int c = 0; c < _cols; c++) {
        if (_board[r][c] != -1 && _findGroup(r, c).length >= 2) {
          hasMove = true;
          break outer;
        }
      }
    }
    if (!hasMove) _gameOver = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        title: const Text('Block Blast',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _newGame),
        ],
      ),
      body: Column(
        children: [
          // Score bar
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF6D28D9), Color(0xFF7C3AED)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _scoreBox('SKOR', _score),
                Container(width: 1, height: 40, color: Colors.white30),
                _scoreBox('TERBAIK', _best),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text('Tap blok berwarna sama (≥2) untuk meledakkannya!',
                style: TextStyle(color: Colors.white54, fontSize: 12)),
          ),

          // Board
          Expanded(
            child: Center(
              child: AnimatedBuilder(
                animation: _shakeAnim,
                builder: (ctx, child) => Transform.translate(
                  offset: Offset(_shakeAnim.value * (Random().nextDouble() - 0.5), 0),
                  child: child,
                ),
                child: AspectRatio(
                  aspectRatio: _cols / _rows,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: _cols,
                          crossAxisSpacing: 3,
                          mainAxisSpacing: 3),
                      itemCount: _rows * _cols,
                      itemBuilder: (ctx, idx) {
                        final r = idx ~/ _cols;
                        final c = idx % _cols;
                        final colorIdx = _board[r][c];
                        final key = '$r,$c';
                        final isSelected = _selected.contains(key);
                        if (colorIdx == -1) {
                          return Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          );
                        }
                        return GestureDetector(
                          onTap: () => _onTap(r, c),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white
                                  : _colors[colorIdx],
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                          color: _colors[colorIdx]
                                              .withOpacity(0.8),
                                          blurRadius: 8,
                                          spreadRadius: 2)
                                    ]
                                  : [],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Game over overlay
          if (_gameOver)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFFDC2626), Color(0xFF991B1B)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text('GAME OVER! 🎮',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  Text('Skor: $_score',
                      style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _newGame,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFDC2626)),
                    child: const Text('Main Lagi'),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _scoreBox(String label, int value) => Column(
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white60, fontSize: 11)),
          Text('$value',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
        ],
      );
}
