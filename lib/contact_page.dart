import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage>
    with TickerProviderStateMixin {
  // ─── PALETTE ──────────────────────────────────────────────
  static const Color _bg    = Color(0xFF000000);
  static const Color _red   = Color(0xFFFF0040);
  static const Color _redLow= Color(0x22FF0040);
  static const Color _white = Color(0xFFF2F2F2);
  static const Color _muted = Color(0xFF4A4A4A);
  static const Color _dim   = Color(0xFF1C1C1C);

  late AnimationController _glowCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _entryCtrl;

  late Animation<double> _glowAnim;
  late Animation<double> _pulseAnim;
  late Animation<double> _entryFade;
  late Animation<Offset>  _entrySlide;

  final List<Map<String, dynamic>> _contacts = [
    {
      "label"     : "Telegram",
      "subtitle"  : "@NtedPakeE",
      "icon"      : FontAwesomeIcons.telegram,
      "brandColor": const Color(0xFF2AABEE),
      "url"       : "https://t.me/NtedPakeE",
    },
    {
      "label"     : "TikTok",
      "subtitle"  : "@nted.exec",
      "icon"      : FontAwesomeIcons.tiktok,
      "brandColor": Colors.white,
      "url"       : "https://www.tiktok.com/@nted.exec?_r=1&_t=ZS-97tKcZwgjWn",
    },
  ];

  int? _pressedIndex;

  @override
  void initState() {
    super.initState();

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.04, end: 0.13)
        .animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.3, end: 1.0)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _entryFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _entryCtrl,
          curve: const Interval(0.0, 0.8, curve: Curves.easeOut)),
    );
    _entrySlide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    _pulseCtrl.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    HapticFeedback.lightImpact();
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: _red, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "CUSTOMER SERVICE",
          style: TextStyle(
            color: _white,
            fontFamily: 'Orbitron',
            fontWeight: FontWeight.w700,
            fontSize: 13,
            letterSpacing: 2,
          ),
        ),
      ),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _glowAnim,
            builder: (_, __) => Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.5),
                  radius: 0.9,
                  colors: [
                    _red.withValues(alpha: _glowAnim.value),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Opacity(
            opacity: 0.025,
            child: CustomPaint(
              size: MediaQuery.of(context).size,
              painter: _GridPainter(),
            ),
          ),
          Positioned(top: 8, left: 8,    child: _CornerAccent(isTop: true,  isLeft: true)),
          Positioned(top: 8, right: 8,   child: _CornerAccent(isTop: true,  isLeft: false)),
          Positioned(bottom: 8, left: 8,  child: _CornerAccent(isTop: false, isLeft: true)),
          Positioned(bottom: 8, right: 8, child: _CornerAccent(isTop: false, isLeft: false)),

          Positioned(
            top: 48,
            left: 20,
            child: AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, __) => Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _red.withValues(alpha: _pulseAnim.value * 0.7),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
              child: FadeTransition(
                opacity: _entryFade,
                child: SlideTransition(
                  position: _entrySlide,
                  child: Column(
                    children: [
                      AnimatedBuilder(
                        animation: _pulseAnim,
                        builder: (_, child) => Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _dim,
                            border: Border.all(
                              color: _red.withValues(alpha: _pulseAnim.value * 0.5),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _red.withValues(alpha: _pulseAnim.value * 0.15),
                                blurRadius: 28,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.support_agent_rounded,
                            color: _red,
                            size: 38,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "NEED HELP?",
                        style: TextStyle(
                          color: _white,
                          fontFamily: 'Orbitron',
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _RedLineDivider(),
                      const SizedBox(height: 12),
                      const Text(
                        "Hubungi kami melalui platform\nmedia sosial di bawah ini.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _muted,
                          fontFamily: 'ShareTechMono',
                          fontSize: 11,
                          letterSpacing: 1,
                          height: 1.7,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "// CONTACT CHANNELS",
                          style: TextStyle(
                            color: _red.withValues(alpha: 0.6),
                            fontFamily: 'ShareTechMono',
                            fontSize: 10,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      ..._contacts.asMap().entries.map((e) {
                        final i = e.key;
                        final c = e.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildContactCard(
                            index     : i,
                            label     : c['label'],
                            subtitle  : c['subtitle'],
                            icon      : c['icon'], // sudah FaIconData (subclass IconData)
                            brandColor: c['brandColor'],
                            url       : c['url'],
                          ),
                        );
                      }),
                      const SizedBox(height: 40),
                      _RedLineDivider(),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedBuilder(
                            animation: _pulseAnim,
                            builder: (_, __) => Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: _red.withValues(alpha: _pulseAnim.value * 0.6),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "NTED SUPPORT",
                            style: TextStyle(
                              color: _muted,
                              fontFamily: 'ShareTechMono',
                              fontSize: 10,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(width: 10),
                          AnimatedBuilder(
                            animation: _pulseAnim,
                            builder: (_, __) => Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: _red.withValues(alpha: _pulseAnim.value * 0.6),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard({
    required int index,
    required String label,
    required String subtitle,
    required IconData icon, // sekarang IconData (bisa FaIconData)
    required Color brandColor,
    required String url,
  }) {
    final isPressed = _pressedIndex == index;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressedIndex = index),
      onTapUp: (_) {
        setState(() => _pressedIndex = null);
        _launchUrl(url);
      },
      onTapCancel: () => setState(() => _pressedIndex = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
        decoration: BoxDecoration(
          color: isPressed ? _red.withValues(alpha: 0.08) : _dim,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPressed
                ? _red.withValues(alpha: 0.5)
                : _muted.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: isPressed
              ? [
                  BoxShadow(
                    color: _red.withValues(alpha: 0.12),
                    blurRadius: 20,
                    spreadRadius: 0,
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: brandColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: brandColor.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Center(
                // Gunakan Icon langsung karena FontAwesomeIcons adalah FaIconData (subclass IconData)
                child: Icon(icon, color: brandColor, size: 20),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: _white,
                      fontFamily: 'Orbitron',
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: _muted,
                      fontFamily: 'ShareTechMono',
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isPressed ? _redLow : Colors.black,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isPressed
                      ? _red.withValues(alpha: 0.4)
                      : _muted.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: isPressed ? _red : _muted,
                size: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RedLineDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF0040).withValues(alpha: 0.0),
            const Color(0xFFFF0040).withValues(alpha: 0.9),
            const Color(0xFFFF0040).withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }
}

class _CornerAccent extends StatelessWidget {
  final bool isTop, isLeft;
  const _CornerAccent({required this.isTop, required this.isLeft});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(20, 20),
      painter: _CornerPainter(
        isTop: isTop,
        isLeft: isLeft,
        color: const Color(0xFFFF0040).withValues(alpha: 0.2),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final bool isTop, isLeft;
  final Color color;
  _CornerPainter({required this.isTop, required this.isLeft, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final x  = isLeft ? 0.0 : size.width;
    final y  = isTop  ? 0.0 : size.height;
    final dx = isLeft ?  size.width * 0.5 : -size.width * 0.5;
    final dy = isTop  ?  size.height * 0.5 : -size.height * 0.5;
    canvas.drawLine(Offset(x, y), Offset(x + dx, y), paint);
    canvas.drawLine(Offset(x, y), Offset(x, y + dy), paint);
  }

  @override
  bool shouldRepaint(_CornerPainter old) => false;
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4A4A4A)
      ..strokeWidth = 0.5;
    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => false;
}