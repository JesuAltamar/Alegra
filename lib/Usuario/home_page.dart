// Archivo: home_page.dart

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'dart:math' as math;
import 'juegos/juegos.dart';
import 'package:pro9/Usuario/lista_tareas_page.dart';
import '../chat/chat_screen.dart';
import 'profile_page.dart';
import '../widgets/mood_checkin_widget.dart';
import '../widgets/resources_library_widget.dart';

class HomePage extends StatefulWidget {
  final int usuarioId;
  final String nombreUsuario;

  const HomePage({
    super.key,
    required this.usuarioId,
    required this.nombreUsuario,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  bool _showEmergencyCard = false;
  bool isDarkMode = false;
  int _wellnessSection = 0;

  late AnimationController _emergencyController;
  late AnimationController _cardController;
  late AnimationController _floatingController;
  late Animation<double> _emergencyAnimation;
  late Animation<double> _cardAnimation;
  late Animation<double> _cardOpacityAnimation;
  late Animation<double> _floatingAnimation;

  List<FloatingDecoration> floatingDecorations = [];
  final int decorationCount = 20;

  final Color deepPurple = const Color(0xFF2D1B69);
  final Color vibrantPurple = const Color(0xFF6366F1);
  final Color lightPurple = const Color(0xFFA855F7);
  final Color darkBackground = const Color(0xFF0F0A1F);
  final Color cardDark = const Color(0xFF1A1335);
  final Color accentPink = const Color(0xFFEC4899);
  final Color softWhite = const Color(0xFFF8FAFC);
  final Color cloudBlue = const Color(0xFF8B5CF6);
  final Color mentalhealthGreen = const Color(0xFF10B981);

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initFloatingDecorations();
  }

  void _initAnimations() {
    _emergencyController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _floatingController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();

    _emergencyAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _emergencyController, curve: Curves.easeInOut),
    );
    _cardAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOutBack),
    );
    _cardOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeInOut),
    );
    _floatingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_floatingController);

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _cardController.forward();
    });
  }

  void _initFloatingDecorations() {
    floatingDecorations.clear();
    for (int i = 0; i < decorationCount; i++) {
      floatingDecorations.add(FloatingDecoration());
    }
  }

  @override
  void dispose() {
    _emergencyController.dispose();
    _cardController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final isSmallMobile = screenWidth < 360;
    final isMobile = screenWidth < 800;
    final isTablet = screenWidth >= 800 && screenWidth < 1024;
    final isDesktop = screenWidth >= 1024;

    return Scaffold(
      backgroundColor: isDarkMode ? darkBackground : softWhite,
      appBar: _buildAppBar(isSmallMobile, isMobile, isTablet),
      drawer: isMobile ? _buildDrawer() : null,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [darkBackground, deepPurple.withOpacity(0.3), darkBackground]
                : [softWhite, vibrantPurple.withOpacity(0.05), softWhite],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(
              isSmallMobile ? 12.0 : (isMobile ? 16.0 : 24.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBienvenida(isSmallMobile, isMobile),
                SizedBox(height: isSmallMobile ? 16 : 20),
                AnimatedBuilder(
                  animation: _emergencyAnimation,
                  builder: (context, child) {
                    return _showEmergencyCard
                        ? Transform.scale(
                            scale: _emergencyAnimation.value.clamp(0.0, 1.0),
                            child: Opacity(
                              opacity: _emergencyAnimation.value.clamp(0.0, 1.0),
                              child: Column(
                                children: [
                                  _buildEmergencyCard(isSmallMobile, isMobile),
                                  SizedBox(height: isSmallMobile ? 16 : 20),
                                ],
                              ),
                            ),
                          )
                        : const SizedBox.shrink();
                  },
                ),
                _buildWellnessSection(isSmallMobile, isMobile),
                SizedBox(height: isSmallMobile ? 16 : 20),
                AnimatedBuilder(
                  animation: _cardController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(
                        0,
                        (1 - _cardAnimation.value.clamp(0.0, 1.0)) * 30,
                      ),
                      child: Opacity(
                        opacity: _cardOpacityAnimation.value.clamp(0.0, 1.0),
                        child: _buildGrid(
                          isSmallMobile,
                          isMobile,
                          isTablet,
                          isDesktop,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(
        context,
        isSmallMobile,
        isMobile,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildWellnessSection(bool isSmallMobile, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            'Tu Bienestar Diario',
            style: TextStyle(
              fontSize: isSmallMobile ? 20 : (isMobile ? 22 : 24),
              fontWeight: FontWeight.w800,
              color: isDarkMode ? softWhite : deepPurple,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildWellnessTabs(isSmallMobile, isMobile),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.1),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: _wellnessSection == 0
              ? _buildCheckInSection()
              : _buildLibrarySection(),
        ),
      ],
    );
  }

  Widget _buildWellnessTabs(bool isSmallMobile, bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDarkMode
            ? cardDark.withOpacity(0.5)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: vibrantPurple.withOpacity(0.3), width: 2),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildWellnessTabButton(
              icon: Icons.mood,
              label: 'Check-in',
              index: 0,
              isSmallMobile: isSmallMobile,
              isMobile: isMobile,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildWellnessTabButton(
              icon: Icons.local_library,
              label: 'Recursos',
              index: 1,
              isSmallMobile: isSmallMobile,
              isMobile: isMobile,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWellnessTabButton({
    required IconData icon,
    required String label,
    required int index,
    required bool isSmallMobile,
    required bool isMobile,
  }) {
    final isSelected = _wellnessSection == index;

    return InkWell(
      onTap: () => setState(() => _wellnessSection = index),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          vertical: isSmallMobile ? 10 : 12,
          horizontal: isSmallMobile ? 8 : 12,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(colors: [vibrantPurple, lightPurple])
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: vibrantPurple.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? softWhite
                  : isDarkMode
                      ? Colors.grey[400]
                      : deepPurple.withOpacity(0.7),
              size: 18,
            ),
            if (!isSmallMobile) ...[
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? softWhite
                        : isDarkMode
                            ? Colors.grey[400]
                            : deepPurple.withOpacity(0.7),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCheckInSection() {
    return Column(
      key: const ValueKey('checkin'),
      children: [
        MoodCheckInWidget(
          isDarkMode: isDarkMode,
          deepPurple: deepPurple,
          vibrantPurple: vibrantPurple,
          lightPurple: lightPurple,
          darkBackground: darkBackground,
          cardDark: cardDark,
          accentPink: accentPink,
          softWhite: softWhite,
          mentalhealthGreen: mentalhealthGreen,
        ),
        const SizedBox(height: 16),
        _buildMotivationalCard(),
      ],
    );
  }

  Widget _buildLibrarySection() {
    return Column(
      key: const ValueKey('library'),
      children: [
        ResourcesLibraryWidget(
          isDarkMode: isDarkMode,
          deepPurple: deepPurple,
          vibrantPurple: vibrantPurple,
          lightPurple: lightPurple,
          darkBackground: darkBackground,
          cardDark: cardDark,
          accentPink: accentPink,
          softWhite: softWhite,
          mentalhealthGreen: mentalhealthGreen,
          cloudBlue: cloudBlue,
        ),
      ],
    );
  }

  Widget _buildMotivationalCard() {
    final messages = [
      {
        'icon': Icons.self_improvement,
        'title': 'Recuerda respirar',
        'message': 'Toma un momento para conectar con tu respiración',
        'color': cloudBlue,
      },
      {
        'icon': Icons.favorite_outline,
        'title': 'Eres valioso',
        'message': 'Tu bienestar emocional es importante',
        'color': accentPink,
      },
      {
        'icon': Icons.wb_sunny_outlined,
        'title': 'Un día a la vez',
        'message': 'El progreso no siempre es lineal, y está bien',
        'color': mentalhealthGreen,
      },
      {
        'icon': Icons.spa_outlined,
        'title': 'Tómate un respiro',
        'message': 'Está bien pausar y cuidar de ti mismo',
        'color': lightPurple,
      },
    ];

    final message = messages[DateTime.now().day % messages.length];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            (message['color'] as Color).withOpacity(0.1),
            (message['color'] as Color).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (message['color'] as Color).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: (message['color'] as Color).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              message['icon'] as IconData,
              color: message['color'] as Color,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message['title'] as String,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDarkMode ? softWhite : deepPurple,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message['message'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode
                        ? Colors.grey[300]
                        : deepPurple.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    bool isSmallMobile,
    bool isMobile,
    bool isTablet,
  ) {
    return AppBar(
      elevation: 0,
      backgroundColor: (isDarkMode ? cardDark : softWhite).withOpacity(0.95),
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      leading: isMobile
          ? Builder(
              builder: (context) => Container(
                margin: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: vibrantPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: vibrantPurple.withOpacity(0.3)),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.menu_rounded,
                    color: vibrantPurple,
                    size: 20,
                  ),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  padding: EdgeInsets.zero,
                ),
              ),
            )
          : null,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isSmallMobile ? 28 : 32,
            height: isSmallMobile ? 28 : 32,
            decoration: BoxDecoration(
              color: vibrantPurple,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: vibrantPurple.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              Icons.psychology,
              color: softWhite,
              size: isSmallMobile ? 14 : 16,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            "ALEGRA",
            style: TextStyle(
              fontSize: isSmallMobile ? 16 : 18,
              fontWeight: FontWeight.w900,
              color: isDarkMode ? softWhite : deepPurple,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
      actions: [
        if (!isMobile) ...[
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: accentPink.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: accentPink.withOpacity(0.3)),
            ),
            child: IconButton(
              icon: Icon(
                Icons.person_rounded,
                color: accentPink,
                size: 18,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(
                      nombreUsuario: widget.nombreUsuario,
                      usuarioId: widget.usuarioId,
                    ),
                  ),
                );
              },
              tooltip: "Mi Perfil",
              padding: EdgeInsets.zero,
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: accentPink.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: accentPink.withOpacity(0.3)),
            ),
            child: IconButton(
              icon: Icon(
                Icons.logout_rounded,
                color: accentPink,
                size: 18,
              ),
              onPressed: () => _showLogoutDialog(context),
              tooltip: "Cerrar Sesión",
              padding: EdgeInsets.zero,
            ),
          ),
        ],
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: (isDarkMode ? accentPink : vibrantPurple).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: (isDarkMode ? accentPink : vibrantPurple).withOpacity(0.3),
            ),
          ),
          child: IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: isDarkMode ? accentPink : vibrantPurple,
              size: 18,
            ),
            onPressed: () => setState(() => isDarkMode = !isDarkMode),
            padding: EdgeInsets.zero,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isSmallMobile ? 6 : 8),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [accentPink, lightPurple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: accentPink.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _showEmergencyCard = !_showEmergencyCard;
                    if (_showEmergencyCard) {
                      _emergencyController.forward();
                    } else {
                      _emergencyController.reverse();
                    }
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: isSmallMobile ? 6 : 8,
                    horizontal: isSmallMobile ? 10 : 12,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Symbols.emergency,
                        color: softWhite,
                        size: isSmallMobile ? 18 : 20,
                      ),
                      if (!isSmallMobile) ...[
                        const SizedBox(width: 6),
                        Text(
                          "SOS",
                          style: TextStyle(
                            color: softWhite,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final isSmallMobile = MediaQuery.of(context).size.width < 360;
    final isMobile = MediaQuery.of(context).size.width < 800;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isSmallMobile ? 280 : (isMobile ? 320 : 360),
            ),
            padding: EdgeInsets.all(isSmallMobile ? 16 : 20),
            decoration: BoxDecoration(
              color: isDarkMode ? cardDark : softWhite,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: vibrantPurple.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: vibrantPurple.withOpacity(0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: isSmallMobile ? 60 : 70,
                  height: isSmallMobile ? 60 : 70,
                  decoration: BoxDecoration(
                    color: accentPink.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(35),
                    border: Border.all(
                      color: accentPink.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: accentPink,
                    size: isSmallMobile ? 28 : 32,
                  ),
                ),
                SizedBox(height: isSmallMobile ? 16 : 20),
                Text(
                  "¿Cerrar Sesión?",
                  style: TextStyle(
                    fontSize: isSmallMobile ? 20 : 24,
                    fontWeight: FontWeight.w700,
                    color: isDarkMode ? softWhite : deepPurple,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isSmallMobile ? 8 : 12),
                Text(
                  "Tendrás que iniciar sesión nuevamente.",
                  style: TextStyle(
                    fontSize: isSmallMobile ? 14 : 16,
                    color: isDarkMode
                        ? Colors.grey[300]
                        : deepPurple.withOpacity(0.8),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isSmallMobile ? 24 : 32),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: isSmallMobile ? 44 : 50,
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? cardDark.withOpacity(0.8)
                              : vibrantPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: vibrantPurple.withOpacity(0.3),
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => Navigator.of(context).pop(),
                            borderRadius: BorderRadius.circular(16),
                            child: Center(
                              child: Text(
                                "Cancelar",
                                style: TextStyle(
                                  fontSize: isSmallMobile ? 14 : 16,
                                  fontWeight: FontWeight.w600,
                                  color: vibrantPurple,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: isSmallMobile ? 12 : 16),
                    Expanded(
                      child: Container(
                        height: isSmallMobile ? 44 : 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [accentPink, lightPurple],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: accentPink.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                              _performLogout(context);
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Center(
                              child: Text(
                                "Cerrar",
                                style: TextStyle(
                                  fontSize: isSmallMobile ? 14 : 16,
                                  fontWeight: FontWeight.w700,
                                  color: softWhite,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _performLogout(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          "Sesión cerrada exitosamente",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: mentalhealthGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: isDarkMode ? cardDark : softWhite,
      width: 280,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Header con gradiente completo
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 50, 24, 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [vibrantPurple, accentPink],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: softWhite.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: softWhite.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(Icons.psychology, color: softWhite, size: 32),
                ),
                const SizedBox(height: 16),
                Text(
                  "ALEGRA",
                  style: TextStyle(
                    color: softWhite,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.nombreUsuario,
                  style: TextStyle(
                    color: softWhite.withOpacity(0.9),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                _buildDrawerItem(
                  Icons.home_rounded,
                  "Inicio",
                  () {
                    Navigator.of(context).pop();
                  },
                  mentalhealthGreen,
                ),
                _buildDrawerItem(
                  Icons.checklist_rounded,
                  "Lista de Tareas",
                  () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ListaTareasPage(),
                      ),
                    );
                  },
                  vibrantPurple,
                ),
                _buildDrawerItem(
                  Icons.chat_rounded,
                  "Chat Inteligente",
                  () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(userId: widget.usuarioId),
                      ),
                    );
                  },
                  accentPink,
                ),
                _buildDrawerItem(
                  Icons.sports_esports_rounded,
                  "Juegos",
                  () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => JuegosApp(usuarioId: widget.usuarioId),
                      ),
                    );
                  },
                  cloudBlue,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Divider(),
                ),
                _buildDrawerItem(
                  Icons.person_rounded,
                  "Mi Perfil",
                  () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ProfilePage(
                          nombreUsuario: widget.nombreUsuario,
                          usuarioId: widget.usuarioId,
                        ),
                      ),
                    );
                  },
                  accentPink,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isDarkMode
                      ? Colors.grey[800]!
                      : Colors.grey[300]!,
                  width: 1,
                ),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accentPink, lightPurple],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: accentPink.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      _showLogoutDialog(context);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.logout_rounded,
                            color: softWhite,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Cerrar Sesión',
                            style: TextStyle(
                              color: softWhite,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    IconData icon,
    String title,
    VoidCallback onTap,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDarkMode ? softWhite : deepPurple,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        dense: true,
      ),
    );
  }

  Widget _buildBienvenida(bool isSmallMobile, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallMobile ? 20 : (isMobile ? 24 : 28)),
      decoration: BoxDecoration(
        color: isDarkMode
            ? cardDark.withOpacity(0.9)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: vibrantPurple.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: vibrantPurple.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: isSmallMobile ? 50 : 60,
                height: isSmallMobile ? 50 : 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [vibrantPurple, lightPurple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: vibrantPurple.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.waving_hand_rounded,
                  color: softWhite,
                  size: isSmallMobile ? 24 : 28,
                ),
              ),
              SizedBox(width: isSmallMobile ? 16 : 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "¡Hola, ${widget.nombreUsuario}!",
                      style: TextStyle(
                        fontSize: isSmallMobile ? 20 : (isMobile ? 24 : 28),
                        fontWeight: FontWeight.w700,
                        color: isDarkMode ? softWhite : deepPurple,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Bienvenido de vuelta",
                      style: TextStyle(
                        fontSize: isSmallMobile ? 14 : 16,
                        color: isDarkMode
                            ? Colors.grey[300]
                            : deepPurple.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallMobile ? 16 : 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? cardDark.withOpacity(0.5)
                  : vibrantPurple.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: vibrantPurple.withOpacity(0.3)),
            ),
            child: Text(
              "Tu espacio de apoyo para la salud mental. Explora las herramientas que hemos diseñado para ti.",
              style: TextStyle(
                fontSize: isSmallMobile ? 14 : (isMobile ? 15 : 16),
                color: isDarkMode ? Colors.grey[300] : deepPurple.withOpacity(0.8),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(
    bool isSmallMobile,
    bool isMobile,
    bool isTablet,
    bool isDesktop,
  ) {
    final items = [
      {
        "title": "Lista de Tareas",
        "desc": "Organiza tu rutina diaria de bienestar",
        "icon": Icons.checklist_rounded,
        "color": mentalhealthGreen,
      },
      {
        "title": "Chat Inteligente",
        "desc": "Asistente virtual disponible 24/7",
        "icon": Icons.chat_rounded,
        "color": accentPink,
      },
      {
        "title": "Juegos Interactivos",
        "desc": "Actividades para aliviar el estrés",
        "icon": Icons.sports_esports_rounded,
        "color": cloudBlue,
      },
    ];

    if (isMobile) {
      return Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return AnimatedBuilder(
            animation: _cardController,
            builder: (context, child) {
              final delayedOpacity = (_cardOpacityAnimation.value - (index * 0.1));
              final safeOpacity = delayedOpacity.clamp(0.0, 1.0);

              return Transform.translate(
                offset: Offset(
                  0,
                  (1 - _cardAnimation.value.clamp(0.0, 1.0)) * 50,
                ),
                child: Opacity(
                  opacity: safeOpacity,
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: isSmallMobile ? 12 : 16,
                    ),
                    child: _buildCard(item, isSmallMobile, isMobile),
                  ),
                ),
              );
            },
          );
        }).toList(),
      );
    } else {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isTablet ? 2 : 3,
          childAspectRatio: isDesktop ? 2.5 : 2.2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return AnimatedBuilder(
            animation: _cardController,
            builder: (context, child) {
              final delayedOpacity = (_cardOpacityAnimation.value - (index * 0.1));
              final safeOpacity = delayedOpacity.clamp(0.0, 1.0);

              return Transform.translate(
                offset: Offset(
                  0,
                  (1 - _cardAnimation.value.clamp(0.0, 1.0)) * 50,
                ),
                child: Opacity(
                  opacity: safeOpacity,
                  child: _buildCard(item, isSmallMobile, isMobile),
                ),
              );
            },
          );
        },
      );
    }
  }

  Widget _buildCard(
    Map<String, dynamic> item,
    bool isSmallMobile,
    bool isMobile,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode
            ? cardDark.withOpacity(0.8)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (item["color"] as Color).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (item["color"] as Color).withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (item["title"] == "Lista de Tareas") {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ListaTareasPage(),
                ),
              );
            } else if (item["title"] == "Chat Inteligente") {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ChatScreen(userId: widget.usuarioId),
                ),
              );
            } else if (item["title"] == "Juegos Interactivos") {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => JuegosApp(usuarioId: widget.usuarioId),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: EdgeInsets.all(isSmallMobile ? 20 : (isMobile ? 24 : 28)),
            child: Row(
              children: [
                Container(
                  width: isSmallMobile ? 50 : (isMobile ? 60 : 70),
                  height: isSmallMobile ? 50 : (isMobile ? 60 : 70),
                  decoration: BoxDecoration(
                    color: (item["color"] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: (item["color"] as Color).withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    item["icon"] as IconData,
                    color: item["color"] as Color,
                    size: isSmallMobile ? 24 : (isMobile ? 28 : 32),
                  ),
                ),
                SizedBox(width: isSmallMobile ? 16 : 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item["title"] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: isSmallMobile ? 16 : (isMobile ? 18 : 20),
                          color: isDarkMode ? softWhite : deepPurple,
                        ),
                      ),
                      SizedBox(height: isSmallMobile ? 6 : 8),
                      Text(
                        item["desc"] as String,
                        style: TextStyle(
                          fontSize: isSmallMobile ? 13 : (isMobile ? 14 : 15),
                          color: isDarkMode
                              ? Colors.grey[300]
                              : deepPurple.withOpacity(0.8),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: isSmallMobile ? 36 : 40,
                  height: isSmallMobile ? 36 : 40,
                  decoration: BoxDecoration(
                    color: (item["color"] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: (item["color"] as Color).withOpacity(0.3),
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: item["color"] as Color,
                    size: isSmallMobile ? 18 : 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyCard(bool isSmallMobile, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallMobile ? 20 : (isMobile ? 24 : 28)),
      decoration: BoxDecoration(
        color: isDarkMode
            ? cardDark.withOpacity(0.9)
            : accentPink.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentPink.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: accentPink.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: isSmallMobile ? 50 : 60,
                height: isSmallMobile ? 50 : 60,
                decoration: BoxDecoration(
                  color: accentPink.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: accentPink.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Symbols.emergency,
                  color: accentPink,
                  size: isSmallMobile ? 24 : 28,
                ),
              ),
              SizedBox(width: isSmallMobile ? 16 : 20),
              Expanded(
                child: Text(
                  "Ayuda Inmediata",
                  style: TextStyle(
                    fontSize: isSmallMobile ? 18 : (isMobile ? 20 : 22),
                    fontWeight: FontWeight.w700,
                    color: accentPink,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallMobile ? 16 : 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? cardDark.withOpacity(0.8)
                  : Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accentPink.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Líneas de Apoyo en Colombia",
                  style: TextStyle(
                    fontSize: isSmallMobile ? 16 : 18,
                    fontWeight: FontWeight.w700,
                    color: isDarkMode ? softWhite : deepPurple,
                  ),
                ),
                SizedBox(height: isSmallMobile ? 12 : 16),
                _buildEmergencyContact(
                  "Línea Nacional",
                  "192, opción 4",
                  "Ministerio de Salud",
                  isSmallMobile,
                ),
                _buildEmergencyContact(
                  "Línea 106 Bogotá",
                  "106",
                  "Servicio de atención psicosocial",
                  isSmallMobile,
                ),
                _buildEmergencyContact(
                  "Línea de la Vida",
                  "123",
                  "Medellín y Antioquia",
                  isSmallMobile,
                ),
              ],
            ),
          ),
          SizedBox(height: isSmallMobile ? 12 : 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: mentalhealthGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: mentalhealthGreen.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.favorite_rounded,
                  color: mentalhealthGreen,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Estas líneas están disponibles 24/7. No dudes en buscar ayuda.",
                    style: TextStyle(
                      fontSize: isSmallMobile ? 13 : 14,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode
                          ? Colors.grey[300]
                          : deepPurple.withOpacity(0.8),
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

  Widget _buildEmergencyContact(
    String title,
    String number,
    String description,
    bool isSmallMobile,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: isSmallMobile ? 12 : 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode
            ? cardDark.withOpacity(0.5)
            : accentPink.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentPink.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: isSmallMobile ? 36 : 40,
            height: isSmallMobile ? 36 : 40,
            decoration: BoxDecoration(
              color: accentPink.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: accentPink.withOpacity(0.3)),
            ),
            child: Icon(
              Symbols.phone_in_talk_rounded,
              color: accentPink,
              size: isSmallMobile ? 18 : 20,
            ),
          ),
          SizedBox(width: isSmallMobile ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$title: $number",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: isSmallMobile ? 14 : 16,
                    color: accentPink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: isSmallMobile ? 12 : 13,
                    color: isDarkMode
                        ? Colors.grey[300]
                        : deepPurple.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(
    BuildContext context,
    bool isSmallMobile,
    bool isMobile,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [cloudBlue, mentalhealthGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: cloudBlue.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ChatScreen(userId: widget.usuarioId),
            ),
          );
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Icon(
          Symbols.robot_2_rounded,
          color: softWhite,
          size: isSmallMobile ? 28 : (isMobile ? 32 : 36),
        ),
      ),
    );
  }
}

class FloatingDecoration {
  late double x;
  late double y;
  late double speed;
  late double size;
  late double opacity;
  late Color color;

  FloatingDecoration() {
    reset();
  }

  void reset() {
    final random = math.Random();
    x = random.nextDouble();
    y = 1.0 + random.nextDouble() * 0.1;
    speed = 0.001 + random.nextDouble() * 0.002;
    size = 8 + random.nextDouble() * 12;
    opacity = 0.3 + random.nextDouble() * 0.4;

    final colors = [
      const Color(0xFF6366F1),
      const Color(0xFFA855F7),
      const Color(0xFFEC4899),
      const Color(0xFF8B5CF6),
      const Color(0xFF10B981),
    ];
    color = colors[random.nextInt(colors.length)];
  }

  void update() {
    y -= speed;
    if (y < -0.1) {
      reset();
    }
  }
}