import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'main.dart';
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

  // Red
  static const Color redDeep    = Color(0xFF3D0808);
  static const Color red        = Color(0xFF8B1818);
  static const Color redBright  = Color(0xFFC41E1E);
  static const Color redGlow    = Color(0xFFFF3030);

  // Green
  static const Color greenDeep  = Color(0xFF0A2818);
  static const Color green      = Color(0xFF2E7D32);
  static const Color greenHi    = Color(0xFF4CAF50);

  // Amber
  static const Color amberDeep  = Color(0xFF4A2800);
  static const Color amber      = Color(0xFFCC7A00);
  static const Color amberHi    = Color(0xFFFFB300);

  // Surface
  static const Color leather    = Color(0xFF2A1F18);
  static const Color leatherDark = Color(0xFF1A1310);
  static const Color leatherHi  = Color(0xFF3D2E22);
  static const Color cream      = Color(0xFFE8DFC8);
  static const Color ink        = Color(0xFF2A2520);
}

// ═══════════════════════════════════════════════════════════
// MODELS
// ═══════════════════════════════════════════════════════════
class BugSystem {
  final String id;
  final String name;
  final String description;
  final String icon;
  final int count;
  final int delay;

  BugSystem({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.count = 0,
    this.delay = 0,
  });
}

class GroupItem {
  final String id;
  final String name;
  final bool joined;
  final String avatarUrl;
  final int memberCount;
  bool isExpanded;

  GroupItem({
    required this.id,
    required this.name,
    this.joined = false,
    this.avatarUrl = '',
    this.memberCount = 0,
    this.isExpanded = false,
  });

  GroupItem copyWith({bool? isExpanded}) {
    return GroupItem(
      id: id,
      name: name,
      joined: joined,
      avatarUrl: avatarUrl,
      memberCount: memberCount,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
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

/// Soft metal panel (single container)
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
        border: Border.all(
          color: accentColor,
          width: 1.2,
        ),
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

/// Inset panel (for text field / inner content)
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
        border: Border.all(
          color: Sk.metalDark,
          width: 1.5,
        ),
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
// BUG GROUP PAGE
// ═══════════════════════════════════════════════════════════
class BugGroupPage extends StatefulWidget {
  final String sessionKey;
  final String role;

  const BugGroupPage({
    super.key,
    required this.sessionKey,
    required this.role,
  });

  @override
  State<BugGroupPage> createState() => _BugGroupPageState();
}

class _BugGroupPageState extends State<BugGroupPage> {
  bool _isSending = false;
  bool _isLoading = false;
  bool _isLoadingBugs = false;
  bool _hasSender = false;
  bool _allExpanded = false;
  GroupItem? _selectedGroup;
  BugSystem? _selectedBug;
  final TextEditingController _groupInputController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<GroupItem> _joinedGroups = [];
  List<GroupItem> _filteredGroups = [];
  List<BugSystem> _bugSystems = [];
  int _cooldownTime = 0;

  @override
  void initState() {
    super.initState();
    _checkSenderAndGroups();
    _fetchBugSystems();
  }

  @override
  void dispose() {
    _groupInputController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchBugSystems() async {
    setState(() => _isLoadingBugs = true);

    try {
      final res = await http.get(
        Uri.parse("$baseUrl/bugGroupSystems"),
        headers: {'Content-Type': 'application/json'},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data["valid"] == true) {
          final bugSystems = data["bugSystems"] as List?;
          final newBugs = bugSystems
                  ?.map((b) => BugSystem(
                        id: b["id"] ?? "",
                        name: b["name"] ?? "",
                        description: b["description"] ?? "",
                        icon: b["icon"] ?? "🐛",
                        count: b["count"] ?? 0,
                        delay: b["delay"] ?? 0,
                      ))
                  .toList() ??
              [];

          setState(() {
            _bugSystems = newBugs;
            if (newBugs.isNotEmpty && _selectedBug == null) {
              _selectedBug = newBugs.first;
            }
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching bug systems: $e");
    } finally {
      if (mounted) setState(() => _isLoadingBugs = false);
    }
  }

  Future<void> _checkSenderAndGroups() async {
    setState(() => _isLoading = true);

    try {
      final senderRes = await http.get(
        Uri.parse("$baseUrl/mySender?key=${widget.sessionKey}"),
        headers: {'Content-Type': 'application/json'},
      );

      if (senderRes.statusCode == 200) {
        final senderData = jsonDecode(senderRes.body);
        if (senderData["valid"] == true) {
          final connections = senderData["connections"] as List?;
          if (mounted) {
            setState(() {
              _hasSender =
                  connections != null && connections.isNotEmpty;
            });
          }
        }
      }

      if (_hasSender) {
        final groupRes = await http.get(
          Uri.parse("$baseUrl/myGroup?key=${widget.sessionKey}"),
          headers: {'Content-Type': 'application/json'},
        );

        if (groupRes.statusCode == 200) {
          final groupData = jsonDecode(groupRes.body);
          if (groupData["valid"] == true) {
            final groups = groupData["groups"] as List?;
            final newGroups = groups
                    ?.map((g) => GroupItem(
                          id: g["id"] ?? "",
                          name: g["name"] ?? "-",
                          joined: true,
                          avatarUrl: g["avatar"] ?? "",
                          memberCount: g["memberCount"] ?? 0,
                          isExpanded: false,
                        ))
                    .toList() ??
                [];

            if (mounted) {
              setState(() {
                _joinedGroups = newGroups;
                _filteredGroups = List.from(newGroups);
                if (newGroups.isNotEmpty && _selectedGroup == null) {
                  _selectedGroup = newGroups.first;
                }
              });
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filterGroups(String query) {
    if (query.isEmpty) {
      setState(() => _filteredGroups = List.from(_joinedGroups));
      return;
    }

    final filtered = _joinedGroups.where((group) {
      final name = group.name.toLowerCase();
      final id = group.id.toLowerCase();
      final searchLower = query.toLowerCase();
      return name.contains(searchLower) || id.contains(searchLower);
    }).toList();

    setState(() => _filteredGroups = filtered);
  }

  void _toggleGroupExpansion(int index) {
    setState(() {
      _filteredGroups[index] = _filteredGroups[index].copyWith(
        isExpanded: !_filteredGroups[index].isExpanded,
      );
    });
  }

  void _toggleAllGroups() {
    setState(() {
      _allExpanded = !_allExpanded;
      for (int i = 0; i < _filteredGroups.length; i++) {
        _filteredGroups[i] = _filteredGroups[i].copyWith(
          isExpanded: _allExpanded,
        );
      }
    });
  }

  Future<void> _joinGroupFromInput() async {
    final input = _groupInputController.text.trim();
    if (input.isEmpty) {
      _showToast("Please enter group JID or link", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final res = await http.post(
        Uri.parse("$baseUrl/joinGroup"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'key': widget.sessionKey,
          'groupInput': input,
        }),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data["valid"] == true && data["success"] == true) {
          _showSuccessDialog(
            title: "Group Joined",
            message: data["message"] ?? "Successfully joined group",
          );
          _groupInputController.clear();
          _checkSenderAndGroups();
        } else {
          _showErrorDialog(
            title: "Join Failed",
            message: data["message"] ?? "Failed to join group",
          );
        }
      } else {
        _showErrorDialog(
          title: "Server Error",
          message: "Status: ${res.statusCode}",
        );
      }
    } catch (e) {
      _showErrorDialog(
        title: "Connection Error",
        message: "Failed: $e",
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendBugToGroup() async {
    if (!_hasSender) {
      _showToast("No active sender available", isError: true);
      return;
    }
    if (_selectedGroup == null) {
      _showToast("Please select a group first", isError: true);
      return;
    }
    if (_selectedBug == null) {
      _showToast("Please select a bug system", isError: true);
      return;
    }

    setState(() {
      _isSending = true;
      _cooldownTime = 0;
    });

    try {
      final res = await http.get(Uri.parse(
          "$baseUrl/sendBugGroup?key=${widget.sessionKey}&group=${_selectedGroup!.id.split("@")[0]}&bugType=${_selectedBug!.id}"));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        if (data["cooldown"] == true) {
          final waitTime = data["wait"] ?? 0;
          setState(() => _cooldownTime = waitTime);
          _showToast("Cooldown active: ${waitTime}s", isError: true);
        } else if (data["valid"] == false) {
          _showToast("Invalid session key", isError: true);
        } else if (data["sended"] == true) {
          _showSuccessDialog(
            title: "${_selectedBug!.name} Sent",
            message:
                "Successfully sent ${_selectedBug!.name} to ${_selectedGroup!.name}",
          );
        } else {
          _showToast("Failed to send bug", isError: true);
        }
      } else {
        _showToast("Server error: ${res.statusCode}", isError: true);
      }
    } catch (e) {
      _showToast("Connection failed: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // DIALOGS (Skeuomorphic)
  // ═══════════════════════════════════════════════════════════
  void _showSuccessDialog({required String title, required String message}) {
    _showSkeuoDialog(
      icon: Icons.check_circle_rounded,
      iconColor: Sk.greenHi,
      title: title,
      message: message,
      onClose: () => Navigator.pop(context),
    );
  }

  void _showErrorDialog({required String title, required String message}) {
    _showSkeuoDialog(
      icon: Icons.error_outline_rounded,
      iconColor: Sk.redBright,
      title: title,
      message: message,
      onClose: () => Navigator.pop(context),
    );
  }

  void _showSkeuoDialog({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    required VoidCallback onClose,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: _SoftPanel(
          padding: const EdgeInsets.all(22),
          accent: iconColor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon housing
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: iconColor.withOpacity(0.15),
                      border: Border.all(
                        color: iconColor.withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(icon, color: iconColor, size: 32),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: _Led(color: iconColor, size: 8),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Title
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: iconColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Orbitron',
                  letterSpacing: 1.5,
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
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Sk.cream,
                  fontSize: 12,
                  fontFamily: 'ShareTechMono',
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 22),

              // OK button
              _MetalButton(
                color: iconColor,
                height: 44,
                onTap: onClose,
                label: 'OK',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showToast(String message, {bool isError = false}) {
    final color = isError ? Sk.redBright : Sk.brass;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Sk.metalDark,
        content: Row(
          children: [
            _Led(color: color, size: 8),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
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
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Join Group Panel
                      _buildJoinPanel(),
                      const SizedBox(height: 14),

                      // Search Panel (if has groups)
                      if (_joinedGroups.isNotEmpty) ...[
                        _buildSearchPanel(),
                        const SizedBox(height: 12),
                        _buildGroupsHeader(),
                        const SizedBox(height: 8),
                        _buildGroupsList(),
                        const SizedBox(height: 16),

                        // Bug Systems (if group selected)
                        if (_selectedGroup != null)
                          _buildBugSystemsPanel(),
                      ] else ...[
                        _buildEmptyState(),
                      ],
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

              // Back button
              _MetalIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(width: 10),

              // LED
              const _Led(color: Sk.redBright, size: 7),
              const SizedBox(width: 10),

              // Title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'BUG GROUPS',
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
                      _hasSender
                          ? '${_joinedGroups.length} groups · ${widget.role}'
                          : 'No sender connected',
                      style: TextStyle(
                        color: _hasSender
                            ? Sk.greenHi
                            : Sk.cream.withOpacity(0.5),
                        fontSize: 9,
                        fontFamily: 'ShareTechMono',
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Refresh button
              _MetalIconButton(
                icon: _isLoading
                    ? Icons.hourglass_top_rounded
                    : Icons.refresh_rounded,
                onTap: _checkSenderAndGroups,
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
  // JOIN PANEL
  // ═══════════════════════════════════════════════════════════
  Widget _buildJoinPanel() {
    return _SoftPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _Led(color: Sk.brass, size: 7),
              const SizedBox(width: 8),
              const Icon(Icons.add_circle_outline_rounded,
                  color: Sk.brass, size: 15),
              const SizedBox(width: 8),
              const Text(
                'JOIN NEW GROUP',
                style: TextStyle(
                  color: Sk.brass,
                  fontFamily: 'Orbitron',
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 1.8,
                ),
              ),
              const Spacer(),
              const _Screw(size: 10),
            ],
          ),
          const SizedBox(height: 12),

          // Input field
          _SoftInset(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: Sk.metalDark,
                    border: Border.all(color: Sk.metalLight, width: 1),
                  ),
                  child: const Icon(
                    Icons.link_rounded,
                    color: Sk.brass,
                    size: 13,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _groupInputController,
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
                      hintText: 'Group JID or link...',
                      hintStyle: TextStyle(
                        color: Sk.cream.withOpacity(0.3),
                        fontFamily: 'ShareTechMono',
                        fontSize: 12,
                      ),
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Join button
          _MetalButton(
            color: Sk.brass,
            height: 48,
            onTap: _isLoading ? null : _joinGroupFromInput,
            label: 'JOIN GROUP',
            icon: Icons.add_rounded,
            loading: _isLoading,
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // SEARCH PANEL
  // ═══════════════════════════════════════════════════════════
  Widget _buildSearchPanel() {
    return _SoftPanel(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Row(
        children: [
          const SizedBox(width: 6),
          const Icon(Icons.search_rounded, color: Sk.brass, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _filterGroups,
              style: const TextStyle(
                color: Sk.cream,
                fontFamily: 'ShareTechMono',
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
              cursorColor: Sk.brass,
              cursorWidth: 2,
              decoration: InputDecoration(
                hintText: 'Search groups...',
                hintStyle: TextStyle(
                  color: Sk.cream.withOpacity(0.3),
                  fontFamily: 'ShareTechMono',
                  fontSize: 12,
                ),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            _MetalIconButton(
              icon: Icons.close_rounded,
              size: 26,
              onTap: () {
                _searchController.clear();
                _filterGroups('');
              },
            ),
          _MetalIconButton(
            icon: _allExpanded
                ? Icons.unfold_less_rounded
                : Icons.unfold_more_rounded,
            size: 26,
            onTap: _toggleAllGroups,
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // GROUPS HEADER
  // ═══════════════════════════════════════════════════════════
  Widget _buildGroupsHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          const Icon(Icons.list_alt_rounded,
              color: Sk.brass, size: 16),
          const SizedBox(width: 8),
          const Text(
            'YOUR GROUPS',
            style: TextStyle(
              color: Sk.brass,
              fontFamily: 'Orbitron',
              fontWeight: FontWeight.w900,
              fontSize: 11,
              letterSpacing: 1.8,
            ),
          ),
          const Spacer(),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.black.withOpacity(0.5),
              border: Border.all(color: Sk.metalDark, width: 1),
            ),
            child: Text(
              '${_filteredGroups.length} GROUPS',
              style: const TextStyle(
                color: Sk.brass,
                fontSize: 8,
                fontFamily: 'Orbitron',
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // GROUPS LIST
  // ═══════════════════════════════════════════════════════════
  Widget _buildGroupsList() {
    if (_filteredGroups.isEmpty) {
      return _SoftPanel(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.search_off_rounded,
                color: Sk.metalLight,
                size: 40,
              ),
              const SizedBox(height: 12),
              Text(
                'No groups found',
                style: TextStyle(
                  color: Sk.cream.withOpacity(0.6),
                  fontSize: 13,
                  fontFamily: 'ShareTechMono',
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredGroups.length,
      itemBuilder: (context, index) => _buildGroupCard(index),
    );
  }

  Widget _buildGroupCard(int index) {
    final group = _filteredGroups[index];
    final isSelected = _selectedGroup?.id == group.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
          color: isSelected ? Sk.brass : Sk.metalLight,
          width: isSelected ? 1.8 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? Sk.redBright.withOpacity(0.3)
                : Colors.black.withOpacity(0.5),
            offset: const Offset(0, 4),
            blurRadius: isSelected ? 10 : 6,
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

          Column(
            children: [
              // Header (tap to expand)
              GestureDetector(
                onTap: () => _toggleGroupExpansion(index),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      // Avatar housing
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: isSelected
                                    ? [Sk.brassHi, Sk.brassDark]
                                    : [Sk.metalLight, Sk.metalDark],
                              ),
                              border: Border.all(
                                color: isSelected
                                    ? Sk.brass
                                    : Sk.metalDark,
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              Icons.groups_rounded,
                              color: isSelected
                                  ? Sk.ink
                                  : Sk.brass,
                              size: 22,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: _Led(
                              color: Sk.greenHi,
                              size: 8,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),

                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    group.name,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Sk.cream
                                          : Sk.cream,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      fontFamily: 'Orbitron',
                                      letterSpacing: 0.5,
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
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(3),
                                    color: Sk.green
                                        .withOpacity(0.2),
                                    border: Border.all(
                                      color: Sk.greenHi
                                          .withOpacity(0.5),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Text(
                                    'JOINED',
                                    style: TextStyle(
                                      color: Sk.greenHi,
                                      fontSize: 7,
                                      fontWeight: FontWeight.w900,
                                      fontFamily: 'Orbitron',
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.people_alt_outlined,
                                  color: Sk.cream.withOpacity(0.5),
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${group.memberCount} members',
                                  style: TextStyle(
                                    color: Sk.cream.withOpacity(0.55),
                                    fontSize: 10,
                                    fontFamily: 'ShareTechMono',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  group.isExpanded
                                      ? Icons.keyboard_arrow_up_rounded
                                      : Icons.keyboard_arrow_down_rounded,
                                  color: Sk.brass,
                                  size: 18,
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

              // Expanded content
              if (group.isExpanded) ...[
                Container(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  child: Column(
                    children: [
                      _SoftInset(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            const Icon(Icons.fingerprint_rounded,
                                color: Sk.brass, size: 14),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'GROUP ID',
                                    style: TextStyle(
                                      color:
                                          Sk.cream.withOpacity(0.5),
                                      fontSize: 8,
                                      fontWeight: FontWeight.w900,
                                      fontFamily: 'Orbitron',
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    group.id,
                                    style: const TextStyle(
                                      color: Sk.cream,
                                      fontSize: 10,
                                      fontFamily: 'ShareTechMono',
                                      fontWeight: FontWeight.w700,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      _MetalButton(
                        color: isSelected ? Sk.greenHi : Sk.brass,
                        height: 38,
                        onTap: () {
                          setState(() => _selectedGroup = group);
                        },
                        label:
                            isSelected ? 'SELECTED' : 'SELECT GROUP',
                        icon: isSelected
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // BUG SYSTEMS PANEL
  // ═══════════════════════════════════════════════════════════
  Widget _buildBugSystemsPanel() {
    return _SoftPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _Led(color: Sk.redBright, size: 7),
              const SizedBox(width: 8),
              const Icon(Icons.bug_report_rounded,
                  color: Sk.redBright, size: 15),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'BUG SYSTEMS',
                  style: TextStyle(
                    color: Sk.brass,
                    fontFamily: 'Orbitron',
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
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
              ),
              const _Screw(size: 10),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Selected: ${_selectedGroup!.name}',
            style: TextStyle(
              color: Sk.cream.withOpacity(0.55),
              fontSize: 10,
              fontFamily: 'ShareTechMono',
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 14),

          // Bug systems horizontal list
          _isLoadingBugs
              ? const SizedBox(
                  height: 120,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Sk.brass,
                      strokeWidth: 2,
                    ),
                  ),
                )
              : SizedBox(
                  height: 130,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _bugSystems.length,
                    itemBuilder: (context, index) {
                      return _buildBugSystemCard(_bugSystems[index]);
                    },
                  ),
                ),

          const SizedBox(height: 16),

          // Send button
          _MetalButton(
            color: _cooldownTime > 0 || _selectedBug == null
                ? Sk.metalLight
                : Sk.redBright,
            height: 50,
            onTap: _isSending ||
                    _cooldownTime > 0 ||
                    _selectedBug == null
                ? null
                : _sendBugToGroup,
            label: _cooldownTime > 0
                ? 'WAIT ${_cooldownTime}s'
                : 'SEND ${_selectedBug?.name?.toUpperCase() ?? 'BUG'}',
            icon: _cooldownTime > 0
                ? Icons.timer_outlined
                : Icons.send_rounded,
            loading: _isSending,
          ),
        ],
      ),
    );
  }

  Widget _buildBugSystemCard(BugSystem bug) {
    final isSelected = _selectedBug?.id == bug.id;

    return GestureDetector(
      onTap: () => setState(() => _selectedBug = bug),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12, bottom: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? [Sk.red, Sk.redDeep]
                : [Sk.leather, Sk.leatherDark],
          ),
          border: Border.all(
            color: isSelected ? Sk.brass : Sk.metalLight,
            width: isSelected ? 1.8 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? Sk.redBright.withOpacity(0.3)
                  : Colors.black.withOpacity(0.5),
              offset: const Offset(0, 3),
              blurRadius: isSelected ? 8 : 5,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Icon housing
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.black.withOpacity(0.4),
                    border: Border.all(
                      color: isSelected
                          ? Sk.brass
                          : Sk.metalDark,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      bug.icon,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Sk.brassHi, Sk.brassDark],
                      ),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Sk.ink,
                      size: 13,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              bug.name,
              style: const TextStyle(
                color: Sk.cream,
                fontSize: 12,
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
            Text(
              bug.description,
              style: TextStyle(
                color: Sk.cream.withOpacity(0.55),
                fontSize: 9,
                fontFamily: 'ShareTechMono',
                fontWeight: FontWeight.w700,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // EMPTY STATE
  // ═══════════════════════════════════════════════════════════
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: _SoftPanel(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        child: Column(
          children: [
            // Icon housing
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Sk.metalMid, Sk.metalDark],
                ),
                border: Border.all(color: Sk.metalLight, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.6),
                    offset: const Offset(0, 6),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Icon(
                Icons.group_off_rounded,
                color: Sk.metalLight,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'NO GROUPS AVAILABLE',
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
            const SizedBox(height: 12),
            Text(
              'Connect a WhatsApp sender and join groups to start sending bugs',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Sk.cream.withOpacity(0.55),
                fontSize: 11,
                fontFamily: 'ShareTechMono',
                fontWeight: FontWeight.w700,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// REUSABLE BUTTONS
// ═══════════════════════════════════════════════════════════

/// Metal button (with pressed state)
class _MetalButton extends StatefulWidget {
  final Color color;
  final double height;
  final VoidCallback? onTap;
  final String label;
  final IconData? icon;
  final bool loading;
  const _MetalButton({
    required this.color,
    required this.height,
    required this.onTap,
    required this.label,
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
              child: widget.loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Sk.cream,
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(
                            widget.icon,
                            color: Sk.cream,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          widget.label,
                          style: const TextStyle(
                            color: Sk.cream,
                            fontSize: 12,
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

/// Small metal icon button
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