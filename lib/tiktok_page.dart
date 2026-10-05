// lib/tiktok_page.dart
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

// ═══════════════════════════════════════════════════════
// COLORS — SKEUOMORPHISM
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
  static const Color redBright    = Color(0xFFC41E1E);
  static const Color redGlow      = Color(0xFFFF3030);
  static const Color greenGlow    = Color(0xFF00E676);
  static const Color amberHi      = Color(0xFFF59E0B);
  static const Color cyanHi       = Color(0xFF26C6DA);
  static const Color pinkHi       = Color(0xFFEC407A);
  static const Color cream        = Color(0xFFE8DFC8);
  static const Color ink          = Color(0xFF2A2520);
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
            BoxShadow(color: Colors.black.withOpacity(0.75), offset: const Offset(0, 6), blurRadius: 12),
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
// TIKTOK DOWNLOADER PAGE
// ═══════════════════════════════════════════════════════
class TiktokDownloaderPage extends StatefulWidget {
  const TiktokDownloaderPage({super.key});

  @override
  State<TiktokDownloaderPage> createState() => _TiktokDownloaderPageState();
}

class _TiktokDownloaderPageState extends State<TiktokDownloaderPage> {
  final TextEditingController _urlController = TextEditingController();
  bool _isLoading = false;
  bool _isSharing = false;
  String? _errorMessage;
  Map<String, dynamic>? _videoData;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  // ⚡ User-Agent biar gak diblokir API
  static const Map<String, String> _headers = {
    'User-Agent':
        'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
    'Accept': 'application/json',
  };

  @override
  void initState() {
    super.initState();
    _Pulse.ensureStarted();
  }

  @override
  void dispose() {
    _urlController.dispose();
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════
  // MULTI-API FALLBACK — 3 API sekaligus
  // ═══════════════════════════════════════════════════════
  Future<Map<String, dynamic>?> _tryApi(String url) async {
    final encoded = Uri.encodeComponent(url);
    final apis = <String>[
      'https://api.ryzumi.net/api/downloader/ttdl?url=$encoded',
      'https://api.siputzx.my.id/api/d/tiktok?url=$encoded',
      'https://www.tikwm.com/api/?url=$encoded&hd=1',
    ];

    for (final api in apis) {
      try {
        final res = await http
            .get(Uri.parse(api), headers: _headers)
            .timeout(const Duration(seconds: 15));

        if (res.statusCode != 200) continue;

        final json = jsonDecode(res.body) as Map<String, dynamic>;
        final parsed = _parseResponse(json);
        if (parsed != null && (parsed['videoUrl'] as String).isNotEmpty) {
          return parsed;
        }
      } catch (e) {
        continue;
      }
    }
    return null;
  }

  // Parse response dari berbagai API (format beda-beda)
  Map<String, dynamic>? _parseResponse(Map<String, dynamic> json) {
    try {
      Map<String, dynamic>? d;

      // Format 1: ryzumi.net
      if (json['data']?['data'] != null) {
        d = json['data']['data'];
      }
      // Format 2: siputzx
      else if (json['data'] != null) {
        d = json['data'];
      }
      // Format 3: tikwm
      else if (json['data'] != null) {
        d = json['data'];
      }

      if (d == null) return null;

      // Cari video URL dari berbagai key
      final videoUrl = d['play'] ??
          d['video'] ??
          d['hdplay'] ??
          d['wmplay'] ??
          d['nowm'] ??
          d['url'] ??
          '';

      return {
        'title': d['title'] ?? 'TikTok Video',
        'videoUrl': videoUrl,
        'videoWm': d['wmplay'] ?? videoUrl,
        'videoHd': d['hdplay'] ?? d['hd'] ?? videoUrl,
        'audioUrl': d['music'] ?? d['music_info']?['play'] ?? '',
        'thumbnail': d['cover'] ?? d['origin_cover'] ?? '',
        'creator': d['author']?['nickname'] ??
            d['author']?['unique_id'] ??
            d['author']?['id'] ??
            'Unknown',
        'duration': d['duration'] ?? 0,
      };
    } catch (e) {
      return null;
    }
  }

  Future<void> _downloadTiktok() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      setState(() {
        _errorMessage = 'URL TikTok tidak boleh kosong.';
        _videoData = null;
      });
      return;
    }

    if (!url.contains('tiktok.com') && !url.contains('douyin')) {
      setState(() {
        _errorMessage = 'Link harus dari TikTok (vt.tiktok.com / tiktok.com)';
        _videoData = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _videoData = null;
      _videoController?.dispose();
      _chewieController?.dispose();
      _videoController = null;
      _chewieController = null;
    });

    try {
      final result = await _tryApi(url);

      if (result == null) {
        setState(() {
          _errorMessage =
              'Semua server downloader sedang down. Coba lagi dalam 1 menit.';
        });
        return;
      }

      setState(() => _videoData = result);
      _initializeVideoPlayer();
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan: $e';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _initializeVideoPlayer() {
    final url = _videoData?['videoUrl'] as String?;
    if (url == null || url.isEmpty) return;

    _videoController = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {
          _chewieController = ChewieController(
            videoPlayerController: _videoController!,
            autoPlay: true,
            looping: false,
            showControls: true,
            materialProgressColors: ChewieProgressColors(
              playedColor: Sk.brass,
              handleColor: Sk.brassShine,
              backgroundColor: Sk.metalDark,
              bufferedColor: Sk.metalMid,
            ),
          );
        });
      }).catchError((e) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Gagal load video player: $e';
          });
        }
      });
  }

  Future<void> _shareVideo() async {
    if (_videoData == null) return;
    setState(() => _isSharing = true);

    try {
      final videoUrl =
          _videoData!['videoUrl'] ??
          _videoData!['videoWm'] ??
          _videoData!['videoHd'];

      if (videoUrl == null || (videoUrl as String).isEmpty) {
        _showSnack('URL video tidak tersedia', isError: true);
        return;
      }

      final response = await http
          .get(Uri.parse(videoUrl), headers: _headers)
          .timeout(const Duration(seconds: 30));

      final tempDir = await getTemporaryDirectory();
      final fileName = 'tiktok_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(response.bodyBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Video TikTok dari: ${_videoData!['creator']}',
      );
    } catch (e) {
      _showSnack('Error sharing: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
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
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0806),
      body: Stack(
        children: [
          // Background
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
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Column(
                      children: [
                        _buildInputPlate(),
                        const SizedBox(height: 14),
                        if (_errorMessage != null) _buildErrorPlate(),
                        if (_videoData != null) _buildVideoPlate(),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // APP BAR
  // ═══════════════════════════════════════════════════════
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
                  border: Border.all(color: Colors.black.withOpacity(0.7), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.7),
                      offset: const Offset(0, 3),
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Sk.brass, size: 16),
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
                    border: Border.all(color: Sk.pinkHi, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Sk.pinkHi.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.music_note_rounded,
                    color: Sk.pinkHi,
                    size: 20,
                  ),
                ),
                const Positioned(
                  top: -2,
                  right: -2,
                  child: _Led(color: Sk.cyanHi, size: 6, blink: true),
                ),
              ],
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TIKTOK DL',
                    style: TextStyle(
                      color: Sk.brassHi,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Orbitron',
                      letterSpacing: 2,
                      height: 1,
                      shadows: [
                        Shadow(color: Sk.brassDeep, offset: Offset(0, 1), blurRadius: 1),
                        Shadow(color: Colors.black, offset: Offset(0, 2), blurRadius: 3),
                      ],
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const _Led(color: Sk.greenGlow, size: 4, blink: true),
                      const SizedBox(width: 5),
                      Text(
                        'NO WATERMARK',
                        style: TextStyle(
                          color: Sk.cream.withOpacity(0.55),
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

            const _Led(color: Sk.pinkHi, size: 7, blink: true),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // INPUT PLATE
  // ═══════════════════════════════════════════════════════
  Widget _buildInputPlate() {
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
                    'PASTE URL TIKTOK',
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

          // Label
          Row(
            children: [
              const _Rivet(size: 6),
              const SizedBox(width: 6),
              const Icon(Icons.link_rounded, color: Sk.brass, size: 14),
              const SizedBox(width: 6),
              const Text(
                'TIKTOK LINK',
                style: TextStyle(
                  color: Sk.brass,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Orbitron',
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // TextField (inset)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0A0806), Color(0xFF151210)],
              ),
              border: Border.all(color: Sk.metalDark, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.9),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
                const BoxShadow(
                  color: Colors.white10,
                  offset: Offset(0, -1),
                  blurRadius: 1,
                ),
              ],
            ),
            child: TextField(
              controller: _urlController,
              style: const TextStyle(
                color: Sk.brassShine,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: 'ShareTechMono',
                letterSpacing: 0.3,
              ),
              cursorColor: Sk.greenGlow,
              maxLines: 2,
              minLines: 1,
              decoration: InputDecoration(
                hintText: 'https://vt.tiktok.com/xxx/',
                hintStyle: TextStyle(
                  color: Sk.cream.withOpacity(0.3),
                  fontSize: 11,
                  fontFamily: 'ShareTechMono',
                ),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 10, right: 6, top: 2, bottom: 2),
                  child: Icon(Icons.download_rounded,
                      color: Sk.pinkHi, size: 18),
                ),
                prefixIconConstraints:
                    const BoxConstraints(minWidth: 32, minHeight: 32),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Download button
          _IndustrialButton(
            color: _isLoading ? Sk.metalMid : Sk.pinkHi,
            height: 54,
            onTap: _isLoading ? null : _downloadTiktok,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isLoading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Sk.brass),
                    ),
                  )
                else
                  const Icon(Icons.download_rounded,
                      color: Colors.white, size: 18),
                const SizedBox(width: 10),
                Text(
                  _isLoading ? 'MEMPROSES...' : 'DOWNLOAD',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
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
    );
  }

  // ═══════════════════════════════════════════════════════
  // ERROR PLATE
  // ═══════════════════════════════════════════════════════
  Widget _buildErrorPlate() {
    return _MetalPlate(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Sk.redBright.withOpacity(0.5),
                  Sk.red.withOpacity(0.15),
                  Colors.black.withOpacity(0.9),
                ],
              ),
              border: Border.all(color: Sk.redGlow.withOpacity(0.6), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Sk.redGlow.withOpacity(0.5),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Icon(Icons.error_outline_rounded,
                color: Sk.redGlow, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: Sk.redGlow.withOpacity(0.95),
                fontSize: 11,
                fontFamily: 'ShareTechMono',
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // VIDEO PLATE
  // ═══════════════════════════════════════════════════════
  Widget _buildVideoPlate() {
    return _MetalPlate(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const _Led(color: Sk.greenGlow, size: 7, blink: true),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'VIDEO READY',
                  style: TextStyle(
                    color: Sk.greenGlow,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Orbitron',
                    letterSpacing: 2,
                  ),
                ),
              ),
              const _Screw(size: 10),
            ],
          ),
          const SizedBox(height: 12),

          // Video info
          Row(
            children: [
              const _Rivet(size: 6),
              const SizedBox(width: 6),
              Icon(Icons.person_rounded, color: Sk.cyanHi, size: 12),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  '${_videoData!['creator']}',
                  style: const TextStyle(
                    color: Sk.cyanHi,
                    fontSize: 10,
                    fontFamily: 'Orbitron',
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${_videoData!['title']}',
            style: TextStyle(
              color: Sk.cream.withOpacity(0.75),
              fontSize: 10,
              fontFamily: 'ShareTechMono',
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),

          // Video player
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black.withOpacity(0.7), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.9),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: AspectRatio(
                aspectRatio: _videoController?.value.isInitialized == true
                    ? _videoController!.value.aspectRatio
                    : 9 / 16,
                child: _chewieController != null
                    ? Chewie(controller: _chewieController!)
                    : Container(
                        color: Colors.black,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Sk.brass,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Share button
          _IndustrialButton(
            color: _isSharing ? Sk.metalMid : Sk.cyanHi,
            height: 48,
            onTap: _isSharing ? null : _shareVideo,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isSharing)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Sk.brass),
                    ),
                  )
                else
                  const Icon(Icons.share_rounded,
                      color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(
                  _isSharing ? 'SHARING...' : 'SHARE VIDEO',
                  style: const TextStyle(
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
    );
  }
}