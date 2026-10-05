import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_config.dart';

// ═══════════════════════════════════════════════════════════
// SOFT SKEUOMORPHISM PALETTE
// ═══════════════════════════════════════════════════════════
class Sk {
  // Metal
  static const Color metalDeep   = Color(0xFF15130F);
  static const Color metalDark   = Color(0xFF252220);
  static const Color metalMid    = Color(0xFF3A3630);
  static const Color metalLight  = Color(0xFF55504A);
  static const Color metalHi     = Color(0xFF7A7368);

  // Brass
  static const Color brassDeep   = Color(0xFF5C4410);
  static const Color brassDark   = Color(0xFF8B6914);
  static const Color brass       = Color(0xFFC9A961);
  static const Color brassHi     = Color(0xFFE8C87F);
  static const Color brassShine  = Color(0xFFF5DEB3);

  // Red (primary)
  static const Color redDeep     = Color(0xFF3D0808);
  static const Color red         = Color(0xFF8B1818);
  static const Color redBright   = Color(0xFFC41E1E);
  static const Color redGlow     = Color(0xFFFF3030);
  static const Color redHi       = Color(0xFFFF4D47);

  // Green
  static const Color greenDeep   = Color(0xFF0A2818);
  static const Color green       = Color(0xFF2E7D32);
  static const Color greenHi     = Color(0xFF4CAF50);
  static const Color greenGlow   = Color(0xFF00E676);

  // Amber
  static const Color amberDeep   = Color(0xFF4A2800);
  static const Color amber       = Color(0xFFCC7A00);
  static const Color amberHi     = Color(0xFFFFB300);

  // Surface
  static const Color leather     = Color(0xFF2A1F18);
  static const Color leatherDark = Color(0xFF1A1310);
  static const Color leatherHi   = Color(0xFF3D2E22);
  static const Color cream       = Color(0xFFE8DFC8);
  static const Color ink         = Color(0xFF2A2520);
}

// ═══════════════════════════════════════════════════════════
// REUSABLE COMPONENTS
// ═══════════════════════════════════════════════════════════

/// Static LED
class _Led extends StatelessWidget {
  final Color color;
  final double size;
  const _Led({required this.color, this.size = 7});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.7),
            blurRadius: size,
            spreadRadius: 0.5,
          ),
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: size * 2,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}

/// Rivet
class _Rivet extends StatelessWidget {
  final double size;
  const _Rivet({this.size = 5});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Sk.brassHi, Sk.brassDeep],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            offset: const Offset(1, 1),
            blurRadius: 1,
          ),
        ],
      ),
    );
  }
}

/// Screw
class _Screw extends StatelessWidget {
  final double size;
  const _Screw({this.size = 10});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Sk.metalHi, Sk.metalDark],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            offset: const Offset(1, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: size * 0.6,
          height: 1.2,
          color: Colors.black.withOpacity(0.7),
        ),
      ),
    );
  }
}

/// Soft metal panel
class _SoftPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final Color? accent;
  const _SoftPanel({
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.radius = 12,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = accent ?? Sk.metalLight;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Sk.leather, Sk.leatherDark],
        ),
        border: Border.all(color: accentColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.55),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.06),
            offset: const Offset(-1, -1),
            blurRadius: 2,
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Inset panel
class _SoftInset extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const _SoftInset({
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 12),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFF0F0D0B),
        border: Border.all(color: Sk.metalDark, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.8),
            offset: const Offset(0, 1),
            blurRadius: 2,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.04),
            offset: const Offset(0, -1),
            blurRadius: 1,
          ),
        ],
      ),
      child: child,
    );
  }
}

// ═══════════════════════════════════════════════════════════
// CHANGE PASSWORD PAGE
// ═══════════════════════════════════════════════════════════
class ChangePasswordPage extends StatefulWidget {
  final String username;
  final String sessionKey;

  const ChangePasswordPage({
    super.key,
    required this.username,
    required this.sessionKey,
  });

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final oldPassCtrl = TextEditingController();
  final newPassCtrl = TextEditingController();
  final confirmPassCtrl = TextEditingController();

  bool isLoading = false;
  bool _isObscureOld = true;
  bool _isObscureNew = true;
  bool _isObscureConfirm = true;

  @override
  void dispose() {
    oldPassCtrl.dispose();
    newPassCtrl.dispose();
    confirmPassCtrl.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════
  // API
  // ═══════════════════════════════════════════════════════════
  Future<void> _changePassword() async {
    HapticFeedback.lightImpact();
    final oldPass = oldPassCtrl.text.trim();
    final newPass = newPassCtrl.text.trim();
    final confirmPass = confirmPassCtrl.text.trim();

    if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      _showMessage("Semua field harus diisi");
      return;
    }

    if (newPass.length < 6) {
      _showMessage("Password minimal 6 karakter");
      return;
    }

    if (newPass != confirmPass) {
      _showMessage("Password baru tidak sama dengan konfirmasi");
      return;
    }

    if (newPass == oldPass) {
      _showMessage("Password baru tidak boleh sama dengan yang lama");
      return;
    }

    setState(() => isLoading = true);

    try {
      final res = await http.post(
        Uri.parse("$baseUrl/changepass"),
        body: {
          "username": widget.username,
          "oldPass": oldPass,
          "newPass": newPass,
          "sessionKey": widget.sessionKey,
        },
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(res.body);

      if (data['success'] == true) {
        _showMessage("Password berhasil diubah", isSuccess: true);
        oldPassCtrl.clear();
        newPassCtrl.clear();
        confirmPassCtrl.clear();
      } else {
        _showMessage(data['message'] ?? "Gagal mengubah password");
      }
    } catch (e) {
      _showMessage("Koneksi error. Periksa jaringan.");
    }

    if (mounted) setState(() => isLoading = false);
  }

  void _showMessage(String msg, {bool isSuccess = false}) {
    HapticFeedback.mediumImpact();
    final color = isSuccess ? Sk.greenHi : Sk.amberHi;
    final icon = isSuccess
        ? Icons.check_circle_rounded
        : Icons.warning_amber_rounded;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: _SoftPanel(
          padding: const EdgeInsets.all(20),
          accent: color.withOpacity(0.6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon housing
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.15),
                  border:
                      Border.all(color: color.withOpacity(0.6), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                isSuccess ? 'BERHASIL' : 'PERHATIAN',
                style: TextStyle(
                  color: color,
                  fontFamily: 'Orbitron',
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  letterSpacing: 2,
                  shadows: const [
                    Shadow(
                      color: Colors.black,
                      offset: Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Message
              Text(
                msg,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Sk.cream.withOpacity(0.7),
                  fontFamily: 'ShareTechMono',
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 22),

              // OK button
              _MetalButton(
                label: 'TUTUP',
                color: color,
                height: 44,
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
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
      backgroundColor: const Color(0xFF1A1310),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2A1F18),
              Color(0xFF1A1310),
              Color(0xFF0F0A08),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),

                      // Lock icon housing
                      _buildLockIcon(),
                      const SizedBox(height: 16),

                      // Title
                      const Text(
                        'SECURITY UPDATE',
                        style: TextStyle(
                          color: Sk.brass,
                          fontFamily: 'Orbitron',
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          letterSpacing: 3,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              offset: Offset(0, 1),
                              blurRadius: 2,
                            ),
                            Shadow(
                              color: Sk.redGlow,
                              offset: Offset(0, 0),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Divider
                      Container(
                        width: 60,
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Sk.redBright,
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Subtitle
                      Text(
                        'Ganti password akun kamu',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Sk.cream.withOpacity(0.55),
                          fontFamily: 'ShareTechMono',
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                          letterSpacing: 0.5,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Section header
                      _buildSectionHeader('CREDENTIALS'),
                      const SizedBox(height: 10),

                      // Account info panel
                      _SoftPanel(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        accent: Sk.redBright.withOpacity(0.4),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Sk.redDeep,
                                border: Border.all(
                                    color: Sk.redBright.withOpacity(0.6),
                                    width: 1),
                              ),
                              child: const Icon(Icons.person_rounded,
                                  color: Sk.redGlow, size: 12),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ACCOUNT',
                                    style: TextStyle(
                                      color: Sk.cream.withOpacity(0.45),
                                      fontSize: 8,
                                      fontFamily: 'Orbitron',
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    widget.username,
                                    style: const TextStyle(
                                      color: Sk.cream,
                                      fontSize: 12,
                                      fontFamily: 'ShareTechMono',
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const _Led(color: Sk.greenGlow, size: 8),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Password fields panel
                      _SoftPanel(
                        padding: const EdgeInsets.all(14),
                        accent: Sk.redBright.withOpacity(0.4),
                        child: Column(
                          children: [
                            _PasswordField(
                              label: 'CURRENT PASSWORD',
                              controller: oldPassCtrl,
                              obscure: _isObscureOld,
                              onToggle: () => setState(
                                  () => _isObscureOld = !_isObscureOld),
                              icon: Icons.lock_clock_rounded,
                            ),
                            const SizedBox(height: 14),
                            _PasswordField(
                              label: 'NEW PASSWORD',
                              controller: newPassCtrl,
                              obscure: _isObscureNew,
                              onToggle: () => setState(
                                  () => _isObscureNew = !_isObscureNew),
                              icon: Icons.lock_open_rounded,
                            ),
                            const SizedBox(height: 14),
                            _PasswordField(
                              label: 'CONFIRM PASSWORD',
                              controller: confirmPassCtrl,
                              obscure: _isObscureConfirm,
                              onToggle: () => setState(
                                  () => _isObscureConfirm = !_isObscureConfirm),
                              icon: Icons.lock_reset_rounded,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Update button
                      _MetalButton(
                        label: isLoading
                            ? 'PROCESSING...'
                            : 'UPDATE PASSWORD',
                        color: Sk.redBright,
                        height: 56,
                        icon: isLoading ? null : Icons.security_rounded,
                        loading: isLoading,
                        onTap: isLoading ? null : _changePassword,
                      ),

                      const SizedBox(height: 16),

                      // Security tips panel
                      _buildSecurityTips(),

                      const SizedBox(height: 20),
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

  // ═══════════════════════════════════════════════════════════
  // TOP BAR
  // ═══════════════════════════════════════════════════════════
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Sk.metalMid, Sk.metalDark],
          ),
          border: Border.all(
            color: Sk.redBright.withOpacity(0.4),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.6),
              offset: const Offset(0, 3),
              blurRadius: 6,
            ),
            BoxShadow(
              color: Sk.redGlow.withOpacity(0.15),
              blurRadius: 12,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              const _Screw(size: 12),
              const SizedBox(width: 8),
              _MetalIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(width: 10),
              const _Led(color: Sk.redGlow, size: 8),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'CHANGE PASSWORD',
                      style: TextStyle(
                        color: Sk.redBright,
                        fontFamily: 'Orbitron',
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 2,
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            offset: Offset(0, 1),
                            blurRadius: 2,
                          ),
                          Shadow(
                            color: Sk.redGlow,
                            offset: Offset(0, 0),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'Secure credential update',
                      style: TextStyle(
                        color: Sk.cream.withOpacity(0.55),
                        fontSize: 9,
                        fontFamily: 'ShareTechMono',
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const _Screw(size: 12),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // SECTION HEADER
  // ═══════════════════════════════════════════════════════════
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          const _Led(color: Sk.brass, size: 6),
          const SizedBox(width: 10),
          Text(
            '// $title',
            style: const TextStyle(
              color: Sk.brass,
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
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Sk.redBright.withOpacity(0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // LOCK ICON
  // ═══════════════════════════════════════════════════════════
  Widget _buildLockIcon() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer ring
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Sk.metalLight, Sk.metalDark],
            ),
            border: Border.all(
              color: Sk.redBright.withOpacity(0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Sk.redGlow.withOpacity(0.2),
                blurRadius: 15,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.6),
                offset: const Offset(0, 4),
                blurRadius: 8,
              ),
            ],
          ),
        ),
        // Inner ring
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Sk.leatherDark,
            border: Border.all(
              color: Sk.redBright.withOpacity(0.6),
              width: 1.2,
            ),
          ),
          child: const Icon(
            Icons.lock_reset_rounded,
            color: Sk.redBright,
            size: 32,
          ),
        ),
        // Top LED
        Positioned(
          top: 0,
          right: 0,
          child: _Led(color: Sk.redGlow, size: 10),
        ),
        // Bottom rivet
        const Positioned(
          bottom: 2,
          child: _Rivet(size: 6),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // SECURITY TIPS PANEL
  // ═══════════════════════════════════════════════════════════
  Widget _buildSecurityTips() {
    return _SoftPanel(
      padding: const EdgeInsets.all(12),
      accent: Sk.amberHi.withOpacity(0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Sk.amberDeep,
                  border: Border.all(
                      color: Sk.amberHi.withOpacity(0.5), width: 1),
                ),
                child: const Icon(Icons.info_outline_rounded,
                    color: Sk.amberHi, size: 11),
              ),
              const SizedBox(width: 8),
              const Text(
                'SECURITY TIPS',
                style: TextStyle(
                  color: Sk.amberHi,
                  fontFamily: 'Orbitron',
                  fontWeight: FontWeight.w900,
                  fontSize: 9,
                  letterSpacing: 1.5,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      offset: Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _tipRow('Minimal 8 karakter'),
          _tipRow('Kombinasi huruf & angka'),
          _tipRow('Tambahkan karakter spesial'),
          _tipRow('Jangan pakai data pribadi'),
        ],
      ),
    );
  }

  Widget _tipRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Sk.amberHi,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Sk.cream.withOpacity(0.6),
                fontFamily: 'ShareTechMono',
                fontWeight: FontWeight.w700,
                fontSize: 9,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// PASSWORD FIELD (Skeuomorphic)
// ═══════════════════════════════════════════════════════════
class _PasswordField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;
  final IconData icon;

  const _PasswordField({
    required this.label,
    required this.controller,
    required this.obscure,
    required this.onToggle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: TextStyle(
              color: Sk.cream.withOpacity(0.5),
              fontSize: 8,
              fontFamily: 'Orbitron',
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
        ),
        // Field
        _SoftInset(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Sk.redDeep,
                  border: Border.all(
                      color: Sk.redBright.withOpacity(0.6), width: 1),
                ),
                child: Icon(icon, color: Sk.redGlow, size: 13),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscure,
                  style: const TextStyle(
                    color: Sk.cream,
                    fontSize: 13,
                    fontFamily: 'ShareTechMono',
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                  cursorColor: Sk.brass,
                  cursorWidth: 2,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              GestureDetector(
                onTap: onToggle,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: Sk.metalMid.withOpacity(0.5),
                    border: Border.all(color: Sk.metalDark, width: 1),
                  ),
                  child: Icon(
                    obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Sk.brass,
                    size: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
// METAL BUTTON
// ═══════════════════════════════════════════════════════════
class _MetalButton extends StatefulWidget {
  final String label;
  final Color color;
  final double height;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool loading;
  const _MetalButton({
    required this.label,
    required this.color,
    required this.height,
    required this.onTap,
    this.icon,
    this.loading = false,
  });

  @override
  State<_MetalButton> createState() => _MetalButtonState();
}

class _MetalButtonState extends State<_MetalButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onTap == null;

    return GestureDetector(
      onTapDown: disabled
          ? null
          : (_) => setState(() => _pressed = true),
      onTapUp: disabled
          ? null
          : (_) {
              setState(() => _pressed = false);
              widget.onTap?.call();
            },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        height: widget.height,
        width: double.infinity,
        transform: Matrix4.translationValues(
          _pressed ? 1.5 : 0,
          _pressed ? 1.5 : 0,
          0,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: disabled
                ? [Sk.metalMid, Sk.metalDark]
                : [
                    widget.color.withOpacity(0.9),
                    widget.color,
                    widget.color.withOpacity(0.7),
                  ],
          ),
          border: Border.all(
            color: disabled
                ? Sk.metalDark
                : widget.color.withOpacity(0.9),
            width: 1.5,
          ),
          boxShadow: _pressed || disabled
              ? []
              : [
                  BoxShadow(
                    color: widget.color.withOpacity(0.35),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    offset: const Offset(0, 3),
                    blurRadius: 5,
                  ),
                ],
        ),
        child: Stack(
          children: [
            // Corner rivets
            const Positioned(top: 4, left: 4, child: _Rivet(size: 5)),
            const Positioned(top: 4, right: 4, child: _Rivet(size: 5)),
            const Positioned(bottom: 4, left: 4, child: _Rivet(size: 5)),
            const Positioned(bottom: 4, right: 4, child: _Rivet(size: 5)),

            Center(
              child: widget.loading
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Sk.cream,
                            strokeWidth: 2,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          widget.label,
                          style: const TextStyle(
                            color: Sk.cream,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Orbitron',
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon, color: Sk.cream, size: 15),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          widget.label,
                          style: const TextStyle(
                            color: Sk.cream,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Orbitron',
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
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// METAL ICON BUTTON
// ═══════════════════════════════════════════════════════════
class _MetalIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  const _MetalIconButton({
    required this.icon,
    required this.onTap,
    this.size = 34,
  });

  @override
  State<_MetalIconButton> createState() => _MetalIconButtonState();
}

class _MetalIconButtonState extends State<_MetalIconButton> {
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
        duration: const Duration(milliseconds: 80),
        width: widget.size,
        height: widget.size,
        transform: Matrix4.translationValues(
          _pressed ? 1 : 0,
          _pressed ? 1 : 0,
          0,
        ),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Sk.metalLight, Sk.metalDark],
          ),
          border: Border.all(
            color: Sk.metalHi.withOpacity(0.5),
            width: 1,
          ),
          boxShadow: _pressed
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.6),
                    offset: const Offset(0, 2),
                    blurRadius: 3,
                  ),
                ],
        ),
        child: Icon(
          widget.icon,
          color: Sk.redBright,
          size: widget.size * 0.42,
        ),
      ),
    );
  }
}