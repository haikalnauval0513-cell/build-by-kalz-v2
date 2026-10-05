import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'api_config.dart';

// ═══════════════════════════════════════════════════════════
// SOFT SKEUOMORPHISM PALETTE
// ═══════════════════════════════════════════════════════════
class Sk {
  // Metal
  static const Color metalDeep  = Color(0xFF15130F);
  static const Color metalDark  = Color(0xFF252220);
  static const Color metalMid   = Color(0xFF3A3630);
  static const Color metalLight = Color(0xFF55504A);
  static const Color metalHi    = Color(0xFF7A7368);

  // Brass
  static const Color brassDeep  = Color(0xFF5C4410);
  static const Color brassDark  = Color(0xFF8B6914);
  static const Color brass      = Color(0xFFC9A961);
  static const Color brassHi    = Color(0xFFE8C87F);
  static const Color brassShine = Color(0xFFF5DEB3);

  // Red (candy apple)
  static const Color redDeep    = Color(0xFF3D0808);
  static const Color red        = Color(0xFF8B1818);
  static const Color redBright  = Color(0xFFC41E1E);
  static const Color redGlow    = Color(0xFFFF3030);
  static const Color redHi      = Color(0xFFFF4D47);

  // Green
  static const Color greenDeep  = Color(0xFF0A2818);
  static const Color green      = Color(0xFF2E7D32);
  static const Color greenHi    = Color(0xFF4CAF50);
  static const Color greenGlow  = Color(0xFF00E676);

  // Surface
  static const Color leather    = Color(0xFF2A1F18);
  static const Color leatherDark = Color(0xFF1A1310);
  static const Color leatherHi  = Color(0xFF3D2E22);
  static const Color cream      = Color(0xFFE8DFC8);
  static const Color ink        = Color(0xFF2A2520);
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
            color: color.withOpacity(0.6),
            blurRadius: size,
            spreadRadius: 0.5,
          ),
        ],
      ),
    );
  }
}

/// Small rivet
class _Rivet extends StatelessWidget {
  final double size;
  const _Rivet({this.size = 6});
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
            color: Colors.black.withOpacity(0.5),
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
// BUG SENDER PAGE
// ═══════════════════════════════════════════════════════════
class BugSenderPage extends StatefulWidget {
  final String sessionKey;
  final String username;
  final String role;

  const BugSenderPage({
    super.key,
    required this.sessionKey,
    required this.username,
    required this.role,
  });

  @override
  State<BugSenderPage> createState() => _BugSenderPageState();
}

class _BugSenderPageState extends State<BugSenderPage> {
  List<dynamic> senderList = [];
  bool isLoading = false;
  bool isRefreshing = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchSenders();
  }

  // ─── API ───────────────────────────────────────────────────
  Future<void> _fetchSenders() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final res = await http.get(
        Uri.parse("$baseUrl/mySender?key=${widget.sessionKey}"),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data["valid"] == true) {
          if (mounted) {
            setState(() => senderList = data["connections"] ?? []);
          }
        } else {
          if (mounted) {
            setState(() =>
                errorMessage = data["message"] ?? "Failed to fetch");
          }
        }
      } else {
        if (mounted) {
          setState(() =>
              errorMessage = "Server error: ${res.statusCode}");
        }
      }
    } catch (e) {
      if (mounted) setState(() => errorMessage = "Connection failed");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
          isRefreshing = false;
        });
      }
    }
  }

  Future<void> _refreshSenders() async {
    setState(() => isRefreshing = true);
    await _fetchSenders();
  }

  Future<void> _addSender(String number) async {
    setState(() => isLoading = true);
    try {
      final res = await http.get(Uri.parse(
          "$baseUrl/getPairing?key=${widget.sessionKey}&number=$number"));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data["valid"] == true) {
          _showPairingCodeDialog(number, data['pairingCode']);
        } else {
          _toast(data['message'] ?? "Failed to generate pairing code",
              error: true);
        }
      } else {
        _toast("Server error: ${res.statusCode}", error: true);
      }
    } catch (_) {
      _toast("Connection failed", error: true);
    } finally {
      if (mounted) setState(() => isLoading = false);
      _fetchSenders();
    }
  }

  Future<void> _deleteSender(String senderId) async {
    setState(() => isLoading = true);
    try {
      final res = await http.delete(Uri.parse(
          "$baseUrl/deleteSender?key=${widget.sessionKey}&id=$senderId"));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data["valid"] == true) {
          _toast("Sender deleted successfully");
          _fetchSenders();
        } else {
          _toast(data["message"] ?? "Failed", error: true);
        }
      } else {
        _toast("Server error: ${res.statusCode}", error: true);
      }
    } catch (_) {
      _toast("Connection failed", error: true);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _toast(String msg, {bool error = false}) {
    final color = error ? Sk.redBright : Sk.greenHi;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Sk.metalDark,
        content: Row(
          children: [
            _Led(color: color, size: 8),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                msg,
                style: const TextStyle(
                  color: Sk.cream,
                  fontSize: 12,
                  fontFamily: 'ShareTechMono',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: color.withOpacity(0.5), width: 1.5),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ─── DIALOGS ───────────────────────────────────────────────
  void _showAddSenderDialog() {
    final phoneCtrl = TextEditingController();
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: _SoftPanel(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Sk.redBright.withOpacity(0.15),
                      border: Border.all(
                          color: Sk.redBright.withOpacity(0.5), width: 1.5),
                    ),
                    child: const Icon(Icons.add_link_rounded,
                        color: Sk.redBright, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TAMBAH SENDER',
                          style: TextStyle(
                            color: Sk.brass,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Orbitron',
                            letterSpacing: 1.5,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Masukkan nomor WhatsApp',
                          style: TextStyle(
                            color: Sk.cream,
                            fontSize: 10,
                            fontFamily: 'ShareTechMono',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const _Screw(size: 10),
                ],
              ),
              const SizedBox(height: 18),
              _SoftInset(
                child: TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(
                    color: Sk.cream,
                    fontFamily: 'ShareTechMono',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                  cursorColor: Sk.brass,
                  cursorWidth: 2,
                  decoration: InputDecoration(
                    hintText: '62812XXXXXXXX',
                    hintStyle: TextStyle(
                      color: Sk.cream.withOpacity(0.3),
                      fontFamily: 'ShareTechMono',
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(Icons.phone_outlined,
                        color: Sk.brass, size: 16),
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _MetalButton(
                      label: 'BATAL',
                      color: Sk.metalLight,
                      height: 44,
                      onTap: () => Navigator.pop(ctx),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MetalButton(
                      label: 'GENERATE',
                      color: Sk.redBright,
                      height: 44,
                      icon: Icons.link_rounded,
                      onTap: () {
                        final num = phoneCtrl.text.trim();
                        if (num.isEmpty) {
                          _toast('Masukkan nomor telepon', error: true);
                          return;
                        }
                        Navigator.pop(ctx);
                        _addSender(num);
                      },
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

  void _showPairingCodeDialog(String number, String code) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: _PairingDialogContent(
          number: number,
          code: code,
          onClose: () {
            Navigator.pop(ctx);
            _fetchSenders();
          },
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirm(Map<String, dynamic> sender) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: _SoftPanel(
          padding: const EdgeInsets.all(20),
          accent: Sk.redBright,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Sk.redBright.withOpacity(0.15),
                  border: Border.all(
                      color: Sk.redBright.withOpacity(0.5), width: 1.5),
                ),
                child: const Icon(Icons.delete_forever_rounded,
                    color: Sk.redBright, size: 26),
              ),
              const SizedBox(height: 14),
              const Text(
                'HAPUS SENDER?',
                style: TextStyle(
                  color: Sk.redBright,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Orbitron',
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Sender '${sender['sessionName'] ?? sender['id']}' akan dihapus permanen.",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Sk.cream,
                  fontSize: 11,
                  fontFamily: 'ShareTechMono',
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _MetalButton(
                      label: 'BATAL',
                      color: Sk.metalLight,
                      height: 44,
                      onTap: () => Navigator.pop(ctx, false),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MetalButton(
                      label: 'HAPUS',
                      color: Sk.redBright,
                      height: 44,
                      icon: Icons.delete_outline_rounded,
                      onTap: () => Navigator.pop(ctx, true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed == true) _deleteSender(sender['id']);
  }

  // ─── BUILD ─────────────────────────────────────────────────
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
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFAB(),
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
          border: Border.all(color: Sk.metalLight, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.6),
              offset: const Offset(0, 3),
              blurRadius: 6,
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
              const _Led(color: Sk.greenHi, size: 7),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'BUG SENDER',
                      style: TextStyle(
                        color: Sk.brass,
                        fontFamily: 'Orbitron',
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
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
                    const SizedBox(height: 1),
                    Text(
                      '${senderList.length} sender aktif',
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
              _MetalIconButton(
                icon: isRefreshing
                    ? Icons.hourglass_top_rounded
                    : Icons.refresh_rounded,
                onTap: isLoading ? null : _refreshSenders,
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
  // BODY
  // ═══════════════════════════════════════════════════════════
  Widget _buildBody() {
    if (isLoading && senderList.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Sk.brass, strokeWidth: 2),
      );
    }
    if (errorMessage != null && senderList.isEmpty) {
      return _buildErrorState();
    }
    if (senderList.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      color: Sk.brass,
      backgroundColor: Sk.metalDark,
      onRefresh: _refreshSenders,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 100),
        itemCount: senderList.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _buildStatStrip(),
            );
          }
          return _buildSenderCard(
            Map<String, dynamic>.from(senderList[index - 1]),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // STAT STRIP
  // ═══════════════════════════════════════════════════════════
  Widget _buildStatStrip() {
    return _SoftPanel(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          const _Led(color: Sk.greenHi, size: 7),
          const SizedBox(width: 10),
          const Icon(Icons.wifi_tethering_rounded,
              color: Sk.brass, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${senderList.length} SENDER TERDAFTAR',
              style: const TextStyle(
                color: Sk.brass,
                fontSize: 11,
                fontFamily: 'Orbitron',
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Sk.green.withOpacity(0.2),
              border: Border.all(
                  color: Sk.greenHi.withOpacity(0.5), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _Led(color: Sk.greenGlow, size: 5),
                const SizedBox(width: 5),
                const Text(
                  'LIVE',
                  style: TextStyle(
                    color: Sk.greenGlow,
                    fontSize: 8,
                    fontFamily: 'Orbitron',
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // SENDER CARD
  // ═══════════════════════════════════════════════════════════
  Widget _buildSenderCard(Map<String, dynamic> sender) {
    final name = sender['sessionName'] ?? 'WhatsApp Sender';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Sk.leather, Sk.leatherDark],
        ),
        border: Border.all(color: Sk.metalLight, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
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
      child: Stack(
        children: [
          // Corner rivets
          const Positioned(top: 4, left: 4, child: _Rivet(size: 5)),
          const Positioned(top: 4, right: 4, child: _Rivet(size: 5)),
          const Positioned(bottom: 4, left: 4, child: _Rivet(size: 5)),
          const Positioned(bottom: 4, right: 4, child: _Rivet(size: 5)),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                // Top row
                Row(
                  children: [
                    // WhatsApp avatar housing
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Sk.greenDeep.withOpacity(0.5),
                            border: Border.all(
                                color: Sk.greenHi.withOpacity(0.5),
                                width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Sk.greenGlow.withOpacity(0.2),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: FaIcon(
                              FontAwesomeIcons.whatsapp,
                              color: Sk.greenGlow,
                              size: 22,
                            ),
                          ),
                        ),
                        Positioned(
                          right: -2,
                          bottom: -2,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Sk.metalDark,
                            ),
                            child:
                                const _Led(color: Sk.greenGlow, size: 8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),

                    // Name + status
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              color: Sk.cream,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Orbitron',
                              letterSpacing: 0.5,
                              shadows: [
                                Shadow(
                                  color: Colors.black,
                                  offset: Offset(0, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const _Led(color: Sk.greenGlow, size: 5),
                              const SizedBox(width: 5),
                              Text(
                                'CONNECTED',
                                style: TextStyle(
                                  color: Sk.greenGlow,
                                  fontSize: 8,
                                  fontFamily: 'Orbitron',
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Sk.green.withOpacity(0.2),
                        border: Border.all(
                            color: Sk.greenHi.withOpacity(0.5),
                            width: 1),
                      ),
                      child: const Text(
                        'ACTIVE',
                        style: TextStyle(
                          color: Sk.greenGlow,
                          fontSize: 7,
                          fontFamily: 'Orbitron',
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Divider
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Sk.brass.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: _MetalButton(
                        label: 'REFRESH',
                        color: Sk.brass,
                        height: 40,
                        icon: Icons.refresh_rounded,
                        onTap: _refreshSenders,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _MetalButton(
                        label: 'HAPUS',
                        color: Sk.redBright,
                        height: 40,
                        icon: Icons.delete_outline_rounded,
                        onTap: () => _showDeleteConfirm(sender),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // EMPTY STATE
  // ═══════════════════════════════════════════════════════════
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: _SoftPanel(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Sk.metalMid, Sk.metalDark],
                      ),
                      border: Border.all(
                          color: Sk.greenHi.withOpacity(0.5), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Sk.greenGlow.withOpacity(0.2),
                          blurRadius: 15,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: FaIcon(
                        FontAwesomeIcons.whatsapp,
                        color: Sk.greenGlow,
                        size: 34,
                      ),
                    ),
                  ),
                  const Positioned(
                    top: 4,
                    right: 4,
                    child: _Led(color: Sk.greenGlow, size: 10),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'BELUM ADA SENDER',
                style: TextStyle(
                  color: Sk.brass,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Orbitron',
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
              const SizedBox(height: 10),
              Text(
                'Tambah WhatsApp sender pertama\nuntuk mulai mengirim pesan.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Sk.cream.withOpacity(0.6),
                  fontSize: 11,
                  fontFamily: 'ShareTechMono',
                  fontWeight: FontWeight.w700,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),
              _MetalButton(
                label: 'TAMBAH SENDER',
                color: Sk.redBright,
                height: 46,
                icon: Icons.add_rounded,
                onTap: _showAddSenderDialog,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ERROR STATE
  // ═══════════════════════════════════════════════════════════
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: _SoftPanel(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          accent: Sk.redBright,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Sk.redBright.withOpacity(0.15),
                  border: Border.all(
                      color: Sk.redBright.withOpacity(0.5), width: 1.5),
                ),
                child: const Icon(Icons.wifi_off_rounded,
                    color: Sk.redBright, size: 28),
              ),
              const SizedBox(height: 16),
              const Text(
                'KONEKSI GAGAL',
                style: TextStyle(
                  color: Sk.redBright,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Orbitron',
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                errorMessage ?? 'Unknown error',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Sk.cream,
                  fontSize: 11,
                  fontFamily: 'ShareTechMono',
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              _MetalButton(
                label: 'COBA LAGI',
                color: Sk.brass,
                height: 44,
                icon: Icons.refresh_rounded,
                onTap: _fetchSenders,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // FAB
  // ═══════════════════════════════════════════════════════════
  Widget _buildFAB() {
    return GestureDetector(
      onTap: _showAddSenderDialog,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Sk.redHi, Sk.redBright, Sk.red, Sk.redDeep],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
          border: Border.all(color: Sk.redDeep, width: 2),
          boxShadow: [
            BoxShadow(
              color: Sk.redGlow.withOpacity(0.4),
              blurRadius: 16,
              spreadRadius: -2,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.6),
              offset: const Offset(0, 4),
              blurRadius: 8,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Top shine
            Positioned(
              top: 4,
              left: 10,
              right: 10,
              child: Container(
                height: 10,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.4),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            const Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 26,
              shadows: [
                Shadow(
                  color: Colors.black54,
                  offset: Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// PAIRING DIALOG CONTENT
// ═══════════════════════════════════════════════════════════
class _PairingDialogContent extends StatefulWidget {
  final String number;
  final String code;
  final VoidCallback onClose;

  const _PairingDialogContent({
    required this.number,
    required this.code,
    required this.onClose,
  });

  @override
  State<_PairingDialogContent> createState() => _PairingDialogContentState();
}

class _PairingDialogContentState extends State<_PairingDialogContent> {
  bool _copied = false;

  @override
  Widget build(BuildContext context) {
    return _SoftPanel(
      padding: const EdgeInsets.all(20),
      accent: Sk.redBright,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header icon
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Sk.redBright.withOpacity(0.15),
                  border: Border.all(
                      color: Sk.redBright.withOpacity(0.5), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Sk.redGlow.withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Icon(Icons.phonelink_lock_rounded,
                    color: Sk.redBright, size: 26),
              ),
              const Positioned(
                top: 0,
                right: 0,
                child: _Led(color: Sk.redGlow, size: 10),
              ),
            ],
          ),
          const SizedBox(height: 14),

          const Text(
            'KODE PAIRING',
            style: TextStyle(
              color: Sk.brass,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              fontFamily: 'Orbitron',
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
          const SizedBox(height: 4),
          Text(
            'Nomor: ${widget.number}',
            style: TextStyle(
              color: Sk.cream.withOpacity(0.6),
              fontSize: 10,
              fontFamily: 'ShareTechMono',
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 18),

          // Code box (inset)
          _SoftInset(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Text(
              widget.code,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Sk.brass,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: 10,
                fontFamily: 'monospace',
                shadows: [
                  Shadow(
                    color: Sk.redGlow,
                    offset: Offset(0, 0),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Copy button
          GestureDetector(
            onTap: _copied
                ? null
                : () async {
                    await Clipboard.setData(
                        ClipboardData(text: widget.code));
                    if (mounted) setState(() => _copied = true);
                  },
            child: Container(
              width: double.infinity,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: _copied
                      ? [Sk.greenHi, Sk.green]
                      : [Sk.metalLight, Sk.metalMid, Sk.metalDark],
                ),
                border: Border.all(
                  color: _copied ? Sk.green : Sk.metalDark,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    offset: const Offset(0, 3),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _copied ? Icons.check_rounded : Icons.copy_rounded,
                    color: _copied ? Colors.white : Sk.brass,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _copied ? 'DISALIN!' : 'SALIN KODE',
                    style: TextStyle(
                      color: _copied ? Colors.white : Sk.brass,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Orbitron',
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Instruction
          _SoftInset(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: Sk.brass, size: 14),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Buka WhatsApp → Linked Devices → Link a device → Enter code',
                    style: TextStyle(
                      color: Sk.cream.withOpacity(0.7),
                      fontSize: 9,
                      fontFamily: 'ShareTechMono',
                      fontWeight: FontWeight.w700,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Close button
          _MetalButton(
            label: 'SELESAI & REFRESH',
            color: Sk.greenHi,
            height: 44,
            icon: Icons.check_rounded,
            onTap: widget.onClose,
          ),
        ],
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
            // Corner rivets
            const Positioned(top: 4, left: 4, child: _Rivet(size: 5)),
            const Positioned(top: 4, right: 4, child: _Rivet(size: 5)),
            const Positioned(bottom: 4, left: 4, child: _Rivet(size: 5)),
            const Positioned(bottom: 4, right: 4, child: _Rivet(size: 5)),

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
// METAL ICON BUTTON
// ═══════════════════════════════════════════════════════════
class _MetalIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;
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
      onTapDown: widget.onTap == null
          ? null
          : (_) => setState(() => _pressed = true),
      onTapUp: widget.onTap == null
          ? null
          : (_) {
              setState(() => _pressed = false);
              widget.onTap?.call();
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
          color: widget.onTap == null
              ? Sk.metalDark
              : Sk.brass,
          size: widget.size * 0.42,
        ),
      ),
    );
  }
}