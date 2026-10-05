import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';
// ─── PALETTE (selaras dengan dashboard) ──────────────────────
class _C {
  static const bg      = Color(0xFF000000);
  static const surface = Color(0xFF070707);
  static const card    = Color(0xFF0C0C0C);
  static const line    = Color(0xFF181818);
  static const red     = Color(0xFFFF0040);
  static const muted   = Color(0xFF555555);
  static const dim     = Color(0xFF282828);
  static const white   = Color(0xFFFFFFFF);
}

class InfoPage extends StatefulWidget {
  final String sessionKey;
  const InfoPage({super.key, required this.sessionKey});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> with TickerProviderStateMixin {
  bool isLoading = true;

  bool isApiOnline = false;
  int apiPingMs    = 0;
  Color apiStatusColor = _C.dim;
  String apiStatusText = "CHECKING...";
  Timer? _pingTimer;

  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;
  late AnimationController _glowCtrl;
  late Animation<double> _glow;

  final List<Map<String, dynamic>> rulesList = [
    {
      "title": "NO ACCOUNT BARTERING",
      "icon": Icons.swap_horizontal_circle_outlined,
      "desc":
          "Akun eksklusif Null Tr4sher tidak boleh ditukar dengan barang, jasa, atau akun lain dalam bentuk apa pun. Pelanggaran log akan terpantau.",
    },
    {
      "title": "STRICTLY PERSONAL USE",
      "icon": Icons.person_off_outlined,
      "desc":
          "Setiap akun terenkripsi untuk satu pengguna dan hanya boleh diakses oleh pemilik perangkat yang mendaftar (terikat Device ID).",
    },
    {
      "title": "RESELLING PROHIBITED",
      "icon": Icons.money_off_csred_outlined,
      "desc":
          "Member reguler dilarang memperjualbelikan akun. Akses penjualan eksklusif milik role berwenang (Partner, Owner, atau Reseller).",
    },
    {
      "title": "ILLEGAL DURATION SALES",
      "icon": Icons.timer_off_outlined,
      "desc":
          "Sangat dilarang membagi atau menjual akses eceran (harian, mingguan, trial) yang mengelabui skema periode resmi.",
    },
    {
      "title": "PRICE DUMPING BAN",
      "icon": Icons.trending_down_rounded,
      "desc":
          "Dilarang keras merusak standar harga pasar (banting harga) di bawah kesepakatan jaminan keamanan platform kami.",
    },
  ];

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.2, end: 1.0).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _glowCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _glow = Tween<double>(begin: 0.15, end: 1.0).animate(
        CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));

    _fetchServerInfo();
    _startApiPingLoop();
  }

  @override
  void dispose() {
    _pingTimer?.cancel();
    _pulseCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchServerInfo() async {
    try {
      await http
          .get(Uri.parse(
              '$baseUrl/getServerInfo?key=${widget.sessionKey}'))
          .timeout(const Duration(seconds: 5));
      if (mounted) setState(() => isLoading = false);
    } catch (_) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _startApiPingLoop() {
    _checkApiPing();
    _pingTimer =
        Timer.periodic(const Duration(seconds: 5), (_) => _checkApiPing());
  }

  Future<void> _checkApiPing() async {
    final start = DateTime.now();
    try {
      final res = await http
          .get(Uri.parse(
              '$baseUrl/ping?key=${widget.sessionKey}'))
          .timeout(const Duration(seconds: 3));
      final duration = DateTime.now().difference(start).inMilliseconds;

      if (res.statusCode == 200 && mounted) {
        setState(() {
          isApiOnline    = true;
          apiPingMs      = duration;
          apiStatusColor = _C.red;
          apiStatusText  = "SYS.ONLINE  ::  ${duration}ms";
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          isApiOnline    = false;
          apiPingMs      = 0;
          apiStatusColor = _C.muted;
          apiStatusText  = "SYS.OFFLINE  ::  UNREACHABLE";
        });
      }
    }
  }

  // ─── LOADING ──────────────────────────────────────────────
  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: _C.bg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _pulse,
              builder: (_, __) => Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _C.red.withValues(alpha: 0.3 + _pulse.value * 0.5),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _C.red.withValues(alpha: _pulse.value * 0.25),
                      blurRadius: 30,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _C.red,
                    backgroundColor: _C.dim,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              "AUTHENTICATING",
              style: TextStyle(
                color: _C.muted,
                fontFamily: 'Orbitron',
                fontWeight: FontWeight.w700,
                fontSize: 11,
                letterSpacing: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── STATUS HEADER ────────────────────────────────────────
  Widget _buildStatusHeader() {
    return AnimatedBuilder(
      animation: _glow,
      builder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: apiStatusColor.withValues(
                alpha: 0.15 + _glow.value * 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: apiStatusColor.withValues(alpha: _glow.value * 0.05),
              blurRadius: 30,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            // Status dot
            AnimatedBuilder(
              animation: _pulse,
              builder: (_, __) => Container(
                width: 10, height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: apiStatusColor,
                  boxShadow: [
                    BoxShadow(
                      color: apiStatusColor.withValues(
                          alpha: _pulse.value * 0.7),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    apiStatusText,
                    style: TextStyle(
                      color: isApiOnline ? _C.red : _C.muted,
                      fontFamily: 'ShareTechMono',
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isApiOnline ? "CONNECTION STABLE" : "NO SIGNAL",
                    style: TextStyle(
                      color: _C.muted.withValues(alpha: 0.5),
                      fontFamily: 'ShareTechMono',
                      fontSize: 9,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _C.dim.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _C.line),
              ),
              child: Icon(Icons.memory,
                  color: _C.muted.withValues(alpha: 0.5), size: 16),
            ),
          ],
        ),
      ),
    );
  }

  // ─── SECTION TITLE ────────────────────────────────────────
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 4),
      child: Row(
        children: [
          Container(
            width: 3, height: 14,
            decoration: BoxDecoration(
              color: _C.red,
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: _C.red.withValues(alpha: 0.5),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              color: _C.muted,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 3,
              fontFamily: 'ShareTechMono',
            ),
          ),
        ],
      ),
    );
  }

  // ─── RULE CARD ────────────────────────────────────────────
  Widget _buildRuleCard(int index, Map<String, dynamic> rule) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.line),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Index + icon column
                Column(
                  children: [
                    // Number badge
                    Container(
                      width: 46, height: 46,
                      decoration: BoxDecoration(
                        color: _C.red.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: _C.red.withValues(alpha: 0.15)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(rule['icon'] as IconData,
                              color: _C.red.withValues(alpha: 0.7), size: 19),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Rule number + title
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "0${index + 1}",
                            style: TextStyle(
                              color: _C.red.withValues(alpha: 0.35),
                              fontFamily: 'Orbitron',
                              fontWeight: FontWeight.w900,
                              fontSize: 9,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                              width: 1, height: 10, color: _C.line),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              rule['title'] as String,
                              style: const TextStyle(
                                color: _C.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                                fontFamily: 'Orbitron',
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 9),
                      Text(
                        rule['desc'] as String,
                        style: TextStyle(
                          color: _C.muted,
                          fontSize: 12,
                          height: 1.65,
                          fontFamily: 'ShareTechMono',
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

  // ─── PENALTY BOX ──────────────────────────────────────────
  Widget _buildPenaltyBox() {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 14, bottom: 28),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: _C.red.withValues(
                alpha: 0.18 + _pulse.value * 0.12),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: _C.red.withValues(alpha: _pulse.value * 0.05),
              blurRadius: 40,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Badge
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: _C.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: _C.red.withValues(alpha: 0.25)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: _C.red, size: 17),
                  SizedBox(width: 8),
                  Text(
                    "VIOLATION PENALTY",
                    style: TextStyle(
                      color: _C.red,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Orbitron',
                      letterSpacing: 1.8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Horizontal separator
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  Colors.transparent,
                  _C.line,
                  Colors.transparent,
                ]),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Jika pengguna terdeteksi melanggar salah satu protokol kerahasiaan & aturan di atas secara sengaja:",
              style: TextStyle(
                color: _C.muted,
                fontSize: 12,
                fontFamily: 'ShareTechMono',
                height: 1.7,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            // Penalty result card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: _C.red.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: _C.red.withValues(alpha: 0.2)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete_forever_rounded,
                      color: _C.red, size: 20),
                  SizedBox(width: 10),
                  Text(
                    "AKUN DIHAPUS PERMANEN",
                    style: TextStyle(
                      color: _C.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Orbitron',
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "TIDAK ADA PENGEMBALIAN SALDO ATAU KOMPENSASI.",
              style: TextStyle(
                color: _C.muted.withValues(alpha: 0.6),
                fontSize: 9,
                fontFamily: 'ShareTechMono',
                letterSpacing: 1,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ─── FOOTER ───────────────────────────────────────────────
  Widget _buildFooter() {
    return Column(
      children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _C.card,
            border: Border.all(color: _C.line),
          ),
          child: const Center(
            child: Icon(Icons.shield_moon_rounded,
                color: _C.dim, size: 22),
          ),
        ),
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Peraturan ini dibuat semata-mata untuk menjaga keamanan, kenyamanan, dan kestabilan ekosistem server XTROVIE. Dengan mengakses aplikasi, Anda secara otomatis menyetujui seluruh protokol di atas.",
            style: TextStyle(
              color: _C.muted.withValues(alpha: 0.45),
              fontSize: 11,
              fontStyle: FontStyle.italic,
              fontFamily: 'ShareTechMono',
              height: 1.75,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 22),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 28, height: 1, color: _C.line),
            const SizedBox(width: 8),
            Container(
              width: 4, height: 4,
              decoration: const BoxDecoration(
                  color: _C.dim, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Container(width: 28, height: 1, color: _C.line),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          "XTROVIE © ${DateTime.now().year}",
          style: TextStyle(
            color: _C.muted.withValues(alpha: 0.3),
            fontSize: 9,
            fontFamily: 'Orbitron',
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  // ─── BUILD ────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (isLoading) return _buildLoadingScreen();

    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── AppBar ─────────────────────────────────────
            SliverAppBar(
              backgroundColor: _C.bg,
              elevation: 0,
              pinned: true,
              automaticallyImplyLeading: false,
              expandedHeight: 64,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.symmetric(
                    horizontal: 22, vertical: 14),
                title: Row(
                  children: [
                    AnimatedBuilder(
                      animation: _pulse,
                      builder: (_, __) => Container(
                        width: 6, height: 6,
                        decoration: BoxDecoration(
                          color: _C.red,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _C.red.withValues(
                                  alpha: _pulse.value * 0.7),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "EULA & SYSTEM INFO",
                      style: TextStyle(
                        color: _C.white,
                        fontFamily: 'Orbitron',
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                centerTitle: false,
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Colors.transparent,
                      _C.red.withValues(alpha: 0.18),
                      Colors.transparent,
                    ]),
                  ),
                ),
              ),
            ),

            // ── Content ────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 18, vertical: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildStatusHeader(),
                  _buildSectionTitle("USER PROTOCOLS"),
                  ...rulesList
                      .asMap()
                      .entries
                      .map((e) => _buildRuleCard(e.key, e.value))
                      .toList(),
                  _buildPenaltyBox(),
                  _buildFooter(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
