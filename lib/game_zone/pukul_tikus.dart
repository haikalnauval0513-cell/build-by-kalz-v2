import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PUKUL TIKUS! (WHACK-A-MOLE)
// ─────────────────────────────────────────────────────────────────────────────

class PukulTikusPage extends StatefulWidget {
  const PukulTikusPage({super.key});
  @override
  State<PukulTikusPage> createState() => _PukulTikusPageState();
}

class _PukulTikusPageState extends State<PukulTikusPage>
    with TickerProviderStateMixin {
  static const int _gridSize = 9;
  static const int _gameTime = 30;

  final _rng = Random();
  List<int> _active = []; // active hole indices
  List<int> _bomb = []; // bomb hole indices (don't tap)
  int _score = 0;
  int _best = 0;
  int _miss = 0;
  int _timeLeft = _gameTime;
  bool _started = false;
  bool _finished = false;
  Timer? _gameTimer;
  Timer? _moleTimer;
  List<AnimationController> _controllers = [];
  List<bool> _hit = List.filled(_gridSize, false);

  static const List<String> _moles = ['🐭', '🐹', '🐱'];
  static const String _bomb_emoji = '💣';

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < _gridSize; i++) {
      _controllers.add(
          AnimationController(vsync: this, duration: const Duration(milliseconds: 200)));
    }
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _moleTimer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _startGame() {
    _score = 0;
    _miss = 0;
    _timeLeft = _gameTime;
    _active = [];
    _bomb = [];
    _hit = List.filled(_gridSize, false);
    _finished = false;
    _started = true;

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        _timeLeft--;
        if (_timeLeft <= 0) {
          t.cancel();
          _moleTimer?.cancel();
          _finished = true;
          _active = [];
          _bomb = [];
          if (_score > _best) _best = _score;
        }
      });
    });

    _spawnMoles();
    setState(() {});
  }

  void _spawnMoles() {
    _moleTimer?.cancel();
    // Speed increases as time runs out
    final speed = _timeLeft > 20
        ? 900
        : _timeLeft > 10
            ? 700
            : 500;
    _moleTimer = Timer(Duration(milliseconds: speed), () {
      if (_finished || !_started) return;
      setState(() {
        _active = [];
        _bomb = [];
        _hit = List.filled(_gridSize, false);
        // Spawn 2-3 moles
        final count = _rng.nextInt(2) + 2;
        final positions = List.generate(_gridSize, (i) => i)..shuffle();
        _active = positions.take(count).toList();
        // 30% chance to also add a bomb
        if (_rng.nextDouble() < 0.3 && positions.length > count) {
          _bomb = [positions[count]];
        }
      });
      _spawnMoles();
    });
  }

  void _onTap(int index) {
    if (!_started || _finished) return;
    if (_bomb.contains(index)) {
      // Hit bomb
      setState(() {
        _score = (_score - 5).clamp(0, 9999);
        _bomb.remove(index);
        _hit[index] = true;
      });
      Future.delayed(const Duration(milliseconds: 200),
          () => setState(() => _hit[index] = false));
    } else if (_active.contains(index)) {
      // Hit mole
      _controllers[index].forward(from: 0);
      setState(() {
        _score += 10;
        _active.remove(index);
        _hit[index] = true;
      });
      Future.delayed(const Duration(milliseconds: 200),
          () => setState(() => _hit[index] = false));
    } else {
      // Miss
      setState(() => _miss++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pct = _timeLeft / _gameTime;
    final timerColor = pct > 0.5
        ? Colors.greenAccent
        : pct > 0.25
            ? Colors.orange
            : Colors.redAccent;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        title: const Text('Pukul Tikus! 🐭',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
                child: Text('🏆 $_best',
                    style: const TextStyle(color: Colors.amber))),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: !_started && !_finished
            ? _buildStart()
            : _finished
                ? _buildFinish()
                : _buildGame(timerColor, pct),
      ),
    );
  }

  Widget _buildStart() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🐭', style: TextStyle(fontSize: 72)),
            const SizedBox(height: 16),
            const Text('Pukul Tikus!',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('Tap tikus yang muncul dalam $_gameTime detik!\nHindari bom 💣 (-5 poin)',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white60, fontSize: 16)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _startGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF00E676),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('MULAI!',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            if (_best > 0) ...[
              const SizedBox(height: 16),
              Text('Rekor: $_best poin',
                  style: const TextStyle(color: Colors.amber)),
            ],
          ],
        ),
      );

  Widget _buildFinish() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_score >= 100 ? '🏆' : _score >= 50 ? '😊' : '😅',
                style: const TextStyle(fontSize: 72)),
            const SizedBox(height: 16),
            const Text('Selesai!',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF1E293B), Color(0xFF0F172A)]),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Column(
                children: [
                  _statRow('Skor', '$_score poin', Colors.white),
                  const SizedBox(height: 8),
                  _statRow('Rekor', '$_best poin', Colors.amber),
                  const SizedBox(height: 8),
                  _statRow('Miss', '$_miss kali', Colors.redAccent),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _startGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF00E676),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Main Lagi'),
            ),
          ],
        ),
      );

  Widget _statRow(String label, String value, Color color) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white60, fontSize: 14)),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
        ],
      );

  Widget _buildGame(Color timerColor, double pct) => Column(
        children: [
          // Stats bar
          Row(
            children: [
              _statCard('SKOR', '$_score', Colors.white),
              const SizedBox(width: 8),
              _statCard('WAKTU', '$_timeLeft', timerColor),
              const SizedBox(width: 8),
              _statCard('MISS', '$_miss', Colors.redAccent),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: const Color(0xFF1E293B),
              color: timerColor,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '🐭 Tap tikus! Hindari 💣!',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 12),
          // Game grid
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _gridSize,
              itemBuilder: (ctx, i) {
                final isActive = _active.contains(i);
                final isBomb = _bomb.contains(i);
                final isHit = _hit[i];
                return GestureDetector(
                  onTap: () => _onTap(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: isHit
                          ? (isBomb
                              ? Colors.redAccent.withOpacity(0.3)
                              : Colors.greenAccent.withOpacity(0.3))
                          : const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isActive
                            ? Color(0xFF00E676)
                            : isBomb
                                ? Colors.redAccent
                                : const Color(0xFF334155),
                        width: isActive || isBomb ? 2 : 1,
                      ),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                  color: Colors.greenAccent.withOpacity(0.3),
                                  blurRadius: 8)
                            ]
                          : isBomb
                              ? [
                                  BoxShadow(
                                      color: Colors.redAccent.withOpacity(0.3),
                                      blurRadius: 8)
                                ]
                              : [],
                    ),
                    child: Center(
                      child: AnimatedScale(
                        scale: isActive || isBomb ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 150),
                        child: Text(
                          isBomb
                              ? _bomb_emoji
                              : isActive
                                  ? _moles[i % _moles.length]
                                  : '',
                          style: const TextStyle(fontSize: 40),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );

  Widget _statCard(String label, String value, Color color) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text(label,
                  style:
                      const TextStyle(color: Colors.white54, fontSize: 10)),
              Text(value,
                  style: TextStyle(
                      color: color,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );
}
