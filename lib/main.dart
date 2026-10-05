import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'login_page.dart';
import 'dashboard_page.dart';
import 'home_page.dart';
import 'seller_page.dart';
import 'admin_page.dart';
import 'owner_page.dart';
import 'landing.dart';
import 'api_config.dart';
import 'notification_service.dart';

// ─────────────────────────────────────────────
//  COLOR SYSTEM — LAVA GRAY THEME
// ─────────────────────────────────────────────
class _C {
  static const bg        = Color(0xFF0E0F10);
  static const surface   = Color(0xFF141618);
  static const card      = Color(0xFF1C1E21);
  static const border    = Color(0xFF2C2F33);
  static const borderLit = Color(0xFF43474D);

  static const steel     = Color(0xFF4A4E53);
  static const blueMid   = Color(0xFF5C6166);
  static const blueLight = Color(0xFF838A91);
  static const chrome    = Color(0xFF9CA3AA);
  static const frost     = Color(0xFFB4BBC2);

  static const green     = Color(0xFF22C55E);
  static const amber     = Color(0xFFF59E0B);
  static const red       = Color(0xFFEF4444);

  static const text      = Color(0xFFEAECEE);
  static const textSub   = Color(0xFF9AA0A6);
  static const textDim   = Color(0xFF565A5F);

  static const LinearGradient metalGrad = LinearGradient(
    colors: [Color(0xFF383C40), Color(0xFF5C6166), Color(0xFF838A91)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient surfaceGrad = LinearGradient(
    colors: [Color(0xFF141618), Color(0xFF1C1E21)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bgGrad = LinearGradient(
    colors: [Color(0xFF0E0F10), Color(0xFF141618)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

// ─────────────────────────────────────────────
//  THEME BUILDER
// ─────────────────────────────────────────────
class _AppTheme {
  static const String _font = 'ShareTechMono';

  static ThemeData build() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: _font,
    scaffoldBackgroundColor: _C.bg,

    colorScheme: const ColorScheme.dark(
      brightness:             Brightness.dark,
      primary:                _C.blueLight,
      onPrimary:              _C.bg,
      primaryContainer:       _C.steel,
      onPrimaryContainer:     _C.frost,
      secondary:              _C.chrome,
      onSecondary:            _C.bg,
      secondaryContainer:     _C.borderLit,
      onSecondaryContainer:   _C.text,
      tertiary:               _C.green,
      onTertiary:             _C.bg,
      error:                  _C.red,
      onError:                _C.text,
      surface:                _C.surface,
      onSurface:              _C.text,
      surfaceContainerHighest: _C.card,
      outline:                _C.border,
      outlineVariant:         _C.borderLit,
      shadow:                 Colors.black,
      scrim:                  Colors.black87,
      inverseSurface:         _C.frost,
      onInverseSurface:       _C.bg,
      inversePrimary:         _C.steel,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor:      _C.surface,
      foregroundColor:      _C.text,
      elevation:            0,
      scrolledUnderElevation: 0,
      centerTitle:          false,
      titleTextStyle: TextStyle(
        fontFamily:   _font,
        fontSize:     18,
        fontWeight:   FontWeight.w600,
        color:        _C.text,
        letterSpacing: 0.4,
        fontFamilyFallback: ['monospace'],
      ),
      iconTheme:        IconThemeData(color: _C.chrome,    size: 22),
      actionsIconTheme: IconThemeData(color: _C.textSub,   size: 20),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor:                    Colors.transparent,
        statusBarIconBrightness:           Brightness.light,
        statusBarBrightness:               Brightness.dark,
        systemNavigationBarColor:          _C.bg,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    ),

    cardTheme: CardThemeData(
      color:        _C.card,
      elevation:    0,
      margin:       EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: _C.border, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((s) {
          if (s.contains(WidgetState.disabled)) return _C.border;
          if (s.contains(WidgetState.pressed))  return _C.steel;
          return _C.blueLight;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((s) {
          if (s.contains(WidgetState.disabled)) return _C.textDim;
          return _C.bg;
        }),
        overlayColor:  WidgetStateProperty.all(_C.frost.withValues(alpha: 0.1)),
        elevation:     WidgetStateProperty.all(0),
        shadowColor:   WidgetStateProperty.all(Colors.transparent),
        padding:       WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        textStyle: WidgetStateProperty.all(
          const TextStyle(
            fontFamily: _font,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
            fontFamilyFallback: ['monospace'],
          ),
        ),
        animationDuration: const Duration(milliseconds: 180),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith((s) {
          if (s.contains(WidgetState.pressed)) return _C.frost;
          return _C.chrome;
        }),
        side: WidgetStateProperty.resolveWith((s) {
          if (s.contains(WidgetState.pressed)) return const BorderSide(color: _C.chrome,    width: 1.5);
          if (s.contains(WidgetState.focused)) return const BorderSide(color: _C.blueLight, width: 1.5);
          return const BorderSide(color: _C.borderLit, width: 1);
        }),
        backgroundColor: WidgetStateProperty.resolveWith((s) {
          if (s.contains(WidgetState.pressed)) return _C.blueLight.withValues(alpha: 0.08);
          return Colors.transparent;
        }),
        overlayColor: WidgetStateProperty.all(_C.blueLight.withValues(alpha: 0.06)),
        padding:      WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        textStyle: WidgetStateProperty.all(
          const TextStyle(
            fontFamily: _font,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.6,
            fontFamilyFallback: ['monospace'],
          ),
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith((s) {
          if (s.contains(WidgetState.pressed)) return _C.frost;
          return _C.chrome;
        }),
        overlayColor: WidgetStateProperty.all(_C.blueLight.withValues(alpha: 0.08)),
        padding:      WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        textStyle: WidgetStateProperty.all(
          const TextStyle(
            fontFamily: _font,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.4,
            fontFamilyFallback: ['monospace'],
          ),
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled:      true,
      fillColor:   _C.surface,
      hoverColor:  _C.card,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:   const BorderSide(color: _C.border, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:   const BorderSide(color: _C.border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:   const BorderSide(color: _C.blueLight, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:   const BorderSide(color: _C.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:   const BorderSide(color: _C.red, width: 1.5),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:   const BorderSide(color: _C.textDim, width: 1),
      ),
      labelStyle:          const TextStyle(color: _C.textSub,  fontSize: 13, fontFamilyFallback: ['monospace']),
      hintStyle:           const TextStyle(color: _C.textDim,  fontSize: 13, fontFamilyFallback: ['monospace']),
      errorStyle:          const TextStyle(color: _C.red,      fontSize: 11, fontFamilyFallback: ['monospace']),
      prefixIconColor:     _C.textSub,
      suffixIconColor:     _C.textSub,
      floatingLabelStyle:  const TextStyle(color: _C.blueLight, fontSize: 12, fontFamilyFallback: ['monospace']),
    ),

    chipTheme: ChipThemeData(
      backgroundColor:     _C.surface,
      selectedColor:       _C.steel,
      disabledColor:       _C.border,
      deleteIconColor:     _C.textSub,
      labelStyle:          const TextStyle(color: _C.text,  fontSize: 12, fontFamily: _font, fontFamilyFallback: ['monospace']),
      secondaryLabelStyle: const TextStyle(color: _C.frost, fontSize: 12, fontFamily: _font, fontFamilyFallback: ['monospace']),
      padding:             const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side:         const BorderSide(color: _C.border),
      ),
      side:            const BorderSide(color: _C.border),
      elevation:       0,
      pressElevation:  0,
      showCheckmark:   false,
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor:      _C.surface,
      selectedItemColor:    _C.blueLight,
      unselectedItemColor:  _C.textDim,
      elevation:            0,
      type:                 BottomNavigationBarType.fixed,
      selectedLabelStyle:   TextStyle(fontSize: 10, fontFamily: _font, fontWeight: FontWeight.w600, fontFamilyFallback: ['monospace']),
      unselectedLabelStyle: TextStyle(fontSize: 10, fontFamily: _font, fontFamilyFallback: ['monospace']),
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor:  _C.surface,
      indicatorColor:   _C.steel.withValues(alpha: 0.45),
      iconTheme: WidgetStateProperty.resolveWith((s) {
        if (s.contains(WidgetState.selected)) return const IconThemeData(color: _C.blueLight, size: 22);
        return const IconThemeData(color: _C.textDim, size: 22);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((s) {
        if (s.contains(WidgetState.selected)) {
          return const TextStyle(color: _C.blueLight, fontSize: 11, fontFamily: _font, fontWeight: FontWeight.w600, fontFamilyFallback: ['monospace']);
        }
        return const TextStyle(color: _C.textDim, fontSize: 11, fontFamily: _font, fontFamilyFallback: ['monospace']);
      }),
      elevation:     0,
      overlayColor:  WidgetStateProperty.all(_C.blueLight.withValues(alpha: 0.06)),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    ),

    navigationRailTheme: NavigationRailThemeData(
      backgroundColor:            _C.surface,
      selectedIconTheme:          const IconThemeData(color: _C.blueLight, size: 22),
      unselectedIconTheme:        const IconThemeData(color: _C.textDim,   size: 22),
      selectedLabelTextStyle:     const TextStyle(color: _C.blueLight, fontSize: 11, fontFamily: _font, fontWeight: FontWeight.w600, fontFamilyFallback: ['monospace']),
      unselectedLabelTextStyle:   const TextStyle(color: _C.textDim,   fontSize: 11, fontFamily: _font, fontFamilyFallback: ['monospace']),
      indicatorColor:             _C.steel.withValues(alpha: 0.4),
      elevation:                  0,
      useIndicator:               true,
    ),

    drawerTheme: DrawerThemeData(
      backgroundColor:   _C.surface,
      elevation:         0,
      surfaceTintColor:  Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight:    Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: _C.card,
      elevation:       0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side:         const BorderSide(color: _C.borderLit, width: 1),
      ),
      titleTextStyle: const TextStyle(
        fontFamily:    _font,
        fontSize:      18,
        fontWeight:    FontWeight.w700,
        color:         _C.text,
        letterSpacing: 0.2,
        fontFamilyFallback: ['monospace'],
      ),
      contentTextStyle: const TextStyle(
        fontFamily: _font,
        fontSize:   14,
        color:      _C.textSub,
        height:     1.6,
        fontFamilyFallback: ['monospace'],
      ),
    ),

    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor:      _C.surface,
      modalBackgroundColor: _C.surface,
      elevation:            0,
      modalElevation:       0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      showDragHandle:  true,
      dragHandleColor: _C.borderLit,
      dragHandleSize:  Size(40, 4),
      clipBehavior:    Clip.antiAlias,
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor:  _C.card,
      contentTextStyle: const TextStyle(color: _C.text, fontFamily: _font, fontSize: 13, fontFamilyFallback: ['monospace']),
      actionTextColor:  _C.blueLight,
      behavior:         SnackBarBehavior.floating,
      elevation:        0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side:         const BorderSide(color: _C.borderLit, width: 1),
      ),
    ),

    tabBarTheme: TabBarThemeData(
      labelColor:           _C.blueLight,
      unselectedLabelColor: _C.textDim,
      indicatorColor:       _C.blueLight,
      indicatorSize:        TabBarIndicatorSize.label,
      labelStyle:           const TextStyle(fontFamily: _font, fontSize: 13, fontWeight: FontWeight.w600, fontFamilyFallback: ['monospace']),
      unselectedLabelStyle: const TextStyle(fontFamily: _font, fontSize: 13, fontFamilyFallback: ['monospace']),
      overlayColor:         WidgetStateProperty.all(_C.blueLight.withValues(alpha: 0.06)),
      dividerColor:         _C.border,
    ),

    listTileTheme: const ListTileThemeData(
      tileColor:         Colors.transparent,
      selectedTileColor: Color(0x1A838A91),
      iconColor:         _C.textSub,
      selectedColor:     _C.blueLight,
      textColor:         _C.text,
      subtitleTextStyle: TextStyle(color: _C.textSub, fontSize: 12, fontFamilyFallback: ['monospace']),
      contentPadding:    EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
    ),

    dividerTheme: const DividerThemeData(
      color:     _C.border,
      thickness: 1,
      space:     1,
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) {
        if (s.contains(WidgetState.selected)) return _C.blueLight;
        return _C.textDim;
      }),
      trackColor: WidgetStateProperty.resolveWith((s) {
        if (s.contains(WidgetState.selected)) return _C.steel.withValues(alpha: 0.5);
        return _C.border;
      }),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      overlayColor:      WidgetStateProperty.all(_C.blueLight.withValues(alpha: 0.08)),
    ),

    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((s) {
        if (s.contains(WidgetState.selected)) return _C.blueLight;
        return Colors.transparent;
      }),
      checkColor:   WidgetStateProperty.all(_C.bg),
      side:         const BorderSide(color: _C.borderLit, width: 1.5),
      shape:        RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      overlayColor: WidgetStateProperty.all(_C.blueLight.withValues(alpha: 0.08)),
    ),

    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((s) {
        if (s.contains(WidgetState.selected)) return _C.blueLight;
        return _C.textDim;
      }),
      overlayColor: WidgetStateProperty.all(_C.blueLight.withValues(alpha: 0.08)),
    ),

    sliderTheme: SliderThemeData(
      activeTrackColor:    _C.blueLight,
      inactiveTrackColor:  _C.border,
      thumbColor:          _C.blueLight,
      overlayColor:        _C.blueLight.withValues(alpha: 0.12),
      valueIndicatorColor: _C.steel,
      valueIndicatorTextStyle: const TextStyle(color: _C.text, fontSize: 12, fontFamily: _font, fontFamilyFallback: ['monospace']),
      trackHeight:         3,
      thumbShape:          const RoundSliderThumbShape(enabledThumbRadius: 7),
    ),

    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color:              _C.blueLight,
      linearTrackColor:   _C.border,
      circularTrackColor: _C.border,
      linearMinHeight:    3,
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor:    _C.blueLight,
      foregroundColor:    _C.bg,
      elevation:          0,
      focusElevation:     0,
      hoverElevation:     0,
      highlightElevation: 0,
      splashColor:        _C.frost.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    iconTheme:        const IconThemeData(color: _C.chrome,    size: 22),
    primaryIconTheme: const IconThemeData(color: _C.blueLight, size: 22),

    popupMenuTheme: PopupMenuThemeData(
      color:            _C.card,
      elevation:        0,
      shadowColor:      Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side:         const BorderSide(color: _C.borderLit, width: 1),
      ),
      textStyle: const TextStyle(color: _C.text, fontFamily: _font, fontSize: 13, fontFamilyFallback: ['monospace']),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(color: _C.text, fontFamily: _font, fontSize: 13, fontFamilyFallback: ['monospace']),
      ),
      iconColor: _C.textSub,
    ),

    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color:        _C.surface,
        borderRadius: BorderRadius.circular(8),
        border:       Border.all(color: _C.borderLit),
      ),
      textStyle: const TextStyle(color: _C.text, fontSize: 11, fontFamily: _font, fontFamilyFallback: ['monospace']),
      padding:   const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    ),

    scrollbarTheme: ScrollbarThemeData(
      thumbColor:      WidgetStateProperty.all(_C.borderLit),
      trackColor:      WidgetStateProperty.all(_C.surface),
      radius:          const Radius.circular(4),
      thickness:       WidgetStateProperty.all(3),
      crossAxisMargin: 2,
    ),

    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: _SteelTransitionBuilder(),
        TargetPlatform.iOS:     _SteelTransitionBuilder(),
        TargetPlatform.windows: _SteelTransitionBuilder(),
        TargetPlatform.macOS:   _SteelTransitionBuilder(),
        TargetPlatform.linux:   _SteelTransitionBuilder(),
      },
    ),

    textTheme: const TextTheme(
      displayLarge:   TextStyle(fontFamily: _font, fontSize: 57, fontWeight: FontWeight.w800, color: _C.text, letterSpacing: -1.5, fontFamilyFallback: ['monospace']),
      displayMedium:  TextStyle(fontFamily: _font, fontSize: 45, fontWeight: FontWeight.w700, color: _C.text, letterSpacing: -1.0, fontFamilyFallback: ['monospace']),
      displaySmall:   TextStyle(fontFamily: _font, fontSize: 36, fontWeight: FontWeight.w700, color: _C.text, letterSpacing: -0.5, fontFamilyFallback: ['monospace']),
      headlineLarge:  TextStyle(fontFamily: _font, fontSize: 32, fontWeight: FontWeight.w700, color: _C.text, letterSpacing: -0.3, fontFamilyFallback: ['monospace']),
      headlineMedium: TextStyle(fontFamily: _font, fontSize: 26, fontWeight: FontWeight.w600, color: _C.text, letterSpacing: -0.2, fontFamilyFallback: ['monospace']),
      headlineSmall:  TextStyle(fontFamily: _font, fontSize: 22, fontWeight: FontWeight.w600, color: _C.text, fontFamilyFallback: ['monospace']),
      titleLarge:     TextStyle(fontFamily: _font, fontSize: 18, fontWeight: FontWeight.w600, color: _C.text, letterSpacing: 0.2, fontFamilyFallback: ['monospace']),
      titleMedium:    TextStyle(fontFamily: _font, fontSize: 15, fontWeight: FontWeight.w500, color: _C.text, letterSpacing: 0.1, fontFamilyFallback: ['monospace']),
      titleSmall:     TextStyle(fontFamily: _font, fontSize: 13, fontWeight: FontWeight.w500, color: _C.textSub, fontFamilyFallback: ['monospace']),
      bodyLarge:      TextStyle(fontFamily: _font, fontSize: 16, fontWeight: FontWeight.w400, color: _C.text,    height: 1.6, fontFamilyFallback: ['monospace']),
      bodyMedium:     TextStyle(fontFamily: _font, fontSize: 14, fontWeight: FontWeight.w400, color: _C.text,    height: 1.6, fontFamilyFallback: ['monospace']),
      bodySmall:      TextStyle(fontFamily: _font, fontSize: 12, fontWeight: FontWeight.w400, color: _C.textSub, height: 1.5, fontFamilyFallback: ['monospace']),
      labelLarge:     TextStyle(fontFamily: _font, fontSize: 14, fontWeight: FontWeight.w600, color: _C.text,    letterSpacing: 0.5, fontFamilyFallback: ['monospace']),
      labelMedium:    TextStyle(fontFamily: _font, fontSize: 12, fontWeight: FontWeight.w500, color: _C.textSub, letterSpacing: 0.4, fontFamilyFallback: ['monospace']),
      labelSmall:     TextStyle(fontFamily: _font, fontSize: 10, fontWeight: FontWeight.w500, color: _C.textDim, letterSpacing: 0.6, fontFamilyFallback: ['monospace']),
    ),
  );
}

// ─────────────────────────────────────────────
//  CUSTOM PAGE TRANSITION — Steel Fade + Slide
// ─────────────────────────────────────────────
class _SteelTransitionBuilder extends PageTransitionsBuilder {
  const _SteelTransitionBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final inCurve  = CurvedAnimation(parent: animation,         curve: Curves.easeOutCubic);
    final outCurve = CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeInCubic);

    return FadeTransition(
      opacity: inCurve,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.035),
          end:   Offset.zero,
        ).animate(inCurve),
        child: FadeTransition(
          opacity: Tween<double>(begin: 1.0, end: 0.82).animate(outCurve),
          child: ScaleTransition(
            scale: Tween<double>(begin: 1.0, end: 0.97).animate(outCurve),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  ROUTE BUILDER
// ─────────────────────────────────────────────
Route<dynamic>? _generateRoute(RouteSettings settings) {
  final args = settings.arguments as Map<String, dynamic>?;

  Widget page;

  switch (settings.name) {
    case '/':
    case '/login':
      page = const LoginPage();

    case '/dashboard':
      page = DashboardPage(
        username:    args?['username']    as String? ?? '',
        password:    args?['password']    as String? ?? '',
        role:        args?['role']        as String? ?? '',
        sessionKey:  (args?['sessionKey'] ?? args?['key']) as String? ?? '',
        expiredDate: args?['expiredDate'] as String? ?? '',
        listBug:  List<Map<String, dynamic>>.from(args?['listBug']  ?? []),
        listDoos: List<Map<String, dynamic>>.from(args?['listDoos'] ?? []),
        news:     List<Map<String, dynamic>>.from(args?['news']     ?? []),
      );

    case '/home':
      page = HomePage(
        username:    args?['username']    as String? ?? '',
        password:    args?['password']    as String? ?? '',
        role:        args?['role']        as String? ?? '',
        expiredDate: args?['expiredDate'] as String? ?? '',
        sessionKey:  args?['sessionKey']  as String? ?? '',
        listBug: List<Map<String, dynamic>>.from(args?['listBug'] ?? []),
      );

    case '/seller':
      page = SellerPage(keyToken: args?['keyToken'] as String? ?? '');

    case '/admin':
      page = AdminPage(sessionKey: args?['sessionKey'] as String? ?? '');

    case '/owner':
      page = OwnerPage(
        sessionKey: args?['sessionKey'] as String? ?? '',
        username:   args?['username']    as String? ?? '',
      );

    default:
      page = _NotFoundPage(routeName: settings.name ?? 'unknown');
  }

  return PageRouteBuilder<dynamic>(
    settings: settings,
    transitionDuration:        const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, animation, secondaryAnimation, child) {
      final inCurve  = CurvedAnimation(parent: animation,         curve: Curves.easeOutCubic);
      final outCurve = CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeInCubic);

      return FadeTransition(
        opacity: inCurve,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.035),
            end:   Offset.zero,
          ).animate(inCurve),
          child: FadeTransition(
            opacity: Tween<double>(begin: 1.0, end: 0.82).animate(outCurve),
            child: ScaleTransition(
              scale: Tween<double>(begin: 1.0, end: 0.97).animate(outCurve),
              child: child,
            ),
          ),
        ),
      );
    },
  );
}

// ─────────────────────────────────────────────
//  404 PAGE
// ─────────────────────────────────────────────
class _NotFoundPage extends StatefulWidget {
  const _NotFoundPage({required this.routeName});
  final String routeName;

  @override
  State<_NotFoundPage> createState() => _NotFoundPageState();
}

class _NotFoundPageState extends State<_NotFoundPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _fade;
  late final Animation<Offset>   _slide;
  late final Animation<double>   _glow;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
      ..forward();

    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _glow  = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.5, 1, curve: Curves.easeOut)));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _glow,
                    builder: (_, child) => Container(
                      width: 88, height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _C.surface,
                        border: Border.all(color: _C.borderLit, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color:        _C.blueLight.withValues(alpha: 0.18 * _glow.value),
                            blurRadius:   40,
                            spreadRadius: 6,
                          ),
                        ],
                      ),
                      child: child,
                    ),
                    child: const Icon(Icons.explore_off_rounded, color: _C.textSub, size: 34),
                  ),

                  const SizedBox(height: 28),

                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [_C.textDim, _C.borderLit],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: const Text(
                      '404',
                      style: TextStyle(
                        fontFamily:    'ShareTechMono',
                        fontSize:      72,
                        fontWeight:    FontWeight.w800,
                        color:         Colors.white,
                        height:        1,
                        letterSpacing: -3,
                        fontFamilyFallback: ['monospace'],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Route not found',
                    style: TextStyle(
                      fontFamily: 'ShareTechMono',
                      fontSize:   16,
                      fontWeight: FontWeight.w600,
                      color:      _C.textSub,
                      letterSpacing: 0.3,
                      fontFamilyFallback: ['monospace'],
                    ),
                  ),

                  const SizedBox(height: 6),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color:        _C.surface,
                      borderRadius: BorderRadius.circular(6),
                      border:       Border.all(color: _C.border),
                    ),
                    child: Text(
                      '"${widget.routeName}"',
                      style: const TextStyle(
                        fontFamily: 'ShareTechMono',
                        fontSize:   12,
                        color:      _C.textDim,
                        letterSpacing: 0.2,
                        fontFamilyFallback: ['monospace'],
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  OutlinedButton.icon(
                    onPressed: () =>
                        Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false),
                    icon:  const Icon(Icons.arrow_back_rounded, size: 16),
                    label: const Text('Back to Home'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  ENTRY POINT
// ─────────────────────────────────────────────
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ═══ Init local notification (tanpa Firebase) ═══
  await NotificationService.init();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor:                    Colors.transparent,
    statusBarIconBrightness:           Brightness.light,
    statusBarBrightness:               Brightness.dark,
    systemNavigationBarColor:          _C.bg,
    systemNavigationBarDividerColor:   Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const _NtedApp());
}

// ─────────────────────────────────────────────
//  ROOT APP WIDGET
// ─────────────────────────────────────────────
class _NtedApp extends StatelessWidget {
  const _NtedApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title:           'Null Tr4sher',
      theme:           _AppTheme.build(),
      initialRoute:    '/',
      onGenerateRoute: _generateRoute,

      builder: (context, child) {
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(
            textScaler: TextScaler.linear(
              mq.textScaleFactor.clamp(0.85, 1.2),
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}