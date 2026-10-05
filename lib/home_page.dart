import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';

// ═══════════════════════════════════════════════════════════
// MILITARY COMMAND PALETTE
// ═══════════════════════════════════════════════════════════
class Sk {
  // Steel / titanium
  static const Color steel1 = Color(0xFF1A1D21);
  static const Color steel2 = Color(0xFF2C3138);
  static const Color steel3 = Color(0xFF424850);
  static const Color steel4 = Color(0xFF5A6068);
  static const Color steel5 = Color(0xFF7A8088);

  // Titanium / chrome
  static const Color chromeDark = Color(0xFF8A9098);
  static const Color chrome = Color(0xFFB8BEC6);
  static const Color chromeHi = Color(0xFFD8DEE6);

  // Signal red
  static const Color crimsonDeep = Color(0xFF3A0505);
  static const Color crimsonDark = Color(0xFF7A0A0A);
  static const Color crimson = Color(0xFFB51212);
  static const Color crimsonHi = Color(0xFFE81C1C);
  static const Color crimsonGlow = Color(0xFFFF3A3A);

  // Signal orange
  static const Color orangeDeep = Color(0xFF3A1A00);
  static const Color orange = Color(0xFFD06A00);
  static const Color orangeHi = Color(0xFFFF8C1A);

  // Signal green
  static const Color greenDeep = Color(0xFF082A12);
  static const Color green = Color(0xFF1E7A3E);
  static const Color greenHi = Color(0xFF32CC5E);
  static const Color greenGlow = Color(0xFF00FF88);

  // Signal cyan
  static const Color cyanDeep = Color(0xFF062A30);
  static const Color cyan = Color(0xFF0E8A9C);
  static const Color cyanHi = Color(0xFF26D0E8);

  // Amber
  static const Color amber = Color(0xFFFFB300);
  static const Color amberGlow = Color(0xFFFFD54F);

  // Paper
  static const Color paper = Color(0xFF1F1A12);
  static const Color paperHi = Color(0xFF2D2818);
  static const Color ink = Color(0xFFE8DFC8);
  static const Color inkDim = Color(0xFFB0A78E);

  // Slate
  static const Color slate1 = Color(0xFF0F1114);
  static const Color slate2 = Color(0xFF161A20);
  static const Color slate3 = Color(0xFF1E242C);
}

// ═══════════════════════════════════════════════════════════
// CORE UI COMPONENTS
// ═══════════════════════════════════════════════════════════

class _Led extends StatefulWidget {
  final Color color;
  final double size;
  final bool pulse;
  const _Led({required this.color, this.size = 8, this.pulse = false});

  @override
  State<_Led> createState() => _LedState();
}

class _LedState extends State<_Led> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.pulse) _c.repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        final opacity = widget.pulse ? 0.5 + _c.value * 0.5 : 1.0;
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withOpacity(opacity),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.7 * opacity),
                blurRadius: widget.size * 1.2,
                spreadRadius: widget.size * 0.3,
              ),
              BoxShadow(
                color: widget.color.withOpacity(0.3 * opacity),
                blurRadius: widget.size * 2.5,
                spreadRadius: widget.size * 0.6,
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.6),
                offset: Offset(-widget.size * 0.15, -widget.size * 0.15),
                blurRadius: widget.size * 0.3,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Rivet extends StatelessWidget {
  final double size;
  const _Rivet({this.size = 8});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          center: Alignment(-0.4, -0.4),
          colors: [Sk.chromeHi, Sk.chrome, Sk.steel3, Sk.steel1],
          stops: [0.0, 0.35, 0.7, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.7),
            offset: const Offset(1, 1),
            blurRadius: 1.5,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.2),
            offset: const Offset(-0.5, -0.5),
            blurRadius: 0.5,
          ),
        ],
      ),
    );
  }
}

class _Screw extends StatelessWidget {
  final double size;
  final double rotation;
  const _Screw({this.size = 12, this.rotation = 0.785});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          center: Alignment(-0.4, -0.4),
          colors: [Sk.chrome, Sk.steel4, Sk.steel2, Sk.steel1],
          stops: [0.0, 0.4, 0.75, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.8),
            offset: const Offset(1, 1.5),
            blurRadius: 2,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.15),
            offset: const Offset(-0.5, -0.5),
            blurRadius: 0.5,
          ),
        ],
      ),
      child: Center(
        child: Transform.rotate(
          angle: rotation,
          child: Container(
            width: size * 0.65,
            height: 1.5,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ),
      ),
    );
  }
}

class _TacticalPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final Color? accent;
  final bool elevated;
  const _TacticalPanel({
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.radius = 12,
    this.accent,
    this.elevated = true,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = accent ?? Sk.steel3;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Sk.slate3, Sk.slate2, Sk.slate1],
          stops: [0.0, 0.5, 1.0],
        ),
        border: Border.all(
          color: accentColor,
          width: 1.2,
        ),
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.75),
                  offset: const Offset(0, 6),
                  blurRadius: 12,
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.05),
                  offset: const Offset(-1.5, -1.5),
                  blurRadius: 3,
                ),
                BoxShadow(
                  color: accentColor.withOpacity(0.15),
                  blurRadius: 16,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}

class _DisplayPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color glowColor;
  final bool glow;
  const _DisplayPanel({
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.glowColor = Sk.crimson,
    this.glow = false,
  });

  @override
  Widget build(BuildContext context) {
    final gc = glowColor;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF06080A), Color(0xFF0F1216)],
        ),
        border: Border.all(
          color: glow ? gc.withOpacity(0.6) : Sk.steel2,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.95),
            offset: const Offset(0, 3),
            blurRadius: 5,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.08),
            offset: const Offset(0, -1),
            blurRadius: 1,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.7),
            offset: const Offset(0, 1),
            blurRadius: 0,
            spreadRadius: 1,
          ),
          if (glow)
            BoxShadow(
              color: gc.withOpacity(0.4),
              blurRadius: 14,
              spreadRadius: 0,
            ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accent;
  final Widget? trailing;
  const _SectionHeader({
    required this.title,
    required this.icon,
    this.accent = Sk.crimsonHi,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final ac = accent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Sk.steel3, Sk.steel2, Sk.steel1],
        ),
        border: Border.all(color: Sk.steel1, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            offset: const Offset(0, 2),
            blurRadius: 3,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.08),
            offset: const Offset(0, -1),
            blurRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [ac, ac.withOpacity(0.6)],
              ),
              border: Border.all(
                color: ac.withOpacity(0.8),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: ac.withOpacity(0.4),
                  blurRadius: 6,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 13),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Sk.chromeHi,
                fontFamily: 'Orbitron',
                fontWeight: FontWeight.w900,
                fontSize: 10,
                letterSpacing: 2,
                shadows: [
                  Shadow(
                    color: Colors.black,
                    offset: Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ),
          if (trailing != null) trailing!,
          const SizedBox(width: 6),
          const _Screw(size: 10, rotation: 0),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// HOME PAGE
// ═══════════════════════════════════════════════════════════
class HomePage extends StatefulWidget {
  final String username;
  final String password;
  final String sessionKey;
  final List<Map<String, dynamic>> listBug;
  final String role;
  final String expiredDate;

  const HomePage({
    super.key,
    required this.username,
    required this.password,
    required this.sessionKey,
    required this.listBug,
    required this.role,
    required this.expiredDate,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _cursorCtrl;

  late AnimationController _sendCtrl;
  late Animation<double> _sendScale;
  late Animation<double> _sendGlow;
  late Animation<double> _sendRotate;

  final targetController = TextEditingController();
  final PageController _imagePageController = PageController();

  Timer? _imageSliderTimer;
  Timer? _senderTimer;
  Timer? _typeTimer;

  int _currentImagePage = 0;

  final List<String> _sliderImages = [
    'assets/images/welcome.png',
    'assets/images/trasher.jpeg',
  ];

  String? _selectedBugId;
  bool _isSending = false;
  String? _responseMessage;

  List<String> _globalSenders = [];
  bool _isLoadingSenders = false;
  int _privateSenderCount = 0;
  int _globalSenderCount = 0;
  bool _loadingSender = false;

  String _selectedSender = 'private';

  String _typedText = "";
  int _typeIndex = 0;
  bool _isDeleting = false;

  bool get canAccessGlobalSender {
    final r = widget.role.toLowerCase();
    return r == 'developer' ||
        r == 'staf' ||
        r == 'moderator' ||
        r == 'owner' ||
        r == 'patner';
  }

  @override
  void initState() {
    super.initState();

    _cursorCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _sendCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _sendScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.04)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.04, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.97)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.97, end: 1.06)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 40,
      ),
    ]).animate(_sendCtrl);

    _sendGlow = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _sendCtrl,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _sendRotate = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _sendCtrl,
        curve: const Interval(0.2, 0.8, curve: Curves.easeInOut),
      ),
    );

    _fetchSenderStats();
    _loadGlobalSenders();

    _senderTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _fetchSenderStats();
    });

    _imageSliderTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_imagePageController.hasClients) {
        _currentImagePage =
            (_currentImagePage + 1) % _sliderImages.length;
        _imagePageController.animateToPage(
          _currentImagePage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });

    if (widget.listBug.isNotEmpty) {
      _selectedBugId = widget.listBug[0]['bug_id'] as String? ?? '0';
    }

    _startTypewriter();
  }

  void _startTypewriter() {
    const fullText = "vantaniv zasta";
    _typeTimer?.cancel();
    _typeIndex = 0;
    _isDeleting = false;
    _typedText = "";

    _typeTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (!mounted) return;
      setState(() {
        if (!_isDeleting) {
          if (_typeIndex < fullText.length) {
            _typedText = fullText.substring(0, _typeIndex + 1);
            _typeIndex++;
          } else {
            _isDeleting = true;
            timer.cancel();
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) _startDeleting();
            });
          }
        }
      });
    });
  }

  void _startDeleting() {
    _typeTimer?.cancel();
    _typeTimer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      if (!mounted) return;
      setState(() {
        if (_typeIndex > 0) {
          _typedText = _typedText.substring(0, _typeIndex - 1);
          _typeIndex--;
        } else {
          timer.cancel();
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) _startTypewriter();
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _cursorCtrl.dispose();
    _sendCtrl.dispose();
    targetController.dispose();
    _imagePageController.dispose();
    _senderTimer?.cancel();
    _imageSliderTimer?.cancel();
    _typeTimer?.cancel();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════
  // API
  // ═══════════════════════════════════════════════════════════
  Future<void> _fetchSenderStats() async {
    if (_loadingSender) return;
    if (mounted) setState(() => _loadingSender = true);
    try {
      final response = await http
          .get(Uri.parse(
              "$baseUrl/getSenderStats?key=${widget.sessionKey}"))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['valid'] == true && mounted) {
          setState(() {
            _privateSenderCount = data['private'] ?? 0;
            _globalSenderCount = data['global'] ?? 0;
            _loadingSender = false;
          });
          return;
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _loadingSender = false);
  }

  Future<void> _loadGlobalSenders() async {
    if (mounted) setState(() => _isLoadingSenders = true);
    try {
      final res = await http
          .get(Uri.parse(
              '$baseUrl/getActiveSenders?key=${widget.sessionKey}'))
          .timeout(const Duration(seconds: 10));
      final data = jsonDecode(res.body);
      if (data['valid'] == true && data['senders'] != null && mounted) {
        setState(() {
          _globalSenders = List<String>.from(data['senders']);
          _globalSenderCount = _globalSenders.length;
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoadingSenders = false);
  }

  String? formatPhoneNumber(String input) {
    final cleaned = input.replaceAll(RegExp(r'[^\d+]'), '');
    if (!cleaned.startsWith('+') || cleaned.length < 8) return null;
    return cleaned;
  }

  void _setResponse(String type, String msg) {
    if (!mounted) return;
    setState(() => _responseMessage = '$type|$msg');
  }

  Future<void> _sendBug() async {
    final rawInput = targetController.text.trim();
    final key = widget.sessionKey;

    if (formatPhoneNumber(rawInput) == null) {
      _showAlert("Nomor Tidak Valid",
          "Gunakan format internasional.\nContoh: +62812xxxxxxxx");
      return;
    }

    if (_selectedSender == 'global' && !canAccessGlobalSender) {
      _showAlert(
          "Akses Ditolak", "Sender Global hanya untuk Staf Dan Vvip");
      return;
    }

    if (_selectedBugId == null || _selectedBugId!.isEmpty) {
      _showAlert("No Bug Selected", "Pilih 1 bug untuk dikirim.");
      return;
    }

    if (_selectedSender == 'private' && _privateSenderCount == 0) {
      _showAlert(
          "No Private Sender", "Tidak ada private sender tersedia.");
      return;
    }
    if (_selectedSender == 'global' && _globalSenderCount == 0) {
      _showAlert(
          "No Global Sender", "Tidak ada global sender tersedia.");
      return;
    }

    HapticFeedback.mediumImpact();
    _sendCtrl.forward(from: 0);

    setState(() {
      _isSending = true;
      _responseMessage = null;
    });

    try {
      final encodedTarget = Uri.encodeComponent(rawInput);
      final res = await http.get(Uri.parse('$baseUrl/sendBug'
        '?key=$key'
        '&target=$encodedTarget'
        '&bug=$_selectedBugId'
        '${_selectedSender == 'global' ? '&senderMode=global' : '&sender=private'}',
      )).timeout(const Duration(seconds: 15));
      final data = jsonDecode(res.body);

      if (data['valid'] == false) {
        _setResponse('error', 'Session key tidak valid. Login ulang.');
      } else if (data['cooldown'] == true) {
        _setResponse('warning',
            'Cooldown aktif! Tunggu ${data['wait'] ?? 0} detik.');
      } else if (data['sended'] == true) {
        _setResponse('success',
            'Bug berhasil dikirim ke $rawInput! [${data['role'] ?? widget.role}]');
        targetController.clear();
        HapticFeedback.heavyImpact();
      } else {
        _setResponse('error', 'Gagal mengirim. Server maintenance.');
      }
    } catch (e) {
      _setResponse('error', 'Koneksi error. Periksa jaringan.');
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _showAlert(String title, String msg) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: _TacticalPanel(
          padding: const EdgeInsets.all(20),
          accent: Sk.crimsonHi,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Sk.crimsonDeep,
                      border: Border.all(
                          color: Sk.crimsonHi.withOpacity(0.6),
                          width: 1.5),
                    ),
                    child: const Icon(Icons.warning_amber_rounded,
                        color: Sk.crimsonGlow, size: 26),
                  ),
                  const Positioned(
                    top: 0,
                    right: 0,
                    child:
                        _Led(color: Sk.crimsonGlow, size: 10, pulse: true),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                title.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Sk.chromeHi,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Orbitron',
                  letterSpacing: 2,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      offset: Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                msg,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Sk.inkDim,
                  fontSize: 11,
                  fontFamily: 'ShareTechMono',
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Sk.crimsonHi, Sk.crimson, Sk.crimsonDark],
                    ),
                    border: Border.all(
                      color: Sk.crimsonDeep,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Sk.crimsonGlow.withOpacity(0.4),
                        blurRadius: 12,
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.6),
                        offset: const Offset(0, 3),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Orbitron',
                      letterSpacing: 2.5,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          offset: Offset(0, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // TOP COMMAND BAR
  // ═══════════════════════════════════════════════════════════
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Sk.steel3, Sk.steel2, Sk.steel1],
          ),
          border: Border.all(color: Sk.steel1, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.7),
              offset: const Offset(0, 4),
              blurRadius: 8,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.05),
              offset: const Offset(0, -1),
              blurRadius: 2,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              const _Screw(size: 12),
              const SizedBox(width: 8),
              const _Led(color: Sk.greenGlow, size: 6, pulse: true),
              const SizedBox(width: 8),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    center: Alignment(-0.3, -0.3),
                    colors: [Sk.crimsonHi, Sk.crimson, Sk.crimsonDeep],
                  ),
                  border: Border.all(color: Sk.crimsonDeep, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Sk.crimsonGlow.withOpacity(0.4),
                      blurRadius: 10,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: const Icon(Icons.shield_rounded,
                    color: Colors.white, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        _typedText.isEmpty ? " " : _typedText,
                        style: const TextStyle(
                          color: Sk.chromeHi,
                          fontFamily: 'Orbitron',
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          letterSpacing: 2.5,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              offset: Offset(0, 1),
                              blurRadius: 2,
                            ),
                            Shadow(
                              color: Sk.crimson,
                              offset: Offset(0, 0),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    FadeTransition(
                      opacity: _cursorCtrl,
                      child: Container(
                        width: 2,
                        height: 14,
                        margin: const EdgeInsets.only(left: 2),
                        color: Sk.crimsonHi,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Sk.steel4, Sk.steel2],
                  ),
                  border: Border.all(color: Sk.steel5, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      offset: const Offset(0, 2),
                      blurRadius: 3,
                    ),
                  ],
                ),
                child: const Text(
                  'V6.0',
                  style: TextStyle(
                    color: Sk.chromeHi,
                    fontFamily: 'Orbitron',
                    fontWeight: FontWeight.w900,
                    fontSize: 9,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const _Screw(size: 12, rotation: 0),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // COMMANDER BANNER
  // ═══════════════════════════════════════════════════════════
  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Sk.steel4, Sk.steel3, Sk.steel2, Sk.steel1],
          stops: [0.0, 0.4, 0.7, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.75),
            offset: const Offset(0, 8),
            blurRadius: 16,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.08),
            offset: const Offset(-2, -2),
            blurRadius: 4,
          ),
          BoxShadow(
            color: Sk.crimsonGlow.withOpacity(0.12),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.all(3),
      child: Container(
        height: 158,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Sk.slate3, Sk.slate2, Sk.slate1],
          ),
          border: Border.all(color: Sk.steel1, width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/background.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: Sk.slate1),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.55),
                        Colors.black.withOpacity(0.75),
                        Colors.black.withOpacity(0.85),
                      ],
                    ),
                  ),
                ),
              ),
              const Positioned(top: 5, left: 5, child: _Rivet(size: 8)),
              const Positioned(top: 5, right: 5, child: _Rivet(size: 8)),
              const Positioned(bottom: 5, left: 5, child: _Rivet(size: 8)),
              const Positioned(bottom: 5, right: 5, child: _Rivet(size: 8)),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              const _Led(
                                  color: Sk.greenGlow,
                                  size: 6,
                                  pulse: true),
                              const SizedBox(width: 6),
                              Text(
                                'WELCOME BACK',
                                style: TextStyle(
                                  color: Sk.ink.withOpacity(0.75),
                                  fontSize: 9,
                                  fontFamily: 'Orbitron',
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.username.toUpperCase(),
                            style: const TextStyle(
                              color: Sk.chromeHi,
                              fontFamily: 'Orbitron',
                              fontWeight: FontWeight.w900,
                              fontSize: 24,
                              letterSpacing: 2,
                              shadows: [
                                Shadow(
                                  color: Colors.black87,
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                ),
                                Shadow(
                                  color: Sk.crimson,
                                  offset: Offset(0, 0),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: Sk.slate1.withOpacity(0.75),
                              border:
                                  Border.all(color: Sk.steel3, width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const _Led(
                                    color: Sk.crimsonHi, size: 5),
                                const SizedBox(width: 6),
                                Text(
                                  'EXP: ${widget.expiredDate}',
                                  style: const TextStyle(
                                    color: Sk.chrome,
                                    fontSize: 9,
                                    fontFamily: 'ShareTechMono',
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Sk.crimsonHi,
                                Sk.crimson,
                                Sk.crimsonDark
                              ],
                            ),
                            border: Border.all(
                                color: Sk.crimsonDeep, width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: Sk.crimsonGlow
                                    .withOpacity(0.5),
                                blurRadius: 8,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Text(
                            widget.role.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Orbitron',
                              fontWeight: FontWeight.w900,
                              fontSize: 9,
                              letterSpacing: 1.5,
                              shadows: [
                                Shadow(
                                  color: Colors.black54,
                                  offset: Offset(0, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const RadialGradient(
                                  center: Alignment(-0.3, -0.3),
                                  colors: [
                                    Sk.chrome,
                                    Sk.steel4,
                                    Sk.steel2,
                                    Sk.steel1,
                                  ],
                                  stops: [0.0, 0.4, 0.7, 1.0],
                                ),
                                border: Border.all(
                                  color: Sk.crimsonHi,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Sk.crimsonGlow
                                        .withOpacity(0.4),
                                    blurRadius: 12,
                                    spreadRadius: 1,
                                  ),
                                  BoxShadow(
                                    color: Colors.black
                                        .withOpacity(0.7),
                                    offset: const Offset(0, 3),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  widget.username.isNotEmpty
                                      ? widget.username[0].toUpperCase()
                                      : 'A',
                                  style: const TextStyle(
                                    color: Sk.chromeHi,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    fontFamily: 'Orbitron',
                                    shadows: [
                                      Shadow(
                                        color: Colors.black87,
                                        offset: Offset(0, 1),
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const Positioned(
                              bottom: 0,
                              right: 0,
                              child: _Led(
                                  color: Sk.greenGlow,
                                  size: 10,
                                  pulse: true),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // STATS ROW
  // ═══════════════════════════════════════════════════════════
  Widget _buildStatsBar() {
    return _TacticalPanel(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      accent: Sk.steel3,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statReadout(
            icon: Icons.bug_report_rounded,
            value: '${widget.listBug.length}',
            label: 'TOTAL CMD',
            color: Sk.crimsonHi,
          ),
          _divider(),
          _statReadout(
            icon: Icons.bolt_rounded,
            value: 'HARD',
            label: 'MODE',
            color: Sk.orangeHi,
          ),
          _divider(),
          _statReadout(
            icon: Icons.shield_rounded,
            value: 'SECURE',
            label: 'STATUS',
            color: Sk.greenGlow,
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 40,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Sk.steel3,
              Colors.transparent,
            ],
          ),
        ),
      );

  Widget _statReadout({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.3, -0.3),
                colors: [
                  color.withOpacity(0.35),
                  color.withOpacity(0.1),
                  Colors.black.withOpacity(0.8),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              border: Border.all(
                color: color.withOpacity(0.6),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.35),
                  blurRadius: 10,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 12,
              fontFamily: 'Orbitron',
              letterSpacing: 1,
              shadows: [
                Shadow(color: color.withOpacity(0.6), blurRadius: 6),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Sk.chrome.withOpacity(0.5),
              fontSize: 7,
              fontFamily: 'Orbitron',
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // IMAGE SLIDER
  // ═══════════════════════════════════════════════════════════
  Widget _buildImageSlider() {
    return _TacticalPanel(
      padding: const EdgeInsets.all(4),
      accent: Sk.steel3,
      child: AspectRatio(
        aspectRatio: 21 / 9,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              PageView.builder(
                controller: _imagePageController,
                itemCount: _sliderImages.length,
                onPageChanged: (int index) {
                  setState(() => _currentImagePage = index);
                },
                itemBuilder: (context, index) {
                  return Image.asset(
                    _sliderImages[index],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: Sk.slate1),
                  );
                },
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: Colors.black.withOpacity(0.7),
                    border: Border.all(
                        color: Sk.steel3.withOpacity(0.5), width: 1),
                  ),
                  child: Row(
                    children: List.generate(
                      _sliderImages.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        height: 4,
                        width: _currentImagePage == index ? 14 : 5,
                        decoration: BoxDecoration(
                          color: _currentImagePage == index
                              ? Sk.crimsonHi
                              : Sk.chrome.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: _currentImagePage == index
                              ? [
                                  BoxShadow(
                                    color: Sk.crimsonGlow
                                        .withOpacity(0.7),
                                    blurRadius: 6,
                                    spreadRadius: 0,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // TARGET INPUT
  // ═══════════════════════════════════════════════════════════
  Widget _buildTargetPanel() {
    return _TacticalPanel(
      accent: Sk.crimsonHi.withOpacity(0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            title: 'TARGET NUMBER',
            icon: Icons.phone_android_rounded,
            accent: Sk.crimsonHi,
          ),
          const SizedBox(height: 12),
          _DisplayPanel(
            glowColor: Sk.crimsonGlow,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Sk.steel4, Sk.steel2],
                    ),
                    border: Border.all(color: Sk.steel1, width: 1),
                  ),
                  child: const Icon(
                    Icons.language_rounded,
                    color: Sk.crimsonHi,
                    size: 13,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: targetController,
                    style: const TextStyle(
                      color: Sk.chromeHi,
                      fontFamily: 'ShareTechMono',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                    cursorColor: Sk.crimsonHi,
                    cursorWidth: 2,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: '+62812XXXXXXXX',
                      hintStyle: TextStyle(
                        color: Sk.chrome.withOpacity(0.3),
                        fontFamily: 'ShareTechMono',
                        fontSize: 13,
                        letterSpacing: 1,
                      ),
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // BUG SELECTOR
  // ═══════════════════════════════════════════════════════════
  Widget _buildBugPanel() {
    return _TacticalPanel(
      accent: Sk.crimsonHi.withOpacity(0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: 'SELECT COMMAND',
            icon: Icons.bug_report_rounded,
            accent: Sk.crimsonHi,
            trailing: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: Sk.crimsonDeep,
                border: Border.all(
                    color: Sk.crimsonHi.withOpacity(0.6), width: 1),
              ),
              child: Text(
                '${widget.listBug.length}',
                style: const TextStyle(
                  color: Sk.crimsonGlow,
                  fontFamily: 'Orbitron',
                  fontWeight: FontWeight.w900,
                  fontSize: 8,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: List.generate(widget.listBug.length, (index) {
                final bug = widget.listBug[index];
                final bugId = bug['bug_id'] as String? ?? '$index';
                final isSelected = _selectedBugId == bugId;

                return _BugChip(
                  bugId: bugId,
                  isSelected: isSelected,
                  isFirst: index == 0,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedBugId = bugId);
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // SENDER PANEL
  // ═══════════════════════════════════════════════════════════
  Widget _buildSenderPanel() {
    return _TacticalPanel(
      accent: Sk.steel3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: 'SELECT SENDER',
            icon: Icons.swap_horiz_rounded,
            accent: Sk.crimsonHi,
            trailing: GestureDetector(
              onTap: () {
                _fetchSenderStats();
                _loadGlobalSenders();
                HapticFeedback.lightImpact();
              },
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Sk.steel4, Sk.steel2],
                  ),
                  border: Border.all(color: Sk.steel1, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      offset: const Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
                child: (_isLoadingSenders || _loadingSender)
                    ? const Padding(
                        padding: EdgeInsets.all(5),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Sk.crimsonHi,
                        ),
                      )
                    : const Icon(
                        Icons.refresh_rounded,
                        color: Sk.chromeHi,
                        size: 13,
                      ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _DisplayPanel(
            glowColor: Sk.greenGlow,
            glow: _privateSenderCount + _globalSenderCount > 0,
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                const _Led(color: Sk.greenGlow, size: 6, pulse: true),
                const SizedBox(width: 8),
                Text(
                  _loadingSender
                      ? 'READING SYSTEM...'
                      : '${_privateSenderCount + _globalSenderCount} SENDER ONLINE',
                  style: const TextStyle(
                    color: Sk.greenGlow,
                    fontFamily: 'Orbitron',
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: Sk.greenDeep,
                    border: Border.all(
                        color: Sk.greenGlow.withOpacity(0.5), width: 1),
                  ),
                  child: const Text(
                    'LIVE',
                    style: TextStyle(
                      color: Sk.greenGlow,
                      fontFamily: 'Orbitron',
                      fontSize: 7,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SenderTile(
                  icon: Icons.person_rounded,
                  title: 'PRIBADI',
                  count: _privateSenderCount,
                  isSelected: _selectedSender == 'private',
                  isLocked: false,
                  accent: Sk.crimsonHi,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedSender = 'private');
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SenderTile(
                  icon: Icons.public_rounded,
                  title: 'GLOBAL',
                  count: _globalSenderCount,
                  isSelected: _selectedSender == 'global',
                  isLocked: !canAccessGlobalSender,
                  accent: Sk.orangeHi,
                  onTap: () {
                    if (!canAccessGlobalSender) {
                      _showAlert('Akses Ditolak',
                          'Sender Global hanya untuk Staf Dan Vvip');
                      return;
                    }
                    HapticFeedback.selectionClick();
                    setState(() => _selectedSender = 'global');
                    _loadGlobalSenders();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_selectedSender == 'global' && _globalSenders.isNotEmpty)
            _DisplayPanel(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.format_list_bulleted_rounded,
                          color: Sk.orangeHi, size: 11),
                      const SizedBox(width: 6),
                      Text(
                        '${_globalSenders.length} ACTIVE SENDERS',
                        style: const TextStyle(
                          color: Sk.orangeHi,
                          fontSize: 9,
                          fontFamily: 'Orbitron',
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...(_globalSenders.take(3).map(
                        (s) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              const _Led(color: Sk.greenGlow, size: 4),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  s,
                                  style: const TextStyle(
                                    color: Sk.chrome,
                                    fontSize: 10,
                                    fontFamily: 'ShareTechMono',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                ],
              ),
            )
          else
            Row(
              children: [
                const _Led(color: Sk.orange, size: 5),
                const SizedBox(width: 8),
                Text(
                  'Sender Global Null Stay One',
                  style: TextStyle(
                    color: Sk.chrome.withOpacity(0.55),
                    fontFamily: 'ShareTechMono',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // SEND BUTTON — WITH ANIMATION
  // ═══════════════════════════════════════════════════════════
  Widget _buildSendButton() {
    return AnimatedBuilder(
      animation: _sendCtrl,
      builder: (context, _) {
        final isAnimating = _sendCtrl.isAnimating || _isSending;
        final scale = isAnimating ? _sendScale.value : 1.0;
        final glowAlpha = isAnimating ? _sendGlow.value : 0.35;
        final rotate = isAnimating ? _sendRotate.value * math.pi * 2 : 0.0;

        return Transform.scale(
          scale: scale,
          child: GestureDetector(
            onTap: _isSending ? null : _sendBug,
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFF3A3A),
                    Sk.crimsonHi,
                    Sk.crimson,
                    Sk.crimsonDeep,
                  ],
                  stops: [0.0, 0.25, 0.65, 1.0],
                ),
                border: Border.all(
                  color: Sk.crimsonDeep,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Sk.crimsonGlow.withOpacity(glowAlpha),
                    offset: const Offset(0, 0),
                    blurRadius: 20 + (glowAlpha * 15),
                    spreadRadius: -2,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.7),
                    offset: const Offset(0, 6),
                    blurRadius: 10,
                  ),
                  const BoxShadow(
                    color: Colors.white38,
                    offset: Offset(0, -2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 4,
                    left: 12,
                    right: 12,
                    child: Container(
                      height: 14,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(7),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withOpacity(0.4),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (isAnimating)
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Transform.rotate(
                          angle: rotate,
                          child: CustomPaint(
                            painter: _SendRingPainter(
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                        ),
                      ),
                    ),
                  const Positioned(top: 5, left: 5, child: _Rivet(size: 7)),
                  const Positioned(top: 5, right: 5, child: _Rivet(size: 7)),
                  const Positioned(
                      bottom: 5, left: 5, child: _Rivet(size: 7)),
                  const Positioned(
                      bottom: 5, right: 5, child: _Rivet(size: 7)),
                  _isSending
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'TRANSMITTING...',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                                fontFamily: 'Orbitron',
                                letterSpacing: 2.5,
                                shadows: [
                                  Shadow(
                                    color: Colors.black87,
                                    offset: const Offset(0, 1),
                                    blurRadius: 3,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.rocket_launch_rounded,
                              color: Colors.white,
                              size: 24,
                              shadows: [
                                Shadow(
                                  color: Colors.black87,
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            SizedBox(width: 12),
                            Text(
                              'SEND BUG',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 17,
                                fontFamily: 'Orbitron',
                                letterSpacing: 4,
                                shadows: [
                                  Shadow(
                                    color: Colors.black87,
                                    offset: Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                  Shadow(
                                    color: Sk.amberGlow,
                                    offset: Offset(0, -1),
                                    blurRadius: 3,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 12),
                            _Led(
                                color: Sk.greenGlow,
                                size: 8,
                                pulse: true),
                          ],
                        ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // RESPONSE MESSAGE
  // ═══════════════════════════════════════════════════════════
  Widget _buildResponseMessage() {
    if (_responseMessage == null) return const SizedBox.shrink();

    final parts = _responseMessage!.split('|');
    final type = parts[0];
    final msg = parts.length > 1 ? parts[1] : '';

    Color color;
    Color deepColor;
    IconData icon;
    String title;
    switch (type) {
      case 'success':
        color = Sk.greenGlow;
        deepColor = Sk.greenDeep;
        icon = Icons.check_circle_rounded;
        title = 'BERHASIL';
        break;
      case 'warning':
        color = Sk.amber;
        deepColor = Sk.orangeDeep;
        icon = Icons.warning_rounded;
        title = 'PERINGATAN';
        break;
      default:
        color = Sk.crimsonGlow;
        deepColor = Sk.crimsonDeep;
        icon = Icons.error_rounded;
        title = 'GAGAL';
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: _TacticalPanel(
        accent: color.withOpacity(0.5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: deepColor,
                border: Border.all(
                    color: color.withOpacity(0.6), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.35),
                    blurRadius: 10,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontFamily: 'Orbitron',
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          offset: const Offset(0, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    msg,
                    style: const TextStyle(
                      color: Sk.chrome,
                      fontFamily: 'ShareTechMono',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => _responseMessage = null),
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Sk.steel4, Sk.steel2],
                  ),
                  border: Border.all(color: Sk.steel1, width: 1),
                ),
                child: const Icon(Icons.close_rounded,
                    color: Sk.chromeHi, size: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Sk.slate1,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Sk.slate3, Sk.slate2, Sk.slate1],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildStatsBar(),
                      const SizedBox(height: 12),
                      _buildImageSlider(),
                      const SizedBox(height: 12),
                      _buildTargetPanel(),
                      const SizedBox(height: 12),
                      _buildBugPanel(),
                      const SizedBox(height: 12),
                      _buildSenderPanel(),
                      const SizedBox(height: 20),
                      _buildSendButton(),
                      _buildResponseMessage(),
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

// ═══════════════════════════════════════════════════════════
// SEND RING PAINTER
// ═══════════════════════════════════════════════════════════
class _SendRingPainter extends CustomPainter {
  final Color color;
  _SendRingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(2, 2, size.width - 4, size.height - 4);
    const segments = 8;
    const gap = 0.15;

    for (int i = 0; i < segments; i++) {
      final start = (i / segments) * 2 * math.pi + gap;
      final sweep = (1 / segments) * 2 * math.pi - gap * 2;
      canvas.drawArc(rect, start, sweep, false, paint);
    }
  }

  @override
  bool shouldRepaint(_SendRingPainter old) => old.color != color;
}

// ═══════════════════════════════════════════════════════════
// BUG CHIP
// ═══════════════════════════════════════════════════════════
class _BugChip extends StatelessWidget {
  final String bugId;
  final bool isSelected;
  final bool isFirst;
  final VoidCallback onTap;
  const _BugChip({
    required this.bugId,
    required this.isSelected,
    required this.isFirst,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 118,
        margin: EdgeInsets.only(
          left: isFirst ? 0 : 10,
          right: 4,
          top: 4,
          bottom: 4,
        ),
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? [Sk.crimsonHi, Sk.crimson, Sk.crimsonDeep]
                : [Sk.steel3, Sk.steel2, Sk.steel1],
            stops: const [0.0, 0.5, 1.0],
          ),
          border: Border.all(
            color: isSelected ? Sk.crimsonGlow : Sk.steel2,
            width: isSelected ? 1.8 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? Sk.crimsonGlow.withOpacity(0.5)
                  : Colors.black.withOpacity(0.5),
              offset: const Offset(0, 3),
              blurRadius: isSelected ? 12 : 5,
              spreadRadius: isSelected ? 0 : 0,
            ),
            if (isSelected)
              const BoxShadow(
                color: Colors.white24,
                offset: Offset(0, -1),
                blurRadius: 2,
              ),
          ],
        ),
        child: Stack(
          children: [
            if (isSelected) ...[
              const Positioned(top: 2, left: 2, child: _Rivet(size: 4)),
              const Positioned(top: 2, right: 2, child: _Rivet(size: 4)),
              const Positioned(bottom: 2, left: 2, child: _Rivet(size: 4)),
              const Positioned(bottom: 2, right: 2, child: _Rivet(size: 4)),
            ],
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.4),
                        border: Border.all(
                          color:
                              isSelected ? Sk.crimsonGlow : Sk.steel3,
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.shield_rounded,
                        color: isSelected ? Sk.crimsonGlow : Sk.chrome,
                        size: 13,
                      ),
                    ),
                    const Spacer(),
                    if (isSelected)
                      const Icon(
                        Icons.workspace_premium_rounded,
                        color: Sk.amberGlow,
                        size: 14,
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _Led(
                      color: isSelected ? Sk.greenGlow : Sk.steel4,
                      size: 5,
                      pulse: isSelected,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isSelected ? 'READY' : 'IDLE',
                      style: TextStyle(
                        color: isSelected
                            ? Sk.greenGlow
                            : Sk.chrome.withOpacity(0.4),
                        fontSize: 7,
                        fontFamily: 'Orbitron',
                        letterSpacing: 1,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  bugId.toUpperCase(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : Sk.chrome,
                    fontFamily: 'Orbitron',
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: 0.8,
                    shadows: isSelected
                        ? const [
                            Shadow(
                              color: Colors.black54,
                              offset: Offset(0, 1),
                              blurRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'id: ${bugId.toLowerCase()}',
                  style: TextStyle(
                    color: Sk.chrome.withOpacity(0.5),
                    fontFamily: 'ShareTechMono',
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// SENDER TILE
// ═══════════════════════════════════════════════════════════
class _SenderTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final int count;
  final bool isSelected;
  final bool isLocked;
  final Color accent;
  final VoidCallback onTap;

  const _SenderTile({
    required this.icon,
    required this.title,
    required this.count,
    required this.isSelected,
    required this.isLocked,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 124,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? [
                    accent,
                    accent.withOpacity(0.7),
                    accent.withOpacity(0.4)
                  ]
                : [Sk.steel3, Sk.steel2, Sk.steel1],
            stops: const [0.0, 0.5, 1.0],
          ),
          border: Border.all(
            color: isSelected ? accent : Sk.steel2,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? accent.withOpacity(0.5)
                  : Colors.black.withOpacity(0.5),
              offset: const Offset(0, 4),
              blurRadius: isSelected ? 12 : 6,
              spreadRadius: 0,
            ),
            if (isSelected)
              const BoxShadow(
                color: Colors.white30,
                offset: Offset(0, -1),
                blurRadius: 2,
              ),
          ],
        ),
        child: Stack(
          children: [
            if (isSelected) ...[
              const Positioned(top: 4, left: 4, child: _Rivet(size: 5)),
              const Positioned(top: 4, right: 4, child: _Rivet(size: 5)),
              const Positioned(bottom: 4, left: 4, child: _Rivet(size: 5)),
              const Positioned(bottom: 4, right: 4, child: _Rivet(size: 5)),
            ],
            if (isLocked)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Sk.crimsonDeep,
                    border: Border.all(
                        color: Sk.crimsonHi.withOpacity(0.7),
                        width: 1.2),
                  ),
                  child: const Icon(Icons.lock_rounded,
                      color: Sk.crimsonGlow, size: 10),
                ),
              ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            center: const Alignment(-0.3, -0.3),
                            colors: isSelected
                                ? [
                                    Colors.white.withOpacity(0.4),
                                    accent.withOpacity(0.5),
                                    accent.withOpacity(0.3),
                                  ]
                                : [
                                    Sk.steel4,
                                    Sk.steel3,
                                    Sk.steel1,
                                  ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                          border: Border.all(
                            color:
                                isSelected ? Colors.white : Sk.steel4,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected
                                  ? accent.withOpacity(0.6)
                                  : Colors.black.withOpacity(0.6),
                              blurRadius: isSelected ? 12 : 4,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Icon(
                          icon,
                          color: isSelected ? Colors.white : Sk.chrome,
                          size: 20,
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: _Led(
                          color:
                              count > 0 ? Sk.greenGlow : Sk.crimsonHi,
                          size: 8,
                          pulse: count > 0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Sk.chrome,
                      fontFamily: 'Orbitron',
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          offset: const Offset(0, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (count == 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: Sk.crimsonDeep,
                        border: Border.all(
                            color: Sk.crimsonHi.withOpacity(0.5),
                            width: 1),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.close_rounded,
                              color: Sk.crimsonGlow, size: 8),
                          SizedBox(width: 3),
                          Text(
                            'KOSONG',
                            style: TextStyle(
                              color: Sk.crimsonGlow,
                              fontFamily: 'Orbitron',
                              fontWeight: FontWeight.w900,
                              fontSize: 7,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: Colors.black.withOpacity(0.5),
                        border: Border.all(
                            color: isSelected
                                ? Colors.white30
                                : Sk.steel4,
                            width: 1),
                      ),
                      child: Text(
                        '$count SENDER',
                        style: TextStyle(
                          color:
                              isSelected ? Colors.white : Sk.greenGlow,
                          fontFamily: 'Orbitron',
                          fontWeight: FontWeight.w900,
                          fontSize: 7,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}