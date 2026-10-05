// lib/cakun.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/cakun_service.dart';

// ═══════════════════════════════════════════════════════
// COLORS
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
  static const Color redGlow      = Color(0xFFFF3030);
  static const Color greenGlow    = Color(0xFF00E676);
  static const Color amberHi      = Color(0xFFF59E0B);
  static const Color cream        = Color(0xFFE8DFC8);
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
  const _MetalPlate({required this.child, this.padding = const EdgeInsets.all(16)});
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
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
            borderRadius: BorderRadius.circular(13),
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
      onTapUp: enabled ? (_) { setState(() => _pressed = false); widget.onTap?.call(); } : null,
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
// SKEO TEXT FIELD
// ═══════════════════════════════════════════════════════
class _SkeuoField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool numericOnly;
  final String? Function(String?)? validator;
  const _SkeuoField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.numericOnly = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _Rivet(size: 6),
              const SizedBox(width: 6),
              Text(label,
                  style: const TextStyle(
                    color: Sk.brass,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Orbitron',
                    letterSpacing: 1.5,
                  )),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0A0806), Color(0xFF151210)],
              ),
              border: Border.all(color: Sk.metalDark, width: 1.2),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.9), offset: const Offset(0, 2), blurRadius: 3),
              ],
            ),
            child: TextFormField(
              controller: controller,
              validator: validator,
              keyboardType: numericOnly ? TextInputType.number : TextInputType.text,
              inputFormatters: numericOnly ? [FilteringTextInputFormatter.digitsOnly] : null,
              style: const TextStyle(
                color: Sk.brassShine,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                fontFamily: 'ShareTechMono',
                letterSpacing: 0.5,
              ),
              cursorColor: Sk.greenGlow,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: Sk.cream.withOpacity(0.3),
                  fontSize: 11,
                  fontFamily: 'ShareTechMono',
                ),
                prefixIcon: Icon(icon, color: Sk.brass, size: 18),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// COPYABLE ROW
// ═══════════════════════════════════════════════════════
class _CopyableResultRow extends StatefulWidget {
  final String label;
  final String value;
  final Color color;
  final IconData copyIcon;
  const _CopyableResultRow({
    required this.label,
    required this.value,
    required this.color,
    this.copyIcon = Icons.copy_rounded,
  });

  @override
  State<_CopyableResultRow> createState() => _CopyableResultRowState();
}

class _CopyableResultRowState extends State<_CopyableResultRow> {
  bool _copied = false;
  bool _pressed = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.value));
    HapticFeedback.lightImpact();
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 78,
            child: Text(
              widget.label,
              style: TextStyle(
                color: Sk.cream.withOpacity(0.55),
                fontSize: 9,
                fontFamily: 'ShareTechMono',
                letterSpacing: 1,
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTapDown: (_) => setState(() => _pressed = true),
              onTapUp: (_) {
                setState(() => _pressed = false);
                _copy();
              },
              onTapCancel: () => setState(() => _pressed = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: _copied
                      ? Sk.greenGlow.withOpacity(0.15)
                      : Colors.black.withOpacity(0.5),
                  border: Border.all(
                    color: _copied
                        ? Sk.greenGlow
                        : (_pressed ? widget.color : widget.color.withOpacity(0.4)),
                    width: _pressed ? 1.5 : 1,
                  ),
                  boxShadow: _copied
                      ? [BoxShadow(color: Sk.greenGlow.withOpacity(0.4), blurRadius: 8, spreadRadius: 1)]
                      : null,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.value,
                        style: TextStyle(
                          color: _copied ? Sk.greenGlow : widget.color,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Orbitron',
                          letterSpacing: 0.5,
                          shadows: [
                            Shadow(
                              color: (_copied ? Sk.greenGlow : widget.color).withOpacity(0.5),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _copied
                          ? const Icon(Icons.check_circle_rounded, key: ValueKey('check'), color: Sk.greenGlow, size: 16)
                          : Icon(widget.copyIcon, key: const ValueKey('copy'), color: widget.color.withOpacity(0.7), size: 14),
                    ),
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

// ═══════════════════════════════════════════════════════
// INFO ROW
// ═══════════════════════════════════════════════════════
class _InfoResultRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _InfoResultRow({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 78,
            child: Text(
              label,
              style: TextStyle(
                color: Sk.cream.withOpacity(0.55),
                fontSize: 9,
                fontFamily: 'ShareTechMono',
                letterSpacing: 1,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.black.withOpacity(0.5),
                border: Border.all(color: color.withOpacity(0.4), width: 1),
              ),
              child: Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Orbitron',
                  letterSpacing: 0.5,
                  shadows: [Shadow(color: color.withOpacity(0.5), blurRadius: 4)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// CAKUN PAGE
// ═══════════════════════════════════════════════════════
class CakunPage extends StatefulWidget {
  final String? sessionKey;
  final String? username;
  final String? role;
  const CakunPage({
    super.key,
    this.sessionKey,
    this.username,
    this.role,
  });

  @override
  State<CakunPage> createState() => _CakunPageState();
}

class _CakunPageState extends State<CakunPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _telegramIdCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _loading = false;
  bool _useCustomPassword = false;

  @override
  void initState() {
    super.initState();
    _Pulse.ensureStarted();
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _telegramIdCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // ✅ FIX: tidak ada parameter duration
  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final res = await CakunService.createAkun(
      username: _usernameCtrl.text.trim(),
      telegramId: _telegramIdCtrl.text.trim(),
      password: _useCustomPassword && _passwordCtrl.text.trim().isNotEmpty
          ? _passwordCtrl.text.trim()
          : null,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (res.success) {
      HapticFeedback.mediumImpact();
      _showResultDialog(res.data!);
      _usernameCtrl.clear();
      _telegramIdCtrl.clear();
      _passwordCtrl.clear();
      setState(() => _useCustomPassword = false);
    } else {
      HapticFeedback.heavyImpact();
      _showSnack(res.message ?? 'Error', Sk.red);
    }
  }

  void _showSnack(String msg, Color c) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            _Led(color: c, size: 8, blink: true),
            const SizedBox(width: 10),
            Expanded(
              child: Text(msg,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
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
      ),
    );
  }

  void _showResultDialog(AkunData data) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: _MetalPlate(
          padding: const EdgeInsets.all(18),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const _Led(color: Sk.greenGlow, size: 10, blink: true),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'AKUN BERHASIL',
                        style: TextStyle(
                          color: Sk.brass,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Orbitron',
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Sk.metalDark,
                          border: Border.all(color: Sk.red, width: 1),
                        ),
                        child: const Icon(Icons.close, color: Sk.brass, size: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Sk.amberHi.withOpacity(0.15),
                    border: Border.all(color: Sk.amberHi.withOpacity(0.6), width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.touch_app_rounded, color: Sk.amberHi, size: 11),
                      const SizedBox(width: 5),
                      Text(
                        'Tap username / password untuk copy',
                        style: TextStyle(
                          color: Sk.amberHi.withOpacity(0.95),
                          fontSize: 9,
                          fontFamily: 'ShareTechMono',
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                _CopyableResultRow(
                  label: 'USERNAME',
                  value: data.username,
                  color: Sk.brassShine,
                  copyIcon: Icons.person_rounded,
                ),
                _CopyableResultRow(
                  label: 'PASSWORD',
                  value: data.password,
                  color: Sk.amberHi,
                  copyIcon: Icons.key_rounded,
                ),

                _InfoResultRow(label: 'ROLE', value: data.role.toUpperCase(), color: Sk.redGlow),
                _InfoResultRow(label: 'EXPIRED', value: data.expiredDate, color: Sk.greenGlow),
                _InfoResultRow(label: 'PAIR ID', value: data.pairId, color: Sk.brass),
                _InfoResultRow(label: 'DURATION', value: '${data.durationDays} HARI', color: Sk.cream),

                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: Sk.greenGlow.withOpacity(0.12),
                    border: Border.all(color: Sk.greenGlow.withOpacity(0.5), width: 1),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: Sk.greenGlow, size: 13),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Akun aktif · Notif terkirim ke group',
                          style: TextStyle(
                            color: Sk.greenGlow.withOpacity(0.95),
                            fontSize: 10,
                            fontFamily: 'ShareTechMono',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                _IndustrialButton(
                  color: Sk.greenGlow,
                  height: 44,
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(
                      text:
                          '╭─『 ACCOUNT DETAIL 』─⪩\n'
                          'Username: ${data.username}\n'
                          'Password: ${data.password}\n'
                          'Role: ${data.role.toUpperCase()}\n'
                          'Expired: ${data.expiredDate}\n'
                          'PairId: ${data.pairId}\n'
                          '╰─────────────────⪩',
                    ));
                    if (ctx.mounted) Navigator.pop(ctx);
                    _showSnack('Semua credential dicopy!', Sk.greenGlow);
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.copy_all_rounded, color: Colors.white, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'COPY SEMUA',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Orbitron',
                          letterSpacing: 1.5,
                        ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0806),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Sk.brass),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            _Led(color: Sk.greenGlow, size: 6, blink: true),
            SizedBox(width: 10),
            Text(
              'CREATE AKUN',
              style: TextStyle(
                color: Sk.brassHi,
                fontSize: 13,
                fontWeight: FontWeight.w900,
                fontFamily: 'Orbitron',
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Sk.metalMid, Sk.metalDark, Sk.metalDeep],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.3, -0.3),
            radius: 1.2,
            colors: [Color(0xFF2A1F18), Color(0xFF1A1310), Color(0xFF0A0806)],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(14),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildFormPlate(),
                const SizedBox(height: 14),
                _buildInfoPlate(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormPlate() {
    return _MetalPlate(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              _Screw(size: 12),
              SizedBox(width: 10),
              Expanded(
                child: Center(
                  child: Text(
                    'FORM CREATE AKUN',
                    style: TextStyle(
                      color: Sk.brass,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Orbitron',
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              _Screw(size: 12),
            ],
          ),
          const SizedBox(height: 16),

          _SkeuoField(
            controller: _usernameCtrl,
            label: 'USERNAME',
            hint: 'minimal 3 karakter',
            icon: Icons.person_rounded,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Username wajib diisi';
              if (v.trim().length < 3) return 'Username minimal 3 karakter';
              return null;
            },
          ),

          _SkeuoField(
            controller: _telegramIdCtrl,
            label: 'TELEGRAM ID',
            hint: 'contoh: 123456789',
            icon: Icons.badge_rounded,
            numericOnly: true,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Telegram ID wajib diisi';
              if (!RegExp(r'^\d+$').hasMatch(v.trim())) return 'Harus angka';
              return null;
            },
          ),

          GestureDetector(
            onTap: () => setState(() => _useCustomPassword = !_useCustomPassword),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.black.withOpacity(0.4),
                border: Border.all(
                  color: _useCustomPassword ? Sk.greenGlow : Sk.metalDark,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: _useCustomPassword ? Sk.greenGlow.withOpacity(0.2) : Colors.transparent,
                      border: Border.all(
                        color: _useCustomPassword ? Sk.greenGlow : Sk.metalLight,
                        width: 1.5,
                      ),
                    ),
                    child: _useCustomPassword
                        ? const Icon(Icons.check, color: Sk.greenGlow, size: 14)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.key_rounded, color: Sk.amberHi, size: 14),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      'Pakai password custom',
                      style: TextStyle(
                        color: Sk.cream,
                        fontSize: 11,
                        fontFamily: 'ShareTechMono',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const _Led(color: Sk.amberHi, size: 5, blink: true),
                ],
              ),
            ),
          ),

          if (_useCustomPassword)
            _SkeuoField(
              controller: _passwordCtrl,
              label: 'PASSWORD CUSTOM',
              hint: 'minimal 4 karakter',
              icon: Icons.lock_rounded,
              validator: (v) {
                if (!_useCustomPassword) return null;
                if (v == null || v.trim().isEmpty) return 'Password wajib diisi';
                if (v.trim().length < 4) return 'Password minimal 4 karakter';
                return null;
              },
            ),

          const SizedBox(height: 8),

          _IndustrialButton(
            color: _loading ? Sk.metalMid : Sk.greenGlow,
            height: 54,
            onTap: _loading ? null : _submit,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_loading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(color: Sk.cream, strokeWidth: 2),
                  )
                else
                  const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 10),
                Text(
                  _loading ? 'MEMPROSES...' : 'CREATE AKUN',
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
          _infoLine('• Setiap ID Telegram hanya bisa 1 akun'),
          _infoLine('• Role otomatis: MEMBER'),
          _infoLine('• Duration: 50000 hari (lifetime)'),
          _infoLine('• Password: custom atau auto-generate'),
          _infoLine('• Akun langsung muncul di popup, tap untuk copy'),
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