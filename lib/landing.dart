import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:video_player/video_player.dart';
import 'main.dart';

// ─── COLOR PALETTE MODERN ──────────────────────────────────────────────
class ModernColors {
  static const Color bg = Color(0xFF0A0A0A);
  static const Color surface = Color(0xFF121212);
  static const Color card = Color(0xFF1A1A1A);
  static const Color red = Color(0xFFE63946);
  static const Color redLight = Color(0xFFFF6B6B);
  static const Color gold = Color(0xFFFFD700);
  static const Color goldLight = Color(0xFFFFF3B0);
  static const Color text = Color(0xFFF5F5F5);
  static const Color textSub = Color(0xFFB0B0B0);
  static const Color border = Color(0x2AFFFFFF);
}

// ─── LANDING PAGE ──────────────────────────────────────────────────────────
class LandingPage extends StatefulWidget {
  const LandingPage({super.key});
  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with TickerProviderStateMixin {
  final PageController _pageCtrl = PageController();
  int _currentPage = 0;

  late VideoPlayerController _videoCtrl;
  bool _videoReady = false;

  late AnimationController _glowCtrl;
  late AnimationController _entranceCtrl;
  late Animation<double> _glow;
  late Animation<double> _fade;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();

    _videoCtrl = VideoPlayerController.asset('assets/videos/landing.mp4')
      ..initialize().then((_) {
        if (mounted) {
          setState(() => _videoReady = true);
          _videoCtrl.setLooping(true);
          _videoCtrl.setVolume(0);
          _videoCtrl.play();
        }
      });

    _glowCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
    _entranceCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));

    _glow = Tween<double>(begin: 0.3, end: 1.0)
        .animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));
    _fade = CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOutCubic));

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _entranceCtrl.forward();
    });
  }

  @override
  void dispose() {
    _videoCtrl.dispose();
    _glowCtrl.dispose();
    _entranceCtrl.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  Future<void> _launch(String url) async {
    final u = Uri.parse(url);
    if (await canLaunchUrl(u)) await launchUrl(u, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernColors.bg,
      body: Stack(children: [
        CustomPaint(painter: _ModernBgPainter()),
        SafeArea(
          child: FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slideUp,
              child: Stack(children: [
                PageView(
                  controller: _pageCtrl,
                  scrollDirection: Axis.vertical,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  children: [
                    _buildWelcomePage(),
                    _buildJapanesePage(),
                    _buildMainLanding(),
                  ],
                ),
                Positioned(
                  right: 14,
                  top: 0,
                  bottom: 0,
                  child: Center(child: _buildDotIndicator()),
                ),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  // ─── PAGE 1: WELCOME ──────────────────────────────────────────────────
  Widget _buildWelcomePage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [ModernColors.bg, ModernColors.red.withOpacity(0.05)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (b) => const LinearGradient(
                  colors: [ModernColors.gold, ModernColors.red],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(b),
                child: const Text(
                  '.WELCOME.',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 6,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'ENTER THE DARK',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  color: ModernColors.textSub,
                  letterSpacing: 4,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJapanesePage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [ModernColors.bg, ModernColors.gold.withOpacity(0.03)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'vantaniv zasta',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: ModernColors.text,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ModernColors.card.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ModernColors.border),
              ),
              child: Text(
                'WhatsApp application crashes which was developed by the #NtedFamily team.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: ModernColors.textSub,
                  height: 1.7,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── PAGE 3: MAIN LANDING ────────────────────────────────────────────
  Widget _buildMainLanding() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(children: [
        _buildHeroVideo(),
        _buildTitleSection(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(children: [
            const SizedBox(height: 18),
            _buildGlassCard(),
            const SizedBox(height: 14),
            _buildSignInButton(),
            const SizedBox(height: 10),
            _buildDevOwnerRow(),
            const SizedBox(height: 14),
            _buildFooter(),
            const SizedBox(height: 20),
          ]),
        ),
      ]),
    );
  }

  Widget _buildHeroVideo() {
    return SizedBox(
      height: 280,
      width: double.infinity,
      child: _videoReady
          ? FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _videoCtrl.value.size.width,
                height: _videoCtrl.value.size.height,
                child: VideoPlayer(_videoCtrl),
              ),
            )
          : Container(
              color: ModernColors.bg,
              child: const Center(
                child: CircularProgressIndicator(
                  color: ModernColors.red,
                  strokeWidth: 2,
                ),
              ),
            ),
    );
  }

  Widget _buildTitleSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          'NTED',
          style: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 34,
            fontWeight: FontWeight.w900,
            color: ModernColors.text,
            letterSpacing: 6,
            height: 1.1,
          ),
        ),
        ShaderMask(
          shaderCallback: (b) => const LinearGradient(
            colors: [ModernColors.red, ModernColors.gold],
          ).createShader(b),
          child: Text(
            'vantaniv zasta',
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 34,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 4,
              height: 1.1,
            ),
          ),
        ),
        const SizedBox(height: 6),
      ]),
    );
  }

  // ─── GLASS CARD (MODERN) ─────────────────────────────────────────────
  Widget _buildGlassCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: ModernColors.card.withOpacity(0.7),
        border: Border.all(color: ModernColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: ModernColors.red.withOpacity(0.08),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          margin: const EdgeInsets.only(top: 2, right: 12),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [ModernColors.red, ModernColors.gold],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.info_outline_rounded, color: Colors.white, size: 18),
        ),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              'vantaniv zasta',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: ModernColors.text,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'The best app of all time, with its tools and WhatsApp Crash features.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: ModernColors.textSub,
                height: 1.5,
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _buildSignInButton() {
    return AnimatedBuilder(
      animation: _glowCtrl,
      builder: (_, __) => GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/login'),
        child: Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(
              colors: [ModernColors.red, ModernColors.gold],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: ModernColors.red.withOpacity(0.4 * _glow.value),
                blurRadius: 24,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: ModernColors.gold.withOpacity(0.2 * _glow.value),
                blurRadius: 40,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Row(children: [
                  const Icon(Icons.login_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  const Text(
                    'SIGN IN',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ]),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 18),
                child: Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 22),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDevOwnerRow() {
    return Row(children: [
      Expanded(child: _buildSocialButton('DEVELOPER', 'https://t.me/NtedPakeE', FontAwesomeIcons.telegram, ModernColors.red)),
      const SizedBox(width: 10),
      Expanded(child: _buildSocialButton('OWNER', 'https://t.me/NtedPakeE', FontAwesomeIcons.telegram, ModernColors.gold)),
    ]);
  }

  Widget _buildSocialButton(String label, String url, IconData icon, Color color) {
    return GestureDetector(
      onTap: () => _launch(url),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.2), Colors.transparent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          FaIcon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 1,
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: ModernColors.card.withOpacity(0.5),
        border: Border.all(color: ModernColors.border),
      ),
      child: Column(children: [
        Text(
          'Create: NtedExecutive',
          style: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: ModernColors.text,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '© vantaniv zasta Since 2026',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            color: ModernColors.textSub,
            letterSpacing: 1,
          ),
        ),
      ]),
    );
  }

  Widget _buildDotIndicator() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final isActive = _currentPage == i;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(vertical: 4),
          width: isActive ? 12 : 8,
          height: isActive ? 12 : 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? ModernColors.gold : ModernColors.textSub.withOpacity(0.3),
            boxShadow: isActive
                ? [BoxShadow(color: ModernColors.gold.withOpacity(0.5), blurRadius: 10)]
                : null,
          ),
        );
      }),
    );
  }
}

// ─── BACKGROUND PAINTER ─────────────────────────────────────────────────
class _ModernBgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Base gradient
    final basePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF050505), Color(0xFF0A0A0A), Color(0xFF121212)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), basePaint);

    // Glow circles
    final glowPaint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(42);

    for (int i = 0; i < 3; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 200 + 80;
      glowPaint
        ..shader = RadialGradient(
          colors: [
            ModernColors.red.withOpacity(0.03),
            Colors.transparent,
          ],
          radius: 0.8,
        ).createShader(Rect.fromCircle(center: Offset(x, y), radius: radius));
      canvas.drawCircle(Offset(x, y), radius, glowPaint);
    }

    // Hex grid
    final hexPaint = Paint()
      ..color = const Color(0xFF2A1A00).withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    const hexSize = 30.0;
    final hexH = hexSize * math.sqrt(3);
    final hexW = hexSize * 2;

    for (double row = 0; row < size.height / hexH + 2; row++) {
      for (double col = 0; col < size.width / hexW + 2; col++) {
        final cx = col * hexW * 0.75 - hexSize;
        final cy = row * hexH + (col.toInt().isOdd ? hexH / 2 : 0) - hexH;
        _drawHex(canvas, hexPaint, Offset(cx, cy), hexSize);
      }
    }
  }

  void _drawHex(Canvas canvas, Paint paint, Offset center, double size) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = math.pi / 180 * (60 * i - 30);
      final x = center.dx + size * math.cos(angle);
      final y = center.dy + size * math.sin(angle);
      if (i == 0) path.moveTo(x, y);
      else path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ModernBgPainter old) => false;
}