import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'notification_service.dart';

class Sk {
  static const Color metalDeep   = Color(0xFF1A1815);
  static const Color metalDark   = Color(0xFF2A2723);
  static const Color metalMid    = Color(0xFF3D3933);
  static const Color metalLight  = Color(0xFF5A554C);
  static const Color metalHi     = Color(0xFF9A9286);
  static const Color brassDeep   = Color(0xFF6B5015);
  static const Color brassDark   = Color(0xFF8B6914);
  static const Color brass       = Color(0xFFC9A961);
  static const Color brassHi     = Color(0xFFE8C87F);
  static const Color brassShine  = Color(0xFFF5DEB3);
  static const Color red         = Color(0xFF8B1818);
  static const Color redBright   = Color(0xFFC41E1E);
  static const Color redGlow     = Color(0xFFFF3030);
  static const Color greenGlow   = Color(0xFF00E676);
  static const Color amberHi     = Color(0xFFF59E0B);
  static const Color cyanHi      = Color(0xFF26C6DA);
  static const Color cream       = Color(0xFFE8DFC8);
  static const Color ink         = Color(0xFF2A2520);
  static const Color leather     = Color(0xFF2A1F18);
  static const Color leatherDark = Color(0xFF1A1310);
  static const Color leatherHi   = Color(0xFF3D2E22);
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
        width: size,
        height: size,
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

class _Rivet extends StatelessWidget {
  final double size;
  const _Rivet({this.size = 10});
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
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
            colors: _pressed
                ? [dark, dark, widget.color]
                : [light, widget.color, dark],
            stops: const [0.0, 0.5, 1.0],
          ),
          boxShadow: _pressed
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.9),
                    offset: const Offset(0, 1),
                    blurRadius: 3,
                  ),
                ]
              : [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.45),
                    offset: const Offset(0, 5),
                    blurRadius: 10,
                    spreadRadius: -2,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.75),
                    offset: const Offset(0, 4),
                    blurRadius: 6,
                  ),
                ],
          border: Border.all(
            color: dark.withValues(alpha: 0.9),
            width: 1.5,
          ),
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
              child: Opacity(
                opacity: enabled ? 1 : 0.5,
                child: widget.child,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ FIXED: pakai .r/.g/.b (bukan .red/.green/.blue yang deprecated)
  static Color _lighten(Color c) => Color.fromARGB(
        (c.a * 255).round(),
        ((c.r * 255).round() + 40).clamp(0, 255),
        ((c.g * 255).round() + 40).clamp(0, 255),
        ((c.b * 255).round() + 30).clamp(0, 255),
      );

  static Color _darken(Color c) => Color.fromARGB(
        (c.a * 255).round(),
        ((c.r * 255).round() - 60).clamp(0, 255),
        ((c.g * 255).round() - 50).clamp(0, 255),
        ((c.b * 255).round() - 40).clamp(0, 255),
      );
}

// ═══════════════════════════════════════════════════════
// MODEL NOTIFIKASI
// ═══════════════════════════════════════════════════════
class AppNotification {
  final String id;
  final String title;
  final String body;
  final String type;
  final DateTime createdAt;
  final bool isRead;
  final String? fromUser;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    required this.isRead,
    this.fromUser,
  });

  AppNotification copyWith({bool? isRead}) => AppNotification(
        id: id,
        title: title,
        body: body,
        type: type,
        createdAt: createdAt,
        isRead: isRead ?? this.isRead,
        fromUser: fromUser,
      );

  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
        id: (j['id'] ?? '').toString(),
        title: (j['title'] ?? 'Notifikasi').toString(),
        body: (j['body'] ?? j['message'] ?? '').toString(),
        type: (j['type'] ?? 'info').toString().toLowerCase(),
        createdAt:
            DateTime.tryParse((j['created_at'] ?? '').toString())?.toLocal() ??
                DateTime.now(),
        isRead: j['is_read'] == true || j['is_read'] == 1,
        fromUser: j['from']?.toString(),
      );

  Color get accent {
    switch (type) {
      case 'success':
        return Sk.greenGlow;
      case 'warning':
        return Sk.amberHi;
      case 'error':
        return Sk.redGlow;
      default:
        return Sk.cyanHi;
    }
  }

  IconData get icon {
    switch (type) {
      case 'success':
        return Icons.check_circle_rounded;
      case 'warning':
        return Icons.warning_amber_rounded;
      case 'error':
        return Icons.error_rounded;
      default:
        return Icons.campaign_rounded;
    }
  }
}

// ═══════════════════════════════════════════════════════
// CHECK NOTIF PAGE — BROADCAST INBOX
// ═══════════════════════════════════════════════════════
class CheckNotifPage extends StatefulWidget {
  final String sessionKey;
  final String username;
  final String role;

  const CheckNotifPage({
    super.key,
    required this.sessionKey,
    required this.username,
    required this.role,
  });

  @override
  State<CheckNotifPage> createState() => _CheckNotifPageState();
}

class _CheckNotifPageState extends State<CheckNotifPage> {
  final List<AppNotification> _notifications = [];
  bool _isLoading = true;
  String? _error;
  Timer? _pollTimer;

  // ═══ Field untuk deteksi notif baru ═══
  final Set<String> _seenIds = {};
  bool _firstLoad = true;

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  @override
  void initState() {
    super.initState();
    _Pulse.ensureStarted();
    _fetch();

    _pollTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _fetch(silent: true),
    );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════
  // API
  // ═══════════════════════════════════════════════════════
  Future<void> _fetch({bool silent = false}) async {
    if (!silent) setState(() => _isLoading = true);
    try {
      final uri = Uri.parse(
        '$baseUrl/getNotifications'
        '?key=${Uri.encodeComponent(widget.sessionKey)}'
        '&username=${Uri.encodeComponent(widget.username)}',
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = (data['notifications'] ?? data['data'] ?? []) as List;
        final parsed = list
            .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        // ═══════════════════════════════════════════════════
        // DETEKSI NOTIF BARU → tampilkan ke bar HP
        // ═══════════════════════════════════════════════════
        if (_firstLoad) {
          _seenIds.addAll(parsed.map((e) => e.id));
          _firstLoad = false;
        } else {
          for (final n in parsed) {
            if (!_seenIds.contains(n.id)) {
              _seenIds.add(n.id);
              if (!n.isRead) {
                await NotificationService.show(
                  id: n.id.hashCode & 0x7fffffff,
                  title: n.title,
                  body: n.body,
                  payload: n.id,
                );
              }
            }
          }
        }
        // ═══════════════════════════════════════════════════

        if (!mounted) return;
        setState(() {
          _notifications
            ..clear()
            ..addAll(parsed);
          _error = null;
        });
      } else {
        if (!mounted) return;
        setState(() => _error = 'HTTP ${res.statusCode}');
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Gagal memuat notifikasi');
    } finally {
      if (mounted && !silent) setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsRead(AppNotification n) async {
    if (n.isRead) return;
    final idx = _notifications.indexWhere((e) => e.id == n.id);
    if (idx == -1) return;
    setState(() => _notifications[idx] = n.copyWith(isRead: true));

    try {
      await http
          .post(
            Uri.parse('$baseUrl/markNotificationRead'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'key': widget.sessionKey,
              'username': widget.username,
              'id': n.id,
            }),
          )
          .timeout(const Duration(seconds: 10));
    } catch (_) {}
  }

  Future<void> _markAllRead() async {
    if (_unreadCount == 0) return;
    HapticFeedback.mediumImpact();

    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }
    setState(() {});

    try {
      await http
          .post(
            Uri.parse('$baseUrl/markAllRead'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'key': widget.sessionKey,
              'username': widget.username,
            }),
          )
          .timeout(const Duration(seconds: 10));
      _snack('Semua notifikasi ditandai dibaca');
    } catch (_) {
      _snack('Gagal menandai semua', isError: true);
      _fetch(silent: true);
    }
  }

  Future<void> _deleteNotification(AppNotification n) async {
    final ok = await _confirmDialog(n);
    if (ok != true) return;
    final idx = _notifications.indexWhere((e) => e.id == n.id);
    if (idx == -1) return;
    final removed = _notifications.removeAt(idx);
    setState(() {});
    HapticFeedback.mediumImpact();

    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/deleteNotification'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'key': widget.sessionKey,
              'username': widget.username,
              'id': n.id,
            }),
          )
          .timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) throw Exception();
      _snack('Notifikasi disembunyikan');
    } catch (_) {
      if (!mounted) return;
      setState(() => _notifications.insert(idx, removed));
      _snack('Gagal menghapus notifikasi', isError: true);
    }
  }

  // ═══════════════════════════════════════════════════════
  // UI HELPERS
  // ═══════════════════════════════════════════════════════
  void _snack(String msg, {bool isError = false}) {
    if (!mounted) return;
    final c = isError ? Sk.redGlow : Sk.greenGlow;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            _Led(color: c, size: 8, blink: true),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                msg,
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
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<bool?> _confirmDialog(AppNotification n) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: _MetalPlate(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.delete_forever_rounded,
                  color: Sk.redGlow, size: 36),
              const SizedBox(height: 12),
              const Text(
                'HAPUS DARI INBOX?',
                style: TextStyle(
                  color: Sk.redGlow,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Orbitron',
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                n.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Sk.cream.withValues(alpha: 0.7),
                  fontSize: 11,
                  fontFamily: 'ShareTechMono',
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Notif ini hanya disembunyikan dari inbox Anda.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Sk.cream.withValues(alpha: 0.45),
                  fontSize: 9,
                  fontFamily: 'ShareTechMono',
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _IndustrialButton(
                      color: Sk.metalMid,
                      height: 44,
                      onTap: () => Navigator.pop(ctx, false),
                      child: const Text(
                        'BATAL',
                        style: TextStyle(
                          color: Sk.cream,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Orbitron',
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _IndustrialButton(
                      color: Sk.red,
                      height: 44,
                      onTap: () => Navigator.pop(ctx, true),
                      child: const Text(
                        'HAPUS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Orbitron',
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openDetail(AppNotification n) {
    _markAsRead(n);
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: _MetalPlate(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const RadialGradient(
                            colors: [Sk.metalHi, Sk.metalMid, Sk.metalDark],
                          ),
                          border: Border.all(color: n.accent, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: n.accent.withValues(alpha: 0.5),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Icon(n.icon, color: n.accent, size: 22),
                      ),
                      const Positioned(
                        top: -2,
                        right: -2,
                        child: _Led(color: Sk.greenGlow, size: 6, blink: true),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          margin: const EdgeInsets.only(bottom: 4),
                          decoration: BoxDecoration(
                            color: n.accent.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: n.accent.withValues(alpha: 0.6),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            n.type.toUpperCase(),
                            style: TextStyle(
                              color: n.accent,
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Orbitron',
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        Text(
                          n.title,
                          style: const TextStyle(
                            color: Sk.brassHi,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Orbitron',
                            letterSpacing: 1,
                            height: 1.2,
                            shadows: [
                              Shadow(
                                color: Colors.black,
                                offset: Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTime(n.createdAt),
                          style: TextStyle(
                            color: Sk.cream.withValues(alpha: 0.55),
                            fontSize: 9,
                            fontFamily: 'ShareTechMono',
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    Colors.transparent,
                    n.accent.withValues(alpha: 0.6),
                    Colors.transparent,
                  ]),
                ),
              ),
              const SizedBox(height: 14),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(ctx).size.height * 0.4,
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: SelectableText(
                    n.body,
                    style: const TextStyle(
                      color: Sk.cream,
                      fontSize: 12,
                      height: 1.6,
                      fontFamily: 'ShareTechMono',
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
              if (n.fromUser != null && n.fromUser!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Sk.metalDark),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.podcasts_rounded,
                          size: 12, color: Sk.brass),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Broadcast dari: ${n.fromUser}',
                          style: TextStyle(
                            color: Sk.cream.withValues(alpha: 0.7),
                            fontSize: 10,
                            fontFamily: 'ShareTechMono',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _IndustrialButton(
                      color: Sk.red,
                      height: 46,
                      onTap: () {
                        Navigator.pop(ctx);
                        _deleteNotification(n);
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.delete_outline_rounded,
                              color: Colors.white, size: 14),
                          SizedBox(width: 6),
                          Text(
                            'HAPUS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Orbitron',
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _IndustrialButton(
                      color: n.accent,
                      height: 46,
                      onTap: () => Navigator.pop(ctx),
                      child: const Text(
                        'TUTUP',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Orbitron',
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ],
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
                Expanded(child: _buildBody()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: _MetalPlate(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
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
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.7),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.7),
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
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Sk.brass,
                  size: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),
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
                    border: Border.all(color: Sk.cyanHi, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Sk.cyanHi.withValues(alpha: 0.5),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.campaign_rounded,
                    color: Sk.cyanHi,
                    size: 20,
                  ),
                ),
                if (_unreadCount > 0)
                  Positioned(
                    top: -3,
                    right: -3,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: Sk.redGlow,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Sk.redGlow.withValues(alpha: 0.7),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      constraints: const BoxConstraints(minWidth: 16),
                      child: Text(
                        _unreadCount > 99 ? '99+' : '$_unreadCount',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Orbitron',
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'NOTIFIKASI PAGE',
                    style: TextStyle(
                      color: Sk.brassHi,
                      fontSize: 13,
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
                          blurRadius: 3,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const _Led(color: Sk.cyanHi, size: 4, blink: true),
                      const SizedBox(width: 5),
                      Text(
                        _unreadCount > 0
                            ? '$_unreadCount BELUM DIBACA'
                            : 'SEMUA TERBACA',
                        style: TextStyle(
                          color: Sk.cream.withValues(alpha: 0.55),
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
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _fetch();
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Sk.metalLight, Sk.metalMid, Sk.metalDark],
                  ),
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.7),
                    width: 1.2,
                  ),
                ),
                child: const Icon(
                  Icons.refresh_rounded,
                  color: Sk.brass,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _notifications.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Sk.brass),
          strokeWidth: 3,
        ),
      );
    }

    if (_error != null && _notifications.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _MetalPlate(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wifi_off_rounded,
                    color: Sk.redGlow, size: 40),
                const SizedBox(height: 12),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Sk.cream,
                    fontSize: 12,
                    fontFamily: 'ShareTechMono',
                  ),
                ),
                const SizedBox(height: 14),
                _IndustrialButton(
                  color: Sk.red,
                  height: 44,
                  onTap: () => _fetch(),
                  child: const Text(
                    'COBA LAGI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Orbitron',
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_notifications.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _MetalPlate(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                        border: Border.all(color: Sk.metalLight, width: 2),
                      ),
                      child: const Icon(
                        Icons.campaign_rounded,
                        color: Sk.metalHi,
                        size: 28,
                      ),
                    ),
                    const Positioned(
                      top: -2,
                      right: -2,
                      child: _Led(color: Sk.cyanHi, size: 8, blink: true),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'TIDAK ADA BROADCAST',
                  style: TextStyle(
                    color: Sk.brass,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Orbitron',
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Owner belum mengirim broadcast.\nTarik ke bawah untuk refresh.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Sk.cream.withValues(alpha: 0.6),
                    fontSize: 10,
                    fontFamily: 'ShareTechMono',
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _fetch(),
      color: Sk.brass,
      backgroundColor: Sk.metalDark,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _notifications.length + 1,
        itemBuilder: (_, i) {
          if (i == 0) return _buildActionBar();
          final n = _notifications[i - 1];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _NotifTile(
              notif: n,
              onTap: () => _openDetail(n),
              onDelete: () => _deleteNotification(n),
              timeAgo: _formatTime(n.createdAt),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionBar() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Sk.metalDark),
              ),
              child: Row(
                children: [
                  const _Led(color: Sk.cyanHi, size: 6, blink: true),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'TOTAL: ${_notifications.length}  |  BARU: $_unreadCount',
                      style: TextStyle(
                        color: Sk.cream.withValues(alpha: 0.7),
                        fontSize: 9,
                        fontFamily: 'ShareTechMono',
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _unreadCount > 0 ? _markAllRead : null,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  colors: _unreadCount > 0
                      ? [Sk.brassHi, Sk.brass, Sk.brassDark]
                      : [Sk.metalMid, Sk.metalDark],
                ),
                border: Border.all(
                  color: Colors.black.withValues(alpha: 0.6),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.done_all_rounded,
                    size: 12,
                    color: _unreadCount > 0
                        ? Colors.white
                        : Sk.cream.withValues(alpha: 0.4),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'BACA SEMUA',
                    style: TextStyle(
                      color: _unreadCount > 0
                          ? Colors.white
                          : Sk.cream.withValues(alpha: 0.4),
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Orbitron',
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatTime(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inSeconds < 0) return 'baru saja';
    if (d.inSeconds < 60) return '${d.inSeconds}s lalu';
    if (d.inMinutes < 60) return '${d.inMinutes}m lalu';
    if (d.inHours < 24) return '${d.inHours}j lalu';
    if (d.inDays < 7) return '${d.inDays}h lalu';
    final dd = t.day.toString().padLeft(2, '0');
    final mm = t.month.toString().padLeft(2, '0');
    return '$dd/$mm/${t.year}';
  }
}

// ═══════════════════════════════════════════════════════
// TILE NOTIFIKASI
// ═══════════════════════════════════════════════════════
class _NotifTile extends StatelessWidget {
  final AppNotification notif;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final String timeAgo;

  const _NotifTile({
    required this.notif,
    required this.onTap,
    required this.onDelete,
    required this.timeAgo,
  });

  @override
  Widget build(BuildContext context) {
    final c = notif.accent;
    final unread = !notif.isRead;

    return GestureDetector(
      onTap: onTap,
      onLongPress: () {
        HapticFeedback.mediumImpact();
        onDelete();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: unread
                ? [
                    Color.lerp(Sk.leatherHi, c, 0.08)!,
                    Sk.leather,
                    Sk.leatherDark,
                  ]
                : [Sk.leather, Sk.leatherDark],
          ),
          border: Border.all(
            color: unread ? c.withValues(alpha: 0.55) : Sk.metalDark,
            width: unread ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: unread ? c.withValues(alpha: 0.15) : Colors.black26,
              blurRadius: unread ? 10 : 4,
              spreadRadius: unread ? 1 : 0,
            ),
            const BoxShadow(
              color: Colors.black54,
              offset: Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        center: const Alignment(-0.35, -0.35),
                        colors: [
                          c.withValues(alpha: 0.35),
                          c.withValues(alpha: 0.12),
                          Colors.black.withValues(alpha: 0.85),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                      border: Border.all(
                        color: c.withValues(alpha: unread ? 0.85 : 0.4),
                        width: 1.8,
                      ),
                      boxShadow: unread
                          ? [
                              BoxShadow(
                                color: c.withValues(alpha: 0.45),
                                blurRadius: 10,
                                spreadRadius: 0.5,
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      notif.icon,
                      color: c,
                      size: 20,
                      shadows: const [
                        Shadow(color: Colors.black, blurRadius: 3),
                      ],
                    ),
                  ),
                  if (unread)
                    const Positioned(
                      top: -1,
                      right: -1,
                      child: _Led(color: Sk.redGlow, size: 7, blink: true),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notif.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: unread ? Sk.brassHi : Sk.brass,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Orbitron',
                              letterSpacing: 0.5,
                              height: 1.2,
                              shadows: unread
                                  ? const [
                                      Shadow(
                                        color: Colors.black,
                                        offset: Offset(0, 1),
                                        blurRadius: 2,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        ),
                        if (unread) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: Sk.redGlow.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'BARU',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 7,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'Orbitron',
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notif.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color:
                            Sk.cream.withValues(alpha: unread ? 0.85 : 0.55),
                        fontSize: 10.5,
                        fontFamily: 'ShareTechMono',
                        height: 1.35,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 10,
                          color: Sk.cream.withValues(alpha: 0.4),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          timeAgo,
                          style: TextStyle(
                            color: Sk.cream.withValues(alpha: 0.5),
                            fontSize: 9,
                            fontFamily: 'ShareTechMono',
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: c.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(
                              color: c.withValues(alpha: 0.5),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            notif.type.toUpperCase(),
                            style: TextStyle(
                              color: c,
                              fontSize: 7,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Orbitron',
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            onDelete();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withValues(alpha: 0.5),
                              border: Border.all(
                                color: Sk.red.withValues(alpha: 0.6),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 11,
                              color: Sk.redGlow,
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
      ),
    );
  }
}