import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class ConocenosPage extends StatefulWidget {
  final bool isDarkMode;
  const ConocenosPage({super.key, this.isDarkMode = false});

  @override
  State<ConocenosPage> createState() => _ConocenosPageState();
}

class _ConocenosPageState extends State<ConocenosPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool isDarkMode = false;

  // Paleta de colores Alegra (de PagInicio)
  final Color deepPurple = const Color(0xFF2D1B69);
  final Color vibrantPurple = const Color(0xFF6366F1);
  final Color lightPurple = const Color(0xFFA855F7);
  final Color darkBackground = const Color(0xFF0F0A1F);
  final Color cardDark = const Color(0xFF1A1335);
  final Color accentPink = const Color(0xFFEC4899);
  final Color softWhite = const Color(0xFFF8FAFC);
  final Color cloudBlue = const Color(0xFF8B5CF6);
  final Color mentalhealthGreen = const Color(0xFF10B981);

  // Datos del equipo
  final List<TeamMember> teamMembers = [
    TeamMember(
      name: "Angie Tatiana Pinto Cotes",
      role: "Documentación y apoyo Fronted",
      initials: "AP",
      color: Color(0xFF6366F1), // vibrantPurple
    ),
    TeamMember(
      name: "Stefany Jisell Escobar Araujo",
      role: "Desarrollo Frontend",
      initials: "SE",
      color: Color(0xFF10B981), // mentalhealthGreen
    ),
    TeamMember(
      name: "Jesús Daniel Altamar Pacheco",
      role: "Desarrollo Backend",
      initials: "JA",
      color: Color(0xFF8B5CF6), // cloudBlue
    ),
    TeamMember(
      name: "Camilo Andres Fragozo Silva",
      role: "Prototipo y Diagramas",
      initials: "CF",
      color: Color(0xFFEC4899), // accentPink
    ),
  ];

  @override
  void initState() {
    super.initState();
    isDarkMode = widget.isDarkMode;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    final isTablet = screenSize.width >= 600 && screenSize.width < 1024;
    final horizontalPadding = isMobile ? 20.0 : (isTablet ? 40.0 : 80.0);

    return Scaffold(
      backgroundColor: isDarkMode ? darkBackground : softWhite,
      appBar: _buildAppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                isDarkMode
                    ? [
                      darkBackground,
                      deepPurple.withOpacity(0.3),
                      darkBackground,
                    ]
                    : [softWhite, vibrantPurple.withOpacity(0.05), softWhite],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    child: Center(
                      child: Container(
                        constraints: BoxConstraints(maxWidth: 1200),
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                          vertical: 40,
                        ),
                        child: _buildLeadershipSection(isMobile, isTablet),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: (isDarkMode ? cardDark : softWhite).withOpacity(0.95),
      elevation: 0,
      leading: Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: vibrantPurple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: vibrantPurple.withOpacity(0.3)),
        ),
        child: IconButton(
          icon: Icon(Icons.arrow_back, color: vibrantPurple, size: 20),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: vibrantPurple,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: vibrantPurple.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(Icons.psychology_rounded, color: softWhite, size: 16),
          ),
          const SizedBox(width: 12),
          Text(
            'Conócenos',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDarkMode ? softWhite : deepPurple,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
      centerTitle: false,
      actions: [
        Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: vibrantPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: vibrantPurple.withOpacity(0.3)),
          ),
          child: IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: isDarkMode ? accentPink : vibrantPurple,
              size: 20,
            ),
            onPressed: () {
              setState(() {
                isDarkMode = !isDarkMode;
              });
            },
          ),
        ),
        SizedBox(width: 16),
      ],
    );
  }

  Widget _buildLeadershipSection(bool isMobile, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 32 : 48),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              isDarkMode
                  ? [cardDark.withOpacity(0.95), deepPurple.withOpacity(0.7)]
                  : [Color(0xFFE5E7EB), Color(0xFFDDD6FE).withOpacity(0.6)],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: vibrantPurple.withOpacity(0.2), width: 2),
        boxShadow: [
          BoxShadow(
            color: vibrantPurple.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextSection(true),
        const SizedBox(height: 40),
        Text(
          'Nuestro equipo',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: isDarkMode ? softWhite : deepPurple,
          ),
        ),
        const SizedBox(height: 20),
        _buildTeamGrid(true),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: _buildTextSection(false)),
        const SizedBox(width: 60),
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nuestro equipo',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: isDarkMode ? softWhite : deepPurple,
                ),
              ),
              const SizedBox(height: 24),
              _buildTeamGrid(false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextSection(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quienes Somos',
          style: TextStyle(
            fontSize: isMobile ? 28 : 36,
            fontWeight: FontWeight.w900,
            color: isDarkMode ? softWhite : deepPurple,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: isMobile ? 16 : 20),
        Container(
          constraints: BoxConstraints(
            maxWidth: isMobile ? double.infinity : 320,
          ),
          child: Text(
            'Somos un equipo joven y comprometido con el bienestar emocional, convencidos de que la innovación tecnológica puede ser una herramienta poderosa para generar un impacto positivo en la sociedad. Con Alegra, buscamos aportar una solución digital accesible y confiable que apoye la salud mental, fomente la prevención y brinde acompañamiento oportuno. Nuestro objetivo es transformar ideas en acciones que inspiren esperanza y contribuyan al cuidado integral de las personas.',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color:
                  isDarkMode ? Colors.grey[300] : deepPurple.withOpacity(0.75),
              height: 1.7,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTeamGrid(bool isMobile) {
    return Column(
      children: List.generate((teamMembers.length / 2).ceil(), (rowIndex) {
        final startIndex = rowIndex * 2;
        final endIndex = (startIndex + 2).clamp(0, teamMembers.length);
        final rowMembers = teamMembers.sublist(startIndex, endIndex);

        return Padding(
          padding: EdgeInsets.only(bottom: isMobile ? 20 : 24),
          child: Row(
            children: [
              for (int i = 0; i < rowMembers.length; i++) ...[
                Expanded(child: _buildTeamCard(rowMembers[i], isMobile)),
                if (i < rowMembers.length - 1)
                  SizedBox(width: isMobile ? 16 : 24),
              ],
              if (rowMembers.length == 1) ...[
                SizedBox(width: isMobile ? 16 : 24),
                Expanded(child: SizedBox()),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTeamCard(TeamMember member, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color:
            isDarkMode
                ? cardDark.withOpacity(0.6)
                : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: member.color.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: member.color.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: isMobile ? 60 : 70,
            height: isMobile ? 60 : 70,
            decoration: BoxDecoration(
              color: member.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: member.color.withOpacity(0.4),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Text(
                member.initials,
                style: TextStyle(
                  fontSize: isMobile ? 18 : 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Text(
            member.name,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.w700,
              color: isDarkMode ? softWhite : deepPurple,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),
          Text(
            member.role,
            style: TextStyle(
              fontSize: isMobile ? 12 : 13,
              color:
                  isDarkMode ? Colors.grey[400] : deepPurple.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class TeamMember {
  final String name;
  final String role;
  final String initials;
  final Color color;

  TeamMember({
    required this.name,
    required this.role,
    required this.initials,
    required this.color,
  });
}
