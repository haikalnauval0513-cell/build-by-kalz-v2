import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'manage_server.dart';
import 'wifi_internal.dart';
import 'wifi_external.dart';
import 'nik_check.dart';
import 'tiktok_page.dart';
import 'instagram_page.dart';
import 'qr_gen.dart';
import 'domain_page.dart';
import 'spam_ngl.dart';
import 'device_dashboard.dart';
import 'game_zone/block_blast.dart';
import 'game_zone/catur.dart';
import 'game_zone/ludo_game.dart';
import 'game_zone/pukul_tikus.dart';
import 'api_config.dart';

// ═══════════════════════════════════════════════════════════
// SKEUOMORPHISM COLOR PALETTE
// ═══════════════════════════════════════════════════════════
class Sk {
  static const Color metalDeep   = Color(0xFF15130F);
  static const Color metalDark   = Color(0xFF252220);
  static const Color metalMid    = Color(0xFF3A3630);
  static const Color metalLight  = Color(0xFF55504A);
  static const Color metalShine  = Color(0xFF7A7368);
  static const Color metalHi     = Color(0xFF9A9286);

  static const Color brassDeep   = Color(0xFF5C4410);
  static const Color brassDark   = Color(0xFF8B6914);
  static const Color brass       = Color(0xFFC9A961);
  static const Color brassHi     = Color(0xFFE8C87F);
  static const Color brassShine  = Color(0xFFF5DEB3);

  static const Color redDeep     = Color(0xFF3D0808);
  static const Color red         = Color(0xFF8B1818);
  static const Color redBright   = Color(0xFFC41E1E);

  static const Color amberDeep   = Color(0xFF4A2800);
  static const Color amber       = Color(0xFFCC7A00);
  static const Color amberHi     = Color(0xFFFFB300);

  static const Color greenDeep   = Color(0xFF0A2818);
  static const Color green       = Color(0xFF1B5E20);
  static const Color greenHi     = Color(0xFF4CAF50);
  static const Color greenGlow   = Color(0xFF00E676);

  static const Color blueDeep    = Color(0xFF0A1A3D);
  static const Color blue        = Color(0xFF1565C0);
  static const Color blueHi      = Color(0xFF42A5F5);

  static const Color purpleDeep  = Color(0xFF240A3D);
  static const Color purple      = Color(0xFF6A1B9A);
  static const Color purpleHi    = Color(0xFFAB47BC);

  static const Color pinkDeep    = Color(0xFF3D0A22);
  static const Color pink        = Color(0xFFAD1457);
  static const Color pinkHi      = Color(0xFFEC407A);

  static const Color cyanDeep    = Color(0xFF0A2D2D);
  static const Color cyan        = Color(0xFF00838F);
  static const Color cyanHi      = Color(0xFF26C6DA);

  static const Color leather     = Color(0xFF2A1F18);
  static const Color leatherDark = Color(0xFF1A1310);
  static const Color leatherHi   = Color(0xFF3D2E22);
  static const Color cream       = Color(0xFFE8DFC8);
  static const Color paper       = Color(0xFFD4C8A8);
  static const Color ink         = Color(0xFF2A2520);
}

// ═══════════════════════════════════════════════════════════
// GLOBAL PULSE
// ═══════════════════════════════════════════════════════════
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

// ═══════════════════════════════════════════════════════════
// _Led
// ═══════════════════════════════════════════════════════════
class _Led extends StatelessWidget {
  final Color color;
  final double size;
  final bool blink;
  const _Led({required this.color, this.size = 8, this.blink = false});

  @override
  Widget build(BuildContext context) {
    if (!blink) return _buildLed(1.0);
    return ValueListenableBuilder<double>(
      valueListenable: _Pulse.v,
      builder: (_, v, __) => _buildLed(0.45 + v * 0.55),
    );
  }

  Widget _buildLed(double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.35, -0.35),
          colors: [
            Colors.white.withOpacity(0.85 * opacity),
            color.withOpacity(opacity),
            color.withOpacity(0.6 * opacity),
          ],
          stops: const [0.0, 0.4, 1.0],
        ),
        border: Border.all(
          color: Colors.black.withOpacity(0.85),
          width: size * 0.12,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.75 * opacity),
            blurRadius: size * 1.4,
            spreadRadius: size * 0.2,
          ),
          BoxShadow(
            color: color.withOpacity(0.35 * opacity),
            blurRadius: size * 2.8,
            spreadRadius: size * 0.5,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// _Screw
// ═══════════════════════════════════════════════════════════
class _Screw extends StatelessWidget {
  final double size;
  final double rotation;
  const _Screw({this.size = 14, this.rotation = 0.785});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          center: Alignment(-0.35, -0.35),
          colors: [Sk.metalHi, Sk.metalLight, Sk.metalMid, Sk.metalDark],
          stops: [0.0, 0.35, 0.7, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.9),
            offset: const Offset(0.8, 1.5),
            blurRadius: 2.5,
            spreadRadius: -0.5,
          ),
          const BoxShadow(
            color: Colors.white38,
            offset: Offset(-0.8, -0.8),
            blurRadius: 1.5,
          ),
        ],
      ),
      child: Center(
        child: Transform.rotate(
          angle: rotation,
          child: Container(
            width: size * 0.7,
            height: size * 0.11,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.9),
              borderRadius: BorderRadius.circular(size * 0.05),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.15),
                  offset: const Offset(0, 1),
                  blurRadius: 0.5,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// _Rivet
// ═══════════════════════════════════════════════════════════
class _Rivet extends StatelessWidget {
  final double size;
  const _Rivet({this.size = 10});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          center: Alignment(-0.35, -0.35),
          colors: [Sk.brassShine, Sk.brassHi, Sk.brass, Sk.brassDeep],
          stops: [0.0, 0.3, 0.65, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.9),
            offset: const Offset(0.5, 1),
            blurRadius: 1.5,
          ),
          const BoxShadow(
            color: Colors.white54,
            offset: Offset(-0.5, -0.5),
            blurRadius: 1,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// _MetalPlate
// ═══════════════════════════════════════════════════════════
class _MetalPlate extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final bool brass;
  const _MetalPlate({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 16,
    this.brass = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: brass
              ? const [Sk.brassHi, Sk.brass, Sk.brassDark, Sk.brassDeep]
              : const [Sk.metalHi, Sk.metalMid, Sk.metalDark, Sk.metalDeep],
          stops: const [0.0, 0.4, 0.7, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.75),
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
          border: Border.all(color: Colors.black.withOpacity(0.5)),
        ),
        child: child,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// _IndustrialTile — ✅ FIXED (super.key ditambahkan)
// ═══════════════════════════════════════════════════════════
class _IndustrialTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _IndustrialTile({
    super.key,                    // ✅ FIX
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  State<_IndustrialTile> createState() => _IndustrialTileState();
}

class _IndustrialTileState extends State<_IndustrialTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTapDown: (_) {
          if (!_pressed) setState(() => _pressed = true);
        },
        onTapUp: (_) {
          if (_pressed) setState(() => _pressed = false);
          HapticFeedback.lightImpact();
          widget.onTap();
        },
        onTapCancel: () {
          if (_pressed) setState(() => _pressed = false);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(
            _pressed ? 2 : 0,
            _pressed ? 2 : 0,
            0,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Sk.metalHi, Sk.metalMid, Sk.metalDark, Sk.metalDeep],
              stops: [0.0, 0.4, 0.7, 1.0],
            ),
            boxShadow: _pressed
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.95),
                      offset: const Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.75),
                      offset: const Offset(0, 6),
                      blurRadius: 10,
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Sk.leatherHi, Sk.leather, Sk.leatherDark],
              ),
              border: Border.all(color: Colors.black.withOpacity(0.5)),
            ),
            child: Stack(
              children: [
                const Positioned(top: 2, left: 2, child: _Rivet(size: 5)),
                const Positioned(top: 2, right: 2, child: _Rivet(size: 5)),
                const Positioned(bottom: 2, left: 2, child: _Rivet(size: 5)),
                const Positioned(bottom: 2, right: 2, child: _Rivet(size: 5)),

                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                center: const Alignment(-0.35, -0.35),
                                colors: [
                                  widget.color.withOpacity(0.45),
                                  widget.color.withOpacity(0.15),
                                  Colors.black.withOpacity(0.92),
                                ],
                                stops: const [0.0, 0.5, 1.0],
                              ),
                              border: Border.all(
                                color: widget.color.withOpacity(0.55),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.color.withOpacity(0.4),
                                  blurRadius: 10,
                                  spreadRadius: 0,
                                ),
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.85),
                                  offset: const Offset(0, 2),
                                  blurRadius: 5,
                                  spreadRadius: -1,
                                ),
                              ],
                            ),
                            child: Icon(
                              widget.icon,
                              color: widget.color,
                              size: 22,
                              shadows: [
                                Shadow(
                                  color: widget.color.withOpacity(0.8),
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: _Led(
                              color: widget.color,
                              size: 6,
                              blink: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: Sk.cream,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Orbitron',
                          letterSpacing: 0.8,
                          height: 1.1,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              offset: Offset(0, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),

                      Text(
                        widget.subtitle,
                        style: TextStyle(
                          color: Sk.cream.withOpacity(0.5),
                          fontSize: 7.5,
                          fontFamily: 'ShareTechMono',
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                          height: 1.1,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// _SheetMenuItem
// ═══════════════════════════════════════════════════════════
class _SheetMenuItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _SheetMenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_SheetMenuItem> createState() => _SheetMenuItemState();
}

class _SheetMenuItemState extends State<_SheetMenuItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          height: 58,
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              begin: _pressed ? Alignment.bottomCenter : Alignment.topCenter,
              end: _pressed ? Alignment.topCenter : Alignment.bottomCenter,
              colors: _pressed
                  ? const [Sk.metalDark, Sk.metalMid]
                  : const [Sk.metalLight, Sk.metalMid, Sk.metalDark],
              stops: const [0.0, 0.5, 1.0],
            ),
            boxShadow: _pressed
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.9),
                      offset: const Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.7),
                      offset: const Offset(0, 4),
                      blurRadius: 6,
                    ),
                    const BoxShadow(
                      color: Colors.white24,
                      offset: Offset(0, -1),
                      blurRadius: 2,
                    ),
                  ],
            border: Border.all(
              color: Colors.black.withOpacity(0.6),
              width: 1.2,
            ),
          ),
          child: Stack(
            children: [
              const Positioned(left: 5, top: 5, child: _Rivet(size: 6)),
              const Positioned(left: 5, bottom: 5, child: _Rivet(size: 6)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          center: const Alignment(-0.35, -0.35),
                          colors: [
                            widget.color.withOpacity(0.4),
                            widget.color.withOpacity(0.12),
                            Colors.black.withOpacity(0.9),
                          ],
                        ),
                        border: Border.all(
                          color: widget.color.withOpacity(0.6),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: widget.color.withOpacity(0.4),
                            blurRadius: 7,
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.8),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.icon,
                        color: widget.color,
                        size: 18,
                        shadows: [
                          Shadow(
                            color: widget.color.withOpacity(0.8),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        widget.label,
                        style: const TextStyle(
                          color: Sk.cream,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Orbitron',
                          letterSpacing: 0.8,
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
                    _Led(color: widget.color, size: 5, blink: true),
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Sk.brass,
                      size: 12,
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
}

// ═══════════════════════════════════════════════════════════
// TOOLS PAGE
// ═══════════════════════════════════════════════════════════
class ToolsPage extends StatefulWidget {
  final String sessionKey;
  final String userRole;
  final String username;
  final List<Map<String, dynamic>> listDoos;

  const ToolsPage({
    super.key,
    required this.sessionKey,
    required this.userRole,
    required this.username,
    required this.listDoos,
  });

  @override
  State<ToolsPage> createState() => _ToolsPageState();
}

class _ToolsPageState extends State<ToolsPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _gaugeController;

  static const List<_ToolCategory> _categories = [
    _ToolCategory(
      icon: Icons.cloud_outlined,
      title: "PANEL",
      subtitle: "Manajemen server",
      color: Sk.blueHi,
    ),
    _ToolCategory(
      icon: Icons.sports_esports_outlined,
      title: "GAME & AI",
      subtitle: "Catur, asisten",
      color: Sk.pinkHi,
    ),
    _ToolCategory(
      icon: Icons.wifi_outlined,
      title: "NETWORK",
      subtitle: "WiFi, spam",
      color: Sk.cyanHi,
    ),
    _ToolCategory(
      icon: Icons.search_outlined,
      title: "OSINT",
      subtitle: "NIK, domain",
      color: Sk.amberHi,
    ),
    _ToolCategory(
      icon: Icons.download_outlined,
      title: "DOWNLOADER",
      subtitle: "TikTok, IG",
      color: Sk.purpleHi,
    ),
    _ToolCategory(
      icon: Icons.build_outlined,
      title: "NTED CONTROL",
      subtitle: "Rat Malware",
      color: Sk.redBright,
    ),
    _ToolCategory(
      icon: Icons.rocket_launch_outlined,
      title: "GENERATOR",
      subtitle: "Quote, story",
      color: Sk.greenGlow,
    ),
    _ToolCategory(
      icon: Icons.auto_awesome_outlined,
      title: "ANIME",
      subtitle: "Streaming, 18+",
      color: Sk.pinkHi,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _Pulse.ensureStarted();
    _gaugeController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _gaugeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0806),
      body: Stack(
        children: [
          const Positioned.fill(
            child: RepaintBoundary(
              child: _LeatherWall(),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 8),
                _buildHeaderPanel(),
                const SizedBox(height: 12),
                _buildSectionHeader(),
                const SizedBox(height: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: GridView.builder(
                      addAutomaticKeepAlives: false,
                      addRepaintBoundaries: false,
                      cacheExtent: 400,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _categories.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.82,
                      ),
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        return _IndustrialTile(
                          key: ValueKey(category.title),
                          icon: category.icon,
                          title: category.title,
                          subtitle: category.subtitle,
                          color: category.color,
                          onTap: () => _onCategoryTap(context, category),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildStatusBar(),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderPanel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: _MetalPlate(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      center: Alignment(-0.3, -0.3),
                      colors: [Sk.metalHi, Sk.metalMid, Sk.metalDark],
                    ),
                    border: Border.all(color: Sk.brass, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.85),
                        offset: const Offset(0, 4),
                        blurRadius: 8,
                      ),
                      BoxShadow(
                        color: Sk.brass.withOpacity(0.4),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Image.asset(
                        'assets/images/otaxlogo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.shield_moon_outlined,
                          color: Sk.brassShine,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  top: -2,
                  child: _Led(color: Sk.greenGlow, size: 6, blink: true),
                ),
                const Positioned(
                  bottom: -2,
                  child: _Led(color: Sk.brass, size: 6, blink: true),
                ),
              ],
            ),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'vantaniv zasta',
                    style: TextStyle(
                      color: Sk.brassHi,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Orbitron',
                      letterSpacing: 2,
                      height: 1,
                      shadows: [
                        Shadow(
                          color: Sk.brassDeep,
                          offset: Offset(0, 1),
                          blurRadius: 1,
                        ),
                        Shadow(
                          color: Colors.black,
                          offset: Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const _Led(color: Sk.greenGlow, size: 5, blink: true),
                      const SizedBox(width: 5),
                      Text(
                        'TOOLS GATEWAY LATEST',
                        style: TextStyle(
                          color: Sk.cream.withOpacity(0.6),
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'ShareTechMono',
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Sk.brassHi, Sk.brass, Sk.brassDark],
                ),
                border: Border.all(color: Sk.brassShine, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.7),
                    offset: const Offset(0, 3),
                    blurRadius: 5,
                  ),
                  const BoxShadow(
                    color: Colors.white54,
                    offset: Offset(0, -1),
                    blurRadius: 1,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'ROLE',
                    style: TextStyle(
                      color: Sk.brassDeep.withOpacity(0.8),
                      fontSize: 6,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Orbitron',
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    widget.userRole.toUpperCase(),
                    style: const TextStyle(
                      color: Sk.ink,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Orbitron',
                      letterSpacing: 1,
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

  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          const _Led(color: Sk.greenGlow, size: 8, blink: true),
          const SizedBox(width: 10),
          const Text(
            'MENU APPLICATION',
            style: TextStyle(
              color: Sk.brass,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              fontFamily: 'Orbitron',
              letterSpacing: 2.5,
              shadows: [
                Shadow(
                  color: Colors.black,
                  offset: Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AnimatedBuilder(
              animation: _gaugeController,
              builder: (_, __) => CustomPaint(
                size: const Size(double.infinity, 4),
                painter: _GaugeLinePainter(
                  progress: _gaugeController.value,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.black.withOpacity(0.6),
              border: Border.all(color: Sk.brassDeep, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.8),
                  offset: const Offset(0, 2),
                  blurRadius: 3,
                ),
              ],
            ),
            child: Text(
              '${_categories.length} ITEMS',
              style: TextStyle(
                color: Sk.brass.withOpacity(0.9),
                fontSize: 8,
                fontWeight: FontWeight.w900,
                fontFamily: 'Orbitron',
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        height: 34,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Sk.metalMid, Sk.metalDark, Sk.metalDeep],
          ),
          border: Border.all(
            color: Sk.metalLight.withOpacity(0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.75),
              offset: const Offset(0, 4),
              blurRadius: 8,
            ),
            const BoxShadow(
              color: Colors.white12,
              offset: Offset(0, -1),
              blurRadius: 2,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              const _Screw(size: 10),
              const SizedBox(width: 8),
              const _Led(color: Sk.greenGlow, size: 6, blink: true),
              const SizedBox(width: 8),
              Text(
                'SYSTEM READY',
                style: TextStyle(
                  color: Sk.greenGlow.withOpacity(0.9),
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Orbitron',
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              const _Led(color: Sk.brass, size: 5, blink: true),
              const SizedBox(width: 6),
              Text(
                'SECURE · FAST · RELIABLE',
                style: TextStyle(
                  color: Sk.brass.withOpacity(0.75),
                  fontSize: 7,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'ShareTechMono',
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(width: 8),
              const _Led(color: Sk.greenGlow, size: 5, blink: true),
              const SizedBox(width: 8),
              const _Screw(size: 10, rotation: 0),
            ],
          ),
        ),
      ),
    );
  }

  void _onCategoryTap(BuildContext context, _ToolCategory category) {
    switch (category.title) {
      case "PANEL":
        _showVpsTools(context);
        break;
      case "GAME & AI":
        _showGamesTools(context);
        break;
      case "NETWORK":
        _showNetworkTools(context);
        break;
      case "OSINT":
        _showOSINTTools(context);
        break;
      case "DOWNLOADER":
        _showDownloaderTools(context);
        break;
      case "NTED CONTROL":
        _showUtilityTools(context);
        break;
      case "GENERATOR":
        _showQuickAccess(context);
        break;
      case "ANIME":
        _showAnimeTools(context);
        break;
    }
  }

  void _showModalSheet(
    BuildContext context,
    String title,
    IconData icon,
    Color accentColor,
    List<Widget> items,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.65,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Sk.metalHi, Sk.metalMid, Sk.metalDark, Sk.metalDeep],
            stops: [0.0, 0.4, 0.7, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.9),
              offset: const Offset(0, -6),
              blurRadius: 20,
            ),
            const BoxShadow(
              color: Colors.white24,
              offset: Offset(0, 1),
              blurRadius: 2,
            ),
          ],
        ),
        padding: const EdgeInsets.all(3),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Sk.leatherHi, Sk.leather, Sk.leatherDark],
            ),
            border: Border.all(color: Colors.black.withOpacity(0.6)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  gradient: const LinearGradient(
                    colors: [Sk.metalDark, Sk.metalLight, Sk.metalDark],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.7),
                      offset: const Offset(0, 1),
                      blurRadius: 2,
                    ),
                    const BoxShadow(
                      color: Colors.white24,
                      offset: Offset(0, -1),
                      blurRadius: 1,
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          center: const Alignment(-0.35, -0.35),
                          colors: [
                            accentColor.withOpacity(0.4),
                            accentColor.withOpacity(0.12),
                            Colors.black.withOpacity(0.9),
                          ],
                        ),
                        border: Border.all(
                          color: accentColor.withOpacity(0.6),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withOpacity(0.5),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.8),
                            offset: const Offset(0, 3),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Icon(
                        icon,
                        color: accentColor,
                        size: 22,
                        shadows: [
                          Shadow(
                            color: accentColor.withOpacity(0.9),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        title.toUpperCase(),
                        style: const TextStyle(
                          color: Sk.brass,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Orbitron',
                          letterSpacing: 1.8,
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
                    _Led(color: accentColor, size: 7, blink: true),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Sk.metalLight, Sk.metalMid, Sk.metalDark],
                          ),
                          border: Border.all(
                            color: Sk.red.withOpacity(0.6),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.8),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                            ),
                            const BoxShadow(
                              color: Colors.white24,
                              offset: Offset(0, -1),
                              blurRadius: 1,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Sk.brass,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Sk.brass.withOpacity(0.5),
                      Sk.brass.withOpacity(0.5),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: items,
                  ),
                ),
              ),

              Container(
                margin: const EdgeInsets.only(bottom: 12, top: 4),
                width: 80,
                height: 3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: Sk.metalDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModalItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return _SheetMenuItem(
      icon: icon,
      label: label,
      color: Sk.brass,
      onTap: onTap,
    );
  }

  void _showAnimeTools(BuildContext context) {
    _showModalSheet(context, "Anime", Icons.auto_awesome_outlined, Sk.pinkHi, [
      _buildModalItem(
        icon: Icons.movie_outlined,
        label: "Anime Page",
        onTap: () => _showComingSoon(context),
      ),
      _buildModalItem(
        icon: Icons.lock_outlined,
        label: "18+",
        onTap: () {
          Navigator.pop(context);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (dialogContext) => Dialog(
                  backgroundColor: Colors.transparent,
                  child: _MetalPlate(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            _Led(color: Sk.amberHi, size: 10, blink: true),
                            SizedBox(width: 10),
                            Text(
                              'INFORMASI',
                              style: TextStyle(
                                color: Sk.brass,
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'Orbitron',
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Mohon Maaf Fitur Ini Ditutup\nSelama Bulan Ramadhan',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Sk.cream,
                            fontSize: 12,
                            fontFamily: 'ShareTechMono',
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () => Navigator.pop(dialogContext),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Sk.amberHi, Sk.amber, Sk.amberDeep],
                              ),
                              border: Border.all(
                                color: Colors.black.withOpacity(0.6),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.7),
                                  offset: const Offset(0, 4),
                                  blurRadius: 6,
                                ),
                                const BoxShadow(
                                  color: Colors.white38,
                                  offset: Offset(0, -1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                            child: const Text(
                              'OK',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'Orbitron',
                                letterSpacing: 2,
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
          });
        },
      ),
    ]);
  }

  void _showVpsTools(BuildContext context) {
    _showModalSheet(context, "Panel", Icons.cloud_outlined, Sk.blueHi, [
      _buildModalItem(
        icon: Icons.sports_esports_outlined,
        label: "Cpanel",
        onTap: () => _showComingSoon(context),
      ),
      _buildModalItem(
        icon: Icons.security_outlined,
        label: "Colong Sender",
        onTap: () => _showComingSoon(context),
      ),
      _buildModalItem(
        icon: Icons.computer_outlined,
        label: "Buat VPS DigitalOcean",
        onTap: () => _showComingSoon(context),
      ),
      _buildModalItem(
        icon: Icons.settings_ethernet_outlined,
        label: "Install Panel Pterodactyl",
        onTap: () => _showComingSoon(context),
      ),
      _buildModalItem(
        icon: Icons.build_circle_outlined,
        label: "Install Flutter",
        onTap: () => _showComingSoon(context),
      ),
    ]);
  }

  void _showGamesTools(BuildContext context) {
    _showModalSheet(
      context,
      "Game & AI",
      Icons.sports_esports_outlined,
      Sk.pinkHi,
      [
        _buildModalItem(
          icon: Icons.grid_on_outlined,
          label: "Block Blast",
          onTap: () {
            Navigator.pop(context);
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const BlockBlastPage()));
          },
        ),
        _buildModalItem(
          icon: Icons.extension_outlined,
          label: "Catur",
          onTap: () {
            Navigator.pop(context);
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const CaturPage()));
          },
        ),
        _buildModalItem(
          icon: Icons.casino_outlined,
          label: "Ludo",
          onTap: () {
            Navigator.pop(context);
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const LudoGamePage()));
          },
        ),
        _buildModalItem(
          icon: Icons.pets_outlined,
          label: "Pukul Tikus",
          onTap: () {
            Navigator.pop(context);
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PukulTikusPage()));
          },
        ),
        _buildModalItem(
          icon: Icons.smart_toy_outlined,
          label: "AI Assistant",
          onTap: () => _showComingSoon(context),
        ),
      ],
    );
  }

  void _showNetworkTools(BuildContext context) {
    _showModalSheet(context, "Network", Icons.wifi_outlined, Sk.cyanHi, [
      _buildModalItem(
        icon: Icons.newspaper_outlined,
        label: "Spam NGL",
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => const NglPage()));
        },
      ),
      _buildModalItem(
        icon: Icons.wifi_off_outlined,
        label: "WiFi Internal",
        onTap: () {
          Navigator.pop(context);
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const WifiKillerPage()));
        },
      ),
      if (widget.userRole == "KINGZ" || widget.userRole == "OWNER")
        _buildModalItem(
          icon: Icons.router_outlined,
          label: "WiFi External",
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WifiInternalPage(sessionKey: widget.sessionKey),
              ),
            );
          },
        ),
    ]);
  }

  void _showOSINTTools(BuildContext context) {
    _showModalSheet(context, "OSINT", Icons.search_outlined, Sk.amberHi, [
      _buildModalItem(
        icon: Icons.badge_outlined,
        label: "NIK Detail",
        onTap: () {
          Navigator.pop(context);
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const NikCheckerPage()));
        },
      ),
      _buildModalItem(
        icon: Icons.domain_outlined,
        label: "Domain OSINT",
        onTap: () {
          Navigator.pop(context);
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const DomainOsintPage()));
        },
      ),
      _buildModalItem(
        icon: Icons.person_search_outlined,
        label: "Phone Lookup",
        onTap: () => _showComingSoon(context),
      ),
      _buildModalItem(
        icon: Icons.email_outlined,
        label: "Email OSINT",
        onTap: () => _showComingSoon(context),
      ),
    ]);
  }

  void _showDownloaderTools(BuildContext context) {
    _showModalSheet(
      context,
      "Downloader",
      Icons.download_outlined,
      Sk.purpleHi,
      [
        _buildModalItem(
          icon: Icons.video_library_outlined,
          label: "TikTok",
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const TiktokDownloaderPage()));
          },
        ),
        _buildModalItem(
          icon: Icons.camera_alt_outlined,
          label: "Instagram",
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const InstagramDownloaderPage()));
          },
        ),
      ],
    );
  }

  void _showUtilityTools(BuildContext context) {
    _showModalSheet(
      context,
      "NTED CONTROL",
      Icons.build_outlined,
      Sk.redBright,
      [
        _buildModalItem(
          icon: Icons.badge_outlined,
          label: "RAT Controll",
          onTap: () => _showComingSoon(context),
        ),
        _buildModalItem(
          icon: Icons.dashboard_rounded,
          label: "Device Dashboard",
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DeviceDashboardPage(
                  username: widget.username,
                  role: widget.userRole,
                  sessionKey: widget.sessionKey,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _showQuickAccess(BuildContext context) {
    _showModalSheet(context, "Generator", Icons.auto_awesome, Sk.greenGlow, [
      _buildModalItem(
        icon: Icons.phone_iphone,
        label: "iPhone Quote",
        onTap: () => _showComingSoon(context),
      ),
      _buildModalItem(
        icon: Icons.auto_stories_outlined,
        label: "Fake Story",
        onTap: () => _showComingSoon(context),
      ),
      _buildModalItem(
        icon: Icons.flutter_dash,
        label: "Fake Tweet",
        onTap: () => _showComingSoon(context),
      ),
      _buildModalItem(
        icon: Icons.cloud_upload_outlined,
        label: "To Url",
        onTap: () => _showComingSoon(context),
      ),
    ]);
  }

  void _showComingSoon(BuildContext context) {
    Navigator.pop(context);
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            _Led(color: Sk.amberHi, size: 8, blink: true),
            SizedBox(width: 12),
            Text(
              'SEGERA HADIR',
              style: TextStyle(
                color: Sk.cream,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                fontFamily: 'Orbitron',
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        backgroundColor: Sk.metalDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Sk.brass, width: 1.5),
        ),
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// TOOL CATEGORY MODEL
// ═══════════════════════════════════════════════════════════
class _ToolCategory {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  const _ToolCategory({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}

// ═══════════════════════════════════════════════════════════
// GAUGE LINE PAINTER
// ═══════════════════════════════════════════════════════════
class _GaugeLinePainter extends CustomPainter {
  final double progress;
  _GaugeLinePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final trackRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(size.height / 2),
    );
    canvas.drawRRect(trackRRect, Paint()..color = const Color(0xFF0A0806));
    canvas.drawRRect(
      trackRRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.black.withOpacity(0.9),
    );

    final lightX = size.width * progress;
    final lightRect = Rect.fromLTWH(
      (lightX - 20).clamp(0, size.width),
      0,
      40,
      size.height,
    );
    canvas.drawRect(
      lightRect,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Sk.brass.withOpacity(0.0),
            Sk.brass.withOpacity(0.8),
            Sk.brassShine,
            Sk.brass.withOpacity(0.8),
            Sk.brass.withOpacity(0.0),
          ],
          stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
        ).createShader(lightRect),
    );

    canvas.drawCircle(
      Offset(lightX, size.height / 2),
      6,
      Paint()
        ..color = Sk.brassShine.withOpacity(0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
  }

  @override
  bool shouldRepaint(_GaugeLinePainter old) => old.progress != progress;
}

// ═══════════════════════════════════════════════════════════
// LEATHER WALL
// ═══════════════════════════════════════════════════════════
class _LeatherWall extends StatelessWidget {
  const _LeatherWall();

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: const CustomPaint(painter: _LeatherTexturePainter()),
    );
  }
}

class _LeatherTexturePainter extends CustomPainter {
  const _LeatherTexturePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rand = math.Random(42);

    final dotPaint = Paint()..color = Colors.black.withOpacity(0.06);
    for (int i = 0; i < 300; i++) {
      canvas.drawCircle(
        Offset(rand.nextDouble() * size.width, rand.nextDouble() * size.height),
        rand.nextDouble() * 1.2,
        dotPaint,
      );
    }

    final linePaint = Paint()
      ..color = Colors.black.withOpacity(0.04)
      ..strokeWidth = 0.5;
    for (int i = 0; i < 100; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final len = rand.nextDouble() * 12 + 3;
      final angle = rand.nextDouble() * math.pi;
      canvas.drawLine(
        Offset(x, y),
        Offset(x + math.cos(angle) * len, y + math.sin(angle) * len),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(_LeatherTexturePainter old) => false;
}