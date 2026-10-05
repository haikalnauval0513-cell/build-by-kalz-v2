// lib/video_splash_page.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'dashboard_page.dart';

// ═══════════════════════════════════════════════════════
// COLORS — SKEUOMORPHISM
// ═══════════════════════════════════════════════════════
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
  static const Color cyanGlow     = Color(0xFF00E5FF);
  static const Color cream        = Color(0xFFE8DFC8);
  static const Color ink          = Color(0xFF2A2520);
  static const Color leather      = Color(0xFF2A1F18);
  static const Color leatherDark  = Color(0xFF1A1310);
  static const Color leatherHi    = Color(0xFF3D2E22);
}

// ═══════════════════════════════════════════════════════
// GLOBAL PULSE
// ═══════════════════════════════════════════════════════
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
              Colors.white.withValues(alpha: 0.85 * opacity),
              color.withValues(alpha: opacity),
              color.withValues(alpha: 0.55 * opacity),
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.85),
            width: size * 0.1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.75 * opacity),
              blurRadius: size * 1.4,
              spreadRadius: size * 0.2,
            ),
            BoxShadow(
              color: color.withValues(alpha: 0.35 * opacity),
              blurRadius: size * 2.6,
              spreadRadius: size * 0.4,
            ),
          ],
        ),
      );
}

// ═══════════════════════════════════════════════════════
// SCREW
// ═══════════════════════════════════════════════════════
class _Screw extends StatelessWidget {
  final double size;
  final double rotation;
  const _Screw({this.size = 14, this.rotation = 0.785});
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
            angle: rotation,
            child: Container(
              width: size * 0.7, height: size * 0.11,
              color: Colors.black.withValues(alpha: 0.9),
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
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.75),
              offset: const Offset(0, 6),
              blurRadius: 12,
            ),
            const BoxShadow(
              color: Colors.white24,
              offset: Offset(-1, -1),
              blurRadius: 3,
            ),
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
            border: Border.all(color: Colors.black.withValues(alpha: 0.5)),
          ),
          child: child,
        ),
      );
}

// ═══════════════════════════════════════════════════════
// VIDEO SPLASH PAGE
// ═══════════════════════════════════════════════════════
class VideoSplashPage extends StatefulWidget {
  final Map<String, dynamic> dashboardArgs;

  const VideoSplashPage({super.key, required this.dashboardArgs});

  @override
  State<VideoSplashPage> createState() => _VideoSplashPageState();
}

class _VideoSplashPageState extends State<VideoSplashPage>
    with TickerProviderStateMixin {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _navigated = false;

  late AnimationController _entryCtrl;
  late AnimationController _floatCtrl;
  late AnimationController _loadCtrl;
  late AnimationController _scanCtrl;

  late Animation<double> _logoFade;
  late Animation<double> _logoScale;
  late Animation<Offset> _subtitleSlide;
  late Animation<double> _loadProgress;
  late Animation<double> _ledPulse;

  @override
  void initState() {
    super.initState();
    _Pulse.ensureStarted();
    _setupAnimations();
    _initVideo();
  }

  void _setupAnimations() {
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..forward();

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _loadCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..forward();

    _scanCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    _subtitleSlide = Tween<Offset>(
      begin: const Offset(0, 0.8),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOutBack),
    ));

    _loadProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _loadCtrl, curve: Curves.linear),
    );

    _ledPulse = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );
  }

  Future<void> _initVideo() async {
    _controller = VideoPlayerController.asset('assets/videos/login.mp4');

    try {
      await _controller.initialize();
      await _controller.setVolume(1.0);
      await _controller.setLooping(false);
      _controller.addListener(_onVideoEnd);
      await _controller.play();
      if (mounted) setState(() => _isInitialized = true);
    } catch (e) {
      _goToDashboard();
    }
  }

  void _onVideoEnd() {
    if (!_navigated &&
        _controller.value.position >= _controller.value.duration &&
        _controller.value.duration > Duration.zero) {
      _goToDashboard();
    }
  }

  void _goToDashboard() {
    if (_navigated) return;
    _navigated = true;
    HapticFeedback.mediumImpact();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => DashboardPage(
            username: widget.dashboardArgs['username'],
            password: widget.dashboardArgs['password'],
            role: widget.dashboardArgs['role'],
            sessionKey: widget.dashboardArgs['key'],
            expiredDate: widget.dashboardArgs['expiredDate'],
            listBug: List<Map<String, dynamic>>.from(
                widget.dashboardArgs['listBug'] ?? []),
            listDoos: List<Map<String, dynamic>>.from(
                widget.dashboardArgs['listDoos'] ?? []),
            news: List<Map<String, dynamic>>.from(
                widget.dashboardArgs['news'] ?? []),
          ),
          transitionDuration: const Duration(milliseconds: 500),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onVideoEnd);
    _controller.dispose();
    _entryCtrl.dispose();
    _floatCtrl.dispose();
    _loadCtrl.dispose();
    _scanCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_isInitialized)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            )
          else
            Container(
              color: Sk.metalDeep,
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Sk.brass),
                ),
              ),
            ),

          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.4),
                    Colors.black.withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.5),
                    Colors.black.withValues(alpha: 0.85),
                    Colors.black.withValues(alpha: 0.95),
                  ],
                  stops: const [0.0, 0.25, 0.55, 0.8, 1.0],
                ),
              ),
            ),
          ),

          AnimatedBuilder(
            animation: _scanCtrl,
            builder: (_, __) => Positioned(
              top: _scanCtrl.value *
                  MediaQuery.of(context).size.height,
              left: 0,
              right: 0,
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Sk.cyanGlow.withValues(alpha: 0.4),
                      Sk.cyanGlow.withValues(alpha: 0.8),
                      Sk.cyanGlow.withValues(alpha: 0.4),
                      Colors.transparent,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Sk.cyanGlow.withValues(alpha: 0.5),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),

                FadeTransition(
                  opacity: _logoFade,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: _buildLogoMedallion(),
                  ),
                ),

                const SizedBox(height: 24),

                FadeTransition(
                  opacity: _logoFade,
                  child: _buildTitle(),
                ),

                const SizedBox(height: 12),

                SlideTransition(
                  position: _subtitleSlide,
                  child: FadeTransition(
                    opacity: _logoFade,
                    child: _buildSubtitle(),
                  ),
                ),

                const Spacer(flex: 2),

                FadeTransition(
                  opacity: _logoFade,
                  child: _buildLoadingPanel(),
                ),

                const SizedBox(height: 16),

                FadeTransition(
                  opacity: _logoFade,
                  child: _buildEnterButton(),
                ),

                const Spacer(flex: 1),
              ],
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 12,
            child: FadeTransition(
              opacity: _logoFade,
              child: _buildSkipButton(),
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 12,
            child: FadeTransition(
              opacity: _logoFade,
              child: _buildCornerPanel(),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // LOGO MEDALLION
  // ═══════════════════════════════════════════════════════
  Widget _buildLogoMedallion() {
    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _floatCtrl,
            builder: (_, __) => Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Sk.cyanGlow.withValues(
                      alpha: 0.15 + _floatCtrl.value * 0.15,
                    ),
                    Colors.transparent,
                  ],
                  stops: const [0.6, 1.0],
                ),
              ),
            ),
          ),

          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Sk.brassShine, Sk.brass, Sk.brassDark, Sk.brassDeep],
                stops: [0.0, 0.4, 0.7, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.85),
                  offset: const Offset(0, 8),
                  blurRadius: 20,
                ),
                BoxShadow(
                  color: Sk.brass.withValues(alpha: 0.4),
                  blurRadius: 25,
                  spreadRadius: 3,
                ),
              ],
            ),
            padding: const EdgeInsets.all(4),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Sk.metalHi, Sk.metalMid, Sk.metalDark],
                ),
              ),
              padding: const EdgeInsets.all(6),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Sk.leatherHi, Sk.leather, Sk.leatherDark],
                  ),
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.7),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.shield_moon_rounded,
                  color: Sk.brassShine,
                  size: 55,
                  shadows: [
                    Shadow(color: Sk.brass, blurRadius: 20),
                    Shadow(
                      color: Colors.black,
                      offset: Offset(0, 2),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ),
          ),

          ...List.generate(8, (i) {
            final angle = (i * math.pi * 2 / 8) - math.pi / 2;
            final r = 68.0;
            return Positioned(
              left: 80 + math.cos(angle) * r - 5,
              top: 80 + math.sin(angle) * r - 5,
              child: const _Rivet(size: 10),
            );
          }),

          Positioned(
            top: 0,
            child: AnimatedBuilder(
              animation: _ledPulse,
              builder: (_, __) => _Led(
                color: Sk.greenGlow,
                size: 10,
                blink: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // TITLE — FIXED: hanya satu `padding:` ✅
  // ═══════════════════════════════════════════════════════
  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Sk.metalHi, Sk.metalMid, Sk.metalDark, Sk.metalDeep],
            stops: [0.0, 0.4, 0.7, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.85),
              offset: const Offset(0, 8),
              blurRadius: 16,
            ),
            const BoxShadow(
              color: Colors.white24,
              offset: Offset(-1, -1),
              blurRadius: 3,
            ),
          ],
        ),
        padding: const EdgeInsets.all(3), // ✅ hanya satu padding
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Sk.leatherHi, Sk.leather, Sk.leatherDark],
            ),
            border: Border.all(color: Colors.black.withValues(alpha: 0.5)),
          ),
          child: Stack(
            children: [
              Transform.translate(
                offset: const Offset(1, 1),
                child: Text(
                  'vantaniv zasta',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Orbitron',
                    letterSpacing: 6,
                    height: 1,
                  ),
                ),
              ),
              const Text(
                'vantaniv zasta',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Sk.brassShine,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Orbitron',
                  letterSpacing: 6,
                  height: 1,
                  shadows: [
                    Shadow(color: Sk.brass, blurRadius: 15),
                    Shadow(
                      color: Sk.brassDeep,
                      offset: Offset(0, 1),
                      blurRadius: 2,
                    ),
                    Shadow(
                      color: Colors.black,
                      offset: Offset(0, 2),
                      blurRadius: 6,
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

  // ═══════════════════════════════════════════════════════
  // SUBTITLE
  // ═══════════════════════════════════════════════════════
  Widget _buildSubtitle() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.black.withValues(alpha: 0.6),
            border: Border.all(color: Sk.metalDark, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.8),
                offset: const Offset(0, 3),
                blurRadius: 6,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              _Led(color: Sk.cyanGlow, size: 6, blink: true),
              SizedBox(width: 8),
              Text(
                'SYSTEM ONLINE',
                style: TextStyle(
                  color: Sk.cyanGlow,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Orbitron',
                  letterSpacing: 2.5,
                  shadows: [Shadow(color: Sk.cyanGlow, blurRadius: 6)],
                ),
              ),
              SizedBox(width: 8),
              _Led(color: Sk.greenGlow, size: 6, blink: true),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'SECURITY · ENTERPRISE · EDITION',
          style: TextStyle(
            color: Sk.cream.withValues(alpha: 0.5),
            fontSize: 9,
            fontWeight: FontWeight.w600,
            fontFamily: 'ShareTechMono',
            letterSpacing: 4,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════
  // LOADING PANEL
  // ═══════════════════════════════════════════════════════
  Widget _buildLoadingPanel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.black.withValues(alpha: 0.7),
          border: Border.all(color: Sk.metalDark, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.9),
              offset: const Offset(0, 3),
              blurRadius: 8,
            ),
            const BoxShadow(
              color: Colors.white10,
              offset: Offset(0, -1),
              blurRadius: 1,
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                const _Screw(size: 10),
                const SizedBox(width: 8),
                const _Led(color: Sk.amberHi, size: 6, blink: true),
                const SizedBox(width: 8),
                Expanded(
                  child: AnimatedBuilder(
                    animation: _loadProgress,
                    builder: (_, __) => Text(
                      'INITIALIZING SYSTEM ${(_loadProgress.value * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: Sk.amberHi,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Orbitron',
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
                const _Screw(size: 10, rotation: 0),
              ],
            ),
            const SizedBox(height: 10),

            AnimatedBuilder(
              animation: _loadProgress,
              builder: (_, __) => Container(
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: Colors.black,
                  border: Border.all(color: Sk.metalDark, width: 0.8),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _loadProgress.value,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      gradient: const LinearGradient(
                        colors: [Sk.brassDark, Sk.brass, Sk.brassShine],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Sk.brass.withValues(alpha: 0.8),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // ENTER BUTTON
  // ═══════════════════════════════════════════════════════
  Widget _buildEnterButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: GestureDetector(
        onTap: _goToDashboard,
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Sk.brassShine, Sk.brassHi, Sk.brass, Sk.brassDark],
              stops: [0.0, 0.3, 0.7, 1.0],
            ),
            border: Border.all(color: Sk.brassDeep, width: 2),
            boxShadow: [
              BoxShadow(
                color: Sk.brass.withValues(alpha: 0.5),
                blurRadius: 15,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.8),
                offset: const Offset(0, 5),
                blurRadius: 8,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 3,
                left: 15,
                right: 15,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.5),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              const Positioned(top: 5, left: 5, child: _Rivet(size: 6)),
              const Positioned(top: 5, right: 5, child: _Rivet(size: 6)),
              const Positioned(bottom: 5, left: 5, child: _Rivet(size: 6)),
              const Positioned(bottom: 5, right: 5, child: _Rivet(size: 6)),

              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _Led(color: Sk.ink, size: 8, blink: false),
                  SizedBox(width: 12),
                  Text(
                    'ENTER SYSTEM',
                    style: TextStyle(
                      color: Sk.ink,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Orbitron',
                      letterSpacing: 3,
                      shadows: [
                        Shadow(
                          color: Colors.white54,
                          offset: Offset(0, 1),
                          blurRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12),
                  _Led(color: Sk.ink, size: 8, blink: false),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // SKIP BUTTON
  // ═══════════════════════════════════════════════════════
  Widget _buildSkipButton() {
    return GestureDetector(
      onTap: _goToDashboard,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Sk.metalMid, Sk.metalDark],
          ),
          border: Border.all(
            color: Sk.metalLight.withValues(alpha: 0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.75),
              offset: const Offset(0, 3),
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            _Led(color: Sk.amberHi, size: 5, blink: true),
            SizedBox(width: 8),
            Text(
              'SKIP',
              style: TextStyle(
                color: Sk.cream,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                fontFamily: 'Orbitron',
                letterSpacing: 2,
              ),
            ),
            SizedBox(width: 6),
            Icon(
              Icons.skip_next_rounded,
              color: Sk.brass,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // CORNER PANEL (top-left)
  // ═══════════════════════════════════════════════════════
  Widget _buildCornerPanel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Sk.metalMid, Sk.metalDark],
        ),
        border: Border.all(
          color: Sk.metalLight.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.75),
            offset: const Offset(0, 3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          _Screw(size: 8),
          SizedBox(width: 6),
          _Led(color: Sk.greenGlow, size: 5, blink: true),
          SizedBox(width: 6),
          Text(
            'LATEST',
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
    );
  }
}