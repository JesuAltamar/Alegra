// lib/screens/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'package:pro9/services/api_chat_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatScreen extends StatefulWidget {
  final int? userId; // Opcional: ID del usuario autenticado
  
  const ChatScreen({Key? key, this.userId}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ApiChatService _apiService = ApiChatService();
  final String sessionId = DateTime.now().millisecondsSinceEpoch.toString();
  
  List<Map<String, dynamic>> messages = [];
  final ScrollController _scrollController = ScrollController();

  // Animaciones
  late AnimationController _particlesController;
  late AnimationController _messageController;
  late AnimationController _typingController;

  List<ChatParticle> particles = [];
  final int particleCount = 15;
  bool isDarkMode = false;
  bool isTyping = false;

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
  final Color crisisRed = Color(0xFFEF4444);

  @override
  void initState() {
    super.initState();

    _particlesController = AnimationController(
      duration: const Duration(seconds: 25),
      vsync: this,
    )..repeat();

    _messageController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _typingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _initParticles();
    _addWelcomeMessage();
  }

  void _initParticles() {
    particles.clear();
    for (int i = 0; i < particleCount; i++) {
      particles.add(ChatParticle());
    }
  }

  void _addWelcomeMessage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        messages.insert(0, {
          'sender': 'bot',
          'message': '¡Hola! Soy Alegra, tu asistente de bienestar emocional. ¿Cómo te sientes hoy?',
          'is_crisis': false,
        });
      });
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _particlesController.dispose();
    _messageController.dispose();
    _typingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? darkBackground : softWhite,
      appBar: _buildAppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode
              ? RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.5,
                  colors: [
                    deepPurple.withOpacity(0.2),
                    darkBackground,
                    Color(0xFF0A0614),
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    softWhite,
                    vibrantPurple.withOpacity(0.03),
                    lightPurple.withOpacity(0.02),
                  ],
                ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: messages.length + (isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (isTyping && index == 0) {
                      return _buildTypingIndicator();
                    }

                    final msgIndex = isTyping ? index - 1 : index;
                    final msg = messages[msgIndex];
                    final isUser = msg['sender'] == 'user';

                    return _buildMessageBubble(msg, isUser);
                  },
                ),
              ),
              _buildInputField(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [vibrantPurple, lightPurple]),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: vibrantPurple.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.psychology, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Asistente Alegra',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDarkMode ? softWhite : deepPurple,
              ),
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: isDarkMode
                ? cardDark.withOpacity(0.8)
                : Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode
                  ? vibrantPurple.withOpacity(0.3)
                  : deepPurple.withOpacity(0.1),
            ),
          ),
          child: IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: isDarkMode ? accentPink : vibrantPurple,
            ),
            onPressed: () {
              setState(() {
                isDarkMode = !isDarkMode;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg, bool isUser) {
    final isCrisis = msg['is_crisis'] == true;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                Container(
                  width: 32,
                  height: 32,
                  margin: const EdgeInsets.only(right: 8, top: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isCrisis
                          ? [crisisRed, Colors.orange]
                          : [vibrantPurple, cloudBlue],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (isCrisis ? crisisRed : vibrantPurple).withOpacity(0.3),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    isCrisis ? Icons.warning : Icons.psychology,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ],
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isUser
                        ? (isDarkMode ? vibrantPurple.withOpacity(0.9) : vibrantPurple)
                        : (isDarkMode ? cardDark.withOpacity(0.9) : Colors.white),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                    border: isCrisis
                        ? Border.all(color: crisisRed, width: 2)
                        : (isUser
                            ? null
                            : Border.all(
                                color: isDarkMode
                                    ? vibrantPurple.withOpacity(0.2)
                                    : deepPurple.withOpacity(0.08),
                              )),
                    boxShadow: [
                      BoxShadow(
                        color: (isDarkMode ? Colors.black : vibrantPurple)
                            .withOpacity(isDarkMode ? 0.2 : 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    msg['message']!,
                    style: GoogleFonts.inter(
                      color: isUser
                          ? Colors.white
                          : (isDarkMode
                              ? softWhite.withOpacity(0.95)
                              : deepPurple.withOpacity(0.9)),
                      fontSize: 15,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              if (isUser) ...[
                Container(
                  width: 32,
                  height: 32,
                  margin: const EdgeInsets.only(left: 8, top: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [accentPink, lightPurple]),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: accentPink.withOpacity(0.2),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(Icons.person, color: Colors.white, size: 16),
                ),
              ],
            ],
          ),
          if (isCrisis) ...[
            SizedBox(height: 8),
            _buildCrisisAlert(),
          ],
        ],
      ),
    );
  }

  Widget _buildCrisisAlert() {
    return Container(
      margin: EdgeInsets.only(left: 40),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: crisisRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: crisisRed.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.phone, color: crisisRed, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Ayuda disponible: Línea 106 (24/7)',
              style: GoogleFonts.inter(
                color: crisisRed,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => _showCrisisDialog(),
            child: Text(
              'Ver más',
              style: GoogleFonts.inter(
                color: crisisRed,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 8, top: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [vibrantPurple, cloudBlue]),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.psychology, color: Colors.white, size: 16),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDarkMode ? cardDark.withOpacity(0.9) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDarkMode
                    ? vibrantPurple.withOpacity(0.2)
                    : deepPurple.withOpacity(0.08),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < 3; i++)
                  AnimatedBuilder(
                    animation: _typingController,
                    builder: (context, child) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        child: Transform.translate(
                          offset: Offset(
                            0,
                            math.sin((_typingController.value * 2 * math.pi) + (i * 0.5)) * 3,
                          ),
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: vibrantPurple,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? cardDark.withOpacity(0.95) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDarkMode
              ? vibrantPurple.withOpacity(0.3)
              : deepPurple.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: (isDarkMode ? Colors.black : vibrantPurple)
                .withOpacity(isDarkMode ? 0.3 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
           Expanded(
            child: TextField(
              controller: _controller,
              style: GoogleFonts.inter(
                color: isDarkMode ? softWhite : deepPurple,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Comparte lo que sientes...',
                hintStyle: GoogleFonts.inter(
                  color: isDarkMode
                      ? softWhite.withOpacity(0.6)
                      : deepPurple.withOpacity(0.6),
                  fontSize: 15,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
              onSubmitted: (text) {
                if (text.trim().isNotEmpty) {
                  _sendMessage(text.trim());
                }
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [vibrantPurple, lightPurple]),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: vibrantPurple.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.send_rounded),
              color: Colors.white,
              onPressed: () {
                final text = _controller.text.trim();
                if (text.isNotEmpty) {
                  _sendMessage(text);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(String text) async {
  setState(() {
    messages.insert(0, {'sender': 'user', 'message': text, 'is_crisis': false});
    _controller.clear();
    isTyping = true;
  });

  _scrollToBottom();
  _typingController.repeat();

  try {
    // 🔥 ENVÍA EL USER_ID CORRECTAMENTE
    final response = await _apiService.sendMessage(
      message: text,
      sessionId: sessionId,
      userId: widget.userId, // 👈 IMPORTANTE: Viene del constructor
    );

    await Future.delayed(const Duration(milliseconds: 1500));

    setState(() {
      isTyping = false;
      messages.insert(0, {
        'sender': 'bot',
        'message': response['reply'] ?? 'Sin respuesta',
        'is_crisis': response['is_crisis'] ?? false,
        'crisis_level': response['crisis_level'] ?? 'none',
      });
    });

    if (response['crisis_level'] == 'severe') _showCrisisDialog();
    _scrollToBottom();
  } catch (e) {
    setState(() {
      isTyping = false;
      messages.insert(0, {
        'sender': 'bot',
        'message': 'Error de conexión. Llama a Línea 106 si necesitas ayuda urgente.',
        'is_crisis': false,
      });
    });
    _scrollToBottom();
    print('Error: $e');
  }

  _typingController.stop();
}
  void _showCrisisDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? cardDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.emergency, color: crisisRed, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Recursos de Ayuda Inmediata',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: isDarkMode ? softWhite : deepPurple,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Si estás en crisis o necesitas ayuda inmediata:',
                style: GoogleFonts.inter(
                  color: isDarkMode ? softWhite : deepPurple,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 20),
              _buildCrisisOption(
                icon: Icons.phone,
                title: 'Línea 106',
                subtitle: 'Atención en crisis 24/7 - Colombia',
                color: crisisRed,
                onTap: () async {
                  final url = Uri.parse('tel:106');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  }
                },
              ),
              SizedBox(height: 12),
              _buildCrisisOption(
                icon: Icons.phone_in_talk,
                title: 'Línea 155',
                subtitle: 'Orientación psicológica',
                color: mentalhealthGreen,
                onTap: () async {
                  final url = Uri.parse('tel:155');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  }
                },
              ),
              SizedBox(height: 12),
              _buildCrisisOption(
                icon: Icons.chat,
                title: 'WhatsApp Línea Amiga',
                subtitle: '+57 300 754 8933',
                color: mentalhealthGreen,
                onTap: () async {
                  final url = Uri.parse('https://wa.me/573007548933');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  }
                },
              ),
              SizedBox(height: 12),
              _buildCrisisOption(
                icon: Icons.public,
                title: 'Recursos Internacionales',
                subtitle: 'findahelpline.com',
                color: vibrantPurple,
                onTap: () async {
                  final url = Uri.parse('https://findahelpline.com');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  }
                },
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: mentalhealthGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '💚 No estás solo. Hay personas capacitadas esperando ayudarte ahora mismo.',
                  style: GoogleFonts.inter(
                    color: isDarkMode ? softWhite : deepPurple,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Entendido',
              style: GoogleFonts.inter(
                color: vibrantPurple,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCrisisOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: isDarkMode ? softWhite : deepPurple,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: (isDarkMode ? softWhite : deepPurple).withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: color),
          ],
        ),
      ),
    );
  }
}

// Clases auxiliares
class ChatParticle {
  late double x;
  late double y;
  late double speed;
  late double size;
  late double opacity;
  late double angle;

  ChatParticle() {
    reset();
  }

  void reset() {
    x = math.Random().nextDouble();
    y = 1.0 + math.Random().nextDouble() * 0.1;
    speed = 0.0003 + math.Random().nextDouble() * 0.0007;
    size = 0.5 + math.Random().nextDouble() * 1.5;
    opacity = 0.05 + math.Random().nextDouble() * 0.15;
    angle = math.Random().nextDouble() * 2 * math.pi;
  }

  void update() {
    y -= speed;
    x += math.sin(angle) * 0.00005;

    if (y < -0.1) {
      reset();
    }
  }
}