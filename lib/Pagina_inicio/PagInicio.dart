import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pro9/Pagina_inicio/UnifiedLoginPage.dart';
import 'package:pro9/ConocenosPage.dart';
import 'package:pro9/Pagina_inicio/ServicesPage.dart';

class PagInicio extends StatefulWidget {
  const PagInicio({Key? key}) : super(key: key);

  @override
  State<PagInicio> createState() => _PagInicioState();
}

class _PagInicioState extends State<PagInicio> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _floatingController;
  late AnimationController _cardController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _cardAnimation;
  late Animation<double> _floatingAnimation;

  late ScrollController _scrollController;
  late PageController _pageController;
  bool isDarkMode = false;

  // Paleta de colores
  final Color deepPurple = Color(0xFF2D1B69);
  final Color vibrantPurple = Color(0xFF6366F1);
  final Color lightPurple = Color(0xFFA855F7);
  final Color darkBackground = Color(0xFF0F0A1F);
  final Color cardDark = Color(0xFF1A1335);
  final Color accentPink = Color(0xFFEC4899);
  final Color softWhite = Color(0xFFF8FAFC);
  final Color cloudBlue = Color(0xFF8B5CF6);
  final Color mentalhealthGreen = Color(0xFF10B981);

  // Carousel state
  int _currentCarouselIndex = 0;
  late Timer _carouselTimer;

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'stefanyjisellescobararaujo@gmail.com',
      queryParameters: {
        'subject': 'Consulta sobre Alegra',
        'body': 'Hola, me gustaría obtener más información sobre Alegra...',
      },
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      }
    } catch (e) {
      print('Error al abrir email: $e');
    }
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _launchWhatsApp() async {
    final String phoneNumber = "+573242161502";
    final String message = "Hola, me gustaría saber más sobre Alegra";
    final String whatsappUrl =
        "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}";
    final Uri uri = Uri.parse(whatsappUrl);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      print('Error al abrir WhatsApp: $e');
    }
  }

  Future<void> _launchMaps() async {
    const String address = "Valledupar, Cesar, Colombia";
    final String googleMapsUrl =
        "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}";
    final Uri uri = Uri.parse(googleMapsUrl);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      print('Error al abrir Maps: $e');
    }
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDarkMode ? cardDark : softWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Política de Privacidad',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDarkMode ? softWhite : deepPurple,
              fontSize: 20,
            ),
          ),
          content: SingleChildScrollView(
            child: Text(
              'En Alegra, protegemos tu privacidad y datos personales. Toda la información que compartes con nosotros está encriptada y segura.',
              style: TextStyle(
                color:
                    isDarkMode ? Colors.grey[300] : deepPurple.withOpacity(0.8),
                height: 1.6,
                fontSize: 16,
              ),
            ),
          ),
          actions: [
            Container(
              decoration: BoxDecoration(
                color: vibrantPurple,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cerrar',
                  style: TextStyle(
                    color: softWhite,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showContactOptions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDarkMode ? cardDark : softWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Contacto',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDarkMode ? softWhite : deepPurple,
              fontSize: 20,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.email, color: accentPink),
                title: Text(
                  'Email',
                  style: TextStyle(color: isDarkMode ? softWhite : deepPurple),
                ),
                subtitle: Text(
                  'somosalegra027@gmail.com',
                  style: TextStyle(color: Colors.grey),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _launchEmail();
                },
              ),
              ListTile(
                leading: Icon(Icons.phone, color: mentalhealthGreen),
                title: Text(
                  'WhatsApp',
                  style: TextStyle(color: isDarkMode ? softWhite : deepPurple),
                ),
                subtitle: Text(
                  '+57 3026139761',
                  style: TextStyle(color: Colors.grey),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _launchWhatsApp();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cerrar', style: TextStyle(color: vibrantPurple)),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _pageController = PageController(initialPage: 0);

    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();

    _cardController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _cardAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.elasticOut),
    );

    _floatingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_floatingController);

    _animationController.forward();

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _cardController.forward();
    });

    _carouselTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (mounted && _pageController.hasClients) {
        final nextPage = (_currentCarouselIndex + 1) % 3;
        _pageController.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pageController.dispose();
    _animationController.dispose();
    _floatingController.dispose();
    _cardController.dispose();
    _carouselTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;

    return Scaffold(
      backgroundColor: isDarkMode ? darkBackground : softWhite,
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
        child: Column(
          children: [
            _buildHeader(isMobile),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    _buildHeroSection(isMobile, isTablet),
                    _buildMainContent(isMobile, isTablet),
                    _buildFooter(isMobile),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 80,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: (isDarkMode ? cardDark : softWhite).withOpacity(0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: vibrantPurple,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: vibrantPurple.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(Icons.psychology, color: softWhite, size: 20),
          ),
          SizedBox(width: 16),
          Text(
            'ALEGRA',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: isDarkMode ? softWhite : deepPurple,
              letterSpacing: 1.2,
            ),
          ),
          Spacer(),
          if (!isMobile) ...[
            _buildNavLink('Inicio', isInicio: true),
            _buildNavLink('Conócenos', isConocenos: true),
            _buildNavLink('Servicios', isServicios: true),
            _buildNavLink('Contacto', isContacto: true),
            SizedBox(width: 16),
            Container(
              decoration: BoxDecoration(
                color: vibrantPurple,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: vibrantPurple.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              const UnifiedLoginPage(nombreUsuario: null),
                    ),
                  );
                },
                child: Text(
                  'Iniciar Sesión',
                  style: TextStyle(
                    color: softWhite,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
          SizedBox(width: 16),
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: isDarkMode ? accentPink : vibrantPurple,
              size: 24,
            ),
            onPressed: () {
              setState(() {
                isDarkMode = !isDarkMode;
              });
            },
          ),
          if (isMobile)
            IconButton(
              icon: Icon(
                Icons.menu,
                color: isDarkMode ? softWhite : deepPurple,
              ),
              onPressed: () {
                _showMobileMenu();
              },
            ),
        ],
      ),
    );
  }

  Widget _buildNavLink(
    String text, {
    bool isInicio = false,
    bool isConocenos = false,
    bool isServicios = false,
    bool isContacto = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 24),
      child: TextButton(
        onPressed: () {
          if (isInicio) {
            _scrollToTop();
          } else if (isConocenos) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ConocenosPage()),
            );
          } else if (isServicios) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ServicesPage()),
            );
          } else if (isContacto) {
            _showContactOptions();
          }
        },
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color:
                isDarkMode
                    ? softWhite.withOpacity(0.8)
                    : deepPurple.withOpacity(0.8),
          ),
        ),
      ),
    );
  }

  void _showMobileMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDarkMode ? cardDark : softWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.home, color: vibrantPurple),
                title: Text('Inicio'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: Icon(Icons.info, color: vibrantPurple),
                title: Text('Conócenos'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ConocenosPage(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.medical_services, color: vibrantPurple),
                title: Text('Servicios'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ServicesPage(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.contact_mail, color: vibrantPurple),
                title: Text('Contacto'),
                onTap: () {
                  Navigator.pop(context);
                  _showContactOptions();
                },
              ),
              SizedBox(height: 16),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: vibrantPurple,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                const UnifiedLoginPage(nombreUsuario: null),
                      ),
                    );
                  },
                  child: Text(
                    'Iniciar Sesión',
                    style: TextStyle(
                      color: softWhite,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeroSection(bool isMobile, bool isTablet) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeInAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: isMobile ? 20 : 80,
                vertical: isMobile ? 40 : 60,
              ),
              padding: EdgeInsets.all(isMobile ? 30 : 60),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors:
                      isDarkMode
                          ? [
                            Color(0xFF1A1335).withOpacity(0.95),
                            Color(0xFF2D1B69).withOpacity(0.7),
                          ]
                          : [
                            Color(0xFFE5E7EB),
                            Color(0xFFDDD6FE).withOpacity(0.6),
                          ],
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: vibrantPurple.withOpacity(0.1),
                    blurRadius: 30,
                    offset: Offset(0, 15),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: isMobile ? 1 : 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: vibrantPurple.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: vibrantPurple.withOpacity(0.4),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('💡', style: TextStyle(fontSize: 14)),
                              SizedBox(width: 6),
                              Text(
                                'Cuidado mental personalizado',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: vibrantPurple,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: isMobile ? 24 : 32),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Tu ',
                                style: TextStyle(
                                  fontSize:
                                      isMobile ? 34 : (isTablet ? 44 : 52),
                                  fontWeight: FontWeight.w900,
                                  color: isDarkMode ? softWhite : deepPurple,
                                  height: 1.15,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              TextSpan(
                                text: 'bienestar mental\n',
                                style: TextStyle(
                                  fontSize:
                                      isMobile ? 34 : (isTablet ? 44 : 52),
                                  fontWeight: FontWeight.w900,
                                  color: vibrantPurple,
                                  height: 1.15,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              TextSpan(
                                text: 'es nuestra prioridad',
                                style: TextStyle(
                                  fontSize:
                                      isMobile ? 34 : (isTablet ? 44 : 52),
                                  fontWeight: FontWeight.w900,
                                  color: isDarkMode ? softWhite : deepPurple,
                                  height: 1.15,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: isMobile ? 20 : 28),
                        Container(
                          constraints: BoxConstraints(
                            maxWidth: isMobile ? double.infinity : 520,
                          ),
                          child: Text(
                            ' En Alegra creemos que cada día es una nueva oportunidad para cuidarte, encontrar calma y dar pequeños pasos hacia tu bienestar.',
                            style: TextStyle(
                              fontSize: isMobile ? 15 : 17,
                              color:
                                  isDarkMode
                                      ? Colors.grey[300]
                                      : deepPurple.withOpacity(0.75),
                              height: 1.7,
                            ),
                          ),
                        ),
                        SizedBox(height: isMobile ? 32 : 44),
                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    vibrantPurple,
                                    vibrantPurple.withOpacity(0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: vibrantPurple.withOpacity(0.4),
                                    blurRadius: 16,
                                    offset: Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  foregroundColor: softWhite,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isMobile ? 28 : 36,
                                    vertical: isMobile ? 16 : 18,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => const UnifiedLoginPage(
                                            nombreUsuario: null,
                                          ),
                                    ),
                                  );
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Comenzar ahora',
                                      style: TextStyle(
                                        fontSize: isMobile ? 15 : 17,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Icon(Icons.arrow_forward_rounded, size: 18),
                                  ],
                                ),
                              ),
                            ),
                            OutlinedButton(
                              onPressed: () {
                                _scrollController.animateTo(
                                  600,
                                  duration: Duration(milliseconds: 800),
                                  curve: Curves.easeInOut,
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor:
                                    isDarkMode ? vibrantPurple : deepPurple,
                                backgroundColor:
                                    isDarkMode
                                        ? Colors.white.withOpacity(0.05)
                                        : Colors.white.withOpacity(0.6),
                                side: BorderSide(
                                  color:
                                      isDarkMode ? vibrantPurple : deepPurple,
                                  width: 1.5,
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 24 : 28,
                                  vertical: isMobile ? 16 : 18,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                'Ver más',
                                style: TextStyle(
                                  fontSize: isMobile ? 15 : 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (!isMobile) ...[
                    SizedBox(width: 60),
                    Expanded(
                      flex: 4,
                      child: Container(
                        height: 450,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 400,
                              height: 400,
                              decoration: BoxDecoration(
                                color:
                                    isDarkMode
                                        ? cardDark.withOpacity(0.8)
                                        : Colors.white.withOpacity(0.95),
                                borderRadius: BorderRadius.circular(32),
                                boxShadow: [
                                  BoxShadow(
                                    color: vibrantPurple.withOpacity(0.15),
                                    blurRadius: 30,
                                    offset: Offset(0, 15),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 50,
                              right: 30,
                              child: AnimatedBuilder(
                                animation: _floatingAnimation,
                                builder: (context, child) {
                                  return Transform.rotate(
                                    angle: _floatingAnimation.value * 0.5,
                                    child: Container(
                                      width: 120,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: lightPurple.withOpacity(0.3),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(60),
                                          topRight: Radius.circular(20),
                                          bottomLeft: Radius.circular(40),
                                          bottomRight: Radius.circular(80),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Positioned(
                              top: 80,
                              left: 20,
                              child: AnimatedBuilder(
                                animation: _floatingAnimation,
                                builder: (context, child) {
                                  return Transform.rotate(
                                    angle: -_floatingAnimation.value * 0.3,
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: accentPink.withOpacity(0.2),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(50),
                                          topRight: Radius.circular(50),
                                          bottomLeft: Radius.circular(10),
                                          bottomRight: Radius.circular(50),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Positioned(
                              top: 80,
                              child: AnimatedBuilder(
                                animation: _floatingAnimation,
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(
                                      0,
                                      math.sin(
                                            _floatingAnimation.value *
                                                2 *
                                                math.pi,
                                          ) *
                                          8,
                                    ),
                                    child: Column(
                                      children: [
                                        Container(
                                          width: 140,
                                          height: 140,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Color(0xFFFFE0E6),
                                                Color(0xFFFFB3C1),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: accentPink.withOpacity(
                                                  0.3,
                                                ),
                                                blurRadius: 15,
                                                offset: Offset(0, 8),
                                              ),
                                            ],
                                          ),
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Positioned(
                                                top: 40,
                                                left: 35,
                                                child: Container(
                                                  width: 20,
                                                  height: 20,
                                                  decoration: BoxDecoration(
                                                    color: deepPurple,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                top: 40,
                                                right: 35,
                                                child: Container(
                                                  width: 20,
                                                  height: 20,
                                                  decoration: BoxDecoration(
                                                    color: deepPurple,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                bottom: 45,
                                                child: Container(
                                                  width: 40,
                                                  height: 20,
                                                  decoration: BoxDecoration(
                                                    color: Colors.transparent,
                                                    border: Border(
                                                      bottom: BorderSide(
                                                        color: deepPurple,
                                                        width: 4,
                                                      ),
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.only(
                                                          bottomLeft:
                                                              Radius.circular(
                                                                20,
                                                              ),
                                                          bottomRight:
                                                              Radius.circular(
                                                                20,
                                                              ),
                                                        ),
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                top: 65,
                                                left: 15,
                                                child: Container(
                                                  width: 15,
                                                  height: 15,
                                                  decoration: BoxDecoration(
                                                    color: accentPink
                                                        .withOpacity(0.4),
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                top: 65,
                                                right: 15,
                                                child: Container(
                                                  width: 15,
                                                  height: 15,
                                                  decoration: BoxDecoration(
                                                    color: accentPink
                                                        .withOpacity(0.4),
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Container(
                                          width: 100,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                vibrantPurple.withOpacity(0.8),
                                                lightPurple.withOpacity(0.6),
                                              ],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              40,
                                            ),
                                          ),
                                          child: Center(
                                            child: Icon(
                                              Icons.favorite,
                                              color: softWhite,
                                              size: 30,
                                            ),
                                          ),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 30,
                                              height: 15,
                                              decoration: BoxDecoration(
                                                color: Color(0xFFFFB3C1),
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                            ),
                                            SizedBox(width: 40),
                                            Container(
                                              width: 30,
                                              height: 15,
                                              decoration: BoxDecoration(
                                                color: Color(0xFFFFB3C1),
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            Positioned(
                              bottom: 80,
                              right: 60,
                              child: AnimatedBuilder(
                                animation: _floatingAnimation,
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(
                                      0,
                                      math.sin(
                                            _floatingAnimation.value *
                                                2 *
                                                math.pi,
                                          ) *
                                          3,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            color: vibrantPurple,
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              Container(
                                                width: 20,
                                                height: 20,
                                                margin: EdgeInsets.only(top: 5),
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFFFB4A2),
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              Container(
                                                width: 30,
                                                height: 30,
                                                margin: EdgeInsets.only(top: 5),
                                                decoration: BoxDecoration(
                                                  color: softWhite,
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: 30,
                                          height: 40,
                                          child: Column(
                                            children: List.generate(4, (index) {
                                              return Container(
                                                width: 30,
                                                height: 8,
                                                margin: EdgeInsets.only(
                                                  bottom: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Color(
                                                    0xFFBB86FC,
                                                  ).withOpacity(0.8),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                              );
                                            }),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            ...List.generate(8, (index) {
                              final positions = [
                                {
                                  'top': 60.0,
                                  'left': 80.0,
                                  'icon': Icons.favorite,
                                  'color': accentPink,
                                },
                                {
                                  'top': 120.0,
                                  'right': 50.0,
                                  'icon': Icons.star,
                                  'color': mentalhealthGreen,
                                },
                                {
                                  'top': 200.0,
                                  'left': 40.0,
                                  'icon': Icons.local_hospital,
                                  'color': cloudBlue,
                                },
                                {
                                  'top': 250.0,
                                  'right': 80.0,
                                  'icon': Icons.psychology,
                                  'color': lightPurple,
                                },
                                {
                                  'bottom': 120.0,
                                  'left': 60.0,
                                  'icon': Icons.self_improvement,
                                  'color': vibrantPurple,
                                },
                                {
                                  'bottom': 160.0,
                                  'right': 40.0,
                                  'icon': Icons.mood,
                                  'color': accentPink,
                                },
                                {
                                  'top': 90.0,
                                  'right': 120.0,
                                  'icon': Icons.spa,
                                  'color': mentalhealthGreen,
                                },
                                {
                                  'bottom': 200.0,
                                  'left': 100.0,
                                  'icon': Icons.brightness_high,
                                  'color': Color(0xFFFFD93D),
                                },
                              ];

                              if (index >= positions.length) return Container();

                              final pos = positions[index];

                              return AnimatedBuilder(
                                animation: _floatingAnimation,
                                builder: (context, child) {
                                  return Positioned(
                                    top: pos['top'] as double?,
                                    left: pos['left'] as double?,
                                    right: pos['right'] as double?,
                                    bottom: pos['bottom'] as double?,
                                    child: Transform.translate(
                                      offset: Offset(
                                        math.sin(
                                              _floatingAnimation.value *
                                                      2 *
                                                      math.pi +
                                                  index,
                                            ) *
                                            5,
                                        math.cos(
                                              _floatingAnimation.value *
                                                      2 *
                                                      math.pi +
                                                  index,
                                            ) *
                                            3,
                                      ),
                                      child: Container(
                                        width: 35,
                                        height: 35,
                                        decoration: BoxDecoration(
                                          color: (pos['color'] as Color)
                                              .withOpacity(0.2),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: pos['color'] as Color,
                                            width: 2,
                                          ),
                                        ),
                                        child: Icon(
                                          pos['icon'] as IconData,
                                          size: 18,
                                          color: pos['color'] as Color,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            }),
                            Positioned(
                              bottom: 40,
                              child: Column(
                                children: [
                                  Text(
                                    'ALEGRA',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      color: vibrantPurple,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: vibrantPurple,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'MENTAL HEALTH',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: softWhite,
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
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainContent(bool isMobile, bool isTablet) {
    return AnimatedBuilder(
      animation: _fadeInAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeInAnimation,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 20 : 80,
              vertical: 60,
            ),
            child: Column(
              children: [
                SizedBox(height: 80),
                isMobile || isTablet
                    ? Column(
                      children: [
                        _buildBodyContent(isMobile, isTablet),
                        SizedBox(height: 60),
                        _buildSidebar(isMobile),
                        SizedBox(height: 80),
                      ],
                    )
                    : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 7,
                          child: _buildBodyContent(isMobile, isTablet),
                        ),
                        SizedBox(width: 40),
                        Expanded(flex: 3, child: _buildSidebar(isMobile)),
                      ],
                    ),
                SizedBox(height: 40),
                _buildCardsSection(isMobile, isTablet),
                SizedBox(height: 100),
                _buildMissionVisionSection(isMobile, isTablet),
                SizedBox(height: 100),
                _buildBenefitsSection(isMobile, isTablet),
                SizedBox(height: 80),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSidebar(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode ? cardDark.withOpacity(0.8) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: vibrantPurple.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.article, color: vibrantPurple, size: 20),
              SizedBox(width: 12),
              Text(
                'Artículos Recientes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? softWhite : deepPurple,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          _buildSidebarItem(
            '',
            'Pequeños logros diarios suman grandes cambios',
            Icons.self_improvement,
            mentalhealthGreen,
          ),
          SizedBox(height: 16),
          _buildSidebarItem(
            '',
            '¿Sabías que… jugar unos minutos al día puede ayudarte a liberar tensión y mejorar tu concentración?',
            Icons.favorite,
            accentPink,
          ),
          SizedBox(height: 16),
          _buildSidebarItem(
            '',
            'Diviértete y libera el estrés con actividades básicas.',
            Icons.spa,
            cloudBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? softWhite : deepPurple,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        isDarkMode
                            ? Colors.grey[400]
                            : deepPurple.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyContent(bool isMobile, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: vibrantPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.auto_awesome, color: vibrantPurple, size: 20),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                'Sobre Alegra',
                style: TextStyle(
                  fontSize: isMobile ? 24 : 32,
                  fontWeight: FontWeight.w800,
                  color: isDarkMode ? softWhite : deepPurple,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color:
                isDarkMode
                    ? cardDark.withOpacity(0.6)
                    : Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bienestar Mental Integral',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? softWhite : deepPurple,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Alegra es una plataforma web enfocada en la salud mental que integra un chatbot de apoyo emocional, juegos básicos de distracción y un checklist para organizar actividades diarias. Su propósito es ofrecer un espacio accesible y confiable que fomente el bienestar emocional.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color:
                      isDarkMode
                          ? Colors.grey[300]
                          : deepPurple.withOpacity(0.8),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Nuestra plataforma está diseñada pensando en ti. Cada herramienta ha sido cuidadosamente desarrollada para brindarte el apoyo que necesitas en tu día a día. Ya sea que busques organizar tus tareas, relajarte con un juego, o simplemente conversar con nuestro asistente virtual, Alegra está aquí para acompañarte en tu camino hacia el bienestar.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color:
                      isDarkMode
                          ? Colors.grey[300]
                          : deepPurple.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCardsSection(bool isMobile, bool isTablet) {
    return AnimatedBuilder(
      animation: _cardAnimation,
      builder: (context, child) {
        return Column(
          children: [
            Text(
              'Herramientas para tu bienestar',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isMobile ? 24 : 32,
                fontWeight: FontWeight.w800,
                color: isDarkMode ? softWhite : deepPurple,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Descubre todas las formas en que Alegra puede ayudarte',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                color:
                    isDarkMode ? Colors.grey[300] : deepPurple.withOpacity(0.7),
              ),
            ),
            SizedBox(height: 30),
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: isMobile ? 1 : (isTablet ? 2 : 3),
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: isMobile ? 1.2 : 1.1,
              children: [
                _buildFeatureCard(
                  Icons.checklist,
                  'Lista de Tareas',
                  'Organiza tu rutina diaria de bienestar con recordatorios personalizados',
                  mentalhealthGreen,
                  0,
                ),
                _buildFeatureCard(
                  Icons.psychology,
                  'ChatBot',
                  'Asistente inteligente disponible 24/7 para apoyo emocional',
                  vibrantPurple,
                  1,
                ),
                _buildFeatureCard(
                  Icons.games_outlined,
                  'Juegos Interactivos',
                  'Ejercicios interactivos para reducir estrés y ansiedad',
                  accentPink,
                  2,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildFeatureCard(
    IconData icon,
    String title,
    String description,
    Color accentColor,
    int index,
  ) {
    return Transform.translate(
      offset: Offset(0, (1 - _cardAnimation.value) * 50),
      child: Opacity(
        opacity: _cardAnimation.value.clamp(0.0, 1.0),
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color:
                isDarkMode
                    ? cardDark.withOpacity(0.8)
                    : Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accentColor.withOpacity(0.3), width: 2),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.1),
                blurRadius: 15,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: accentColor.withOpacity(0.3)),
                ),
                child: Icon(icon, color: accentColor, size: 24),
              ),
              SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? softWhite : deepPurple,
                ),
              ),
              SizedBox(height: 8),
              Expanded(
                child: Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color:
                        isDarkMode
                            ? Colors.grey[300]
                            : deepPurple.withOpacity(0.7),
                    height: 1.4,
                  ),
                ),
              ),
              Container(
                width: 30,
                height: 3,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMissionVisionSection(bool isMobile, bool isTablet) {
    return Column(
      children: [
        Text(
          'Nuestro Compromiso',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isMobile ? 28 : 36,
            fontWeight: FontWeight.w900,
            color: isDarkMode ? softWhite : deepPurple,
          ),
        ),
        SizedBox(height: 40),
        GridView.count(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: isMobile ? 1 : (isTablet ? 2 : 3),
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: isMobile ? 1.3 : 1.0,
          children: [
            _buildMVVCard(
              Icons.flag,
              'Misión',
              'Proporcionar herramientas accesibles y efectivas que promuevan el bienestar mental, creando un espacio seguro donde cada persona pueda encontrar apoyo emocional y recursos para mejorar su calidad de vida.',
              vibrantPurple,
            ),
            _buildMVVCard(
              Icons.visibility,
              'Visión',
              'Ser la plataforma líder en salud mental digital, reconocida por su impacto positivo en la vida de las personas y por democratizar el acceso al cuidado emocional a través de la tecnología.',
              accentPink,
            ),
            _buildMVVCard(
              Icons.favorite,
              'Valores',
              'Empatía, confidencialidad, accesibilidad, innovación y compromiso con el bienestar integral de cada usuario que confía en nuestra plataforma.',
              mentalhealthGreen,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMVVCard(
    IconData icon,
    String title,
    String description,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDarkMode ? cardDark.withOpacity(0.8) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.3), width: 2),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDarkMode ? softWhite : deepPurple,
            ),
          ),
          SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color:
                  isDarkMode ? Colors.grey[300] : deepPurple.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsSection(bool isMobile, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 28 : 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            vibrantPurple.withOpacity(0.1),
            lightPurple.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: vibrantPurple.withOpacity(0.2), width: 2),
      ),
      child: Column(
        children: [
          Text(
            '¿Por qué elegir Alegra?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 24 : 32,
              fontWeight: FontWeight.w800,
              color: isDarkMode ? softWhite : deepPurple,
            ),
          ),
          SizedBox(height: 32),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              _buildBenefitItem(
                Icons.school,
                'Hecha por estudiantes como tú',
                'Un proyecto cercano, creado con dedicación para apoyar a quienes lo necesitan.',
              ),
              _buildBenefitItem(
                Icons.access_time,
                'Disponible siempre que lo necesites',
                'Accede a un espacio pensado para ti en cualquier momento.',
              ),
              _buildBenefitItem(
                Icons.psychology,
                'Fácil de usar',
                'Una plataforma sencilla, amigable y sin complicaciones.',
              ),
              _buildBenefitItem(
                Icons.people_alt,
                'Crecemos contigo',
                'Alegra está en constante evolución, añadiendo nuevas funciones poco a poco.',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String title, String subtitle) {
    return Container(
      width: 200,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:
            isDarkMode
                ? cardDark.withOpacity(0.6)
                : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: vibrantPurple, size: 32),
          SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDarkMode ? softWhite : deepPurple,
            ),
          ),
          SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color:
                  isDarkMode ? Colors.grey[400] : deepPurple.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 24 : 32,
        horizontal: isMobile ? 20 : 80,
      ),
      decoration: BoxDecoration(
        color:
            isDarkMode
                ? cardDark.withOpacity(0.95)
                : Colors.white.withOpacity(0.95),
        border: Border(
          top: BorderSide(
            color:
                isDarkMode
                    ? vibrantPurple.withOpacity(0.2)
                    : deepPurple.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          if (!isMobile)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: vibrantPurple,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.psychology,
                              color: softWhite,
                              size: 18,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'ALEGRA',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: isDarkMode ? softWhite : deepPurple,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Transformando vidas a través del bienestar mental',
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              isDarkMode
                                  ? Colors.grey[400]
                                  : deepPurple.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ubicación',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDarkMode ? softWhite : deepPurple,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Valledupar, Cesar',
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              isDarkMode
                                  ? Colors.grey[400]
                                  : deepPurple.withOpacity(0.6),
                        ),
                      ),
                      Text(
                        'Colombia',
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              isDarkMode
                                  ? Colors.grey[400]
                                  : deepPurple.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Conéctate',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDarkMode ? softWhite : deepPurple,
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          _buildSocialIcon(
                            Icons.email,
                            _launchEmail,
                            accentPink,
                          ),
                          SizedBox(width: 12),
                          _buildSocialIcon(
                            Icons.phone,
                            _launchWhatsApp,
                            mentalhealthGreen,
                          ),
                          SizedBox(width: 12),
                          _buildSocialIcon(
                            Icons.location_on,
                            _launchMaps,
                            cloudBlue,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          if (isMobile) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: vibrantPurple,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.psychology, color: softWhite, size: 18),
                ),
                SizedBox(width: 12),
                Text(
                  'ALEGRA',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: isDarkMode ? softWhite : deepPurple,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialIcon(Icons.email, _launchEmail, accentPink),
                SizedBox(width: 12),
                _buildSocialIcon(
                  Icons.phone,
                  _launchWhatsApp,
                  mentalhealthGreen,
                ),
                SizedBox(width: 12),
                _buildSocialIcon(Icons.location_on, _launchMaps, cloudBlue),
              ],
            ),
            SizedBox(height: 20),
          ],
          if (!isMobile) SizedBox(height: 24),
          Divider(color: isDarkMode ? Colors.grey[800] : Colors.grey[300]),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  '© 2024 Alegra',
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        isDarkMode
                            ? Colors.grey[400]
                            : deepPurple.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildFooterLink('Política de Privacidad'),
              _buildFooterLink('Contacto'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String text) {
    return Container(
      decoration: BoxDecoration(
        color: vibrantPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: vibrantPurple.withOpacity(0.3)),
      ),
      child: TextButton(
        onPressed: () {
          if (text.contains('Privacidad')) {
            _showPrivacyPolicy();
          } else if (text.contains('Contacto')) {
            _showContactOptions();
          }
        },
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: vibrantPurple,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, VoidCallback onTap, Color color) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 18),
        onPressed: onTap,
        padding: EdgeInsets.zero,
      ),
    );
  }
}
