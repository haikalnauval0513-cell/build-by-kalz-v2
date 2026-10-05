// lib/ai_page.dart
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

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
  static const Color redGlow      = Color(0xFFFF3030);
  static const Color greenGlow    = Color(0xFF00E676);
  static const Color amberHi      = Color(0xFFF59E0B);
  static const Color cyanHi       = Color(0xFF26C6DA);
  static const Color cream        = Color(0xFFE8DFC8);
  static const Color ink          = Color(0xFF2A2520); // ✅ DITAMBAHKAN
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
              color: Colors.black.withValues(alpha: 0.9),
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

// ═══════════════════════════════════════════════════════
// INDUSTRIAL BUTTON (small, icon-only)
// ═══════════════════════════════════════════════════════
class _IconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final double size;
  const _IconButton({
    required this.icon,
    required this.onTap,
    this.color = Sk.brass,
    this.size = 40,
  });

  @override
  State<_IconButton> createState() => _IconButtonState();
}

class _IconButtonState extends State<_IconButton> {
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
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            begin: _pressed ? Alignment.bottomCenter : Alignment.topCenter,
            end: _pressed ? Alignment.topCenter : Alignment.bottomCenter,
            colors: _pressed
                ? [Sk.metalDark, Sk.metalMid]
                : [Sk.metalLight, Sk.metalMid, Sk.metalDark],
            stops: const [0.0, 0.5, 1.0],
          ),
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.7),
            width: 1.2,
          ),
          boxShadow: _pressed
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.9),
                    offset: const Offset(0, 1),
                    blurRadius: 2,
                  ),
                ]
              : [
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
        child: Icon(widget.icon, color: widget.color, size: widget.size * 0.5),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// AI PAGE — SKEUOMORPHISM
// ═══════════════════════════════════════════════════════
class AIPage extends StatefulWidget {
  final String sessionKey;
  final String username;
  final String role;

  const AIPage({
    Key? key,
    required this.sessionKey,
    required this.username,
    required this.role,
  }) : super(key: key);

  @override
  _AIPageState createState() => _AIPageState();
}

class _AIPageState extends State<AIPage> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _Pulse.ensureStarted();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String prompt) async {
    if (prompt.trim().isEmpty || _isLoading) return;

    setState(() {
      _messages.add({'role': 'user', 'content': prompt});
      _isLoading = true;
    });
    _textController.clear();
    _scrollToBottom();

    try {
      final uri = Uri.parse(
          'https://api.siputzx.my.id/api/ai/gemini-lite?prompt=${Uri.encodeComponent(prompt)}&model=gemini-2.0-flash-lite');
      final response = await http.get(uri).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final aiResponse =
            json['data']['parts'][0]['text'] ?? 'Maaf, tidak ada respons.';
        setState(() {
          _messages.add({'role': 'assistant', 'content': aiResponse});
        });
      } else {
        setState(() {
          _messages.add({
            'role': 'assistant',
            'content':
                'Error: Gagal terhubung ke server (${response.statusCode})',
          });
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({'role': 'assistant', 'content': 'Exception: $e'});
      });
    } finally {
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
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
                _buildAppBar(),
                const SizedBox(height: 8),
                Expanded(child: _buildChatArea()),
                _buildInputArea(),
                _buildStatusBar(),
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
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: _MetalPlate(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            _IconButton(
              icon: Icons.arrow_back_rounded,
              color: Sk.brass,
              onTap: () => Navigator.pop(context),
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
                    border: Border.all(color: Sk.brass, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Sk.brass.withValues(alpha: 0.4),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.smart_toy_rounded,
                    color: Sk.brassShine,
                    size: 20,
                  ),
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
                  const Text(
                    'TR4SHER NULL AI',
                    style: TextStyle(
                      color: Sk.brassHi,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Orbitron',
                      letterSpacing: 1.5,
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
                        'GEMINI 2.0 FLASH LITE',
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

            _IconButton(
              icon: Icons.refresh_rounded,
              color: Sk.amberHi,
              onTap: () => setState(() => _messages.clear()),
            ),
            const SizedBox(width: 6),
            _IconButton(
              icon: Icons.info_outline_rounded,
              color: Sk.cyanHi,
              onTap: _showInfoDialog,
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // CHAT AREA
  // ═══════════════════════════════════════════════════════
  Widget _buildChatArea() {
    if (_messages.isEmpty && !_isLoading) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      physics: const BouncingScrollPhysics(),
      itemCount: _messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length && _isLoading) {
          return _buildLoadingBubble();
        }
        final msg = _messages[index];
        final isUser = msg['role'] == 'user';
        return RepaintBoundary(
          child: _buildMessageBubble(msg['content'], isUser),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [Sk.metalHi, Sk.metalMid, Sk.metalDark, Sk.metalDeep],
                stops: [0.0, 0.4, 0.7, 1.0],
              ),
              border: Border.all(color: Sk.brass, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Sk.brass.withValues(alpha: 0.35),
                  blurRadius: 20,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              color: Sk.brassShine,
              size: 45,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'AI ASSISTANT',
            style: TextStyle(
              color: Sk.brass,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              fontFamily: 'Orbitron',
              letterSpacing: 3,
              shadows: [
                Shadow(color: Colors.black, offset: Offset(0, 1), blurRadius: 2),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Mulai percakapan dengan AI',
            style: TextStyle(
              color: Sk.cream.withValues(alpha: 0.5),
              fontSize: 11,
              fontFamily: 'ShareTechMono',
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              _Led(color: Sk.greenGlow, size: 6, blink: true),
              SizedBox(width: 8),
              _Led(color: Sk.brass, size: 6, blink: true),
              SizedBox(width: 8),
              _Led(color: Sk.cyanHi, size: 6, blink: true),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // MESSAGE BUBBLE
  // ═══════════════════════════════════════════════════════
  Widget _buildMessageBubble(String text, bool isUser) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(14),
                topRight: const Radius.circular(14),
                bottomLeft: isUser ? const Radius.circular(14) : const Radius.circular(3),
                bottomRight: isUser ? const Radius.circular(3) : const Radius.circular(14),
              ),
              gradient: isUser
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Sk.brassHi, Sk.brass, Sk.brassDark, Sk.brassDeep],
                      stops: [0.0, 0.4, 0.7, 1.0],
                    )
                  : const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Sk.metalLight, Sk.metalMid, Sk.metalDark],
                      stops: [0.0, 0.5, 1.0],
                    ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.7),
                  offset: const Offset(0, 3),
                  blurRadius: 6,
                ),
                if (isUser)
                  BoxShadow(
                    color: Sk.brass.withValues(alpha: 0.25),
                    blurRadius: 8,
                    spreadRadius: -1,
                  ),
              ],
              border: Border.all(
                color: isUser ? Sk.brassShine : Colors.black.withValues(alpha: 0.6),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isUser ? Icons.person_rounded : Icons.smart_toy_rounded,
                      size: 11,
                      color: isUser ? Sk.brassDeep : Sk.brass,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isUser ? 'YOU' : 'AI',
                      style: TextStyle(
                        color: isUser ? Sk.brassDeep : Sk.brass,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Orbitron',
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    _Led(
                      color: isUser ? Sk.brassDeep : Sk.greenGlow,
                      size: 4,
                      blink: false,
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                Text(
                  text,
                  style: TextStyle(
                    color: isUser ? Sk.ink : Sk.cream, // ✅ Sk.ink sekarang ADA
                    fontSize: 13,
                    height: 1.5,
                    fontFamily: 'ShareTechMono',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // LOADING BUBBLE
  // ═══════════════════════════════════════════════════════
  Widget _buildLoadingBubble() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(14),
              topRight: Radius.circular(14),
              bottomLeft: Radius.circular(3),
              bottomRight: Radius.circular(14),
            ),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Sk.metalLight, Sk.metalMid, Sk.metalDark],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.7),
                offset: const Offset(0, 3),
                blurRadius: 6,
              ),
            ],
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.6),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Sk.brass),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'AI SEDANG MENGETIK...',
                style: TextStyle(
                  color: Sk.cream.withValues(alpha: 0.7),
                  fontSize: 10,
                  fontFamily: 'ShareTechMono',
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(width: 8),
              const _Led(color: Sk.greenGlow, size: 5, blink: true),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // INPUT AREA
  // ═══════════════════════════════════════════════════════
  Widget _buildInputArea() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: _MetalPlate(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF0A0806), Color(0xFF151210)],
                  ),
                  border: Border.all(color: Sk.metalDark, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.9),
                      offset: const Offset(0, 2),
                      blurRadius: 3,
                    ),
                  ],
                ),
                child: TextField(
                  controller: _textController,
                  style: const TextStyle(
                    color: Sk.brassShine,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'ShareTechMono',
                    letterSpacing: 0.3,
                  ),
                  cursorColor: Sk.greenGlow,
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: _sendMessage,
                  decoration: InputDecoration(
                    hintText: 'Tanyakan sesuatu...',
                    hintStyle: TextStyle(
                      color: Sk.cream.withValues(alpha: 0.3),
                      fontSize: 11,
                      fontFamily: 'ShareTechMono',
                      letterSpacing: 1,
                    ),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(left: 10, right: 6),
                      child: Icon(Icons.chat_bubble_outline_rounded,
                          color: Sk.brass, size: 16),
                    ),
                    prefixIconConstraints:
                        const BoxConstraints(minWidth: 32, minHeight: 32),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            _SendButton(
              enabled: !_isLoading,
              onTap: () => _sendMessage(_textController.text),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // STATUS BAR
  // ═══════════════════════════════════════════════════════
  Widget _buildStatusBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Container(
        height: 28,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Sk.metalMid, Sk.metalDark, Sk.metalDeep],
          ),
          border: Border.all(
            color: Sk.metalLight.withValues(alpha: 0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.75),
              offset: const Offset(0, 3),
              blurRadius: 6,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              const _Screw(size: 8),
              const SizedBox(width: 6),
              const _Led(color: Sk.greenGlow, size: 5, blink: true),
              const SizedBox(width: 6),
              Text(
                'AI ONLINE',
                style: TextStyle(
                  color: Sk.greenGlow.withValues(alpha: 0.9),
                  fontSize: 7,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Orbitron',
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              Text(
                'TR4SHER NULL AI · ASSISTANT',
                style: TextStyle(
                  color: Sk.brass.withValues(alpha: 0.75),
                  fontSize: 6.5,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'ShareTechMono',
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(width: 6),
              const _Led(color: Sk.brass, size: 5, blink: true),
              const SizedBox(width: 6),
              const _Screw(size: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // INFO DIALOG
  // ═══════════════════════════════════════════════════════
  void _showInfoDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: _MetalPlate(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const RadialGradient(
                            colors: [Sk.metalHi, Sk.metalMid, Sk.metalDark],
                          ),
                          border: Border.all(color: Sk.brass, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Sk.brass.withValues(alpha: 0.4),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.smart_toy_rounded,
                          color: Sk.brassShine,
                          size: 22,
                        ),
                      ),
                      const Positioned(
                        top: -2,
                        right: -2,
                        child: _Led(color: Sk.greenGlow, size: 7, blink: true),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TR4SHER NULL AI',
                          style: TextStyle(
                            color: Sk.brass,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Orbitron',
                            letterSpacing: 1.5,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Powered by Gemini 2.0 Flash Lite',
                          style: TextStyle(
                            color: Sk.cream,
                            fontSize: 9,
                            fontFamily: 'ShareTechMono',
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Sk.metalLight, Sk.metalDark],
                        ),
                        border: Border.all(
                          color: Sk.red.withValues(alpha: 0.6),
                          width: 1,
                        ),
                      ),
                      child: const Icon(Icons.close_rounded,
                          color: Sk.brass, size: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _buildInfoRow('USERNAME', widget.username, Sk.brassShine),
              _buildInfoRow('ROLE', widget.role.toUpperCase(), Sk.redGlow),
              _buildInfoRow(
                'SESSION',
                widget.sessionKey.length > 8
                    ? '${widget.sessionKey.substring(0, 8)}...'
                    : widget.sessionKey,
                Sk.greenGlow,
              ),
              _buildInfoRow('MODEL', 'GEMINI 2.0 FLASH', Sk.cyanHi),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Sk.greenGlow.withValues(alpha: 0.12),
                  border: Border.all(
                    color: Sk.greenGlow.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.check_circle_rounded,
                        color: Sk.greenGlow, size: 13),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'AI Assistant aktif dan siap membantu',
                        style: TextStyle(
                          color: Sk.greenGlow,
                          fontSize: 10,
                          fontFamily: 'ShareTechMono',
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

  Widget _buildInfoRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 78,
            child: Text(
              label,
              style: TextStyle(
                color: Sk.cream.withValues(alpha: 0.55),
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
                color: Colors.black.withValues(alpha: 0.5),
                border: Border.all(
                  color: color.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Orbitron',
                  letterSpacing: 0.5,
                  shadows: [
                    Shadow(
                      color: color.withValues(alpha: 0.5),
                      blurRadius: 4,
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// SEND BUTTON
// ═══════════════════════════════════════════════════════
class _SendButton extends StatefulWidget {
  final bool enabled;
  final VoidCallback onTap;
  const _SendButton({required this.enabled, required this.onTap});

  @override
  State<_SendButton> createState() => _SendButtonState();
}

class _SendButtonState extends State<_SendButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.enabled
          ? (_) => setState(() => _pressed = true)
          : null,
      onTapUp: widget.enabled
          ? (_) {
              setState(() => _pressed = false);
              HapticFeedback.lightImpact();
              widget.onTap();
            }
          : null,
      onTapCancel: widget.enabled
          ? () => setState(() => _pressed = false)
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: _pressed ? Alignment.bottomCenter : Alignment.topCenter,
            end: _pressed ? Alignment.topCenter : Alignment.bottomCenter,
            colors: widget.enabled
                ? const [Sk.brassShine, Sk.brassHi, Sk.brass, Sk.brassDark]
                : const [Sk.metalLight, Sk.metalMid, Sk.metalDark],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
          border: Border.all(
            color: widget.enabled ? Sk.brassDeep : Sk.metalDark,
            width: 1.5,
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
                  if (widget.enabled)
                    BoxShadow(
                      color: Sk.brass.withValues(alpha: 0.5),
                      blurRadius: 10,
                      spreadRadius: 0,
                    ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.8),
                    offset: const Offset(0, 3),
                    blurRadius: 5,
                  ),
                ],
        ),
        child: Icon(
          Icons.send_rounded,
          color: widget.enabled ? Sk.ink : Sk.metalDark, // ✅ Sk.ink ADA
          size: 20,
        ),
      ),
    );
  }
}