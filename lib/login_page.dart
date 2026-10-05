import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'video_splash_page.dart';
import 'cakun.dart';
import 'api_config.dart';

class _C {
  static const bg          = Color(0xFF1A1A1A);
  static const metalDark   = Color(0xFF2B2B2B);
  static const metalMid    = Color(0xFF3D3D3D);
  static const metalLight  = Color(0xFF5A5A5A);
  static const metalShine  = Color(0xFF7A7A7A);
  static const bloodRed    = Color(0xFF8B0000);
  static const bloodRedHi  = Color(0xFFCC1010);
  static const bloodRedLo  = Color(0xFF4A0000);
  static const goldDark    = Color(0xFF8B6914);
  static const gold        = Color(0xFFD4AF37);
  static const goldHi      = Color(0xFFF5DEB3);
  static const cream       = Color(0xFFF5EFE0);
  static const paper       = Color(0xFFEDE4D3);
  static const paperDark   = Color(0xFFD4C8B0);
  static const black       = Color(0xFF0A0A0A);
  static const offWhite    = Color(0xFFF5F0E8);
  static const muted       = Color(0xFF8A8A8A);
  static const leather     = Color(0xFF3B2820);
  static const leatherDark = Color(0xFF1F1510);
  static const leatherHi   = Color(0xFF5A3D30);
  static const felt        = Color(0xFF4A1414);
  static const feltDark    = Color(0xFF2A0808);
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with TickerProviderStateMixin {
  final userController = TextEditingController();
  final passController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;
  bool _obscurePass = true;
  String? androidId;

  late AnimationController _entryCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _shakeCtrl;
  late AnimationController _ledCtrl;
  late AnimationController _gaugeCtrl;

  late Animation<double> _logoFade;
  late Animation<double> _logoScale;
  late Animation<double> _formFade;
  late Animation<Offset> _formSlide;
  late Animation<double> _shake;
  late Animation<double> _ledBlink;
  late Animation<double> _gaugeSweep;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initAutoLogin();
  }

  void _setupAnimations() {
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..repeat();

    _ledCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _gaugeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );
    _formFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.4, 0.9, curve: Curves.easeOut),
      ),
    );
    _formSlide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.35, 0.95, curve: Curves.easeOutBack),
    ));
    _shake = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.linear),
    );
    _ledBlink = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _ledCtrl, curve: Curves.easeInOut),
    );
    _gaugeSweep = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _gaugeCtrl, curve: Curves.linear),
    );
  }

  Future<void> _initAutoLogin() async {
    androidId = await _getAndroidId();
    final prefs = await SharedPreferences.getInstance();
    final u = prefs.getString("username");
    final p = prefs.getString("password");
    final k = prefs.getString("key");

    if (u != null && p != null && k != null) {
      try {
        final res = await http.get(Uri.parse(
            "$baseUrl/myInfo?username=$u&password=$p&androidId=$androidId&key=$k"));
        final data = jsonDecode(res.body);
        if (data['valid'] == true) _goToSplash(_buildArgs(data, u, p));
      } catch (_) {}
    }
  }

  Future<String> _getAndroidId() async {
    final android = await DeviceInfoPlugin().androidInfo;
    return android.id ?? "unknown_device";
  }

  Map<String, dynamic> _buildArgs(dynamic data, String u, String p) => {
        "username": u,
        "password": p,
        "role": data['role'],
        "key": data['key'],
        "expiredDate": data['expiredDate'],
        "listBug": (data['listBug'] as List? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList(),
        "listDoos": (data['listDDoS'] as List? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList(),
        "news": (data['news'] as List? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList(),
      };

  void _goToSplash(Map<String, dynamic> args) {
    if (!mounted) return;
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => VideoSplashPage(dashboardArgs: args)));
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final u = userController.text.trim();
    final p = passController.text.trim();
    setState(() => isLoading = true);

    try {
      final res = await http.post(
        Uri.parse("$baseUrl/validate"),
        body: {"username": u, "password": p, "androidId": androidId ?? "unknown"},
      );
      final data = jsonDecode(res.body);

      if (data['expired'] == true) {
        _showAlert("ACCESS EXPIRED",
            "Masa akses Anda telah habis.\nSilakan perpanjang akses.",
            showContact: true);
      } else if (data['valid'] != true) {
        final msg = (data['message'] ?? "").toLowerCase();
        _showAlert(
          "LOGIN GAGAL",
          msg.contains("perangkat") || msg.contains("device")
              ? "Akun ini sedang login di perangkat lain."
              : "Username atau password salah.",
        );
      } else {
        final prefs = await SharedPreferences.getInstance();
        prefs.setString("username", u);
        prefs.setString("password", p);
        prefs.setString("key", data['key']);
        _goToSplash(_buildArgs(data, u, p));
      }
    } catch (_) {
      _showAlert("CONNECTION ERROR", "Gagal terhubung ke server.");
    }
    if (mounted) setState(() => isLoading = false);
  }

  void _showAlert(String title, String message, {bool showContact = false}) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_C.metalMid, _C.metalDark],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.7),
                offset: const Offset(0, 12),
                blurRadius: 30,
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.08),
                offset: const Offset(-2, -2),
                blurRadius: 6,
              ),
            ],
          ),
          child: Container(
            margin: const EdgeInsets.all(4),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_C.metalDark, _C.black],
              ),
              border: Border.all(
                color: _C.metalLight.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      colors: [_C.bloodRedHi, _C.bloodRed, _C.bloodRedLo],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _C.bloodRed.withOpacity(0.6),
                        blurRadius: 15,
                        spreadRadius: 1,
                      ),
                      const BoxShadow(
                        color: Colors.white24,
                        offset: Offset(0, -1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _LedIndicator(
                        color: _C.gold,
                        size: 8,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        title,
                        style: const TextStyle(
                          color: _C.offWhite,
                          fontFamily: 'Orbitron',
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          letterSpacing: 2,
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              offset: Offset(0, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _C.offWhite,
                    fontSize: 13,
                    height: 1.6,
                    fontFamily: 'ShareTechMono',
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    if (showContact) ...[
                      Expanded(
                        child: _SkeuoButton(
                          label: "CONTACT",
                          onTap: () => launchUrl(
                            Uri.parse("https://t.me/NtedPakeE"),
                            mode: LaunchMode.externalApplication,
                          ),
                          isPrimary: false,
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: _SkeuoButton(
                        label: "TUTUP",
                        onTap: () => Navigator.pop(context),
                        isPrimary: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _pulseCtrl.dispose();
    _shakeCtrl.dispose();
    _ledCtrl.dispose();
    _gaugeCtrl.dispose();
    userController.dispose();
    passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final h = size.height;

    return Scaffold(
      backgroundColor: _C.bg,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // ── Background image ────────────────────────────
          Positioned.fill(
            child: Image.asset(
              'assets/images/login.png',
              fit: BoxFit.cover,
            ),
          ),

          // ── Dark vignette overlay ────────────────────────
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.0,
                  colors: [
                    Colors.black.withOpacity(0.5),
                    Colors.black.withOpacity(0.85),
                    Colors.black.withOpacity(0.95),
                  ],
                ),
              ),
            ),
          ),

          // ── Leather texture overlay ──────────────────────
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _LeatherTexturePainter(),
              ),
            ),
          ),

          // ── Main content ─────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    SizedBox(height: h * 0.02),

                    // ── Logo plaque ──────────────────────────
                    FadeTransition(
                      opacity: _logoFade,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: _SkeuoLogoPlaque(),
                      ),
                    ),

                    SizedBox(height: h * 0.03),

                    // ── Control panel ────────────────────────
                    FadeTransition(
                      opacity: _formFade,
                      child: SlideTransition(
                        position: _formSlide,
                        child: _SkeuoControlPanel(
                          formKey: _formKey,
                          userController: userController,
                          passController: passController,
                          obscurePass: _obscurePass,
                          onTogglePass: () => setState(
                              () => _obscurePass = !_obscurePass),
                          isLoading: isLoading,
                          onLogin: _login,
                          shake: _shake,
                          ledBlink: _ledBlink,
                          gaugeSweep: _gaugeSweep,
                          // ✅ AUTO NAVIGATE KE CAKUN PAGE
                          onBuyAccount: () => Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) => const CakunPage(),
                              transitionDuration:
                                  const Duration(milliseconds: 350),
                              transitionsBuilder: (_, anim, __, child) =>
                                  SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(1, 0),
                                  end: Offset.zero,
                                ).animate(CurvedAnimation(
                                  parent: anim,
                                  curve: Curves.easeOutCubic,
                                )),
                                child:
                                    FadeTransition(opacity: anim, child: child),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: h * 0.03),

                    // ── Footer ───────────────────────────────
                    FadeTransition(
                      opacity: _formFade,
                      child: _SkeuoFooter(),
                    ),

                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// SKEUOMORPHIC LOGO PLAQUE
// ════════════════════════════════════════════════════════════

class _SkeuoLogoPlaque extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_C.metalShine, _C.metalMid, _C.metalDark],
          stops: [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.8),
            offset: const Offset(0, 15),
            blurRadius: 30,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.15),
            offset: const Offset(-2, -2),
            blurRadius: 6,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            offset: const Offset(2, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_C.felt, _C.feltDark],
          ),
          border: Border.all(
            color: _C.metalDark.withOpacity(0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.6),
              offset: const Offset(0, 4),
              blurRadius: 8,
              spreadRadius: -2,
            ),
          ],
        ),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [
                        _C.metalShine,
                        _C.metalLight,
                        _C.metalMid,
                        _C.metalDark,
                      ],
                      stops: [0.0, 0.4, 0.7, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.8),
                        offset: const Offset(0, 8),
                        blurRadius: 16,
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.2),
                        offset: const Offset(-3, -3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [_C.black, _C.metalDark],
                      ),
                      border: Border.all(
                        color: _C.gold.withOpacity(0.6),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.9),
                          offset: const Offset(2, 2),
                          blurRadius: 4,
                          spreadRadius: -1,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                ..._buildRivets(radius: 62),
              ],
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _C.metalLight,
                    _C.metalMid,
                    _C.metalDark,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.7),
                    offset: const Offset(0, 3),
                    blurRadius: 6,
                  ),
                  const BoxShadow(
                    color: Colors.white12,
                    offset: Offset(0, -1),
                    blurRadius: 2,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Transform.translate(
                    offset: const Offset(1, 1),
                    child: Text(
                      "vantaniv zasta",
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
                        letterSpacing: 3,
                        color: Colors.white.withOpacity(0.9),
                        height: 1,
                      ),
                    ),
                  ),
                  const Text(
                    "vantaniv zasta",
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                      letterSpacing: 3,
                      color: _C.metalDark,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: _C.black,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.8),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                    spreadRadius: -1,
                  ),
                  const BoxShadow(
                    color: Colors.white10,
                    offset: Offset(0, -1),
                    blurRadius: 1,
                  ),
                ],
                border: Border.all(
                  color: _C.metalDark,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _LedIndicator(color: _C.bloodRedHi, size: 7),
                  const SizedBox(width: 8),
                  Text(
                    "SYSTEM ONLINE",
                    style: TextStyle(
                      color: _C.gold.withOpacity(0.9),
                      fontFamily: 'ShareTechMono',
                      fontSize: 10,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _LedIndicator(color: _C.gold, size: 7),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRivets({required double radius}) {
    final rivets = <Widget>[];
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi * 2 / 8) - math.pi / 2;
      final x = math.cos(angle) * radius;
      final y = math.sin(angle) * radius;
      rivets.add(
        Positioned(
          left: 55 + x - 6,
          top: 55 + y - 6,
          child: _Rivet(size: 12),
        ),
      );
    }
    return rivets;
  }
}

// ════════════════════════════════════════════════════════════
// SKEUOMORPHIC CONTROL PANEL
// ════════════════════════════════════════════════════════════

class _SkeuoControlPanel extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController userController;
  final TextEditingController passController;
  final bool obscurePass;
  final VoidCallback onTogglePass;
  final bool isLoading;
  final VoidCallback onLogin;
  final Animation<double> shake;
  final Animation<double> ledBlink;
  final Animation<double> gaugeSweep;
  final VoidCallback onBuyAccount;

  const _SkeuoControlPanel({
    required this.formKey,
    required this.userController,
    required this.passController,
    required this.obscurePass,
    required this.onTogglePass,
    required this.isLoading,
    required this.onLogin,
    required this.shake,
    required this.ledBlink,
    required this.gaugeSweep,
    required this.onBuyAccount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_C.metalShine, _C.metalMid, _C.metalDark],
          stops: [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.8),
            offset: const Offset(0, 15),
            blurRadius: 30,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.15),
            offset: const Offset(-2, -2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_C.leather, _C.leatherDark],
          ),
          border: Border.all(
            color: Colors.black.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PanelHeader(ledBlink: ledBlink),
              const SizedBox(height: 20),

              _SkeuoField(
                controller: userController,
                hint: "USERNAME",
                icon: Icons.person,
                validator: (v) =>
                    (v == null || v.trim().isEmpty)
                        ? "Username wajib diisi!"
                        : null,
              ),
              const SizedBox(height: 14),

              _SkeuoField(
                controller: passController,
                hint: "PASSWORD",
                icon: Icons.lock,
                obscure: obscurePass,
                validator: (v) =>
                    (v == null || v.trim().isEmpty)
                        ? "Password wajib diisi!"
                        : null,
                suffix: _SkeuoIconButton(
                  icon: obscurePass
                      ? Icons.visibility_off
                      : Icons.visibility,
                  onTap: onTogglePass,
                ),
              ),
              const SizedBox(height: 20),

              _GaugeMeter(sweep: gaugeSweep),
              const SizedBox(height: 20),

              _SkeuoLoginButton(
                isLoading: isLoading,
                onTap: onLogin,
                shake: shake,
              ),
              const SizedBox(height: 18),

              _SkeuoBuyButton(onTap: onBuyAccount),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// PANEL HEADER
// ════════════════════════════════════════════════════════════

class _PanelHeader extends StatelessWidget {
  final Animation<double> ledBlink;
  const _PanelHeader({required this.ledBlink});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_C.metalMid, _C.metalDark],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            offset: const Offset(0, 3),
            blurRadius: 6,
            spreadRadius: -1,
          ),
          const BoxShadow(
            color: Colors.white24,
            offset: Offset(0, -1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          const _Screw(size: 14),
          const SizedBox(width: 10),
          AnimatedBuilder(
            animation: ledBlink,
            builder: (_, __) => _LedIndicator(
              color: _C.bloodRedHi,
              size: 10,
              opacity: ledBlink.value,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Center(
              child: Text(
                "AUTHENTICATION",
                style: TextStyle(
                  color: _C.gold.withOpacity(0.85),
                  fontFamily: 'Orbitron',
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  letterSpacing: 3,
                  shadows: const [
                    Shadow(
                      color: Colors.black,
                      offset: Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          AnimatedBuilder(
            animation: ledBlink,
            builder: (_, __) => _LedIndicator(
              color: _C.gold,
              size: 10,
              opacity: 1.0 - ledBlink.value * 0.5,
            ),
          ),
          const SizedBox(width: 10),
          const _Screw(size: 14),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// SKEUOMORPHIC FIELD
// ════════════════════════════════════════════════════════════

class _SkeuoField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;
  final String? Function(String?)? validator;

  const _SkeuoField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.suffix,
    this.validator,
  });

  @override
  State<_SkeuoField> createState() => _SkeuoFieldState();
}

class _SkeuoFieldState extends State<_SkeuoField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _focused
              ? [const Color(0xFF0D0D0D), const Color(0xFF1A1A1A)]
              : [const Color(0xFF0A0A0A), const Color(0xFF151515)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.9),
            offset: const Offset(0, 2),
            blurRadius: 4,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.06),
            offset: const Offset(0, -1),
            blurRadius: 1,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            offset: const Offset(0, 1),
            blurRadius: 0,
            spreadRadius: 1,
          ),
          if (_focused)
            BoxShadow(
              color: _C.bloodRedHi.withOpacity(0.5),
              blurRadius: 12,
              spreadRadius: 0,
            ),
        ],
        border: Border.all(
          color: _focused ? _C.bloodRed : _C.metalDark,
          width: 1.5,
        ),
      ),
      child: Focus(
        onFocusChange: (v) => setState(() => _focused = v),
        child: TextFormField(
          controller: widget.controller,
          obscureText: widget.obscure,
          style: const TextStyle(
            color: _C.offWhite,
            fontSize: 14,
            fontFamily: 'ShareTechMono',
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
          cursorColor: _C.gold,
          cursorWidth: 2,
          cursorRadius: const Radius.circular(2),
          validator: widget.validator,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(
              color: _C.muted.withOpacity(0.6),
              fontSize: 12,
              fontFamily: 'ShareTechMono',
              fontWeight: FontWeight.w700,
              letterSpacing: 3,
            ),
            prefixIcon: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _focused
                      ? [_C.bloodRedHi, _C.bloodRedLo]
                      : [_C.metalLight, _C.metalDark],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.7),
                    offset: const Offset(0, 2),
                    blurRadius: 3,
                  ),
                  const BoxShadow(
                    color: Colors.white24,
                    offset: Offset(0, -1),
                    blurRadius: 1,
                  ),
                ],
              ),
              child: Icon(
                widget.icon,
                color: _focused ? _C.gold : _C.offWhite,
                size: 18,
              ),
            ),
            prefixIconConstraints:
                const BoxConstraints(minWidth: 46, minHeight: 46),
            suffixIcon: widget.suffix != null
                ? Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: widget.suffix,
                  )
                : null,
            suffixIconConstraints: const BoxConstraints(),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 18),
            errorStyle: const TextStyle(
              color: _C.bloodRedHi,
              fontSize: 10,
              fontFamily: 'ShareTechMono',
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// SKEUO ICON BUTTON
// ════════════════════════════════════════════════════════════

class _SkeuoIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _SkeuoIconButton({required this.icon, required this.onTap});

  @override
  State<_SkeuoIconButton> createState() => _SkeuoIconButtonState();
}

class _SkeuoIconButtonState extends State<_SkeuoIconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            begin: _pressed ? Alignment.bottomRight : Alignment.topLeft,
            end: _pressed ? Alignment.topLeft : Alignment.bottomRight,
            colors: _pressed
                ? [_C.metalDark, _C.metalMid]
                : [_C.metalLight, _C.metalDark],
          ),
          boxShadow: _pressed
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.8),
                    offset: const Offset(0, 1),
                    blurRadius: 3,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.7),
                    offset: const Offset(0, 3),
                    blurRadius: 5,
                  ),
                  const BoxShadow(
                    color: Colors.white24,
                    offset: Offset(0, -1),
                    blurRadius: 1,
                  ),
                ],
        ),
        child: Icon(
          widget.icon,
          color: _C.gold,
          size: 16,
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// GAUGE METER
// ════════════════════════════════════════════════════════════

class _GaugeMeter extends StatelessWidget {
  final Animation<double> sweep;
  const _GaugeMeter({required this.sweep});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xFF0A0A0A),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.9),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
          const BoxShadow(
            color: Colors.white12,
            offset: Offset(0, -1),
            blurRadius: 1,
          ),
        ],
        border: Border.all(color: _C.metalDark, width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                "SECURITY",
                style: TextStyle(
                  color: _C.muted.withOpacity(0.7),
                  fontFamily: 'ShareTechMono',
                  fontSize: 9,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                "ENCRYPTED",
                style: TextStyle(
                  color: _C.gold.withOpacity(0.8),
                  fontFamily: 'ShareTechMono',
                  fontSize: 9,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: sweep,
            builder: (_, __) => CustomPaint(
              size: const Size(double.infinity, 8),
              painter: _GaugePainter(progress: sweep.value),
            ),
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double progress;
  _GaugePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final trackRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final trackRRect = RRect.fromRectAndRadius(
      trackRect,
      const Radius.circular(4),
    );
    canvas.drawRRect(
      trackRRect,
      Paint()..color = const Color(0xFF000000),
    );
    canvas.drawRRect(
      trackRRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.white10,
    );

    final fillWidth = size.width * (0.3 + 0.7 * progress);
    final fillRect = Rect.fromLTWH(0, 0, fillWidth, size.height);
    final fillRRect = RRect.fromRectAndRadius(
      fillRect,
      const Radius.circular(4),
    );
    final fillPaint = Paint()
      ..shader = const LinearGradient(
        colors: [_C.bloodRedLo, _C.bloodRed, _C.bloodRedHi, _C.gold],
      ).createShader(fillRect);
    canvas.drawRRect(fillRRect, fillPaint);

    final shineRect = Rect.fromLTWH(0, 0, fillWidth, size.height * 0.4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(shineRect, const Radius.circular(4)),
      Paint()..color = Colors.white.withOpacity(0.15),
    );
  }

  @override
  bool shouldRepaint(_GaugePainter old) => old.progress != progress;
}

// ════════════════════════════════════════════════════════════
// SKEUOMORPHIC LOGIN BUTTON
// ════════════════════════════════════════════════════════════

class _SkeuoLoginButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onTap;
  final Animation<double> shake;
  const _SkeuoLoginButton({
    required this.isLoading,
    required this.onTap,
    required this.shake,
  });

  @override
  State<_SkeuoLoginButton> createState() => _SkeuoLoginButtonState();
}

class _SkeuoLoginButtonState extends State<_SkeuoLoginButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.shake,
      builder: (_, __) => Transform.translate(
        offset: Offset(
            widget.isLoading ? widget.shake.value * 2 : 0, 0),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) {
            setState(() => _pressed = false);
            if (!widget.isLoading) widget.onTap();
          },
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            height: 62,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                begin: _pressed
                    ? Alignment.bottomCenter
                    : Alignment.topCenter,
                end: _pressed
                    ? Alignment.topCenter
                    : Alignment.bottomCenter,
                colors: widget.isLoading
                    ? [_C.metalMid, _C.metalDark]
                    : [
                        const Color(0xFFFF3030),
                        _C.bloodRedHi,
                        _C.bloodRed,
                        _C.bloodRedLo,
                      ],
                stops: widget.isLoading
                    ? null
                    : const [0.0, 0.3, 0.6, 1.0],
              ),
              boxShadow: _pressed
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.8),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: _C.bloodRedHi.withOpacity(0.4),
                        offset: const Offset(0, 8),
                        blurRadius: 20,
                        spreadRadius: -2,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.8),
                        offset: const Offset(0, 6),
                        blurRadius: 10,
                      ),
                      const BoxShadow(
                        color: Colors.white30,
                        offset: Offset(0, -2),
                        blurRadius: 3,
                      ),
                      const BoxShadow(
                        color: Colors.black45,
                        offset: Offset(0, 2),
                        blurRadius: 4,
                        spreadRadius: -1,
                      ),
                    ],
              border: Border.all(
                color: _C.bloodRedLo,
                width: 2,
              ),
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
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0.4),
                          Colors.white.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ),
                widget.isLoading
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor:
                                  const AlwaysStoppedAnimation<Color>(
                                      _C.gold),
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Text(
                            "AUTHENTICATING...",
                            style: TextStyle(
                              color: _C.offWhite,
                              fontFamily: 'Orbitron',
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                              letterSpacing: 3,
                              shadows: [
                                Shadow(
                                  color: Colors.black,
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.power_settings_new,
                            color: _C.offWhite,
                            size: 22,
                            shadows: [
                              Shadow(
                                color: Colors.black54,
                                offset: Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                          const SizedBox(width: 14),
                          const Text(
                            "LOGIN",
                            style: TextStyle(
                              color: _C.offWhite,
                              fontFamily: 'Orbitron',
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                              letterSpacing: 8,
                              shadows: [
                                Shadow(
                                  color: Colors.black87,
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                ),
                                Shadow(
                                  color: _C.gold,
                                  offset: Offset(0, -1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _C.black.withOpacity(0.3),
                              border: Border.all(
                                color: _C.gold.withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.arrow_forward,
                              color: _C.gold,
                              size: 14,
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// SKEUO CREATE ACCOUNTS BUTTON (navigasi ke CakunPage)
// ════════════════════════════════════════════════════════════

class _SkeuoBuyButton extends StatefulWidget {
  final VoidCallback onTap;
  const _SkeuoBuyButton({required this.onTap});

  @override
  State<_SkeuoBuyButton> createState() => _SkeuoBuyButtonState();
}

class _SkeuoBuyButtonState extends State<_SkeuoBuyButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: _pressed
                ? Alignment.bottomCenter
                : Alignment.topCenter,
            end: _pressed
                ? Alignment.topCenter
                : Alignment.bottomCenter,
            colors: const [
              _C.goldHi,
              _C.gold,
              _C.goldDark,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
          boxShadow: _pressed
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.8),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ]
              : [
                  BoxShadow(
                    color: _C.gold.withOpacity(0.4),
                    offset: const Offset(0, 6),
                    blurRadius: 15,
                    spreadRadius: -2,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.7),
                    offset: const Offset(0, 4),
                    blurRadius: 8,
                  ),
                  const BoxShadow(
                    color: Colors.white54,
                    offset: Offset(0, -1),
                    blurRadius: 2,
                  ),
                ],
          border: Border.all(
            color: _C.goldDark,
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
                height: 10,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.5),
                      Colors.white.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.person_add_alt_1_rounded,
                  color: _C.leatherDark,
                  size: 20,
                ),
                const SizedBox(width: 10),
                const Text(
                  "CREATE ACCOUNTS",
                  style: TextStyle(
                    color: _C.leatherDark,
                    fontSize: 10,
                    fontFamily: 'ShareTechMono',
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    gradient: const LinearGradient(
                      colors: [_C.bloodRed, _C.bloodRedLo],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        offset: const Offset(0, 2),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                  child: const Text(
                    "Free",
                    style: TextStyle(
                      color: _C.offWhite,
                      fontSize: 10,
                      fontFamily: 'Orbitron',
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
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
}

// ════════════════════════════════════════════════════════════
// SMALL SKEUO BUTTON (dialog)
// ════════════════════════════════════════════════════════════

class _SkeuoButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;
  const _SkeuoButton({
    required this.label,
    required this.onTap,
    required this.isPrimary,
  });

  @override
  State<_SkeuoButton> createState() => _SkeuoButtonState();
}

class _SkeuoButtonState extends State<_SkeuoButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        height: 46,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            begin: _pressed
                ? Alignment.bottomCenter
                : Alignment.topCenter,
            end: _pressed
                ? Alignment.topCenter
                : Alignment.bottomCenter,
            colors: widget.isPrimary
                ? const [
                    const Color(0xFFCC1010),
                    _C.bloodRed,
                    _C.bloodRedLo,
                  ]
                : const [_C.metalLight, _C.metalMid, _C.metalDark],
          ),
          boxShadow: _pressed
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.8),
                    offset: const Offset(0, 2),
                    blurRadius: 3,
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
        ),
        child: Center(
          child: Text(
            widget.label,
            style: const TextStyle(
              color: _C.offWhite,
              fontFamily: 'Orbitron',
              fontWeight: FontWeight.w900,
              fontSize: 12,
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
    );
  }
}

// ════════════════════════════════════════════════════════════
// SMALL SKEUO COMPONENTS
// ════════════════════════════════════════════════════════════

class _LedIndicator extends StatelessWidget {
  final Color color;
  final double size;
  final double opacity;
  const _LedIndicator({
    required this.color,
    this.size = 8,
    this.opacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(opacity),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.8 * opacity),
            blurRadius: size,
            spreadRadius: size * 0.3,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.6),
            offset: Offset(-size * 0.2, -size * 0.2),
            blurRadius: size * 0.3,
          ),
        ],
      ),
    );
  }
}

class _Screw extends StatelessWidget {
  final double size;
  const _Screw({this.size = 12});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [_C.metalShine, _C.metalMid, _C.metalDark],
          stops: [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.8),
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
      child: Center(
        child: Transform.rotate(
          angle: math.pi / 4,
          child: Container(
            width: size * 0.6,
            height: 1.5,
            color: _C.black.withOpacity(0.7),
          ),
        ),
      ),
    );
  }
}

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
          center: Alignment(-0.3, -0.3),
          colors: [_C.goldHi, _C.gold, _C.goldDark],
          stops: [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.9),
            offset: const Offset(1, 2),
            blurRadius: 3,
          ),
          const BoxShadow(
            color: Colors.white38,
            offset: Offset(-1, -1),
            blurRadius: 1,
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// FOOTER
// ════════════════════════════════════════════════════════════

class _SkeuoFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_C.metalMid, _C.metalDark],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.7),
            offset: const Offset(0, 6),
            blurRadius: 12,
          ),
          const BoxShadow(
            color: Colors.white12,
            offset: Offset(0, -1),
            blurRadius: 2,
          ),
        ],
        border: Border.all(
          color: _C.metalLight.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LedIndicator(color: _C.bloodRedHi, size: 6),
              const SizedBox(width: 8),
              Text(
                "SECURE • FAST • REBEL",
                style: TextStyle(
                  color: _C.gold.withOpacity(0.8),
                  fontFamily: 'ShareTechMono',
                  fontSize: 10,
                  letterSpacing: 3,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              _LedIndicator(color: _C.gold, size: 6),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            "WhatsApp Crasher And Tools",
            style: TextStyle(
              color: _C.offWhite.withOpacity(0.6),
              fontSize: 11,
              fontStyle: FontStyle.italic,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              gradient: const LinearGradient(
                colors: [_C.bloodRedHi, _C.bloodRedLo],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  offset: const Offset(0, 2),
                  blurRadius: 3,
                ),
              ],
            ),
            child: const Text(
              "© LATEST 2025",
              style: TextStyle(
                color: _C.offWhite,
                fontSize: 9,
                fontFamily: 'ShareTechMono',
                letterSpacing: 3,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// LEATHER TEXTURE PAINTER
// ════════════════════════════════════════════════════════════

class _LeatherTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rand = math.Random(42);
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.06)
      ..strokeWidth = 1;

    for (int i = 0; i < 800; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final r = rand.nextDouble() * 1.5;
      canvas.drawCircle(Offset(x, y), r, paint);
    }

    final linePaint = Paint()
      ..color = Colors.black.withOpacity(0.04)
      ..strokeWidth = 0.5;
    for (int i = 0; i < 200; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final len = rand.nextDouble() * 15 + 3;
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