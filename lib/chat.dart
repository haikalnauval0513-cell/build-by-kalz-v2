import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'api_config.dart';

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

  // Purple (chat accent)
  static const Color purpleDeep = Color(0xFF2A0A3D);
  static const Color purple     = Color(0xFF6A1B9A);
  static const Color purpleHi   = Color(0xFF9C27B0);
  static const Color purpleGlow = Color(0xFFCE93D8);

  // Green (E2EE / online)
  static const Color greenDeep  = Color(0xFF0A2818);
  static const Color green      = Color(0xFF2E7D32);
  static const Color greenHi    = Color(0xFF4CAF50);
  static const Color greenGlow  = Color(0xFF00E676);

  // Red
  static const Color redDeep    = Color(0xFF3D0808);
  static const Color red        = Color(0xFF8B1818);
  static const Color redBright  = Color(0xFFC41E1E);

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

/// Inset panel (dark recessed)
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
// CHAT PAGE
// ═══════════════════════════════════════════════════════════
class ChatPage extends StatefulWidget {
  final String username;
  final String sessionKey;

  const ChatPage({
    super.key,
    required this.username,
    required this.sessionKey,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  WebSocketChannel? _channel;

  // Global chat
  List<dynamic> _globalMessages = [];
  bool _globalLoading = true;
  final TextEditingController _globalInputCtrl = TextEditingController();
  final ScrollController _globalScrollCtrl = ScrollController();
  Map<String, dynamic>? _globalReplyTo;

  // Private chat
  List<dynamic> _privateChats = [];
  List<dynamic> _privateMessages = [];
  String? _selectedUser;
  bool _privateLoading = true;
  final TextEditingController _privateInputCtrl = TextEditingController();
  final ScrollController _privateScrollCtrl = ScrollController();
  Map<String, dynamic>? _privateReplyTo;

  // Profile
  Map<String, dynamic> _myProfile = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initialize();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _channel?.sink.close();
    _globalInputCtrl.dispose();
    _globalScrollCtrl.dispose();
    _privateInputCtrl.dispose();
    _privateScrollCtrl.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════
  // INIT
  // ═══════════════════════════════════════════════════════════
  void _initialize() {
    _loadProfile();
    _connectWebSocket();
    _loadGlobalMessages();
    _loadPrivateChats();
  }

  Future<void> _loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionKey =
          prefs.getString('session_key') ?? widget.sessionKey;
      final res = await http.get(
          Uri.parse('$baseUrl/chat/profile?key=$sessionKey'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['valid'] == true && mounted) {
          setState(() => _myProfile = data['profile']);
        }
      }
    } catch (_) {}
  }

  void _connectWebSocket() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionKey =
          prefs.getString('session_key') ?? widget.sessionKey;
      _channel = WebSocketChannel.connect(Uri.parse(WS_URL));
      _channel!.stream.listen(_handleWebSocketMessage, onError: (_) {});
      _channel!.sink.add(jsonEncode({'type': 'auth', 'key': sessionKey}));
    } catch (_) {}
  }

  void _handleWebSocketMessage(dynamic data) {
    try {
      final msg = jsonDecode(data);
      if (msg['type'] == 'global_message') {
        _addGlobalMessage(msg['message']);
      } else if (msg['type'] == 'private_message') {
        _addPrivateMessage(msg['message']);
      } else if (msg['type'] == 'refresh_chat_list') {
        _loadPrivateChats();
      }
    } catch (_) {}
  }

  // ═══════════════════════════════════════════════════════════
  // GLOBAL CHAT
  // ═══════════════════════════════════════════════════════════
  Future<void> _loadGlobalMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionKey =
          prefs.getString('session_key') ?? widget.sessionKey;
      final res = await http.get(Uri.parse(
          '$baseUrl/chat/global/messages?key=$sessionKey&limit=100'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['valid'] == true && mounted) {
          setState(() {
            _globalMessages = data['messages'];
            _globalLoading = false;
          });
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom(_globalScrollCtrl);
          });
        }
      }
    } catch (_) {
      if (mounted) setState(() => _globalLoading = false);
    }
  }

  void _addGlobalMessage(dynamic msg) {
    if (!mounted) return;
    setState(() => _globalMessages.add(msg));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom(_globalScrollCtrl);
    });
  }

  void _scrollToBottom(ScrollController controller) {
    if (controller.hasClients) {
      controller.animateTo(
        controller.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendGlobalMessage() async {
    final text = _globalInputCtrl.text.trim();
    if (text.isEmpty && _globalReplyTo == null) return;

    String finalText = text;
    if (_globalReplyTo != null) {
      finalText = '@${_globalReplyTo!['sender']} $text';
    }

    setState(() => _globalInputCtrl.text = '');

    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionKey =
          prefs.getString('session_key') ?? widget.sessionKey;
      final body = jsonEncode({
        'message': finalText,
        'type': 'text',
        'replyTo': _globalReplyTo?['id'],
      });

      final res = await http.post(
        Uri.parse('$baseUrl/chat/global/send?key=$sessionKey'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['valid'] == true && mounted) {
          setState(() => _globalReplyTo = null);
          _loadGlobalMessages();
        }
      }
    } catch (_) {}
  }

  // ═══════════════════════════════════════════════════════════
  // PRIVATE CHAT
  // ═══════════════════════════════════════════════════════════
  Future<void> _loadPrivateChats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionKey =
          prefs.getString('session_key') ?? widget.sessionKey;
      final res = await http.get(Uri.parse(
          '$baseUrl/chat/private/users?key=$sessionKey'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['valid'] == true && mounted) {
          setState(() {
            _privateChats = data['users'];
            _privateLoading = false;
          });
        }
      }
    } catch (_) {
      if (mounted) setState(() => _privateLoading = false);
    }
  }

  Future<void> _loadPrivateMessages(String withUser) async {
    setState(() => _privateLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionKey =
          prefs.getString('session_key') ?? widget.sessionKey;
      final res = await http.get(Uri.parse(
          '$baseUrl/chat/private/messages/$withUser?key=$sessionKey&limit=100'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['valid'] == true && mounted) {
          setState(() {
            _privateMessages = data['messages'];
            _privateLoading = false;
          });
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom(_privateScrollCtrl);
          });

          await http.post(Uri.parse(
              '$baseUrl/chat/private/mark-read/$withUser?key=$sessionKey'));
        }
      }
    } catch (_) {
      if (mounted) setState(() => _privateLoading = false);
    }
  }

  void _addPrivateMessage(dynamic msg) {
    if (!mounted) return;
    final isCurrentChat = _selectedUser == msg['sender'] ||
        _selectedUser == msg['receiver'];
    if (isCurrentChat) {
      setState(() => _privateMessages.add(msg));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom(_privateScrollCtrl);
      });
    }
    _loadPrivateChats();
  }

  Future<void> _sendPrivateMessage() async {
    final text = _privateInputCtrl.text.trim();
    if (text.isEmpty || _selectedUser == null) return;

    String finalText = text;
    if (_privateReplyTo != null) {
      finalText = '@${_privateReplyTo!['sender']} $text';
    }

    setState(() => _privateInputCtrl.text = '');

    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionKey =
          prefs.getString('session_key') ?? widget.sessionKey;
      final body = jsonEncode({
        'message': finalText,
        'type': 'text',
        'replyTo': _privateReplyTo?['id'],
      });

      final res = await http.post(
        Uri.parse('$baseUrl/chat/private/send/$_selectedUser?key=$sessionKey'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['valid'] == true && mounted) {
          setState(() => _privateReplyTo = null);
          _loadPrivateMessages(_selectedUser!);
        } else {
          if (mounted) {
            _showToast(data['error'] ?? 'Gagal mengirim pesan',
                error: true);
          }
        }
      }
    } catch (e) {
      if (mounted) _showToast('Error: $e', error: true);
    }
  }

  Future<void> _searchAndStartChat() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SearchUserSheet(
        sessionKey: widget.sessionKey,
        currentUsername: widget.username,
        onSelectUser: (user) {
          Navigator.pop(ctx);
          setState(() {
            _selectedUser = user['username'];
            _privateReplyTo = null;
          });
          _loadPrivateMessages(user['username']);
          _tabController.animateTo(1);
        },
      ),
    );
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null) return '';
    try {
      final time = DateTime.parse(timestamp);
      final now = DateTime.now();
      final diff = now.difference(time);
      if (diff.inSeconds < 60) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) {
      return '';
    }
  }

  void _showToast(String msg, {bool error = false}) {
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
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildGlobalChat(),
                    _buildPrivateChat(),
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
                icon: Icons.arrow_back_rounded,
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(width: 10),
              const _Led(color: Sk.purpleGlow, size: 7),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'NULL TR4SHER CHAT',
                      style: TextStyle(
                        color: Sk.brass,
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
                        ],
                      ),
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
                  _loadGlobalMessages();
                  _loadPrivateChats();
                  if (_selectedUser != null) {
                    _loadPrivateMessages(_selectedUser!);
                  }
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
  // TAB BAR (metal tabs)
  // ═══════════════════════════════════════════════════════════
  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Container(
        height: 46,
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
              color: Colors.black.withOpacity(0.5),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        padding: const EdgeInsets.all(3),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Sk.purpleHi, Sk.purple, Sk.purpleDeep],
            ),
            border: Border.all(
              color: Sk.purpleGlow.withOpacity(0.6),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Sk.purpleHi.withOpacity(0.4),
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ],
          ),
          labelColor: Colors.white,
          unselectedLabelColor: Sk.cream.withOpacity(0.6),
          dividerColor: Colors.transparent,
          labelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            fontFamily: 'Orbitron',
            letterSpacing: 1.5,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            fontFamily: 'Orbitron',
            letterSpacing: 1.5,
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: const [
            Tab(
              height: 40,
              icon: Icon(Icons.public_rounded, size: 16),
              text: 'GLOBAL',
            ),
            Tab(
              height: 40,
              icon: Icon(Icons.lock_rounded, size: 16),
              text: 'PRIVATE',
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // GLOBAL CHAT TAB
  // ═══════════════════════════════════════════════════════════
  Widget _buildGlobalChat() {
    return Column(
      children: [
        if (_globalReplyTo != null) _buildReplyPreviewBar(isGlobal: true),
        Expanded(
          child: _globalLoading
              ? const Center(
                  child: CircularProgressIndicator(
                      color: Sk.brass, strokeWidth: 2),
                )
              : _globalMessages.isEmpty
                  ? _buildEmptyState(
                      'Belum ada pesan',
                      'Jadilah yang pertama mengirim pesan!',
                    )
                  : ListView.builder(
                      controller: _globalScrollCtrl,
                      padding: const EdgeInsets.only(
                          left: 14, right: 14, bottom: 12),
                      itemCount: _globalMessages.length,
                      itemBuilder: (ctx, i) => _buildGlobalMessageBubble(
                          _globalMessages[i]),
                    ),
        ),
        _buildInputBar(
          controller: _globalInputCtrl,
          onSend: _sendGlobalMessage,
          hint: 'Type a message...',
          isGlobal: true,
        ),
      ],
    );
  }

  Widget _buildGlobalMessageBubble(dynamic msg) {
    final isMe = msg['sender'] == widget.username;
    final profile = msg['senderProfile'] ?? {};
    final name = profile['name'] ?? msg['sender'];
    final replyTo = msg['replyTo'];
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return GestureDetector(
      onLongPress: () {
        setState(() {
          _globalReplyTo = {
            'id': msg['id'],
            'sender': msg['sender'],
            'message': msg['message'],
          };
        });
      },
      child: Container(
        margin: EdgeInsets.only(
          left: isMe ? 50 : 0,
          right: isMe ? 0 : 50,
          top: 6,
          bottom: 6,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!isMe) ...[
              GestureDetector(
                onTap: () {
                  if (msg['sender'] != widget.username) {
                    setState(() {
                      _selectedUser = msg['sender'];
                      _privateReplyTo = null;
                    });
                    _loadPrivateMessages(msg['sender']);
                    _tabController.animateTo(1);
                  }
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Sk.purple, Sk.purpleDeep],
                    ),
                    border: Border.all(
                        color: Sk.purpleGlow.withOpacity(0.6), width: 1),
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Orbitron',
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment: isMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  if (!isMe)
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 4),
                      child: Text(
                        name,
                        style: TextStyle(
                          color: Sk.cream.withOpacity(0.55),
                          fontSize: 9,
                          fontFamily: 'ShareTechMono',
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  if (replyTo != null) _buildReplyBubble(replyTo, isMe),
                  _buildBubbleContent(msg['message'] ?? '', isMe),
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
                    child: Text(
                      _formatTime(msg['timestamp']),
                      style: TextStyle(
                        color: Sk.cream.withOpacity(0.4),
                        fontSize: 9,
                        fontFamily: 'ShareTechMono',
                        fontWeight: FontWeight.w700,
                      ),
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

  // ═══════════════════════════════════════════════════════════
  // PRIVATE CHAT TAB
  // ═══════════════════════════════════════════════════════════
  Widget _buildPrivateChat() {
    return _selectedUser == null
        ? _buildChatList()
        : Column(
            children: [
              _buildChatHeader(),
              if (_privateReplyTo != null)
                _buildReplyPreviewBar(isGlobal: false),
              Expanded(
                child: _privateLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: Sk.brass, strokeWidth: 2),
                      )
                    : _privateMessages.isEmpty
                        ? _buildEmptyState(
                            'Belum ada pesan',
                            'Kirim pesan pertama untuk memulai!',
                          )
                        : ListView.builder(
                            controller: _privateScrollCtrl,
                            padding: const EdgeInsets.only(
                                left: 14, right: 14, bottom: 12),
                            itemCount: _privateMessages.length,
                            itemBuilder: (ctx, i) =>
                                _buildPrivateMessageBubble(
                                    _privateMessages[i]),
                          ),
              ),
              _buildInputBar(
                controller: _privateInputCtrl,
                onSend: _sendPrivateMessage,
                hint: 'E2EE encrypted message...',
                isGlobal: false,
              ),
            ],
          );
  }

  Widget _buildChatList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: _SearchBarButton(onTap: _searchAndStartChat),
        ),
        Expanded(
          child: _privateChats.isEmpty
              ? _buildEmptyState(
                  'Belum ada chat',
                  'Cari user untuk memulai percakapan private!',
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  itemCount: _privateChats.length,
                  itemBuilder: (ctx, i) =>
                      _buildChatListItem(_privateChats[i]),
                ),
        ),
      ],
    );
  }

  Widget _buildChatListItem(dynamic chat) {
    final profile = chat['profile'] ?? {};
    final lastMsg = chat['lastMessage'];
    final isUnread = lastMsg != null &&
        lastMsg['sender'] != widget.username &&
        lastMsg['read'] != true;
    final username = chat['username'] as String;
    final initial = username.isNotEmpty ? username[0].toUpperCase() : '?';

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedUser = chat['username'];
          _privateReplyTo = null;
        });
        _loadPrivateMessages(chat['username']);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Sk.leather, Sk.leatherDark],
          ),
          border: Border.all(
            color: isUnread
                ? Sk.purpleHi.withOpacity(0.6)
                : Sk.metalLight,
            width: isUnread ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isUnread
                  ? Sk.purpleHi.withOpacity(0.25)
                  : Colors.black.withOpacity(0.4),
              offset: const Offset(0, 3),
              blurRadius: isUnread ? 8 : 5,
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
                  // Avatar with LED
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Sk.purple, Sk.purpleDeep],
                          ),
                          border: Border.all(
                            color: isUnread
                                ? Sk.purpleGlow
                                : Sk.purpleHi.withOpacity(0.5),
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            initial,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Orbitron',
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: _Led(
                          color: isUnread ? Sk.purpleGlow : Sk.greenGlow,
                          size: 9,
                        ),
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
                                profile['name'] ?? chat['username'],
                                style: const TextStyle(
                                  color: Sk.cream,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
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
                            ),
                            if (isUnread)
                              Container(
                                width: 18,
                                height: 18,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [Sk.purpleGlow, Sk.purpleHi],
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    '!',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (lastMsg != null) ...[
                          const SizedBox(height: 3),
                          Text(
                            '${lastMsg['sender'] == widget.username ? "You: " : ""}${lastMsg['message'] ?? ''}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Sk.cream.withOpacity(
                                  isUnread ? 0.75 : 0.5),
                              fontSize: 10,
                              fontFamily: 'ShareTechMono',
                              fontWeight: isUnread
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (lastMsg != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      _formatTime(lastMsg['timestamp']),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatHeader() {
    final profile = _privateChats.firstWhere(
      (c) => c['username'] == _selectedUser,
      orElse: () => ({'profile': {}}),
    )['profile'] ??
        {};

    final initial = _selectedUser!.isNotEmpty
        ? _selectedUser![0].toUpperCase()
        : '?';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
            color: Colors.black.withOpacity(0.5),
            offset: const Offset(0, 3),
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          _MetalIconButton(
            icon: Icons.arrow_back_rounded,
            size: 30,
            onTap: () => setState(() {
              _selectedUser = null;
              _privateReplyTo = null;
            }),
          ),
          const SizedBox(width: 8),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Sk.purple, Sk.purpleDeep],
                  ),
                  border: Border.all(
                      color: Sk.purpleGlow.withOpacity(0.6), width: 1),
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Orbitron',
                    ),
                  ),
                ),
              ),
              const Positioned(
                bottom: 0,
                right: 0,
                child: _Led(color: Sk.greenGlow, size: 8),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile['name'] ?? _selectedUser!,
                  style: const TextStyle(
                    color: Sk.cream,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
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
                if (profile['bio'] != null &&
                    profile['bio'].toString().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    profile['bio'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Sk.cream.withOpacity(0.5),
                      fontSize: 9,
                      fontFamily: 'ShareTechMono',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // E2EE badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Sk.greenDeep,
              border: Border.all(
                  color: Sk.greenHi.withOpacity(0.6), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _Led(color: Sk.greenGlow, size: 5),
                const SizedBox(width: 5),
                const Text(
                  'E2EE',
                  style: TextStyle(
                    color: Sk.greenGlow,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Orbitron',
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

  Widget _buildPrivateMessageBubble(dynamic msg) {
    final isMe = msg['fromMe'] == true;
    final replyTo = msg['replyTo'];

    return GestureDetector(
      onLongPress: () {
        setState(() {
          _privateReplyTo = {
            'id': msg['id'],
            'sender': msg['sender'],
            'message': msg['message'],
          };
        });
      },
      child: Container(
        margin: EdgeInsets.only(
          left: isMe ? 50 : 0,
          right: isMe ? 0 : 50,
          top: 6,
          bottom: 6,
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (replyTo != null) _buildReplyBubble(replyTo, isMe),
            _buildBubbleContent(msg['message'] ?? '', isMe),
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: Sk.greenDeep,
                      border: Border.all(
                          color: Sk.greenHi.withOpacity(0.4), width: 0.8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.lock_outline_rounded,
                            color: Sk.greenGlow, size: 7),
                        const SizedBox(width: 2),
                        const Text(
                          'E2EE',
                          style: TextStyle(
                            color: Sk.greenGlow,
                            fontSize: 6,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Orbitron',
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatTime(msg['timestamp']),
                    style: TextStyle(
                      color: Sk.cream.withOpacity(0.4),
                      fontSize: 9,
                      fontFamily: 'ShareTechMono',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (isMe && msg['read'] == true)
                    const Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Icon(
                        Icons.done_all_rounded,
                        color: Sk.greenGlow,
                        size: 10,
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

  // ═══════════════════════════════════════════════════════════
  // SHARED BUBBLE CONTENT
  // ═══════════════════════════════════════════════════════════
  Widget _buildBubbleContent(String message, bool isMe) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: isMe
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Sk.purpleHi, Sk.purple],
              )
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Sk.leather, Sk.leatherDark],
              ),
        border: Border.all(
          color: isMe
              ? Sk.purpleGlow.withOpacity(0.6)
              : Sk.metalLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isMe
                ? Sk.purpleHi.withOpacity(0.3)
                : Colors.black.withOpacity(0.4),
            offset: const Offset(0, 2),
            blurRadius: 5,
          ),
        ],
      ),
      child: Text(
        message,
        style: TextStyle(
          color: isMe ? Colors.white : Sk.cream,
          fontSize: 12,
          fontFamily: 'ShareTechMono',
          fontWeight: FontWeight.w700,
          height: 1.4,
          shadows: isMe
              ? const [
                  Shadow(
                    color: Colors.black38,
                    offset: Offset(0, 1),
                    blurRadius: 2,
                  ),
                ]
              : null,
        ),
      ),
    );
  }

  Widget _buildReplyBubble(Map replyTo, bool isMe) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4, left: 4, right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: Colors.black.withOpacity(0.4),
        border: Border(
          left: BorderSide(
            color: isMe ? Sk.purpleGlow : Sk.brass,
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.reply_rounded,
                color: isMe ? Sk.purpleGlow : Sk.brass,
                size: 10,
              ),
              const SizedBox(width: 4),
              Text(
                '@${replyTo['sender']}',
                style: TextStyle(
                  color: isMe ? Sk.purpleGlow : Sk.brass,
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Orbitron',
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            replyTo['message'] ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Sk.cream.withOpacity(0.6),
              fontSize: 9,
              fontFamily: 'ShareTechMono',
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // REPLY PREVIEW BAR
  // ═══════════════════════════════════════════════════════════
  Widget _buildReplyPreviewBar({required bool isGlobal}) {
    final replyData = isGlobal ? _globalReplyTo : _privateReplyTo;
    if (replyData == null) return const SizedBox();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Sk.leather, Sk.leatherDark],
        ),
        border: Border(
          left: BorderSide(color: Sk.brass, width: 3),
          top: BorderSide(color: Sk.metalDark, width: 1),
          right: BorderSide(color: Sk.metalDark, width: 1),
          bottom: BorderSide(color: Sk.metalDark, width: 1),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.reply_rounded, color: Sk.brass, size: 14),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'REPLYING TO @${replyData['sender']}'.toUpperCase(),
                  style: const TextStyle(
                    color: Sk.brass,
                    fontSize: 8,
                    fontFamily: 'Orbitron',
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  replyData['message'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Sk.cream.withOpacity(0.6),
                    fontSize: 10,
                    fontFamily: 'ShareTechMono',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() {
              if (isGlobal) {
                _globalReplyTo = null;
              } else {
                _privateReplyTo = null;
              }
            }),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Sk.metalDark,
                border: Border.all(color: Sk.metalLight, width: 1),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Sk.brass,
                size: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // INPUT BAR
  // ═══════════════════════════════════════════════════════════
  Widget _buildInputBar({
    required TextEditingController controller,
    required VoidCallback onSend,
    required String hint,
    required bool isGlobal,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Sk.metalMid, Sk.metalDark],
          ),
          border: Border.all(color: Sk.metalLight, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              offset: const Offset(0, 3),
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _SoftInset(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  controller: controller,
                  style: const TextStyle(
                    color: Sk.cream,
                    fontFamily: 'ShareTechMono',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                  cursorColor: Sk.brass,
                  cursorWidth: 2,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(
                      color: Sk.cream.withOpacity(0.3),
                      fontFamily: 'ShareTechMono',
                      fontSize: 12,
                    ),
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onSubmitted: (_) => onSend(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _SendButton(
              onTap: onSend,
              color: isGlobal ? Sk.purpleHi : Sk.greenHi,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String message) {
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
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Sk.purple, Sk.purpleDeep],
                  ),
                  border: Border.all(
                      color: Sk.purpleGlow.withOpacity(0.6), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Sk.purpleHi.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: Sk.purpleGlow,
                  size: 30,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  color: Sk.brass,
                  fontSize: 12,
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
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Sk.cream.withOpacity(0.6),
                  fontSize: 11,
                  fontFamily: 'ShareTechMono',
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                ),
              ),
            ],
          ),
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
  final Color color;
  const _SendButton({required this.onTap, required this.color});

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
        width: 44,
        height: 44,
        transform: Matrix4.translationValues(
          _pressed ? 1.5 : 0,
          _pressed ? 1.5 : 0,
          0,
        ),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
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
                    color: widget.color.withOpacity(0.4),
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
          size: 18,
          shadows: [
            Shadow(
              color: Colors.black38,
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
// SEARCH BAR BUTTON
// ═══════════════════════════════════════════════════════════
class _SearchBarButton extends StatefulWidget {
  final VoidCallback onTap;
  const _SearchBarButton({required this.onTap});

  @override
  State<_SearchBarButton> createState() => _SearchBarButtonState();
}

class _SearchBarButtonState extends State<_SearchBarButton> {
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        transform: Matrix4.translationValues(
          _pressed ? 1.5 : 0,
          _pressed ? 1.5 : 0,
          0,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Sk.metalMid, Sk.metalDark],
          ),
          border: Border.all(color: Sk.metalLight, width: 1),
          boxShadow: _pressed
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    offset: const Offset(0, 3),
                    blurRadius: 5,
                  ),
                ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: Sk.brass, size: 16),
            const SizedBox(width: 10),
            Text(
              'CARI USER BARU...',
              style: TextStyle(
                color: Sk.cream.withOpacity(0.5),
                fontFamily: 'Orbitron',
                fontWeight: FontWeight.w900,
                fontSize: 10,
                letterSpacing: 1.5,
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
          color: Sk.brass,
          size: widget.size * 0.42,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// SEARCH USER SHEET
// ═══════════════════════════════════════════════════════════
class _SearchUserSheet extends StatefulWidget {
  final String sessionKey;
  final String currentUsername;
  final Function(Map<String, dynamic>) onSelectUser;

  const _SearchUserSheet({
    required this.sessionKey,
    required this.currentUsername,
    required this.onSelectUser,
  });

  @override
  State<_SearchUserSheet> createState() => _SearchUserSheetState();
}

class _SearchUserSheetState extends State<_SearchUserSheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<dynamic> _results = [];
  bool _loading = false;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _search(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.length < 2) {
        if (mounted) setState(() => _results = []);
        return;
      }
      if (mounted) setState(() => _loading = true);
      try {
        final prefs = await SharedPreferences.getInstance();
        final sessionKey =
            prefs.getString('session_key') ?? widget.sessionKey;
        final res = await http.get(Uri.parse(
            '$baseUrl/chat/search-users?key=$sessionKey&q=$query'));
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          if (data['valid'] == true && mounted) {
            setState(() => _results = data['users'] ?? []);
          }
        }
      } catch (_) {}
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: Sk.metalLight,
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.6),
                    offset: const Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              child: Container(
                padding: const EdgeInsets.all(10),
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
                      color: Colors.black.withOpacity(0.5),
                      offset: const Offset(0, 3),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Sk.purpleHi, Sk.purple],
                        ),
                        border: Border.all(
                            color: Sk.purpleGlow.withOpacity(0.6),
                            width: 1),
                      ),
                      child: const Icon(Icons.search_rounded,
                          color: Colors.white, size: 14),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'CARI USER',
                        style: TextStyle(
                          color: Sk.brass,
                          fontSize: 12,
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
                    ),
                    _MetalIconButton(
                      icon: Icons.close_rounded,
                      size: 30,
                      onTap: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            ),

            // Search input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: _SoftInset(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: _search,
                  style: const TextStyle(
                    color: Sk.cream,
                    fontFamily: 'ShareTechMono',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                  cursorColor: Sk.brass,
                  cursorWidth: 2,
                  decoration: InputDecoration(
                    hintText: 'Masukkan username...',
                    hintStyle: TextStyle(
                      color: Sk.cream.withOpacity(0.3),
                      fontFamily: 'ShareTechMono',
                      fontSize: 12,
                    ),
                    prefixIcon: const Icon(
                      Icons.person_search_rounded,
                      color: Sk.brass,
                      size: 16,
                    ),
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Results
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: Sk.brass, strokeWidth: 2),
                    )
                  : _results.isEmpty
                      ? _buildEmptyResults()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 4),
                          itemCount: _results.length,
                          itemBuilder: (ctx, i) =>
                              _buildUserItem(_results[i]),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyResults() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Sk.metalMid, Sk.metalDark],
              ),
              border: Border.all(color: Sk.metalLight, width: 1.5),
            ),
            child: const Icon(
              Icons.person_search_rounded,
              color: Sk.metalLight,
              size: 26,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'TIDAK ADA USER',
            style: TextStyle(
              color: Sk.brass,
              fontSize: 11,
              fontFamily: 'Orbitron',
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Cari username lain',
            style: TextStyle(
              color: Sk.cream.withOpacity(0.5),
              fontSize: 10,
              fontFamily: 'ShareTechMono',
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserItem(dynamic user) {
    final profile = user['profile'] ?? {};
    final username = user['username'] as String;
    final initial =
        username.isNotEmpty ? username[0].toUpperCase() : '?';

    return GestureDetector(
      onTap: () => widget.onSelectUser(user),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Sk.leather, Sk.leatherDark],
          ),
          border: Border.all(color: Sk.metalLight, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              offset: const Offset(0, 3),
              blurRadius: 5,
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
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Sk.purple, Sk.purpleDeep],
                      ),
                      border: Border.all(
                          color: Sk.purpleGlow.withOpacity(0.6),
                          width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        initial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Orbitron',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile['name'] ?? username,
                          style: const TextStyle(
                            color: Sk.cream,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            fontFamily: 'Orbitron',
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (profile['bio'] != null &&
                            profile['bio'].toString().isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            profile['bio'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Sk.cream.withOpacity(0.5),
                              fontSize: 9,
                              fontFamily: 'ShareTechMono',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: Sk.brassDeep.withOpacity(0.4),
                      border: Border.all(
                          color: Sk.brass.withOpacity(0.6), width: 1),
                    ),
                    child: Text(
                      (user['role'] ?? 'MEMBER').toString().toUpperCase(),
                      style: const TextStyle(
                        color: Sk.brass,
                        fontSize: 7,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Orbitron',
                        letterSpacing: 1,
                      ),
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