import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:battery_plus/battery_plus.dart';

import 'admin_page.dart';
import 'owner_page.dart';
import 'home_page.dart';
import 'seller_page.dart';
import 'change_password_page.dart';
import 'login_page.dart';
import 'profile_page.dart';
import 'riwayat_page.dart';
import 'tools_gateway.dart';
import 'bug_sender.dart';
import 'contact_page.dart';
import 'bug_group_page.dart';
import 'tqto.dart';
import 'chat.dart';
import 'notification_page.dart';
import 'ai_page.dart';
import 'check_notif_page.dart';

class Sk {
  static const Color metalDeep    = Color(0xFF1A1815);
  static const Color metalDark    = Color(0xFF2A2723);
  static const Color metalMid     = Color(0xFF3D3933);
  static const Color metalLight   = Color(0xFF5A554C);
  static const Color metalShine   = Color(0xFF7A7368);
  static const Color metalHi      = Color(0xFF9A9286);

  static const Color brassDeep    = Color(0xFF6B5015);
  static const Color brassDark    = Color(0xFF8B6914);
  static const Color brass        = Color(0xFFC9A961);
  static const Color brassHi      = Color(0xFFE8C87F);
  static const Color brassShine   = Color(0xFFF5DEB3);

  static const Color redDeep      = Color(0xFF3D0808);
  static const Color redDark      = Color(0xFF6B0E0E);
  static const Color red          = Color(0xFF8B1818);
  static const Color redBright    = Color(0xFFC41E1E);
  static const Color redGlow      = Color(0xFFFF3030);

  static const Color amberDeep    = Color(0xFF5A3500);
  static const Color amber        = Color(0xFFD97706);
  static const Color amberHi      = Color(0xFFF59E0B);

  static const Color greenDeep    = Color(0xFF0D2818);
  static const Color green        = Color(0xFF1B5E20);
  static const Color greenHi      = Color(0xFF4CAF50);
  static const Color greenGlow    = Color(0xFF00E676);

  static const Color cream        = Color(0xFFE8DFC8);
  static const Color paper        = Color(0xFFD4C8A8);
  static const Color ink          = Color(0xFF2A2520);

  static const Color leather      = Color(0xFF2A1F18);
  static const Color leatherDark  = Color(0xFF1A1310);
  static const Color leatherHi    = Color(0xFF3D2E22);
}

const String wsUrl = 'ws://lelendxdaycintapanel.ymzpterodactyl.biz.id:2079';

// ═══════════════════════════════════════════════════════════
// GLOBAL PULSE — 1 ticker untuk semua LED
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
// LED
// ═══════════════════════════════════════════════════════════
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

  Widget _dot(double opacity) {
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
            color.withOpacity(0.55 * opacity),
          ],
          stops: const [0.0, 0.4, 1.0],
        ),
        border: Border.all(
          color: Colors.black.withOpacity(0.85),
          width: size * 0.1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.75 * opacity),
            blurRadius: size * 1.4,
            spreadRadius: size * 0.2,
          ),
          BoxShadow(
            color: color.withOpacity(0.35 * opacity),
            blurRadius: size * 2.6,
            spreadRadius: size * 0.4,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// SCREW
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
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// RIVET
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
// METAL PLATE
// ═══════════════════════════════════════════════════════════
class _MetalPlate extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final bool brass;
  final double radius;
  const _MetalPlate({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.brass = false,
    this.radius = 16,
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
            color: Colors.white12,
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
// INSET PANEL
// ═══════════════════════════════════════════════════════════
class _InsetPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color glowColor;
  final bool glow;
  const _InsetPanel({
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.glowColor = Sk.brass,
    this.glow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0A0806), Color(0xFF151210)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.95),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
          const BoxShadow(
            color: Colors.white10,
            offset: Offset(0, -1),
            blurRadius: 1,
          ),
          if (glow)
            BoxShadow(
              color: glowColor.withOpacity(0.35),
              blurRadius: 10,
            ),
        ],
        border: Border.all(
          color: glow ? glowColor.withOpacity(0.7) : Sk.metalDark,
          width: 1.5,
        ),
      ),
      child: child,
    );
  }
}

// ═══════════════════════════════════════════════════════════
// INDUSTRIAL BUTTON
// ═══════════════════════════════════════════════════════════
class _IndustrialButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
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
    final light = _lighten(widget.color);
    final dark = _darken(widget.color);
    final widgetDark = _widgetDark(widget.color);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: _pressed ? Alignment.bottomCenter : Alignment.topCenter,
            end: _pressed ? Alignment.topCenter : Alignment.bottomCenter,
            colors: _pressed
                ? [widgetDark, widgetDark, widget.color]
                : [light, widget.color, dark],
            stops: const [0.0, 0.5, 1.0],
          ),
          boxShadow: _pressed
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.9),
                    offset: const Offset(0, 1),
                    blurRadius: 3,
                  ),
                ]
              : [
                  BoxShadow(
                    color: widget.color.withOpacity(0.45),
                    offset: const Offset(0, 5),
                    blurRadius: 10,
                    spreadRadius: -2,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.75),
                    offset: const Offset(0, 4),
                    blurRadius: 6,
                  ),
                ],
          border: Border.all(
            color: dark.withOpacity(0.9),
            width: 1.5,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 3,
              left: 10,
              right: 10,
              child: Container(
                height: 12,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(_pressed ? 0.08 : 0.3),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: widget.child,
            ),
          ],
        ),
      ),
    );
  }

  static Color _lighten(Color c) => Color.fromARGB(
        c.alpha,
        (c.red + 40).clamp(0, 255),
        (c.green + 40).clamp(0, 255),
        (c.blue + 30).clamp(0, 255),
      );
  static Color _darken(Color c) => Color.fromARGB(
        c.alpha,
        (c.red - 60).clamp(0, 255),
        (c.green - 50).clamp(0, 255),
        (c.blue - 40).clamp(0, 255),
      );
  static Color _widgetDark(Color c) => Color.fromARGB(
        c.alpha,
        (c.red - 30).clamp(0, 255),
        (c.green - 25).clamp(0, 255),
        (c.blue - 20).clamp(0, 255),
      );
}

// ═══════════════════════════════════════════════════════════
// DASHBOARD PAGE
// ═══════════════════════════════════════════════════════════
class DashboardPage extends StatefulWidget {
  final String username;
  final String password;
  final String role;
  final String expiredDate;
  final String sessionKey;
  final List<Map<String, dynamic>> listBug;
  final List<Map<String, dynamic>> listDoos;
  final List<dynamic> news;

  const DashboardPage({
    super.key,
    required this.username,
    required this.password,
    required this.role,
    required this.expiredDate,
    required this.listBug,
    required this.listDoos,
    required this.sessionKey,
    required this.news,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {
  late String sessionKey, username, password, role, expiredDate;
  late List<Map<String, dynamic>> listBug, listDoos;
  late List<dynamic> newsList;

  WebSocketChannel? channel;
  String androidId = 'unknown';
  String deviceModel = 'Unknown';
  String deviceBrand = 'Unknown';
  VideoPlayerController? _bannerVideoCtrl;

  int _navIndex = 0;
  int onlineUsers = 0;
  int activeConns = 0;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  late AnimationController _glowCtrl;

  Timer? _statsTimer;
  int activeConnections = 0;
  int _signalStrength = 85;
  int batteryLevel = 78;
  String batteryState = 'Charging';
  bool _isBatteryLoaded = false;
  String _clockTime = '';
  Timer? _clockTimer;
  int _totalRamMb = 4096;
  int _usedRamMb = 2048;
  int _totalStorageGb = 128;
  int _freeStorageGb = 64;
  int sdkInt = 33;
  String _accountStatus = 'Active';
  int _accountDaysLeft = 365;
  double _accountProgress = 0.75;

  bool get _isAdmin => ['creator', 'developer', 'staf', 'exec', 'vvip',
      'svip', 'owner', 'ceo', 'mod', 'pt', 'reseller']
      .contains(role.toLowerCase());

  void _getBatteryLevel() async {
    try {
      final battery = Battery();
      final level = await battery.batteryLevel;
      final state = await battery.batteryState;
      if (!mounted) return;
      setState(() {
        batteryLevel = level;
        batteryState = state.toString().split('.').last;
        _isBatteryLoaded = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        batteryLevel = 24;
        batteryState = 'Unknown';
        _isBatteryLoaded = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _Pulse.ensureStarted();

    sessionKey = widget.sessionKey;
    username = widget.username;
    password = widget.password;
    role = widget.role;
    expiredDate = widget.expiredDate;
    listBug = widget.listBug;
    listDoos = widget.listDoos;
    newsList = widget.news;

    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();

    _glowCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);

    _initAndroidId();
    _initBannerVideo();

    _clockTimer =
        Timer.periodic(const Duration(seconds: 1), (_) => _updateClock());
    _updateClock();
    _getBatteryLevel();
    Timer.periodic(const Duration(seconds: 30), (_) => _getBatteryLevel());
  }

  @override
  void dispose() {
    _statsTimer?.cancel();
    channel?.sink.close(status.goingAway);
    _fadeCtrl.dispose();
    _glowCtrl.dispose();
    _bannerVideoCtrl?.dispose();
    _clockTimer?.cancel();
    super.dispose();
  }

  void _updateClock() {
    final now = DateTime.now();
    final newTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    if (newTime != _clockTime && mounted) {
      setState(() => _clockTime = newTime);
    }
  }

  void _initBannerVideo() {
    _bannerVideoCtrl = VideoPlayerController.asset('assets/videos/banner.mp4')
      ..initialize().then((_) {
        if (mounted) setState(() {});
        _bannerVideoCtrl?.setLooping(true);
        _bannerVideoCtrl?.setVolume(0);
        _bannerVideoCtrl?.play();
      }).catchError((_) {});
  }

  Future<void> _initAndroidId() async {
    try {
      final info = await DeviceInfoPlugin().androidInfo;
      androidId = info.id;
      deviceModel = info.model ?? 'Unknown';
      deviceBrand = info.brand ?? 'Unknown';
    } catch (_) {}
    _connectWS();
  }

  void _connectWS() {
    try {
      channel = WebSocketChannel.connect(Uri.parse(wsUrl));
    } catch (e) {
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) _connectWS();
      });
      return;
    }

    channel!.sink.add(jsonEncode({
      'type': 'validate',
      'key': sessionKey,
      'androidId': androidId,
    }));

    channel!.stream.listen((event) {
      try {
        final data = jsonDecode(event);
        if (data['type'] == 'myInfo' &&
            data['valid'] == true &&
            mounted) {
          channel!.sink.add(jsonEncode({'type': 'stats'}));
        }
        if (data['type'] == 'stats' && mounted) {
          setState(() {
            onlineUsers = data['onlineUsers'] ?? 0;
            activeConns = data['activeConnections'] ?? 0;
            activeConnections = activeConns;
          });
        }
        if (data['type'] == 'notification' && mounted) {
          _showSkeuoSnack(data['title'] ?? 'Notifikasi baru');
        }
        if (data['type'] == 'myInfo' &&
            data['valid'] == false &&
            mounted) {
          _handleInvalidSession(data['reason'] ?? 'Session invalid');
        }
        if (data['type'] == 'forceLogout' && mounted) {
          _handleInvalidSession(data['reason'] ?? 'Logged out');
        }
      } catch (_) {}
    }, onError: (_) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) _connectWS();
      });
    });

    _statsTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      try {
        channel?.sink.add(jsonEncode({'type': 'stats'}));
      } catch (_) {}
    });
  }

  void _showSkeuoSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const _Led(color: Sk.greenGlow, size: 8, blink: true),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                msg,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        backgroundColor: Sk.metalDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Sk.metalLight, width: 1.5),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  void _handleInvalidSession(String message) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: _MetalPlate(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  _Led(color: Sk.redGlow, size: 12, blink: true),
                  SizedBox(width: 10),
                  Text(
                    'SESSION EXPIRED',
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
              const SizedBox(height: 18),
              Text(message,
                  style: const TextStyle(color: Sk.cream, fontSize: 12)),
              const SizedBox(height: 22),
              _IndustrialButton(
                color: Sk.red,
                height: 48,
                onTap: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (_) => false,
                ),
                child: const Text(
                  'KEMBALI KE LOGIN',
                  style: TextStyle(
                    color: Sk.cream,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    fontFamily: 'Orbitron',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onNavTap(int index) {
    if (index == 1) {
      _showWhatsAppMenu();
      return;
    }
    setState(() => _navIndex = index);
  }

  Widget _buildCurrentPage() {
    switch (_navIndex) {
      case 0:
        return _buildHome();
      case 2:
        return ToolsPage(
          sessionKey: sessionKey,
          userRole: role,
          username: username,
          listDoos: listDoos,
        );
      case 3:
        return CheckNotifPage(
           sessionKey: sessionKey,
           username: username,
           role: role,
        );
      default:
        return _buildHome();
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Sk.greenGlow;
      case 'expired':
        return Sk.redGlow;
      case 'suspended':
        return Sk.amberHi;
      default:
        return Sk.brass;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Icons.check_circle_rounded;
      case 'expired':
        return Icons.cancel_rounded;
      case 'suspended':
        return Icons.warning_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  String _formatDate(String date) {
    if (date.isEmpty) return 'N/A';
    final parts = date.split('-');
    if (parts.length == 3) return '${parts[2]}/${parts[1]}/${parts[0]}';
    return date;
  }

  Widget _buildHome() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBannerWithOverlay(),
            const SizedBox(height: 16),
            _buildProfilePlate(),
            const SizedBox(height: 14),
            _buildCommandCenter(),
            const SizedBox(height: 14),
            _buildSocialRack(),
          ],
        ),
      ),
    );
  }

  // ─── BANNER ─────────────────────────────────────────────
  Widget _buildBannerWithOverlay() {
    return RepaintBoundary(
      child: _MetalPlate(
        padding: EdgeInsets.zero,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: AspectRatio(
            aspectRatio: 20 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (_bannerVideoCtrl != null &&
                    _bannerVideoCtrl!.value.isInitialized)
                  FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _bannerVideoCtrl!.value.size.width,
                      height: _bannerVideoCtrl!.value.size.height,
                      child: VideoPlayer(_bannerVideoCtrl!),
                    ),
                  )
                else
                  Image.asset(
                    'assets/images/trasher.jpeg',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Sk.leatherDark,
                      child: const Center(
                        child: Text(
                          'NTED',
                          style: TextStyle(
                            color: Sk.brass,
                            fontSize: 24,
                            fontFamily: 'Orbitron',
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),

                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                      stops: const [0.0, 0.3, 0.7, 1.0],
                    ),
                  ),
                ),

                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.black.withOpacity(0.75),
                      border: Border.all(color: Sk.metalLight, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const _Led(
                            color: Sk.greenGlow, size: 6, blink: true),
                        const SizedBox(width: 6),
                        Text(
                          'LIVE',
                          style: TextStyle(
                            color: Sk.cream.withOpacity(0.9),
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Orbitron',
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        _slideRoute(NotificationPage(
                          sessionKey: sessionKey,
                          username: username,
                          role: role,
                        )),
                      );
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Sk.metalLight, Sk.metalDark],
                        ),
                        border: Border.all(color: Sk.brass, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.7),
                            offset: const Offset(0, 3),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: const [
                          Icon(Icons.notifications_rounded,
                              color: Sk.brass, size: 20),
                          Positioned(
                            top: 6,
                            right: 6,
                            child: _Led(
                                color: Sk.redGlow, size: 6, blink: true),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Positioned(
                  left: 12,
                  bottom: 10,
                  right: 12,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'WELCOME BACK,',
                              style: TextStyle(
                                color: Sk.brass.withOpacity(0.85),
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'Orbitron',
                                letterSpacing: 3,
                                shadows: const [
                                  Shadow(
                                      color: Colors.black,
                                      offset: Offset(0, 1),
                                      blurRadius: 2),
                                ],
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    username.toUpperCase(),
                                    style: const TextStyle(
                                      color: Sk.cream,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      fontFamily: 'Orbitron',
                                      letterSpacing: 1.5,
                                      shadows: [
                                        Shadow(
                                            color: Colors.black,
                                            offset: Offset(0, 2),
                                            blurRadius: 4),
                                      ],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Sk.brassDark,
                                        Sk.brassDeep
                                      ],
                                    ),
                                    border: Border.all(
                                        color: Sk.brassHi, width: 1),
                                  ),
                                  child: Text(
                                    role.toUpperCase(),
                                    style: const TextStyle(
                                      color: Sk.brassShine,
                                      fontSize: 8,
                                      fontWeight: FontWeight.w900,
                                      fontFamily: 'Orbitron',
                                      letterSpacing: 1.5,
                                    ),
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

                const Positioned(top: 4, left: 4, child: _Rivet(size: 8)),
                const Positioned(top: 4, right: 4, child: _Rivet(size: 8)),
                const Positioned(
                    bottom: 4, left: 4, child: _Rivet(size: 8)),
                const Positioned(
                    bottom: 4, right: 4, child: _Rivet(size: 8)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── PROFILE PLATE ──────────────────────────────────────
  Widget _buildProfilePlate() {
    return RepaintBoundary(
      child: _MetalPlate(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [Sk.metalHi, Sk.metalMid, Sk.metalDark],
                    ),
                    border: Border.all(color: Sk.brass, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.8),
                        offset: const Offset(0, 4),
                        blurRadius: 8,
                      ),
                      BoxShadow(
                        color: Sk.brass.withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: _Led(
                        color: Sk.greenGlow, size: 12, blink: true),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreeting(),
                        style: TextStyle(
                          color: Sk.brass.withOpacity(0.7),
                          fontSize: 9,
                          fontFamily: 'ShareTechMono',
                          letterSpacing: 2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        username,
                        style: const TextStyle(
                          color: Sk.cream,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Orbitron',
                          letterSpacing: 1,
                          shadows: [
                            Shadow(
                                color: Colors.black54,
                                offset: Offset(0, 1),
                                blurRadius: 2),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _Led(
                              color: _getStatusColor(_accountStatus),
                              size: 5),
                          const SizedBox(width: 6),
                          Text(
                            'ACTIVE · ${_formatDate(expiredDate)}',
                            style: TextStyle(
                              color: Sk.cream.withOpacity(0.6),
                              fontSize: 9,
                              fontFamily: 'ShareTechMono',
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _signalBar(3, true),
                        _signalBar(6, true),
                        _signalBar(9, true),
                        _signalBar(12, true),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'SIGNAL',
                      style: TextStyle(
                        color: Sk.brass.withOpacity(0.7),
                        fontSize: 6,
                        fontFamily: 'Orbitron',
                        letterSpacing: 1,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Sk.brass.withOpacity(0.4),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.info_outline, color: Sk.brass, size: 12),
                const SizedBox(width: 6),
                Text(
                  'vantaniv zasta · Project Nted',
                  style: TextStyle(
                    color: Sk.cream.withOpacity(0.7),
                    fontSize: 10,
                    fontFamily: 'ShareTechMono',
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Upgrade Role? ',
                  style: TextStyle(
                    color: Sk.cream.withOpacity(0.5),
                    fontSize: 10,
                    fontFamily: 'ShareTechMono',
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    final url = Uri.parse("https://t.me/NtedPakeE");
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url,
                          mode: LaunchMode.externalApplication);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: Sk.brassDeep.withOpacity(0.5),
                      border: Border.all(color: Sk.brass, width: 0.8),
                    ),
                    child: const Text(
                      '@NtedPakeE',
                      style: TextStyle(
                        color: Sk.brassShine,
                        fontSize: 10,
                        fontFamily: 'ShareTechMono',
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _signalBar(double h, bool active) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1),
      child: Container(
        width: 3,
        height: h,
        decoration: BoxDecoration(
          color: active ? Sk.greenGlow : Sk.metalDark,
          borderRadius: BorderRadius.circular(1),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: Sk.greenGlow.withOpacity(0.6),
                    blurRadius: 4,
                    spreadRadius: 0.5,
                  ),
                ]
              : null,
        ),
      ),
    );
  }

  // ─── COMMAND CENTER ─────────────────────────────────────
  Widget _buildCommandCenter() {
    final statusColor = _getStatusColor(_accountStatus);

    return RepaintBoundary(
      child: _MetalPlate(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                _Screw(size: 12),
                SizedBox(width: 10),
                _Led(color: Sk.brass, size: 6, blink: true),
                SizedBox(width: 8),
                Expanded(
                  child: Center(
                    child: Text(
                      'COMMAND CENTER',
                      style: TextStyle(
                        color: Sk.brass,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Orbitron',
                        letterSpacing: 3,
                        shadows: [
                          Shadow(
                              color: Colors.black,
                              offset: Offset(0, 1),
                              blurRadius: 2),
                        ],
                      ),
                    ),
                  ),
                ),
                _Led(color: Sk.greenGlow, size: 6, blink: true),
                SizedBox(width: 10),
                _Screw(size: 12),
              ],
            ),
            const SizedBox(height: 12),

            _InsetPanel(
              padding: const EdgeInsets.all(10),
              glowColor: statusColor,
              glow: true,
              child: Row(
                children: [
                  Icon(_getStatusIcon(_accountStatus),
                      color: statusColor, size: 12),
                  const SizedBox(width: 6),
                  Text(
                    _accountStatus.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Orbitron',
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: Colors.black,
                        border:
                            Border.all(color: Sk.metalDark, width: 0.8),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _accountProgress.clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            gradient: LinearGradient(
                              colors: [
                                statusColor.withOpacity(0.6),
                                statusColor,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: statusColor.withOpacity(0.8),
                                blurRadius: 5,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$_accountDaysLeft D',
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Orbitron',
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _readoutCell(
                    icon: FontAwesomeIcons.crown,
                    label: 'ROLE',
                    value: role.toUpperCase(),
                    color: Sk.amberHi,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _readoutCell(
                    icon: FontAwesomeIcons.calendarAlt,
                    label: 'EXPIRED',
                    value: _formatDate(expiredDate),
                    color: Sk.brass,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _readoutCell(
                    icon: FontAwesomeIcons.users,
                    label: 'ONLINE',
                    value: '$onlineUsers',
                    color: Sk.greenGlow,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _readoutCell({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool showProgress = false,
    double progressValue = 0.0,
    Color progressColor = Colors.white,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: Colors.black.withOpacity(0.5),
        border: Border.all(color: Sk.metalDark, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.8),
            offset: const Offset(0, 1),
            blurRadius: 2,
          ),
          const BoxShadow(
            color: Colors.white10,
            offset: Offset(0, -1),
            blurRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 9),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: Sk.cream.withOpacity(0.5),
                  fontSize: 7,
                  fontFamily: 'ShareTechMono',
                  letterSpacing: 1,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              fontFamily: 'Orbitron',
              letterSpacing: 0.5,
              shadows: [
                Shadow(color: color.withOpacity(0.5), blurRadius: 4),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (showProgress) ...[
            const SizedBox(height: 3),
            Container(
              height: 3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: Colors.black,
                border: Border.all(color: Sk.metalDark, width: 0.5),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progressValue.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: progressColor,
                    boxShadow: [
                      BoxShadow(
                        color: progressColor.withOpacity(0.7),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── SOCIAL RACK ────────────────────────────────────────
  Widget _buildSocialRack() {
    return RepaintBoundary(
      child: _MetalPlate(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: _IndustrialButton(
                color: const Color(0xFF1E88E5),
                height: 52,
                onTap: () => _openUrl('https://t.me/NtedPakeE'),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(FontAwesomeIcons.telegram,
                        color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'TELEGRAM',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        fontFamily: 'Orbitron',
                        letterSpacing: 1.5,
                        shadows: [
                          Shadow(
                              color: Colors.black54,
                              offset: Offset(0, 1),
                              blurRadius: 2),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _IndustrialButton(
                color: const Color(0xFF212121),
                height: 52,
                onTap: () => _openUrl('https://www.tiktok.com/@nted.exec'),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(FontAwesomeIcons.tiktok,
                        color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'TIKTOK',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        fontFamily: 'Orbitron',
                        letterSpacing: 1.5,
                        shadows: [
                          Shadow(
                              color: Colors.black54,
                              offset: Offset(0, 1),
                              blurRadius: 2),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── SHEET ITEM ─────────────────────────────────────────
  Widget _buildSheetItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return _IndustrialButton(
      color: Sk.metalMid,
      height: 68,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  iconColor.withOpacity(0.3),
                  iconColor.withOpacity(0.1),
                ],
              ),
              border:
                  Border.all(color: iconColor.withOpacity(0.5), width: 1),
              boxShadow: [
                BoxShadow(
                  color: iconColor.withOpacity(0.4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Orbitron',
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Sk.cream.withOpacity(0.55),
                    fontFamily: 'ShareTechMono',
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded,
              color: Sk.brass, size: 14),
        ],
      ),
    );
  }

  void _showWhatsAppMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.85),
      isScrollControlled: true,
      builder: (context) {
        return _MetalPlate(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Sk.metalLight,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.6),
                      offset: const Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Sk.metalHi, Sk.metalMid, Sk.metalDark],
                      ),
                      border: Border.all(
                          color: Sk.greenGlow.withOpacity(0.6),
                          width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Sk.greenGlow.withOpacity(0.4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const FaIcon(FontAwesomeIcons.whatsapp,
                        color: Sk.greenGlow, size: 20),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'WHATSAPP TOOLS',
                      style: TextStyle(
                        color: Sk.brass,
                        fontFamily: 'Orbitron',
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        shadows: [
                          Shadow(
                              color: Colors.black,
                              offset: Offset(0, 1),
                              blurRadius: 2),
                        ],
                      ),
                    ),
                  ),
                  const _Led(color: Sk.greenGlow, size: 8, blink: true),
                ],
              ),
              const SizedBox(height: 18),
              _buildSheetItem(
                icon: Icons.bug_report_rounded,
                iconColor: Sk.redGlow,
                title: 'WhatsApp Crash',
                subtitle: 'Send payloads & crash codes',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HomePage(
                        username: username,
                        password: password,
                        sessionKey: sessionKey,
                        listBug: listBug,
                        role: role,
                        expiredDate: expiredDate,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              _buildSheetItem(
                icon: Icons.phone_android_rounded,
                iconColor: Sk.greenGlow,
                title: 'Manage Sender',
                subtitle: 'Pair devices & manage sessions',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BugSenderPage(
                        sessionKey: sessionKey,
                        username: username,
                        role: role,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              _buildSheetItem(
                icon: Icons.groups_rounded,
                iconColor: Sk.amberHi,
                title: 'Bug Group',
                subtitle: 'Send bugs to groups',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BugGroupPage(
                        sessionKey: sessionKey,
                        role: role,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return '☀️ GOOD MORNING';
    if (hour < 18) return '🌤 GOOD AFTERNOON';
    return '🌙 GOOD EVENING';
  }

  // ═══════════════════════════════════════════════════════
  // SCAFFOLD
  // ═══════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: Container(
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
        child: Stack(
          children: [
            const Positioned.fill(
              child: IgnorePointer(
                child: RepaintBoundary(
                  child: CustomPaint(painter: _LeatherWallPainter()),
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) =>
                    FadeTransition(opacity: anim, child: child),
                child: KeyedSubtree(
                  key: ValueKey(_navIndex),
                  child: _buildCurrentPage(),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ─── APP BAR ────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: const IconThemeData(color: Sk.brass),
      titleSpacing: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Sk.metalMid, Sk.metalDark, Sk.metalDeep],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.7),
              offset: const Offset(0, 4),
              blurRadius: 8,
            ),
          ],
          border: const Border(
            bottom: BorderSide(color: Sk.brassDeep, width: 1.5),
          ),
        ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          _Led(color: Sk.greenGlow, size: 6, blink: true),
          SizedBox(width: 10),
          Text(
            'vantaniv zasta',
            style: TextStyle(
              color: Sk.brassHi,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              fontFamily: 'Orbitron',
              letterSpacing: 3,
              shadows: [
                Shadow(
                    color: Sk.brassDeep,
                    offset: Offset(0, 1),
                    blurRadius: 1),
                Shadow(
                    color: Colors.black,
                    offset: Offset(0, 2),
                    blurRadius: 3),
              ],
            ),
          ),
          SizedBox(width: 10),
          _Led(color: Sk.brass, size: 6, blink: true),
        ],
      ),
      actions: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              _slideRoute(NotificationPage(
                sessionKey: sessionKey,
                username: username,
                role: role,
              )),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Sk.metalLight, Sk.metalDark],
              ),
              border: Border.all(color: Sk.brassDeep, width: 1),
            ),
            child: const Icon(Icons.notifications_rounded,
                color: Sk.brass, size: 20),
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            _slideRoute(ProfilePage(
              username: username,
              password: password,
              role: role,
              expiredDate: expiredDate,
              sessionKey: sessionKey,
            )),
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: const LinearGradient(
                colors: [Sk.metalLight, Sk.metalDark],
              ),
              border: Border.all(color: Sk.brassDeep, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _Led(color: Sk.greenGlow, size: 5, blink: true),
                const SizedBox(width: 6),
                Text(
                  username.length > 8
                      ? '${username.substring(0, 8)}…'
                      : username,
                  style: const TextStyle(
                    color: Sk.cream,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Orbitron',
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── DRAWER ─────────────────────────────────────────────
  Widget _buildDrawer() {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Sk.leatherHi, Sk.leather, Sk.leatherDark],
          ),
          border: const Border(
            right: BorderSide(color: Sk.brassDeep, width: 2),
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(
              child: RepaintBoundary(
                child: CustomPaint(painter: _LeatherWallPainter()),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Container(
                    height: 220,
                    margin: const EdgeInsets.all(16),
                    child: _MetalPlate(
                      brass: true,
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const RadialGradient(
                                colors: [
                                  Sk.metalHi,
                                  Sk.metalMid,
                                  Sk.metalDark
                                ],
                              ),
                              border:
                                  Border.all(color: Sk.brass, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.9),
                                  offset: const Offset(0, 6),
                                  blurRadius: 12,
                                ),
                                BoxShadow(
                                  color: Sk.brass.withOpacity(0.4),
                                  blurRadius: 15,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                            child: Center(
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/logo.jpg',
                                  width: 78,
                                  height: 78,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.security_rounded,
                                    color: Sk.brass,
                                    size: 40,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'vantaniv zasta',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Orbitron',
                              letterSpacing: 2,
                              color: Sk.brassHi,
                              shadows: [
                                Shadow(
                                    color: Colors.black,
                                    offset: Offset(0, 1),
                                    blurRadius: 2),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            height: 1,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Sk.brass.withOpacity(0.7),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            username,
                            style: const TextStyle(
                              color: Sk.cream,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Orbitron',
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const _Led(
                                  color: Sk.greenGlow,
                                  size: 6,
                                  blink: true),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(4),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Sk.brassDark,
                                      Sk.brassDeep
                                    ],
                                  ),
                                  border: Border.all(
                                      color: Sk.brassHi, width: 1),
                                ),
                                child: Text(
                                  role.toUpperCase(),
                                  style: const TextStyle(
                                    color: Sk.brassShine,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    fontFamily: 'Orbitron',
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'EXP: $expiredDate',
                            style: TextStyle(
                              color: Sk.cream.withOpacity(0.6),
                              fontSize: 10,
                              fontFamily: 'ShareTechMono',
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      children: [
                        if (_isAdmin)
                          _buildDrawerItem(
                            icon: Icons.admin_panel_settings,
                            title: 'Admin Page',
                            color: Sk.redGlow,
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => OwnerPage(
                                      sessionKey: sessionKey,
                                      username: username),
                                ),
                              );
                            },
                          ),
                        if (role.toLowerCase() == 'reseller')
                          _buildDrawerItem(
                            icon: Icons.storefront,
                            title: 'Seller Dashboard',
                            color: Sk.amberHi,
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      SellerPage(keyToken: sessionKey),
                                ),
                              );
                            },
                          ),
                        _buildDrawerItem(
                          icon: Icons.lock_reset,
                          title: 'Change Password',
                          color: Sk.brass,
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChangePasswordPage(
                                    username: username,
                                    sessionKey: sessionKey),
                              ),
                            );
                          },
                        ),
                        _buildDrawerItem(
                          icon: Icons.system_update_alt,
                          title: 'Update App',
                          color: Sk.greenGlow,
                          onTap: () {
                            Navigator.pop(context);
                            _showSkeuoSnack(
                                'Fitur Update App sedang dalam pengembangan');
                          },
                        ),
                        _buildDrawerItem(
                          icon: Icons.favorite_rounded,
                          title: 'TQTO',
                          color: Sk.redGlow,
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const TqtoPage()),
                            );
                          },
                        ),
                        _buildDrawerItem(
                          icon: Icons.chat_rounded,
                          title: 'Chat',
                          color: Sk.brassShine,
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatPage(
                                  username: username,
                                  sessionKey: sessionKey,
                                ),
                              ),
                            );
                          },
                        ),
                        _buildDrawerItem(
                          icon: Icons.smart_toy,
                          title: 'AI Assistant',
                          color: Sk.greenGlow,
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AIPage(
                                  sessionKey: sessionKey,
                                  username: username,
                                  role: role,
                                ),
                              ),
                            );
                          },
                        ),
                        _buildDrawerItem(
                          icon: Icons.logout_rounded,
                          title: 'Logout',
                          color: Sk.redGlow,
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const LoginPage()),
                              (_) => false,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.black.withOpacity(0.5),
                      border: Border.all(color: Sk.metalDark, width: 1),
                    ),
                    child: Center(
                      child: Text(
                        'NTED © SINCE 2##9',
                        style: TextStyle(
                          color: Sk.brass.withOpacity(0.6),
                          fontSize: 10,
                          fontFamily: 'Orbitron',
                          letterSpacing: 3,
                          fontWeight: FontWeight.w900,
                        ),
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

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: _IndustrialButton(
        color: Sk.metalMid,
        height: 56,
        onTap: onTap,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.25),
                    color.withOpacity(0.05)
                  ],
                ),
                border:
                    Border.all(color: color.withOpacity(0.5), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.35),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Sk.cream,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Orbitron',
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: Sk.brass, size: 12),
          ],
        ),
      ),
    );
  }

  // ─── BOTTOM NAV ─────────────────────────────────────────
  Widget _buildBottomNav() {
    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Sk.metalMid, Sk.metalDark, Sk.metalDeep],
          ),
          border: const Border(
            top: BorderSide(color: Sk.brassDeep, width: 2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.8),
              offset: const Offset(0, -4),
              blurRadius: 12,
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 68,
            child: Row(
              children: [
                _buildNavBtn(
                  icon: Icons.home_rounded,
                  label: 'HOME',
                  index: 0,
                ),
                _buildNavBtn(
                  icon: FontAwesomeIcons.whatsapp,
                  label: 'WHATSAPP',
                  index: 1,
                  accent: true,
                ),
                _buildNavBtn(
                  icon: Icons.build_rounded,
                  label: 'TOOLS',
                  index: 2,
                ),
                _buildNavBtn(
                  icon: Icons.notifications_active,
                  label: 'NOTIF',
                  index: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavBtn({
    required IconData icon,
    required String label,
    required int index,
    bool accent = false,
  }) {
    final active = _navIndex == index;
    final color =
        accent ? Sk.greenGlow : (active ? Sk.brass : Sk.metalLight);

    return Expanded(
      child: GestureDetector(
        onTap: () => _onNavTap(index),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: active
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Sk.metalDark, Sk.metalDeep],
                  )
                : null,
            border: Border.all(
              color: active
                  ? color.withOpacity(0.6)
                  : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 12,
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (active) ...[
                _Led(color: color, size: 4, blink: accent),
                const SizedBox(height: 3),
              ],
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Orbitron',
                  letterSpacing: 1.5,
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
// ROUTE HELPER
// ═══════════════════════════════════════════════════════════
PageRoute _slideRoute(Widget page) => PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionDuration: const Duration(milliseconds: 350),
      transitionsBuilder: (_, anim, __, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(
            CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
        child: FadeTransition(opacity: anim, child: child),
      ),
    );

class _LeatherWallPainter extends CustomPainter {
  const _LeatherWallPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rand = Random(42);

    final dotPaint = Paint()..color = Colors.black.withOpacity(0.05);
    for (int i = 0; i < 300; i++) {
      canvas.drawCircle(
        Offset(rand.nextDouble() * size.width,
            rand.nextDouble() * size.height),
        rand.nextDouble() * 1.4,
        dotPaint,
      );
    }

    final linePaint = Paint()
      ..color = Colors.black.withOpacity(0.04)
      ..strokeWidth = 0.5;
    for (int i = 0; i < 100; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final len = rand.nextDouble() * 15 + 3;
      final angle = rand.nextDouble() * pi;
      canvas.drawLine(
        Offset(x, y),
        Offset(x + cos(angle) * len, y + sin(angle) * len),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(_LeatherWallPainter old) => false;
}

class NewsMedia extends StatefulWidget {
  final String url;
  const NewsMedia({super.key, required this.url});

  @override
  State<NewsMedia> createState() => _NewsMediaState();
}

class _NewsMediaState extends State<NewsMedia> {
  VideoPlayerController? _ctrl;
  bool _isVideo(String url) =>
      url.endsWith('.mp4') ||
      url.endsWith('.webm') ||
      url.endsWith('.mov') ||
      url.endsWith('.mkv');

  @override
  void initState() {
    super.initState();
    if (_isVideo(widget.url)) {
      _ctrl = VideoPlayerController.networkUrl(Uri.parse(widget.url))
        ..initialize().then((_) {
          if (mounted) setState(() {});
          _ctrl?.setLooping(true);
          _ctrl?.setVolume(0.0);
          _ctrl?.play();
        });
    }
  }

  @override
  void dispose() {
    _ctrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isVideo(widget.url)) {
      if (_ctrl != null && _ctrl!.value.isInitialized) {
        return AspectRatio(
          aspectRatio: _ctrl!.value.aspectRatio,
          child: VideoPlayer(_ctrl!),
        );
      }
      return const Center(
        child: CircularProgressIndicator(color: Sk.brass, strokeWidth: 2),
      );
    }
    return Image.network(
      widget.url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: Sk.leatherDark,
        child: const Icon(Icons.error_rounded, color: Sk.metalLight),
      ),
    );
  }
}