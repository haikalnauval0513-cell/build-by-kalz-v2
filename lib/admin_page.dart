import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'api_config.dart';

class AdminPage extends StatefulWidget {
  final String sessionKey;

  const AdminPage({super.key, required this.sessionKey});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage>
    with TickerProviderStateMixin {
  late String sessionKey;
  List<dynamic> fullUserList = [];
  List<dynamic> filteredList = [];

  final List<String> roleOptions = ['reseller', 'vip', 'member'];
  String selectedRole = 'member';

  int currentPage = 1;
  int itemsPerPage = 25;

  final deleteController = TextEditingController();
  final createUsernameController = TextEditingController();
  final createPasswordController = TextEditingController();
  final createDayController = TextEditingController();
  String newUserRole = 'member';
  bool isLoading = false;

  // Gold & Dark theme - elegant
  static const _bgDark = Color(0xFF0A0A0A);
  static const _bgCard = Color(0xFF141414);
  static const _bgCardAlt = Color(0xFF1A1A1A);
  static const _border = Color(0xFF2A2A2A);
  
  static const _gold = Color(0xFFC9A84C);
  static const _goldLight = Color(0xFFE8D5A0);
  static const _goldDark = Color(0xFFA8893A);
  static const _goldMuted = Color(0xFF8A7A4A);
  
  static const _textPrimary = Color(0xFFF5F0EB);
  static const _textSecondary = Color(0xFF8A8078);
  static const _textDim = Color(0xFF5A5048);
  
  static const _success = Color(0xFF7AAA6A);
  static const _danger = Color(0xFFC97A6A);

  late AnimationController _headerController;
  late AnimationController _pulseController;
  late Animation<double> _headerFade;
  late Animation<double> _headerSlide;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    sessionKey = widget.sessionKey;

    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _headerFade = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOut,
    );
    _headerSlide = Tween<double>(begin: -24, end: 0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOutCubic),
    );
    _pulse = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _headerController.forward();
    _fetchUsers();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _fetchUsers() async {
    setState(() => isLoading = true);
    try {
      final res = await http.get(
        Uri.parse(
            '$baseUrl/listUsers?key=$sessionKey'),
      );
      final data = jsonDecode(res.body);
      if (data['valid'] == true && data['authorized'] == true) {
        fullUserList = data['users'] ?? [];
        _filterAndPaginate();
      } else {
        _alert('Error', data['message'] ?? 'Tidak diizinkan.', isError: true);
      }
    } catch (_) {
      _alert('Koneksi Gagal', 'Tidak dapat menghubungi server.', isError: true);
    }
    setState(() => isLoading = false);
  }

  void _filterAndPaginate() {
    setState(() {
      currentPage = 1;
      filteredList =
          fullUserList.where((u) => u['role'] == selectedRole).toList();
    });
  }

  List<dynamic> _getCurrentPageData() {
    final start = (currentPage - 1) * itemsPerPage;
    final end = start + itemsPerPage;
    return filteredList.sublist(
        start, end > filteredList.length ? filteredList.length : end);
  }

  int get totalPages => (filteredList.length / itemsPerPage).ceil();

  Future<void> _deleteUser() async {
    final username = deleteController.text.trim();
    if (username.isEmpty) {
      _alert('Perhatian', 'Masukkan username yang ingin dihapus.',
          isError: true);
      return;
    }
    setState(() => isLoading = true);
    try {
      final res = await http.get(Uri.parse(
          '$baseUrl/deleteUser?key=$sessionKey&username=$username'));
      final data = jsonDecode(res.body);
      if (data['deleted'] == true) {
        _alert('Berhasil', "User '${data['user']['username']}' telah dihapus.");
        deleteController.clear();
        _fetchUsers();
      } else {
        _alert('Gagal', data['message'] ?? 'Gagal menghapus user.',
            isError: true);
      }
    } catch (_) {
      _alert('Error', 'Tidak dapat menghubungi server.', isError: true);
    }
    setState(() => isLoading = false);
  }

  Future<void> _createAccount() async {
    final username = createUsernameController.text.trim();
    final password = createPasswordController.text.trim();
    final day = createDayController.text.trim();

    if (username.isEmpty || password.isEmpty || day.isEmpty) {
      _alert('Perhatian', 'Semua field wajib diisi.', isError: true);
      return;
    }
    setState(() => isLoading = true);
    try {
      final res = await http.get(Uri.parse(
          '$baseUrl/userAdd?key=$sessionKey&username=$username&password=$password&day=$day&role=$newUserRole'));
      final data = jsonDecode(res.body);
      if (data['created'] == true) {
        _alert('Sukses', "Akun '${data['user']['username']}' berhasil dibuat.");
        createUsernameController.clear();
        createPasswordController.clear();
        createDayController.clear();
        setState(() => newUserRole = 'member');
        _fetchUsers();
      } else {
        _alert('Gagal', data['message'] ?? 'Gagal membuat akun.',
            isError: true);
      }
    } catch (_) {
      _alert('Error', 'Gagal menghubungi server.', isError: true);
    }
    setState(() => isLoading = false);
  }

  void _alert(String title, String message, {bool isError = false}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (ctx, anim, _, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: anim, child: child),
        );
      },
      pageBuilder: (ctx, _, __) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 360),
          decoration: BoxDecoration(
            color: _bgCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isError
                  ? _danger.withOpacity(0.4)
                  : _gold.withOpacity(0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: (isError ? _danger : _gold)
                    .withOpacity(0.15),
                blurRadius: 40,
                spreadRadius: 0,
              ),
            ],
          ),
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (isError ? _danger : _gold)
                      .withOpacity(0.12),
                ),
                child: Icon(
                  isError ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                  color: isError ? _danger : _gold,
                  size: 26,
                ),
              ),
              const SizedBox(height: 16),
              Text(title,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  )),
              const SizedBox(height: 10),
              Text(message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: _textSecondary, fontSize: 14, height: 1.5)),
              const SizedBox(height: 24),
              _buildButton(
                label: 'OK',
                onTap: () => Navigator.pop(ctx),
                isDestructive: false,
                fullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(String username) {
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 280),
      transitionBuilder: (ctx, anim, _, child) => ScaleTransition(
        scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
        child: FadeTransition(opacity: anim, child: child),
      ),
      pageBuilder: (ctx, _, __) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 360),
          decoration: BoxDecoration(
            color: _bgCard,
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: _danger.withOpacity(0.35), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: _danger.withOpacity(0.12),
                blurRadius: 40,
              ),
            ],
          ),
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _danger.withOpacity(0.12),
                ),
                child: const Icon(Icons.delete_outline_rounded,
                    color: _danger, size: 26),
              ),
              const SizedBox(height: 16),
              const Text('Hapus User',
                  style: TextStyle(
                      color: _textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              Text("Yakin ingin menghapus '$username'?\nTindakan ini tidak bisa dibatalkan.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: _textSecondary, fontSize: 14, height: 1.5)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildButton(
                      label: 'Batal',
                      onTap: () => Navigator.pop(ctx, false),
                      isDestructive: false,
                      isOutline: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildButton(
                      label: 'Hapus',
                      onTap: () => Navigator.pop(ctx, true),
                      isDestructive: true,
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

  Widget _buildButton({
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
    bool isOutline = false,
    bool fullWidth = false,
    dynamic icon,
    bool loading = false,
  }) {
    final Color baseColor = isDestructive ? _danger : _gold;

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: 46,
      child: _PressableButton(
        onTap: loading ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            gradient: isOutline
                ? null
                : LinearGradient(
                    colors: [
                      baseColor,
                      baseColor.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            color: isOutline ? Colors.transparent : null,
            borderRadius: BorderRadius.circular(12),
            border: isOutline
                ? Border.all(color: _border, width: 1.5)
                : null,
            boxShadow: isOutline
                ? null
                : [
                    BoxShadow(
                      color: baseColor.withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: loading
              ? const Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.black),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      _DynamicIcon(icon, size: 16, color: isOutline ? _textSecondary : Colors.black),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      label,
                      style: TextStyle(
                        color: isOutline ? _textSecondary : Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required String label,
    required TextEditingController controller,
    required dynamic icon,
    TextInputType type = TextInputType.text,
    bool obscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: type,
        obscureText: obscure,
        style: const TextStyle(
            color: _textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
        cursorColor: _gold,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: _textSecondary, fontSize: 13),
          floatingLabelStyle:
              const TextStyle(color: _gold, fontSize: 12),
          prefixIcon:
              _DynamicIcon(icon, color: _textDim, size: 18),
          filled: true,
          fillColor: _bgDark,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _gold, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
    String? label,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _bgDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null)
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 2),
              child: Text(label,
                  style:
                      const TextStyle(color: _textSecondary, fontSize: 11)),
            ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: _bgCard,
              icon:
                  const Icon(Icons.expand_more, color: _textDim, size: 20),
              style: const TextStyle(
                  color: _textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
              items: options.map((opt) {
                return DropdownMenuItem(
                  value: opt,
                  child: Text(opt.toUpperCase(),
                      style: const TextStyle(letterSpacing: 0.5)),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String subtitle,
    required dynamic icon,
    required List<Widget> children,
    Color? accentColor,
  }) {
    final color = accentColor ?? _gold;
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: _bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.06),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      color: _border.withOpacity(0.6))),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: color.withOpacity(0.2)),
                  ),
                  child: _DynamicIcon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                          color: _textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        )),
                    Text(subtitle,
                        style: const TextStyle(
                            color: _textSecondary, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserItem(Map user, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 350 + (index * 50).clamp(0, 400)),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, 12 * (1 - v)),
          child: child,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _bgDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _gold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  (user['username'] as String)
                      .substring(0, 1)
                      .toUpperCase(),
                  style: const TextStyle(
                    color: _gold,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user['username'],
                      style: const TextStyle(
                          color: _textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      _badge(user['role'].toUpperCase()),
                      const SizedBox(width: 8),
                      Text("Exp: ${user['expiredDate']}",
                          style: const TextStyle(
                              color: _textSecondary, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text("Parent: ${user['parent'] ?? 'SYSTEM'}",
                      style: const TextStyle(
                          color: _textDim, fontSize: 11)),
                ],
              ),
            ),
            _IconBtn(
              icon: Icons.delete_outline_rounded,
              color: _danger,
              onTap: () async {
                final confirm =
                    await _confirmDelete(user['username']);
                if (confirm == true) {
                  deleteController.text = user['username'];
                  _deleteUser();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _gold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _gold.withOpacity(0.3)),
      ),
      child: Text(label,
          style: const TextStyle(
              color: _goldMuted, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildPagination() {
    if (totalPages <= 1) return const SizedBox();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _PillBtn(
            icon: Icons.chevron_left,
            enabled: currentPage > 1,
            onTap: () => setState(() => currentPage--),
          ),
          const SizedBox(width: 6),
          ...List.generate(totalPages, (i) {
            final page = i + 1;
            final active = page == currentPage;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: _PillBtn(
                label: '$page',
                active: active,
                onTap: () => setState(() => currentPage = page),
              ),
            );
          }),
          const SizedBox(width: 6),
          _PillBtn(
            icon: Icons.chevron_right,
            enabled: currentPage < totalPages,
            onTap: () => setState(() => currentPage++),
          ),
        ],
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      body: Stack(
        children: [
          // Background grid pattern
          Positioned.fill(child: _GridBackground()),

          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── Header ──
                SliverToBoxAdapter(
                  child: AnimatedBuilder(
                    animation: _headerController,
                    builder: (_, __) => Opacity(
                      opacity: _headerFade.value,
                      child: Transform.translate(
                        offset: Offset(0, _headerSlide.value),
                        child: _buildHeader(),
                      ),
                    ),
                  ),
                ),

                // ── Content ──
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Stats row
                      _buildStatsRow(),
                      const SizedBox(height: 24),

                      // Section: Delete User
                      _buildSection(
                        title: 'Hapus User',
                        subtitle: 'Nonaktifkan akun dari sistem',
                        icon: FontAwesomeIcons.userSlash,
                        accentColor: _danger,
                        children: [
                          _buildInput(
                            label: 'Username Target',
                            controller: deleteController,
                            icon: FontAwesomeIcons.user,
                          ),
                          const SizedBox(height: 4),
                          _buildButton(
                            label: 'Hapus Akun',
                            onTap: _deleteUser,
                            icon: Icons.delete_outline_rounded,
                            isDestructive: true,
                            fullWidth: true,
                            loading: isLoading,
                          ),
                        ],
                      ),

                      // Section: Create Account
                      _buildSection(
                        title: 'Buat Akun Baru',
                        subtitle: 'Tambah pengguna ke sistem',
                        icon: FontAwesomeIcons.userPlus,
                        children: [
                          _buildInput(
                            label: 'Username',
                            controller: createUsernameController,
                            icon: FontAwesomeIcons.user,
                          ),
                          _buildInput(
                            label: 'Password',
                            controller: createPasswordController,
                            icon: FontAwesomeIcons.lock,
                            obscure: true,
                          ),
                          _buildInput(
                            label: 'Durasi (Hari)',
                            controller: createDayController,
                            icon: FontAwesomeIcons.calendarDay,
                            type: TextInputType.number,
                          ),
                          _buildDropdown(
                            value: newUserRole,
                            options: roleOptions,
                            label: 'Role',
                            onChanged: (v) =>
                                setState(() => newUserRole = v ?? 'member'),
                          ),
                          const SizedBox(height: 16),
                          _buildButton(
                            label: 'Buat Akun',
                            onTap: _createAccount,
                            icon: Icons.add_rounded,
                            fullWidth: true,
                            loading: isLoading,
                          ),
                        ],
                      ),

                      // Section: User Management
                      _buildSection(
                        title: 'User Management',
                        subtitle:
                            '${filteredList.length} pengguna ditemukan',
                        icon: FontAwesomeIcons.users,
                        children: [
                          _buildDropdown(
                            value: selectedRole,
                            options: roleOptions,
                            label: 'Filter Role',
                            onChanged: (v) {
                              if (v != null) {
                                selectedRole = v;
                                _filterAndPaginate();
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          if (isLoading)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 32),
                              child: Center(
                                child: _LoadingDots(),
                              ),
                            )
                          else if (filteredList.isEmpty)
                            _buildEmptyState()
                          else
                            Column(
                              children: [
                                ..._getCurrentPageData()
                                    .asMap()
                                    .entries
                                    .map((e) =>
                                        _buildUserItem(e.value, e.key))
                                    .toList(),
                                const SizedBox(height: 16),
                                _buildPagination(),
                              ],
                            ),
                        ],
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),

          // Loading overlay
          if (isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
      child: Row(
        children: [
          // Logo mark
          AnimatedBuilder(
            animation: _pulseController,
            builder: (_, __) => Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _bgCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: _gold.withOpacity(0.4 * _pulse.value)),
                boxShadow: [
                  BoxShadow(
                    color: _gold.withOpacity(0.2 * _pulse.value),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: const Icon(Icons.admin_panel_settings_outlined,
                  color: _gold, size: 22),
            ),
          ),
          const SizedBox(width: 14),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [_gold, _goldLight],
            ).createShader(bounds),
            child: const Text('Admin Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                )),
          ),
          const Spacer(),
          _IconBtn(
            icon: Icons.refresh_rounded,
            color: _textSecondary,
            onTap: _fetchUsers,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final totalAll = fullUserList.length;
    final totalReseller =
        fullUserList.where((u) => u['role'] == 'reseller').length;
    final totalMember =
        fullUserList.where((u) => u['role'] == 'member').length;

    return Row(
      children: [
        _buildStatCard('Total User', '$totalAll',
            Icons.people_outline_rounded, _gold),
        const SizedBox(width: 10),
        _buildStatCard('Reseller', '$totalReseller',
            Icons.storefront_outlined, _success),
        const SizedBox(width: 10),
        _buildStatCard('Member', '$totalMember',
            Icons.person_outline_rounded, _goldMuted),
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, dynamic icon, Color color) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: _bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DynamicIcon(icon, color: color, size: 18),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    color: color,
                    fontSize: 20,
                    fontWeight: FontWeight.w700)),
            Text(label,
                style:
                    const TextStyle(color: _textSecondary, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, color: _textDim, size: 40),
          const SizedBox(height: 12),
          const Text('Tidak ada data',
              style: TextStyle(color: _textSecondary, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Positioned.fill(
      child: IgnorePointer(
        ignoring: false,
        child: Container(color: Colors.transparent),
      ),
    );
  }
}

// ─── Helper Widgets ──────────────────────────────────────────────────────────

/// Icon button bulat minimal
class _IconBtn extends StatefulWidget {
  final dynamic icon;
  final Color color;
  final VoidCallback onTap;
  const _IconBtn(
      {required this.icon, required this.color, required this.onTap});

  @override
  State<_IconBtn> createState() => _IconBtnState();
}

class _IconBtnState extends State<_IconBtn> {
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
        duration: const Duration(milliseconds: 120),
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: _pressed
              ? widget.color.withOpacity(0.15)
              : _AdminPageState._bgDark,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _AdminPageState._border),
        ),
        child: _DynamicIcon(widget.icon, color: widget.color, size: 18),
      ),
    );
  }
}

/// Tombol pill untuk pagination
class _PillBtn extends StatelessWidget {
  final String? label;
  final dynamic icon;
  final bool active;
  final bool enabled;
  final VoidCallback onTap;

  const _PillBtn({
    this.label,
    this.icon,
    this.active = false,
    this.enabled = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: active
              ? _AdminPageState._gold
              : _AdminPageState._bgDark,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active
                ? _AdminPageState._gold
                : _AdminPageState._border,
          ),
        ),
        child: Center(
          child: icon != null
              ? _DynamicIcon(icon,
                  size: 16,
                  color: enabled
                      ? _AdminPageState._textSecondary
                      : _AdminPageState._border)
              : Text(
                  label ?? '',
                  style: TextStyle(
                    color: active
                        ? Colors.black
                        : _AdminPageState._textSecondary,
                    fontSize: 13,
                    fontWeight: active
                        ? FontWeight.w700
                        : FontWeight.w400,
                  ),
                ),
        ),
      ),
    );
  }
}

/// Tombol dengan efek press (scale + opacity)
class _PressableButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _PressableButton({required this.child, this.onTap});

  @override
  State<_PressableButton> createState() => _PressableButtonState();
}

class _PressableButtonState extends State<_PressableButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) {
        setState(() => _down = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _down = false),
      child: AnimatedScale(
        scale: _down ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedOpacity(
          opacity: widget.onTap == null ? 0.45 : (_down ? 0.85 : 1.0),
          duration: const Duration(milliseconds: 100),
          child: widget.child,
        ),
      ),
    );
  }
}

/// Loading dots animasi
class _LoadingDots extends StatefulWidget {
  const _LoadingDots();

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i / 3;
            final t = ((_c.value - delay) % 1.0).clamp(0.0, 1.0);
            final scale = math.sin(t * math.pi);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.scale(
                scale: 0.5 + scale * 0.5,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _AdminPageState._gold
                        .withOpacity(0.4 + scale * 0.6),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

/// Background grid pattern
class _GridBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GridPainter(),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC9A84C).withOpacity(0.03)
      ..strokeWidth = 0.5;

    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Gradient overlay
    final gradient = RadialGradient(
      center: Alignment.topCenter,
      radius: 1.5,
      colors: [
        Colors.transparent,
        const Color(0xFF0A0A0A).withOpacity(0.85),
      ],
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader =
            gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );
  }

  @override
  bool shouldRepaint(_GridPainter old) => false;
}

// WEBA2APK_DYNAMIC_ICON_START
class _DynamicIcon extends StatelessWidget {
  final dynamic icon;
  final double? size;
  final Color? color;
  final List<Shadow>? shadows;
  final String? semanticLabel;
  final dynamic textDirection;
  final double? fill;
  final double? weight;
  final double? grade;
  final double? opticalSize;
  final bool? applyTextScaling;

  const _DynamicIcon(
    this.icon, {
    Key? key,
    this.size,
    this.color,
    this.shadows,
    this.semanticLabel,
    this.textDirection,
    this.fill,
    this.weight,
    this.grade,
    this.opticalSize,
    this.applyTextScaling,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (icon == null) return const SizedBox(width: 0, height: 0);

    bool isFontAwesome = false;
    try {
      final str = icon.toString();
      final typeStr = icon.runtimeType.toString();
      if (typeStr.contains('FaIcon') ||
          str.contains('FaIcon') ||
          str.contains('font_awesome_flutter') ||
          (icon is IconData && icon.fontPackage == 'font_awesome_flutter')) {
        isFontAwesome = true;
      }
    } catch (_) {}

    if (isFontAwesome) {
      Widget child = FaIcon(
        icon is IconData ? icon : icon,
        size: size,
        color: color,
        semanticLabel: semanticLabel,
        textDirection: textDirection,
      );
      if (shadows != null && shadows!.isNotEmpty) {
        child = DecoratedBox(
          decoration: BoxDecoration(
            boxShadow: shadows!.map((s) => BoxShadow(color: s.color, blurRadius: s.blurRadius)).toList(),
          ),
          child: child,
        );
      }
      return Center(widthFactor: 1.0, heightFactor: 1.0, child: child);
    } else {
      return Center(
        widthFactor: 1.0,
        heightFactor: 1.0,
        child: Icon(
          icon is IconData ? icon : null,
          size: size,
          color: color,
          shadows: shadows,
          semanticLabel: semanticLabel,
          textDirection: textDirection,
          fill: fill,
          weight: weight,
          grade: grade,
          opticalSize: opticalSize,
          applyTextScaling: applyTextScaling,
        ),
      );
    }
  }
}
// WEBA2APK_DYNAMIC_ICON_END
