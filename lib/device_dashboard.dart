import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'control_panel.dart';
import 'api_config.dart';

// ═══════════════════════════════════════════════════════════
// SOFT SKEUOMORPHISM PALETTE — MILITARY RED EDITION
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

  // Red (primary accent)
  static const Color redDeep     = Color(0xFF3D0808);
  static const Color red         = Color(0xFF8B1818);
  static const Color redBright   = Color(0xFFC41E1E);
  static const Color redGlow     = Color(0xFFFF3030);
  static const Color redHi       = Color(0xFFFF4D47);

  // Green (online/success)
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
// MODELS
// ═══════════════════════════════════════════════════════════
class PermissionResult {
  final bool approved;
  final bool allDevices;
  final List<String> devices;

  PermissionResult({
    required this.approved,
    required this.allDevices,
    required this.devices,
  });

  factory PermissionResult.fromJson(Map<String, dynamic> json) {
    return PermissionResult(
      approved: json['approved'] == true,
      allDevices: json['allDevices'] == true,
      devices: List<String>.from(json['devices'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'approved': approved,
        'allDevices': allDevices,
        'devices': devices,
      };
}

class DevicePermissionStore {
  static Future<Map<String, dynamic>> getAll(String sessionKey) async => {};
  static Future<PermissionResult> getFor(
          String username, String sessionKey) async =>
      PermissionResult(approved: true, allDevices: true, devices: []);
  static Future<bool> setPerm(String sessionKey, String username,
          {required bool approved,
          required bool allDevices,
          required List<String> devices}) async =>
      true;
  static Future<bool> removePerm(String sessionKey, String username) async =>
      true;
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
// PAIRING INFO PAGE
// ═══════════════════════════════════════════════════════════
class _PairingInfoPage extends StatelessWidget {
  final String pairId;
  final VoidCallback onCopy;
  final bool isOwner;

  const _PairingInfoPage({
    required this.pairId,
    required this.onCopy,
    required this.isOwner,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pairing ID panel
          _SoftPanel(
            padding: const EdgeInsets.all(14),
            accent: Sk.redBright.withOpacity(0.6),
            child: Column(
              children: [
                Row(
                  children: [
                    const _Screw(size: 10),
                    const SizedBox(width: 8),
                    const _Led(color: Sk.redGlow, size: 8),
                    const SizedBox(width: 8),
                    const Text(
                      'PAIRING ID',
                      style: TextStyle(
                        color: Sk.brass,
                        fontSize: 11,
                        fontFamily: 'Orbitron',
                        fontWeight: FontWeight.w900,
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
                    const Spacer(),
                    const _Screw(size: 10),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _SoftInset(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color: Sk.redDeep,
                                border: Border.all(
                                    color: Sk.redGlow.withOpacity(0.5),
                                    width: 1),
                              ),
                              child: const Icon(Icons.link_rounded,
                                  color: Sk.redGlow, size: 14),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                pairId.isEmpty ? 'MEMUAT...' : pairId,
                                style: const TextStyle(
                                  color: Sk.cream,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'ShareTechMono',
                                  letterSpacing: 3,
                                  shadows: [
                                    Shadow(
                                      color: Sk.redGlow,
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (pairId.isNotEmpty)
                      GestureDetector(
                        onTap: onCopy,
                        child: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Sk.redHi,
                                Sk.redBright,
                                Sk.red,
                                Sk.redDeep,
                              ],
                            ),
                            border: Border.all(
                                color: Sk.redDeep, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Sk.redGlow.withOpacity(0.4),
                                blurRadius: 12,
                                spreadRadius: 0,
                              ),
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                offset: const Offset(0, 3),
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.copy_rounded,
                              color: Colors.white, size: 18),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Section header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                const _Led(color: Sk.brass, size: 7),
                const SizedBox(width: 10),
                const Text(
                  'CARA MENAUTKAN DEVICE',
                  style: TextStyle(
                    color: Sk.brass,
                    fontSize: 11,
                    fontFamily: 'Orbitron',
                    fontWeight: FontWeight.w900,
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
          ),
          const SizedBox(height: 12),

          _StepCard(
            number: 1,
            title: 'INSTALL APK',
            description: 'Install aplikasi target di perangkat',
            icon: Icons.download_rounded,
            color: Sk.redBright,
          ),
          const SizedBox(height: 10),
          _StepCard(
            number: 2,
            title: 'MASUKKAN PAIRING ID',
            description: 'Buka aplikasi lalu masukkan ID di atas',
            icon: Icons.qr_code_scanner_rounded,
            color: Sk.amberHi,
          ),
          const SizedBox(height: 10),
          _StepCard(
            number: 3,
            title: 'BERI IZIN AKSES',
            description: 'Izinkan semua permission yang diminta',
            icon: Icons.security_rounded,
            color: Sk.cyanHi,
          ),
          const SizedBox(height: 10),
          _StepCard(
            number: 4,
            title: 'SELESAI',
            description: 'Device akan muncul di halaman Devices',
            icon: Icons.check_circle_rounded,
            color: Sk.greenHi,
          ),

          const SizedBox(height: 18),

          // Important note
          _SoftPanel(
            padding: const EdgeInsets.all(14),
            accent: Sk.amberHi.withOpacity(0.5),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Sk.amberDeep,
                    border: Border.all(
                        color: Sk.amberHi.withOpacity(0.6), width: 1),
                  ),
                  child: const Icon(Icons.info_rounded,
                      color: Sk.amberHi, size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CATATAN PENTING',
                        style: TextStyle(
                          color: Sk.amberHi,
                          fontSize: 9,
                          fontFamily: 'Orbitron',
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID Pairing hanya dimiliki Owner. Jangan bagikan ke orang yang tidak dikenal.',
                        style: TextStyle(
                          color: Sk.cream.withOpacity(0.65),
                          fontSize: 10,
                          fontFamily: 'ShareTechMono',
                          fontWeight: FontWeight.w700,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (!isOwner) ...[
            const SizedBox(height: 12),
            _SoftPanel(
              padding: const EdgeInsets.all(14),
              accent: Sk.amberHi.withOpacity(0.5),
              child: Row(
                children: [
                  const Icon(Icons.lock_rounded,
                      color: Sk.amberHi, size: 16),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Anda bukan Owner, ID Pairing tidak tersedia.',
                      style: TextStyle(
                        color: Sk.amberHi,
                        fontSize: 10,
                        fontFamily: 'ShareTechMono',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final int number;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const _StepCard({
    required this.number,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Sk.leather, Sk.leatherDark],
        ),
        border: Border.all(color: color.withOpacity(0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            offset: const Offset(0, 3),
            blurRadius: 6,
          ),
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned(top: 4, left: 4, child: _Rivet(size: 4)),
          const Positioned(top: 4, right: 4, child: _Rivet(size: 4)),
          const Positioned(bottom: 4, left: 4, child: _Rivet(size: 4)),
          const Positioned(bottom: 4, right: 4, child: _Rivet(size: 4)),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Number badge
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withOpacity(0.9),
                        color.withOpacity(0.6),
                        color.withOpacity(0.9),
                      ],
                    ),
                    border: Border.all(
                        color: color.withOpacity(0.9), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 10,
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        offset: const Offset(0, 2),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '$number',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Orbitron',
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
                const SizedBox(width: 12),

                // Icon housing
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.15),
                    border: Border.all(
                        color: color.withOpacity(0.6), width: 1.2),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Sk.cream,
                          fontSize: 11,
                          fontFamily: 'Orbitron',
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
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
                      const SizedBox(height: 3),
                      Text(
                        description,
                        style: TextStyle(
                          color: Sk.cream.withOpacity(0.55),
                          fontSize: 9,
                          fontFamily: 'ShareTechMono',
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Sk.metalLight,
                  size: 12,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// DEVICE LIST PAGE
// ═══════════════════════════════════════════════════════════
class _DeviceListPage extends StatefulWidget {
  final List<dynamic> devices;
  final String role;
  final bool isOwner;
  final PermissionResult? perm;
  final bool denied;
  final VoidCallback onRefresh;

  const _DeviceListPage({
    required this.devices,
    required this.role,
    required this.isOwner,
    required this.perm,
    required this.denied,
    required this.onRefresh,
  });

  @override
  State<_DeviceListPage> createState() => _DeviceListPageState();
}

class _DeviceListPageState extends State<_DeviceListPage> {
  List<dynamic> _selectedDevices = [];
  bool _isManagementMode = false;

  void _toggleSelection(String deviceId) {
    setState(() {
      if (_selectedDevices.contains(deviceId)) {
        _selectedDevices.remove(deviceId);
      } else {
        _selectedDevices.add(deviceId);
      }
    });
  }

  void _toggleManagementMode() {
    setState(() {
      _isManagementMode = !_isManagementMode;
      _selectedDevices.clear();
    });
  }

  void _toast(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Sk.metalDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: color.withOpacity(0.6), width: 1.5),
        ),
        margin: const EdgeInsets.all(14),
        content: Row(
          children: [
            _Led(color: color, size: 8),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                msg,
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
      ),
    );
  }

  Future<bool> _confirmDelete({
    required String title,
    required String message,
    required Color color,
    String confirmLabel = 'HAPUS',
  }) async {
    final result = await showDialog<bool>(
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.15),
                  border: Border.all(
                      color: color.withOpacity(0.6), width: 1.5),
                ),
                child: Icon(Icons.delete_forever_rounded,
                    color: color, size: 26),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontFamily: 'Orbitron',
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.8,
                  shadows: const [
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
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Sk.cream.withOpacity(0.65),
                  fontSize: 10,
                  fontFamily: 'ShareTechMono',
                  fontWeight: FontWeight.w700,
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
                      height: 42,
                      onTap: () => Navigator.pop(context, false),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MetalButton(
                      label: confirmLabel,
                      color: color,
                      height: 42,
                      icon: Icons.delete_outline_rounded,
                      onTap: () => Navigator.pop(context, true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return result == true;
  }

  Future<void> _deleteSingleDevice(
      String deviceId, String deviceName) async {
    final confirmed = await _confirmDelete(
      title: 'HAPUS DEVICE',
      message: 'Hapus device "$deviceName"?\nTindakan ini tidak bisa dibatalkan!',
      color: Sk.redBright,
    );
    if (!confirmed) return;

    try {
      final response = await http.delete(Uri.parse(
              '$baseUrl/rat/delete-device?key=${widget.role}&deviceId=$deviceId'))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          widget.onRefresh();
          _toast('Device berhasil dihapus!', Sk.greenHi);
          return;
        }
      }
      _toast('Gagal menghapus device', Sk.redBright);
    } catch (e) {
      _toast('Error: $e', Sk.redBright);
    }
  }

  Future<void> _deleteSelectedDevices() async {
    if (_selectedDevices.isEmpty) return;

    final confirmed = await _confirmDelete(
      title: 'HAPUS DEVICE',
      message:
          'Yakin ingin menghapus ${_selectedDevices.length} device?\nTindakan ini tidak bisa dibatalkan!',
      color: Sk.redBright,
    );
    if (!confirmed) return;

    setState(() => _isManagementMode = false);

    try {
      List<String> failed = [];
      for (var deviceId in _selectedDevices) {
        final response = await http.delete(Uri.parse(
                '$baseUrl/rat/delete-device?key=${widget.role}&deviceId=$deviceId'))
            .timeout(const Duration(seconds: 8));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['success'] != true) failed.add(deviceId);
        } else {
          failed.add(deviceId);
        }
      }

      _selectedDevices.clear();
      widget.onRefresh();

      if (failed.isEmpty) {
        _toast('Semua device berhasil dihapus!', Sk.greenHi);
      } else {
        _toast('${failed.length} device gagal dihapus', Sk.amberHi);
      }
    } catch (e) {
      _toast('Error: $e', Sk.redBright);
    }
  }

  Future<void> _clearOfflineDevices() async {
    final offlineDevices =
        widget.devices.where((d) => d['online'] != true).toList();
    if (offlineDevices.isEmpty) {
      _toast('Tidak ada device offline untuk dihapus', Sk.amberHi);
      return;
    }

    final confirmed = await _confirmDelete(
      title: 'BERSIHKAN OFFLINE',
      message:
          'Hapus ${offlineDevices.length} device offline?\nTindakan ini tidak bisa dibatalkan!',
      color: Sk.amberHi,
      confirmLabel: 'HAPUS SEMUA',
    );
    if (!confirmed) return;

    try {
      List<String> failed = [];
      for (var device in offlineDevices) {
        final deviceId = device['id']?.toString() ?? '';
        if (deviceId.isNotEmpty) {
          final response = await http.delete(Uri.parse(
                  '$baseUrl/rat/delete-device?key=${widget.role}&deviceId=$deviceId'))
              .timeout(const Duration(seconds: 8));
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            if (data['success'] != true) failed.add(deviceId);
          } else {
            failed.add(deviceId);
          }
        }
      }
      widget.onRefresh();

      if (failed.isEmpty) {
        _toast(
            '${offlineDevices.length} device offline berhasil dibersihkan!',
            Sk.greenHi);
      } else {
        _toast('${failed.length} device gagal dihapus', Sk.amberHi);
      }
    } catch (e) {
      _toast('Error: $e', Sk.redBright);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeCount =
        widget.devices.where((d) => d['online'] == true).length;

    return Column(
      children: [
        // Stats panel
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
          child: _SoftPanel(
            padding: const EdgeInsets.all(12),
            accent: Sk.redBright.withOpacity(0.5),
            child: Column(
              children: [
                Row(
                  children: [
                    const _Screw(size: 10),
                    const SizedBox(width: 8),
                    const _Led(color: Sk.redGlow, size: 7),
                    const SizedBox(width: 8),
                    const Text(
                      'DEVICE STATUS',
                      style: TextStyle(
                        color: Sk.brass,
                        fontSize: 10,
                        fontFamily: 'Orbitron',
                        fontWeight: FontWeight.w900,
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
                    const Spacer(),
                    const _Screw(size: 10),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatBox(
                        label: 'ONLINE',
                        value: '$activeCount',
                        color: Sk.greenHi,
                        icon: Icons.wifi_rounded,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatBox(
                        label: 'OFFLINE',
                        value: '${widget.devices.length - activeCount}',
                        color: Sk.redBright,
                        icon: Icons.wifi_off_rounded,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatBox(
                        label: 'TOTAL',
                        value: '${widget.devices.length}',
                        color: Sk.brass,
                        icon: Icons.devices_rounded,
                      ),
                    ),
                  ],
                ),
                if (widget.isOwner && widget.devices.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _SmallActionButton(
                          label: _isManagementMode
                              ? 'BATAL PILIH'
                              : 'PILIH DEVICE',
                          color: _isManagementMode
                              ? Sk.redBright
                              : Sk.cyanHi,
                          icon: _isManagementMode
                              ? Icons.close_rounded
                              : Icons.checklist_rounded,
                          onTap: _toggleManagementMode,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _SmallActionButton(
                          label: 'BERSIHKAN OFFLINE',
                          color: Sk.amberHi,
                          icon: Icons.cleaning_services_rounded,
                          onTap: _clearOfflineDevices,
                        ),
                      ),
                    ],
                  ),
                  if (_isManagementMode && _selectedDevices.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _SmallActionButton(
                      label:
                          'HAPUS ${_selectedDevices.length} DEVICE TERPILIH',
                      color: Sk.redBright,
                      icon: Icons.delete_forever_rounded,
                      onTap: _deleteSelectedDevices,
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),

        // Device list
        Expanded(
          child: widget.devices.isEmpty
              ? _EmptyDeviceWidget(isOwner: widget.isOwner)
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 100),
                  physics: const BouncingScrollPhysics(),
                  itemCount: widget.devices.length,
                  itemBuilder: (ctx, i) {
                    final d = widget.devices[i];
                    final isOnline = d['online'] == true;
                    final deviceId = d['id']?.toString() ?? '';
                    final isSelected = _selectedDevices.contains(deviceId);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _DeviceCard(
                        device: d,
                        isOnline: isOnline,
                        role: widget.role,
                        isManagementMode: _isManagementMode,
                        isSelected: isSelected,
                        onToggleSelect: () => _toggleSelection(deviceId),
                        onDelete: () => _deleteSingleDevice(
                            deviceId, d['model'] ?? 'Unknown'),
                        isOwner: widget.isOwner,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
// STAT BOX
// ═══════════════════════════════════════════════════════════
class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatBox({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black.withOpacity(0.5),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              fontFamily: 'Orbitron',
              letterSpacing: 1,
              shadows: [
                Shadow(color: color.withOpacity(0.6), blurRadius: 6),
              ],
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Sk.cream.withOpacity(0.5),
              fontSize: 7,
              fontFamily: 'Orbitron',
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
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
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        padding: const EdgeInsets.symmetric(vertical: 8),
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
            colors: _pressed
                ? [
                    widget.color.withOpacity(0.4),
                    widget.color.withOpacity(0.2)
                  ]
                : [
                    widget.color.withOpacity(0.8),
                    widget.color.withOpacity(0.5)
                  ],
          ),
          border: Border.all(color: widget.color, width: 1.2),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.icon, color: Colors.white, size: 12),
            const SizedBox(width: 5),
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
// DEVICE CARD
// ═══════════════════════════════════════════════════════════
class _DeviceCard extends StatelessWidget {
  final dynamic device;
  final bool isOnline;
  final String role;
  final bool isManagementMode;
  final bool isSelected;
  final VoidCallback onToggleSelect;
  final VoidCallback onDelete;
  final bool isOwner;

  const _DeviceCard({
    required this.device,
    required this.isOnline,
    required this.role,
    required this.isManagementMode,
    required this.isSelected,
    required this.onToggleSelect,
    required this.onDelete,
    required this.isOwner,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = isOnline ? Sk.greenGlow : Sk.redBright;

    return GestureDetector(
      onTap: isManagementMode
          ? onToggleSelect
          : () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ControlCenterPage(
                      targetDevice: device, role: role),
                ),
              ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? [Sk.red, Sk.redDeep]
                : [Sk.leather, Sk.leatherDark],
          ),
          border: Border.all(
            color: isSelected
                ? Sk.brass
                : (isOnline ? statusColor.withOpacity(0.5) : Sk.metalLight),
            width: isSelected ? 1.8 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? Sk.redBright.withOpacity(0.35)
                  : Colors.black.withOpacity(0.5),
              offset: const Offset(0, 4),
              blurRadius: isSelected ? 10 : 6,
            ),
            if (isOnline && !isSelected)
              BoxShadow(
                color: Sk.greenGlow.withOpacity(0.15),
                blurRadius: 12,
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

            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Checkbox
                  if (isManagementMode) ...[
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? Sk.brass
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? Sk.brass
                              : Sk.metalLight,
                          width: 1.8,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check_rounded,
                              color: Sk.ink, size: 14)
                          : null,
                    ),
                    const SizedBox(width: 10),
                  ],

                  // Device icon housing
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Sk.metalMid.withOpacity(0.5),
                          border: Border.all(
                            color: isOnline
                                ? statusColor.withOpacity(0.6)
                                : Sk.metalLight,
                            width: 1.2,
                          ),
                          boxShadow: [
                            if (isOnline)
                              BoxShadow(
                                color: statusColor.withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: 0,
                              ),
                          ],
                        ),
                        child: Icon(
                          device['model']
                                      ?.toString()
                                      .toLowerCase()
                                      .contains('samsung') ==
                                  true
                              ? Icons.phone_android_rounded
                              : Icons.devices_rounded,
                          color: isOnline
                              ? Sk.greenGlow
                              : Sk.metalLight,
                          size: 20,
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: _Led(color: statusColor, size: 8),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),

                  // Device info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          device['model'] ?? 'Unknown Device',
                          style: TextStyle(
                            color: isOnline ? Sk.cream : Sk.cream.withOpacity(0.6),
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Orbitron',
                            letterSpacing: 0.3,
                            shadows: const [
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
                        const SizedBox(height: 3),
                        Text(
                          device['id'] ?? 'ID: ---',
                          style: TextStyle(
                            color: Sk.cream.withOpacity(0.4),
                            fontSize: 9,
                            fontFamily: 'ShareTechMono',
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(
                              Icons.battery_charging_full_rounded,
                              color: isOnline
                                  ? Sk.brass
                                  : Sk.metalLight,
                              size: 11,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${device['battery'] ?? '?'}%',
                              style: TextStyle(
                                color: isOnline
                                    ? Sk.brass
                                    : Sk.cream.withOpacity(0.4),
                                fontSize: 9,
                                fontFamily: 'ShareTechMono',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (!isOnline &&
                                device['lastSeen'] != null) ...[
                              const SizedBox(width: 8),
                              Text(
                                _formatLastSeen(device['lastSeen']),
                                style: TextStyle(
                                  color: Sk.cream.withOpacity(0.4),
                                  fontSize: 8,
                                  fontFamily: 'ShareTechMono',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Status + actions
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: isOnline
                              ? Sk.greenDeep
                              : Sk.redDeep,
                          border: Border.all(
                            color: statusColor.withOpacity(0.6),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _Led(color: statusColor, size: 5),
                            const SizedBox(width: 4),
                            Text(
                              isOnline ? 'ONLINE' : 'OFFLINE',
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 7,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'Orbitron',
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isManagementMode && isOwner) ...[
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: onDelete,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: Sk.redDeep,
                              border: Border.all(
                                  color: Sk.redBright.withOpacity(0.6),
                                  width: 1),
                            ),
                            child: const Icon(
                              Icons.delete_outline_rounded,
                              color: Sk.redGlow,
                              size: 12,
                            ),
                          ),
                        ),
                      ],
                      if (!isManagementMode) ...[
                        const SizedBox(height: 4),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Sk.metalLight,
                          size: 11,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatLastSeen(String? lastSeenStr) {
    if (lastSeenStr == null) return 'Never';
    try {
      final lastSeen = DateTime.parse(lastSeenStr);
      final diff = DateTime.now().difference(lastSeen);
      if (diff.inSeconds < 60) return '${diff.inSeconds}s';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m';
      if (diff.inHours < 24) return '${diff.inHours}h';
      return '${diff.inDays}d';
    } catch (_) {
      return 'Never';
    }
  }
}

// ═══════════════════════════════════════════════════════════
// EMPTY STATE
// ═══════════════════════════════════════════════════════════
class _EmptyDeviceWidget extends StatelessWidget {
  final bool isOwner;
  const _EmptyDeviceWidget({required this.isOwner});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: _SoftPanel(
          padding:
              const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                      color: Sk.redBright.withOpacity(0.4), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Sk.redGlow.withOpacity(0.15),
                      blurRadius: 15,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.devices_rounded,
                  size: 36,
                  color: Sk.metalLight,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'BELUM ADA DEVICE',
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
                'Tautkan device menggunakan ID Pairing\ndi halaman sebelumnya',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Sk.cream.withOpacity(0.55),
                  fontSize: 10,
                  fontFamily: 'ShareTechMono',
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                ),
              ),
              if (isOwner) ...[
                const SizedBox(height: 20),
                _SoftInset(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.swipe_left_rounded,
                          color: Sk.brass, size: 14),
                      const SizedBox(width: 8),
                      const Text(
                        'GESER KIRI UNTUK PAIRING ID',
                        style: TextStyle(
                          color: Sk.brass,
                          fontSize: 8,
                          fontFamily: 'Orbitron',
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
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
  final VoidCallback onTap;
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
            colors: [
              widget.color.withOpacity(0.9),
              widget.color,
              widget.color.withOpacity(0.7),
            ],
          ),
          border: Border.all(
            color: widget.color.withOpacity(0.9),
            width: 1.5,
          ),
          boxShadow: _pressed
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
                    Icon(widget.icon, color: Colors.white, size: 13),
                    const SizedBox(width: 5),
                  ],
                  Text(
                    widget.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
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
// PERMISSION BOTTOM SHEET (keep for compatibility)
// ═══════════════════════════════════════════════════════════
class _PermissionBottomSheet extends StatelessWidget {
  final String sessionKey;
  final List<dynamic> allDevices;

  const _PermissionBottomSheet({
    required this.sessionKey,
    required this.allDevices,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      padding: const EdgeInsets.all(20),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: Sk.metalLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Sk.greenDeep, Sk.green],
                ),
                border: Border.all(
                    color: Sk.greenGlow.withOpacity(0.6), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Sk.greenGlow.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: Sk.greenGlow, size: 40),
            ),
            const SizedBox(height: 16),
            const Text(
              'AKSES UNIVERSAL',
              style: TextStyle(
                color: Sk.brass,
                fontSize: 14,
                fontFamily: 'Orbitron',
                fontWeight: FontWeight.w900,
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
              'Semua user memiliki akses ke semua device',
              style: TextStyle(
                color: Sk.cream.withOpacity(0.6),
                fontSize: 11,
                fontFamily: 'ShareTechMono',
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),
            _MetalButton(
              label: 'TUTUP',
              color: Sk.greenHi,
              height: 44,
              icon: Icons.check_rounded,
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// MAIN DASHBOARD PAGE
// ═══════════════════════════════════════════════════════════
class DeviceDashboardPage extends StatefulWidget {
  final String username;
  final String role;
  final String sessionKey;

  const DeviceDashboardPage({
    super.key,
    this.username = '',
    this.role = '',
    this.sessionKey = '',
  });

  @override
  State<DeviceDashboardPage> createState() => _DDState();
}

class _DDState extends State<DeviceDashboardPage> {
  List<dynamic> _visible = [];
  bool _loading = true;
  String? _errorMsg;
  String _pairId = '';
  PermissionResult? _perm;
  Timer? _timer;
  late PageController _pageController;
  int _currentPage = 0;

  bool get _isOwner => widget.role.toLowerCase() == 'owner';
  bool get _denied => false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initialize();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    try {
      await _loadAll();
      _timer = Timer.periodic(
          const Duration(seconds: 20), (_) => _loadAll());
    } catch (e) {
      setState(() {
        _loading = false;
        _errorMsg = e.toString();
      });
    }
  }

  Future<void> _loadAll() async {
    if (!mounted) return;
    try {
      final pRes = await http
          .get(Uri.parse(
              '$baseUrl/rat/pairid?key=${widget.sessionKey}'))
          .timeout(const Duration(seconds: 8));
      if (pRes.statusCode == 200) {
        final pd = jsonDecode(pRes.body);
        if (pd['valid'] == true && pd['pairId'] != null) {
          if (mounted) {
            setState(() => _pairId = pd['pairId'].toString());
          }
        }
      }

      final dRes = await http
          .get(Uri.parse(
              '$baseUrl/rat/my-devices?key=${widget.sessionKey}'))
          .timeout(const Duration(seconds: 10));

      if (!mounted) return;
      if (dRes.statusCode != 200) {
        setState(() {
          _loading = false;
          _errorMsg = 'Server error ${dRes.statusCode}';
        });
        return;
      }

      final body = jsonDecode(dRes.body);
      if (body['valid'] != true) {
        setState(() {
          _loading = false;
          _errorMsg = body['message'] ?? 'Error';
        });
        return;
      }

      List<dynamic> devices =
          List<dynamic>.from(body['devices'] ?? []);
      final now = DateTime.now();
      for (var d in devices) {
        try {
          final seen =
              DateTime.parse(d['lastSeen']?.toString() ?? '');
          d['online'] = now.difference(seen).inSeconds < 30;
        } catch (_) {
          d['online'] = false;
        }
      }

      PermissionResult perm = PermissionResult(
          approved: true, allDevices: true, devices: []);

      if (mounted) {
        setState(() {
          _visible = devices;
          _perm = perm;
          _loading = false;
          _errorMsg = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _errorMsg = e.toString();
        });
      }
    }
  }

  void _copyPairId() {
    if (_pairId.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _pairId));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Sk.metalDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
              color: Sk.greenGlow.withOpacity(0.6), width: 1.5),
        ),
        margin: const EdgeInsets.all(14),
        content: Row(
          children: const [
            _Led(color: Sk.greenGlow, size: 8),
            SizedBox(width: 12),
            Text(
              'ID Pairing berhasil disalin!',
              style: TextStyle(
                color: Sk.cream,
                fontWeight: FontWeight.w700,
                fontSize: 11,
                fontFamily: 'ShareTechMono',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openPermissionBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (_) => _PermissionBottomSheet(
        sessionKey: widget.sessionKey,
        allDevices: _visible,
      ),
    );
  }

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
              _buildPageIndicator(),
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: Sk.brass, strokeWidth: 2),
                      )
                    : _errorMsg != null
                        ? _buildErrorView()
                        : Stack(
                            children: [
                              PageView(
                                controller: _pageController,
                                onPageChanged: (page) {
                                  setState(() => _currentPage = page);
                                },
                                children: [
                                  _PairingInfoPage(
                                    pairId: _pairId,
                                    onCopy: _copyPairId,
                                    isOwner: _isOwner,
                                  ),
                                  _DeviceListPage(
                                    devices: _visible,
                                    role: widget.role,
                                    isOwner: _isOwner,
                                    perm: _perm,
                                    denied: _denied,
                                    onRefresh: _loadAll,
                                  ),
                                ],
                              ),
                              if (_isOwner)
                                Positioned(
                                  right: 16,
                                  bottom: 16,
                                  child: GestureDetector(
                                    onTap: _openPermissionBottomSheet,
                                    child: Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: const LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Sk.greenHi,
                                            Sk.green,
                                            Sk.greenDeep,
                                          ],
                                        ),
                                        border: Border.all(
                                            color: Sk.greenDeep,
                                            width: 2),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Sk.greenGlow
                                                .withOpacity(0.4),
                                            blurRadius: 16,
                                            spreadRadius: -2,
                                          ),
                                          BoxShadow(
                                            color: Colors.black
                                                .withOpacity(0.6),
                                            offset: const Offset(0, 4),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.security_rounded,
                                        color: Colors.white,
                                        size: 24,
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
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Sk.metalMid, Sk.metalDark],
          ),
          border: Border.all(
              color: Sk.redBright.withOpacity(0.4), width: 1.2),
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
                icon: Icons.arrow_back_rounded,
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
                      'TR4SHER NULL DASBOARD',
                      style: TextStyle(
                        color: Sk.redBright,
                        fontSize: 11,
                        fontFamily: 'Orbitron',
                        fontWeight: FontWeight.w900,
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
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      '@${widget.username}',
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
                icon: Icons.refresh_rounded,
                onTap: () {
                  setState(() => _loading = true);
                  _loadAll();
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
  // PAGE INDICATOR
  // ═══════════════════════════════════════════════════════════
  Widget _buildPageIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _PageDot(
            isActive: _currentPage == 0,
            color: Sk.redBright,
          ),
          const SizedBox(width: 8),
          _PageDot(
            isActive: _currentPage == 1,
            color: Sk.brass,
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ERROR VIEW
  // ═══════════════════════════════════════════════════════════
  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: _SoftPanel(
          padding:
              const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          accent: Sk.redBright.withOpacity(0.6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Sk.redDeep,
                  border: Border.all(
                      color: Sk.redGlow.withOpacity(0.6), width: 1.5),
                ),
                child: const Icon(Icons.error_rounded,
                    color: Sk.redGlow, size: 32),
              ),
              const SizedBox(height: 18),
              const Text(
                'TERJADI KESALAHAN',
                style: TextStyle(
                  color: Sk.redBright,
                  fontSize: 12,
                  fontFamily: 'Orbitron',
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.8,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _errorMsg ?? 'Unknown error',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Sk.cream.withOpacity(0.6),
                  fontSize: 10,
                  fontFamily: 'ShareTechMono',
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              _MetalButton(
                label: 'COBA LAGI',
                color: Sk.redBright,
                height: 44,
                icon: Icons.refresh_rounded,
                onTap: () {
                  setState(() {
                    _loading = true;
                    _errorMsg = null;
                  });
                  _loadAll();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// PAGE DOT
// ═══════════════════════════════════════════════════════════
class _PageDot extends StatelessWidget {
  final bool isActive;
  final Color color;

  const _PageDot({
    required this.isActive,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isActive ? 26 : 8,
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: isActive ? color : Sk.metalLight,
        border: Border.all(
          color: isActive ? color : Sk.metalDark,
          width: 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: color.withOpacity(0.7),
                  blurRadius: 10,
                  spreadRadius: 0,
                ),
              ]
            : null,
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