import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Sk {
  static const Color metalDark = Color(0xFF2A2724);
  static const Color metalMid = Color(0xFF3A3632);
  static const Color metalLight = Color(0xFF4A4540);
  static const Color metalHi = Color(0xFF5A554E);
  static const Color brassDark = Color(0xFF8B6914);
  static const Color brass = Color(0xFFC9A961);
  static const Color brassHi = Color(0xFFE8C87F);
  static const Color purpleDark  = Color(0xFF4A148C);
  static const Color purple = Color(0xFF7B1FA2);
  static const Color purpleHi = Color(0xFF9C27B0);
  static const Color purpleGlow = Color(0xFFCE93D8);
  static const Color redDeep = Color(0xFF4A0808);
  static const Color red = Color(0xFF8B1818);
  static const Color redBright = Color(0xFFC41E1E);
  static const Color green = Color(0xFF4CAF50);
  static const Color cyan = Color(0xFF26C6DA);
  static const Color leather = Color(0xFF2A1F18);
  static const Color leatherDark = Color(0xFF1A1310);
  static const Color cream = Color(0xFFE8DFC8);
  static const Color ink = Color(0xFF2A2520);
}

class _Led extends StatelessWidget {
  final Color color;
  final double size;
  const _Led({required this.color, this.size = 8});

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
  const _Rivet({this.size = 8});
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
          colors: [Sk.brassHi, Sk.brassDark],
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
  const _Screw({this.size = 12});
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
          height: 1.5,
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
  const _SoftPanel({
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.radius = 14,
  });

  @override
  Widget build(BuildContext context) {
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
          color: Sk.metalLight,
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

class TqtoPage extends StatelessWidget {
  const TqtoPage({super.key});

  final List<Map<String, String>> contributors = const [
    {
      'name': 'Nted',
      'role': 'Maker',
      'avatar': 'https://files.catbox.moe/2ryxq0.jpg',
      'contact': 'https://t.me/NtedPakeE',
    },
    {
      'name': 'Shiro',
      'role': 'Dev Zeus',
      'avatar': 'https://files.catbox.moe/2ryxq0.jpg',
      'contact': 'https://t.me/rdsimmune',
    },
    {
      'name': 'Randa',
      'role': 'Developer Rxhl',
      'avatar': 'https://files.catbox.moe/y6ab5n.jpg',
      'contact': 'https://t.me/rxhlvr',
    },
    {
      'name': 'Melvin',
      'role': 'My best friend',
      'avatar': 'https://files.catbox.moe/y6ab5n.jpg',
      'contact': 'https://t.me/luyatiem',
    },
  ];

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
              _buildTopBar(context),
              const SizedBox(height: 4),
              _buildTitle(),
              const SizedBox(height: 12),
              _buildStatsBar(),
              const SizedBox(height: 14),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 4),
                  physics: const BouncingScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.82,
                  ),
                  itemCount: contributors.length,
                  itemBuilder: (context, index) {
                    final item = contributors[index];
                    return _ContributorCard(
                      name: item['name']!,
                      role: item['role']!,
                      avatarUrl: item['avatar']!,
                      contactUrl: item['contact']!,
                      index: index,
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // TOP BAR
  // ═══════════════════════════════════════════════════════════
  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Sk.metalMid, Sk.metalDark],
          ),
          border: Border.all(
            color: Sk.metalLight,
            width: 1,
          ),
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

              // Back button (metal circle)
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Sk.metalLight, Sk.metalDark],
                    ),
                    border: Border.all(
                      color: Sk.metalHi.withOpacity(0.5),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.6),
                        offset: const Offset(0, 2),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Sk.brass,
                    size: 14,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // LED
              const _Led(color: Sk.purpleGlow, size: 6),
              const SizedBox(width: 10),

              // Title
              const Expanded(
                child: Text(
                  'SPECIAL FAMILY',
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
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Count badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  gradient: const LinearGradient(
                    colors: [Sk.brassHi, Sk.brassDark],
                  ),
                  border: Border.all(color: Sk.brass, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      offset: const Offset(0, 2),
                      blurRadius: 3,
                    ),
                  ],
                ),
                child: Text(
                  '${contributors.length} MEMBER',
                  style: const TextStyle(
                    color: Sk.ink,
                    fontFamily: 'Orbitron',
                    fontWeight: FontWeight.w900,
                    fontSize: 9,
                    letterSpacing: 1,
                  ),
                ),
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
  // TITLE PANEL (TQ TO)
  // ═══════════════════════════════════════════════════════════
  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: _SoftPanel(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        child: Column(
          children: [
            // Main title with brass engraved effect
            Stack(
              alignment: Alignment.center,
              children: [
                // Shadow layer
                Transform.translate(
                  offset: const Offset(2, 2),
                  child: Text(
                    'THANK YOU',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.7),
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Orbitron',
                      letterSpacing: 6,
                    ),
                  ),
                ),
                // Main text
                const Text(
                  'THANK YOU',
                  style: TextStyle(
                    color: Sk.brass,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Orbitron',
                    letterSpacing: 6,
                    shadows: [
                      Shadow(
                        color: Sk.brassHi,
                        offset: Offset(0, -1),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Subtitle
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Rivet(size: 6),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: Sk.purpleDark.withOpacity(0.6),
                    border: Border.all(
                      color: Sk.purpleHi.withOpacity(0.7),
                      width: 1,
                    ),
                  ),
                  child: const Text(
                    'TO ALL CONTRIBUTORS',
                    style: TextStyle(
                      color: Sk.purpleGlow,
                      fontSize: 9,
                      fontFamily: 'Orbitron',
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _Rivet(size: 6),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // STATS BAR
  // ═══════════════════════════════════════════════════════════
  Widget _buildStatsBar() {
    final creatorCount = contributors
        .where((c) =>
            c['role']!.toLowerCase() == 'creator' ||
            c['role']!.toLowerCase() == 'ceo')
        .length;
    final supportCount = contributors
        .where((c) => c['role']!.toLowerCase() == 'support')
        .length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: _SoftPanel(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _statItem(
              icon: Icons.star_rounded,
              value: '$creatorCount',
              label: 'CREATOR',
              color: Sk.brass,
            ),
            _statItem(
              icon: Icons.support_agent_rounded,
              value: '$supportCount',
              label: 'SUPPORT',
              color: Sk.cyan,
            ),
            _statItem(
              icon: Icons.favorite_rounded,
              value: '∞',
              label: 'THANKS',
              color: Sk.redBright,
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.15),
            border: Border.all(
              color: color.withOpacity(0.5),
              width: 1.2,
            ),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w900,
            fontSize: 14,
            fontFamily: 'Orbitron',
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Sk.cream.withOpacity(0.55),
            fontSize: 8,
            fontFamily: 'ShareTechMono',
            letterSpacing: 1,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
// CONTRIBUTOR CARD (Soft Skeuomorphic)
// ═══════════════════════════════════════════════════════════
class _ContributorCard extends StatelessWidget {
  final String name;
  final String role;
  final String avatarUrl;
  final String contactUrl;
  final int index;

  const _ContributorCard({
    required this.name,
    required this.role,
    required this.avatarUrl,
    required this.contactUrl,
    required this.index,
  });

  // Role → color mapping
  Color _roleColor(String r) {
    switch (r.toLowerCase()) {
      case 'creator':
        return Sk.brass;
      case 'ceo':
        return Sk.brassHi;
      case 'support':
        return Sk.cyan;
      default:
        return Sk.purpleGlow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final roleColor = _roleColor(role);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Sk.leather, Sk.leatherDark],
        ),
        border: Border.all(
          color: Sk.metalLight,
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
      child: Stack(
        children: [
          // Corner rivets
          const Positioned(top: 4, left: 4, child: _Rivet(size: 6)),
          const Positioned(top: 4, right: 4, child: _Rivet(size: 6)),
          const Positioned(bottom: 4, left: 4, child: _Rivet(size: 6)),
          const Positioned(bottom: 4, right: 4, child: _Rivet(size: 6)),

          // Main content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Avatar in metal ring housing
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            roleColor.withOpacity(0.7),
                            roleColor.withOpacity(0.3),
                            Sk.metalDark,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: roleColor.withOpacity(0.4),
                            blurRadius: 12,
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.7),
                            offset: const Offset(0, 3),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Sk.metalDark,
                          border: Border.all(
                            color: Colors.black.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: ClipOval(
                          child: Image.network(
                            avatarUrl,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            // NO loadingBuilder (performance)
                            errorBuilder: (_, __, ___) => Container(
                              width: 56,
                              height: 56,
                              color: Sk.metalDark,
                              child: Icon(
                                Icons.person_rounded,
                                color: roleColor.withOpacity(0.6),
                                size: 26,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // LED indicator
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: _Led(color: roleColor, size: 8),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Name
                Text(
                  name,
                  style: const TextStyle(
                    color: Sk.cream,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
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
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),

                // Role badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: roleColor.withOpacity(0.2),
                    border: Border.all(
                      color: roleColor.withOpacity(0.6),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    role.toUpperCase(),
                    style: TextStyle(
                      color: roleColor,
                      fontSize: 8,
                      fontFamily: 'Orbitron',
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Contact button (small metal)
                _ContactButton(
                  color: roleColor,
                  onTap: () async {
                    final Uri uri = Uri.parse(contactUrl);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri,
                          mode: LaunchMode.externalApplication);
                    }
                  },
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
// CONTACT BUTTON
// ═══════════════════════════════════════════════════════════
class _ContactButton extends StatefulWidget {
  final Color color;
  final VoidCallback onTap;
  const _ContactButton({
    required this.color,
    required this.onTap,
  });

  @override
  State<_ContactButton> createState() => _ContactButtonState();
}

class _ContactButtonState extends State<_ContactButton> {
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
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
                ? [
                    widget.color.withOpacity(0.4),
                    widget.color.withOpacity(0.2),
                  ]
                : [
                    widget.color.withOpacity(0.7),
                    widget.color.withOpacity(0.4),
                  ],
          ),
          border: Border.all(
            color: widget.color.withOpacity(0.8),
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
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    offset: const Offset(0, 2),
                    blurRadius: 3,
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_rounded,
              color: Sk.ink,
              size: 12,
            ),
            const SizedBox(width: 5),
            Text(
              'CONTACT',
              style: TextStyle(
                color: Sk.ink,
                fontSize: 9,
                fontWeight: FontWeight.w900,
                fontFamily: 'Orbitron',
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}