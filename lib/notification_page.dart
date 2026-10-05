import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'api_config.dart';

class Sk {
  static const Color metalDeep    = Color(0xFF1A1815);
  static const Color metalDark    = Color(0xFF2A2723);
  static const Color metalMid     = Color(0xFF3D3933);
  static const Color metalLight   = Color(0xFF5A554C);
  static const Color metalHi      = Color(0xFF9A9286);
  static const Color brassDeep    = Color(0xFF6B5015);
  static const Color brassDark    = Color(0xFF8B6914);
  static const Color brass        = Color(0xFFC9A961);
  static const Color brassHi      = Color(0xFFE8C87F);
  static const Color brassShine   = Color(0xFFF5DEB3);
  static const Color red          = Color(0xFF8B1818);
  static const Color redBright    = Color(0xFFC41E1E);
  static const Color redGlow      = Color(0xFFFF3030);
  static const Color greenGlow    = Color(0xFF00E676);
  static const Color amberHi      = Color(0xFFF59E0B);
  static const Color cyanHi       = Color(0xFF26C6DA);
  static const Color cream        = Color(0xFFE8DFC8);
  static const Color ink          = Color(0xFF2A2520);
  static const Color leather      = Color(0xFF2A1F18);
  static const Color leatherDark  = Color(0xFF1A1310);
  static const Color leatherHi    = Color(0xFF3D2E22);
}

class _Pulse {
  static final ValueNotifier<double> v = ValueNotifier<double>(0);
  static bool _started = false;
  static void ensureStarted() {
    if (_started) return;
    _started = true;
    _run();
  }
  static Future<void> _run() async {
    final sw = Stopwatch()..start();
    while (true) {
      await Future<void>.delayed(const Duration(milliseconds: 80));
      final t = (sw.elapsedMilliseconds % 1600) / 1600.0;
      v.value = t < 0.5 ? t * 2 : (1 - t) * 2;
    }
  }
}

// ═══════════════════════════════════════════════════════
// LED
// ═══════════════════════════════════════════════════════
class _Led extends StatelessWidget {
  final Color color;
  final double size;
  final bool blink;
  const _Led({required this.color, this.size = 8, this.blink = false});

  @override
  Widget build(BuildContext context) {
    if (!blink) return _dot(1.0);
    return ValueListenableBuilder<double>(
      valueListenable: _Pulse.v,
      builder: (_, v, __) => _dot(0.45 + v * 0.55),
    );
  }

  Widget _dot(double opacity) => Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: const Alignment(-0.35, -0.35),
            colors: [
              Colors.white.withOpacity(0.85 * opacity),
              color.withOpacity(opacity),
              color.withOpacity(0.55 * opacity),
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
          border: Border.all(color: Colors.black.withOpacity(0.85), width: size * 0.1),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.75 * opacity), blurRadius: size * 1.4, spreadRadius: size * 0.2),
            BoxShadow(color: color.withOpacity(0.35 * opacity), blurRadius: size * 2.6, spreadRadius: size * 0.4),
          ],
        ),
      );
}

// ═══════════════════════════════════════════════════════
// SCREW
// ═══════════════════════════════════════════════════════
class _Screw extends StatelessWidget {
  final double size;
  const _Screw({this.size = 14});
  @override
  Widget build(BuildContext context) => Container(
        width: size, height: size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: Alignment(-0.35, -0.35),
            colors: [Sk.metalHi, Sk.metalLight, Sk.metalMid, Sk.metalDark],
            stops: [0.0, 0.35, 0.7, 1.0],
          ),
        ),
        child: Center(
          child: Transform.rotate(
            angle: 0.785,
            child: Container(
              width: size * 0.7, height: size * 0.11,
              color: Colors.black.withOpacity(0.9),
            ),
          ),
        ),
      );
}

// ═══════════════════════════════════════════════════════
// RIVET
// ═══════════════════════════════════════════════════════
class _Rivet extends StatelessWidget {
  final double size;
  const _Rivet({this.size = 10});
  @override
  Widget build(BuildContext context) => Container(
        width: size, height: size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: Alignment(-0.35, -0.35),
            colors: [Sk.brassShine, Sk.brassHi, Sk.brass, Sk.brassDeep],
            stops: [0.0, 0.3, 0.65, 1.0],
          ),
        ),
      );
}

// ═══════════════════════════════════════════════════════
// METAL PLATE
// ═══════════════════════════════════════════════════════
class _MetalPlate extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double radius;
  const _MetalPlate({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 16,
  });

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Sk.metalHi, Sk.metalMid, Sk.metalDark, Sk.metalDeep],
            stops: [0.0, 0.4, 0.7, 1.0],
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.75), offset: const Offset(0, 6), blurRadius: 12),
          ],
        ),
        padding: const EdgeInsets.all(3),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius - 3),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Sk.leatherHi, Sk.leather, Sk.leatherDark],
            ),
            border: Border.all(color: Colors.black.withOpacity(0.5)),
          ),
          child: child,
        ),
      );
}

// ═══════════════════════════════════════════════════════
// INDUSTRIAL BUTTON
// ═══════════════════════════════════════════════════════
class _IndustrialButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color color;
  final double height;
  const _IndustrialButton({
    required this.child,
    required this.onTap,
    this.color = Sk.brass,
    this.height = 56,
  });

  @override
  State<_IndustrialButton> createState() => _IndustrialButtonState();
}

class _IndustrialButtonState extends State<_IndustrialButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    final light = _lighten(widget.color);
    final dark = _darken(widget.color);

    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: enabled
          ? (_) {
              setState(() => _pressed = false);
              HapticFeedback.mediumImpact();
              widget.onTap?.call();
            }
          : null,
      onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: _pressed ? Alignment.bottomCenter : Alignment.topCenter,
            end: _pressed ? Alignment.topCenter : Alignment.bottomCenter,
            colors: _pressed ? [dark, dark, widget.color] : [light, widget.color, dark],
            stops: const [0.0, 0.5, 1.0],
          ),
          boxShadow: _pressed
              ? [BoxShadow(color: Colors.black.withOpacity(0.9), offset: const Offset(0, 1), blurRadius: 3)]
              : [
                  BoxShadow(color: widget.color.withOpacity(0.45), offset: const Offset(0, 5), blurRadius: 10, spreadRadius: -2),
                  BoxShadow(color: Colors.black.withOpacity(0.75), offset: const Offset(0, 4), blurRadius: 6),
                ],
          border: Border.all(color: dark.withOpacity(0.9), width: 1.5),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Positioned(top: 5, left: 5, child: _Rivet(size: 6)),
            const Positioned(top: 5, right: 5, child: _Rivet(size: 6)),
            const Positioned(bottom: 5, left: 5, child: _Rivet(size: 6)),
            const Positioned(bottom: 5, right: 5, child: _Rivet(size: 6)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Opacity(opacity: enabled ? 1 : 0.5, child: widget.child),
            ),
          ],
        ),
      ),
    );
  }

  static Color _lighten(Color c) => Color.fromARGB(c.alpha, (c.red + 40).clamp(0, 255), (c.green + 40).clamp(0, 255), (c.blue + 30).clamp(0, 255));
  static Color _darken(Color c) => Color.fromARGB(c.alpha, (c.red - 60).clamp(0, 255), (c.green - 50).clamp(0, 255), (c.blue - 40).clamp(0, 255));
}

// ═══════════════════════════════════════════════════════
// NOTIFICATION PAGE
// ═══════════════════════════════════════════════════════
class NotificationPage extends StatefulWidget {
  final String sessionKey;
  final String username;
  final String role;

  const NotificationPage({
    Key? key,
    required this.sessionKey,
    required this.username,
    required this.role,
  }) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _Pulse.ensureStarted();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendReport() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      _showSkeuoSnack('Harap isi pesan laporan', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/sendReport'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'key': widget.sessionKey,
              'username': widget.username,
              'message': message,
            }),
          )
          .timeout(const Duration(seconds: 20));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        _showSkeuoSnack('Laporan berhasil dikirim ke owner!', isError: false);
        _messageController.clear();
        _showSuccessDialog();
      } else {
        _showSkeuoSnack(
            'Gagal: ${data['message'] ?? 'Unknown error'}', isError: true);
      }
    } catch (e) {
      _showSkeuoSnack('Server tidak merespon, membuka Telegram...',
          isError: false);
      _openTelegramChat();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _openTelegramChat() async {
    const ownerUsername = 'elltzyy1_md';
    final url = 'https://t.me/$ownerUsername';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      _showSkeuoSnack('Tidak dapat membuka Telegram', isError: true);
    }
  }

  void _showSkeuoSnack(String message, {bool isError = false}) {
    final c = isError ? Sk.redGlow : Sk.greenGlow;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            _Led(color: c, size: 8, blink: true),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Sk.cream,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'ShareTechMono',
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Sk.metalDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: c, width: 1.5),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // SUCCESS DIALOG
  // ═══════════════════════════════════════════════════════
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: _MetalPlate(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const RadialGradient(
                            colors: [Sk.metalHi, Sk.metalMid, Sk.metalDark],
                          ),
                          border: Border.all(color: Sk.greenGlow, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: Sk.greenGlow.withOpacity(0.5),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Sk.greenGlow,
                          size: 30,
                          shadows: [
                            Shadow(color: Sk.greenGlow, blurRadius: 6),
                          ],
                        ),
                      ),
                      const Positioned(
                        top: -2,
                        right: -2,
                        child: _Led(color: Sk.greenGlow, size: 8, blink: true),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Title
              const Text(
                'LAPORAN TERKIRIM',
                style: TextStyle(
                  color: Sk.brass,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Orbitron',
                  letterSpacing: 2.5,
                  shadows: [
                    Shadow(color: Colors.black, offset: Offset(0, 1), blurRadius: 2),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Message
              Text(
                'Pesan Anda telah diteruskan ke owner.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Sk.cream.withOpacity(0.75),
                  fontSize: 11,
                  fontFamily: 'ShareTechMono',
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),

              // OK button
              _IndustrialButton(
                color: Sk.greenGlow,
                height: 46,
                onTap: () => Navigator.pop(ctx),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Orbitron',
                    letterSpacing: 2.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0806),
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-0.3, -0.3),
                  radius: 1.2,
                  colors: [
                    Color(0xFF2A1F18),
                    Color(0xFF1A1310),
                    Color(0xFF0A0806),
                  ],
                  stops: [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 8),
                _buildAppBar(),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeaderPanel(),
                        const SizedBox(height: 14),
                        _buildFormPlate(),
                        const SizedBox(height: 14),
                        _buildInfoPlate(),
                        const SizedBox(height: 30),
                      ],
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

  // ═══════════════════════════════════════════════════════
  // APP BAR
  // ═══════════════════════════════════════════════════════
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: _MetalPlate(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // Back button
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Sk.metalLight, Sk.metalMid, Sk.metalDark],
                  ),
                  border: Border.all(color: Colors.black.withOpacity(0.7), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.7),
                      offset: const Offset(0, 3),
                      blurRadius: 5,
                    ),
                    const BoxShadow(color: Colors.white24, offset: Offset(0, -1), blurRadius: 1),
                  ],
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Sk.brass, size: 16),
              ),
            ),
            const SizedBox(width: 12),

            // Icon + Title
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [Sk.metalHi, Sk.metalMid, Sk.metalDark],
                    ),
                    border: Border.all(color: Sk.redGlow, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Sk.redGlow.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.notifications_active_rounded,
                    color: Sk.redGlow,
                    size: 20,
                  ),
                ),
                const Positioned(
                  top: -2,
                  right: -2,
                  child: _Led(color: Sk.redGlow, size: 6, blink: true),
                ),
              ],
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'NULL TR4SHER LAPORAN',
                    style: TextStyle(
                      color: Sk.brassHi,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Orbitron',
                      letterSpacing: 2,
                      height: 1,
                      shadows: [
                        Shadow(color: Sk.brassDeep, offset: Offset(0, 1), blurRadius: 1),
                        Shadow(color: Colors.black, offset: Offset(0, 2), blurRadius: 3),
                      ],
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const _Led(color: Sk.redGlow, size: 4, blink: true),
                      const SizedBox(width: 5),
                      Text(
                        'SEND TO OWNER',
                        style: TextStyle(
                          color: Sk.cream.withOpacity(0.55),
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'ShareTechMono',
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // HEADER PANEL
  // ═══════════════════════════════════════════════════════
  Widget _buildHeaderPanel() {
    return _MetalPlate(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          // Icon housing
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: const Alignment(-0.35, -0.35),
                    colors: [
                      Sk.redBright.withOpacity(0.5),
                      Sk.redBright.withOpacity(0.15),
                      Colors.black.withOpacity(0.9),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                  border: Border.all(color: Sk.redGlow.withOpacity(0.6), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Sk.redGlow.withOpacity(0.5),
                      blurRadius: 15,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.campaign_rounded,
                  color: Sk.redGlow,
                  size: 26,
                  shadows: [
                    Shadow(color: Sk.redGlow, blurRadius: 8),
                  ],
                ),
              ),
              const Positioned(
                top: 0,
                right: 0,
                child: _Led(color: Sk.amberHi, size: 7, blink: true),
              ),
            ],
          ),
          const SizedBox(width: 14),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'BUAT LAPORAN',
                  style: TextStyle(
                    color: Sk.brass,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Orbitron',
                    letterSpacing: 2,
                    height: 1,
                    shadows: [
                      Shadow(color: Colors.black, offset: Offset(0, 1), blurRadius: 2),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Kirim pesan langsung ke owner',
                  style: TextStyle(
                    color: Sk.cream.withOpacity(0.6),
                    fontSize: 9,
                    fontFamily: 'ShareTechMono',
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          const _Led(color: Sk.greenGlow, size: 8, blink: true),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // FORM PLATE
  // ═══════════════════════════════════════════════════════
  Widget _buildFormPlate() {
    return _MetalPlate(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with screws
          Row(
            children: const [
              _Screw(size: 12),
              SizedBox(width: 10),
              Expanded(
                child: Center(
                  child: Text(
                    'FORM LAPORAN',
                    style: TextStyle(
                      color: Sk.brass,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Orbitron',
                      letterSpacing: 2,
                      shadows: [
                        Shadow(color: Colors.black, offset: Offset(0, 1), blurRadius: 2),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              _Screw(size: 12),
            ],
          ),
          const SizedBox(height: 16),

          // Label
          Row(
            children: [
              const _Rivet(size: 6),
              const SizedBox(width: 6),
              const Icon(Icons.edit_note_rounded, color: Sk.brass, size: 14),
              const SizedBox(width: 6),
              const Text(
                'PESAN LAPORAN',
                style: TextStyle(
                  color: Sk.brass,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Orbitron',
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // TextField (inset)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0A0806), Color(0xFF151210)],
              ),
              border: Border.all(color: Sk.metalDark, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.9),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
                const BoxShadow(
                  color: Colors.white10,
                  offset: Offset(0, -1),
                  blurRadius: 1,
                ),
              ],
            ),
            child: TextField(
              controller: _messageController,
              maxLines: 6,
              minLines: 5,
              style: const TextStyle(
                color: Sk.brassShine,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFamily: 'ShareTechMono',
                letterSpacing: 0.3,
                height: 1.5,
              ),
              cursorColor: Sk.greenGlow,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Tuliskan laporan atau keluhan Anda...',
                hintStyle: TextStyle(
                  color: Sk.cream.withOpacity(0.3),
                  fontSize: 12,
                  fontFamily: 'ShareTechMono',
                  letterSpacing: 0.5,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // User info panel
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.black.withOpacity(0.5),
              border: Border.all(color: Sk.metalDark, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.7),
                  offset: const Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
            child: Row(
              children: [
                const _Led(color: Sk.greenGlow, size: 6, blink: true),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Dikirim sebagai: ${widget.username} (${widget.role})',
                    style: TextStyle(
                      color: Sk.cream.withOpacity(0.7),
                      fontSize: 10,
                      fontFamily: 'ShareTechMono',
                      letterSpacing: 0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Send button
          _IndustrialButton(
            color: _isLoading ? Sk.metalMid : Sk.red,
            height: 54,
            onTap: _isLoading ? null : _sendReport,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isLoading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Sk.brass),
                    ),
                  )
                else
                  const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 10),
                Text(
                  _isLoading ? 'MENGIRIM...' : 'KIRIM LAPORAN',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Orbitron',
                    letterSpacing: 2,
                    shadows: [
                      Shadow(color: Colors.black54, offset: Offset(0, 1), blurRadius: 2),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // INFO PLATE
  // ═══════════════════════════════════════════════════════
  Widget _buildInfoPlate() {
    return _MetalPlate(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: const [
              _Rivet(size: 8),
              SizedBox(width: 8),
              Icon(Icons.info_outline, color: Sk.brass, size: 14),
              SizedBox(width: 6),
              Text(
                'INFORMASI',
                style: TextStyle(
                  color: Sk.brass,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Orbitron',
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _infoLine('• Laporan langsung diteruskan ke owner bot'),
          _infoLine('• Pastikan pesan jelas, sopan, dan tidak spam'),
          _infoLine('• Balasan akan dikirim via Telegram bot'),
          _infoLine('• Jika server down, otomatis buka Telegram owner'),
        ],
      ),
    );
  }

  Widget _infoLine(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: TextStyle(
              color: Sk.cream.withOpacity(0.65),
              fontSize: 10,
              fontFamily: 'ShareTechMono',
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}