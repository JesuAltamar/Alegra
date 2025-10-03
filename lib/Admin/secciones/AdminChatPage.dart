import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class AdminChatManagement extends StatefulWidget {
  const AdminChatManagement({super.key});

  @override
  State<AdminChatManagement> createState() => _AdminChatManagementState();
}

class _AdminChatManagementState extends State<AdminChatManagement>
    with TickerProviderStateMixin {
  bool isDarkMode = false;
  int selectedTabIndex = 0;
  String selectedFilter = 'Todas';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Datos simulados para el dashboard
  int totalConversaciones = 147;
  int mensajesHoy = 89;
  int usuariosActivos = 23;
  double satisfaccionPromedio = 4.3;
  int conversacionesEnCurso = 5;
  int alertasBienestar = 3;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _mostrarDialogoLogout() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AlegraColors.getSurface(isDarkMode),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.logout, color: Colors.red, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                'Cerrar Sesión',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AlegraColors.getTextPrimary(isDarkMode),
                ),
              ),
            ],
          ),
          content: Text(
            '¿Estás seguro de que quieres cerrar tu sesión de administrador?\n\nSerás redirigido a la página principal.',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: AlegraColors.getTextSecondary(isDarkMode),
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  color: AlegraColors.getTextSecondary(isDarkMode),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Cerrar Sesión',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 768;

    return Scaffold(
      backgroundColor: AlegraColors.getBackground(isDarkMode),
      appBar: AppBar(
        backgroundColor: AlegraColors.getBackground(isDarkMode),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AlegraColors.getTextPrimary(isDarkMode),
          ),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          "Gestión del Chat",
          style: TextStyle(color: AlegraColors.getTextPrimary(isDarkMode)),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Row(
          children: [
            if (isTablet) _buildSidebar(),
            Expanded(child: _buildMainContent(isTablet)),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AlegraColors.getSurface(isDarkMode),
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AlegraColors.getCard(isDarkMode),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AlegraColors.getBorder(isDarkMode),
            width: 1,
          ),
        ),
        child: IconButton(
          icon: const Icon(Icons.logout, color: Colors.red),
          onPressed: _mostrarDialogoLogout,
          tooltip: 'Cerrar Sesión',
        ),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00D4FF), Color(0xFF00A3CC)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00D4FF).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Chat & Consejos Admin',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AlegraColors.getTextPrimary(isDarkMode),
                ),
              ),
              Text(
                'Panel de Administración',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AlegraColors.getTextSecondary(isDarkMode),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AlegraColors.getCard(isDarkMode),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AlegraColors.getBorder(isDarkMode),
              width: 1,
            ),
          ),
          child: IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: isDarkMode ? Colors.orange : Colors.blue,
            ),
            onPressed: () => setState(() => isDarkMode = !isDarkMode),
          ),
        ),
      ],
    );
  }

  Widget _buildSidebar() {
    final menuItems = [
      {'icon': Icons.dashboard, 'title': 'Dashboard', 'index': 0},
      {
        'icon': Icons.chat_bubble_outline,
        'title': 'Conversaciones',
        'index': 1,
      },
      {'icon': Icons.psychology, 'title': 'Entrenar IA', 'index': 2},
      {'icon': Icons.analytics, 'title': 'Análisis', 'index': 3},
      {'icon': Icons.warning_amber, 'title': 'Alertas', 'index': 4},
      {'icon': Icons.settings, 'title': 'Configuración', 'index': 5},
    ];

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: AlegraColors.getSurface(isDarkMode),
        border: Border(
          right: BorderSide(
            color: AlegraColors.getBorder(isDarkMode),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'NAVEGACIÓN',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AlegraColors.getTextSecondary(isDarkMode),
                letterSpacing: 1.2,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                final isSelected = selectedTabIndex == item['index'];

                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 2,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap:
                          () => setState(
                            () => selectedTabIndex = item['index'] as int,
                          ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? const Color(0xFF00D4FF).withOpacity(0.1)
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border:
                              isSelected
                                  ? Border.all(
                                    color: const Color(
                                      0xFF00D4FF,
                                    ).withOpacity(0.3),
                                    width: 1,
                                  )
                                  : null,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item['icon'] as IconData,
                              color:
                                  isSelected
                                      ? const Color(0xFF00D4FF)
                                      : AlegraColors.getTextSecondary(
                                        isDarkMode,
                                      ),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              item['title'] as String,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                color:
                                    isSelected
                                        ? const Color(0xFF00D4FF)
                                        : AlegraColors.getTextPrimary(
                                          isDarkMode,
                                        ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(bool isTablet) {
    switch (selectedTabIndex) {
      case 0:
        return _buildDashboard(isTablet);
      case 1:
        return _buildConversaciones(isTablet);
      case 2:
        return _buildEntrenarIA(isTablet);
      case 3:
        return _buildAnalisis(isTablet);
      case 4:
        return _buildAlertas(isTablet);
      case 5:
        return _buildConfiguracion(isTablet);
      default:
        return _buildDashboard(isTablet);
    }
  }

  Widget _buildDashboard(bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard del Chat',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AlegraColors.getTextPrimary(isDarkMode),
            ),
          ),
          const SizedBox(height: 24),
          _buildMetricsGrid(isTablet),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildConversationChart()),
              if (isTablet) const SizedBox(width: 24),
              if (isTablet) Expanded(flex: 1, child: _buildQuickActions()),
            ],
          ),
          if (!isTablet) ...[const SizedBox(height: 24), _buildQuickActions()],
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(bool isTablet) {
    final metrics = [
      {
        'title': 'Conversaciones Totales',
        'value': '$totalConversaciones',
        'change': '+12% esta semana',
        'icon': Icons.chat_bubble_outline,
        'color': const Color(0xFF00D4FF),
      },
      {
        'title': 'Mensajes Hoy',
        'value': '$mensajesHoy',
        'change': '23 usuarios activos',
        'icon': Icons.message,
        'color': const Color(0xFF10B981),
      },
      {
        'title': 'Satisfacción',
        'value': '${satisfaccionPromedio}/5',
        'change': '+0.2 vs mes anterior',
        'icon': Icons.sentiment_satisfied,
        'color': const Color(0xFFF59E0B),
      },
      {
        'title': 'Alertas Bienestar',
        'value': '$alertasBienestar',
        'change': 'Requieren atención',
        'icon': Icons.warning_amber,
        'color': const Color(0xFFEF4444),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? 4 : 2,
        childAspectRatio: isTablet ? 1.2 : 1.3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: metrics.length,
      itemBuilder: (context, index) {
        final metric = metrics[index];
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AlegraColors.getSurface(isDarkMode),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AlegraColors.getBorder(isDarkMode),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDarkMode ? 0.1 : 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (metric['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      metric['icon'] as IconData,
                      color: metric['color'] as Color,
                      size: 20,
                    ),
                  ),
                  Icon(
                    Icons.trending_up,
                    color: const Color(0xFF10B981),
                    size: 16,
                  ),
                ],
              ),
              const Spacer(),
              Text(
                metric['value'] as String,
                style: GoogleFonts.inter(
                  fontSize: isTablet ? 24 : 20,
                  fontWeight: FontWeight.w700,
                  color: AlegraColors.getTextPrimary(isDarkMode),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                metric['title'] as String,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AlegraColors.getTextSecondary(isDarkMode),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                metric['change'] as String,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: AlegraColors.getTextSecondary(isDarkMode),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildConversationChart() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AlegraColors.getSurface(isDarkMode),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AlegraColors.getBorder(isDarkMode), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Conversaciones por Hora',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AlegraColors.getTextPrimary(isDarkMode),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(height: 200, child: _buildSimpleChart()),
        ],
      ),
    );
  }

  Widget _buildSimpleChart() {
    final data = [5, 8, 12, 15, 23, 18, 25, 20, 16, 12, 8, 6];
    final maxValue = data.reduce(math.max);
    final hours = [
      '00',
      '02',
      '04',
      '06',
      '08',
      '10',
      '12',
      '14',
      '16',
      '18',
      '20',
      '22',
    ];

    return Column(
      children: [
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(data.length, (index) {
              final value = data[index];
              final height = (value / maxValue) * 140 + 20;

              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 24,
                    height: height,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Color(0xFF00D4FF), Color(0xFF00A3CC)],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hours[index],
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: AlegraColors.getTextSecondary(isDarkMode),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {
        'title': 'Ver Conversaciones Activas',
        'subtitle': '$conversacionesEnCurso en curso',
        'icon': Icons.chat_bubble,
        'color': const Color(0xFF00D4FF),
        'onTap': () => setState(() => selectedTabIndex = 1),
      },
      {
        'title': 'Revisar Alertas',
        'subtitle': '$alertasBienestar alertas pendientes',
        'icon': Icons.warning_amber,
        'color': const Color(0xFFEF4444),
        'onTap': () => setState(() => selectedTabIndex = 4),
      },
      {
        'title': 'Entrenar Respuestas',
        'subtitle': 'Mejorar IA del asistente',
        'icon': Icons.psychology,
        'color': const Color(0xFF10B981),
        'onTap': () => setState(() => selectedTabIndex = 2),
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AlegraColors.getSurface(isDarkMode),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AlegraColors.getBorder(isDarkMode), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Acciones Rápidas',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AlegraColors.getTextPrimary(isDarkMode),
            ),
          ),
          const SizedBox(height: 16),
          ...actions.map((action) => _buildActionTile(action)).toList(),
        ],
      ),
    );
  }

  Widget _buildActionTile(Map<String, dynamic> action) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: action['onTap'] as VoidCallback,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AlegraColors.getCard(isDarkMode),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AlegraColors.getBorder(isDarkMode),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (action['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    action['icon'] as IconData,
                    color: action['color'] as Color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        action['title'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AlegraColors.getTextPrimary(isDarkMode),
                        ),
                      ),
                      Text(
                        action['subtitle'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AlegraColors.getTextSecondary(isDarkMode),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AlegraColors.getTextSecondary(isDarkMode),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConversaciones(bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Conversaciones Activas',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AlegraColors.getTextPrimary(isDarkMode),
                ),
              ),
              _buildFilterDropdown(),
            ],
          ),
          const SizedBox(height: 24),
          _buildConversationsList(),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AlegraColors.getCard(isDarkMode),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AlegraColors.getBorder(isDarkMode), width: 1),
      ),
      child: DropdownButton<String>(
        value: selectedFilter,
        underline: Container(),
        items:
            ['Todas', 'Activas', 'Completadas', 'Con Alertas'].map((
              String value,
            ) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AlegraColors.getTextPrimary(isDarkMode),
                  ),
                ),
              );
            }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            setState(() {
              selectedFilter = newValue;
            });
          }
        },
      ),
    );
  }

  Widget _buildConversationsList() {
    final conversations = [
      {
        'user': 'Usuario #123',
        'lastMessage': 'Me siento muy ansioso últimamente...',
        'time': '2 min ago',
        'status': 'active',
        'priority': 'high',
        'messageCount': 15,
      },
      {
        'user': 'Usuario #456',
        'lastMessage': 'Gracias por el consejo, me ayudó mucho.',
        'time': '5 min ago',
        'status': 'completed',
        'priority': 'normal',
        'messageCount': 8,
      },
      {
        'user': 'Usuario #789',
        'lastMessage': 'No puedo dormir, tengo pesadillas...',
        'time': '10 min ago',
        'status': 'active',
        'priority': 'urgent',
        'messageCount': 23,
      },
    ];

    return Column(
      children:
          conversations.map((conv) => _buildConversationTile(conv)).toList(),
    );
  }

  Widget _buildConversationTile(Map<String, dynamic> conversation) {
    Color priorityColor;
    switch (conversation['priority']) {
      case 'urgent':
        priorityColor = Colors.red;
        break;
      case 'high':
        priorityColor = Colors.orange;
        break;
      default:
        priorityColor = Colors.green;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AlegraColors.getSurface(isDarkMode),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AlegraColors.getBorder(isDarkMode), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: priorityColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      conversation['user'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AlegraColors.getTextPrimary(isDarkMode),
                      ),
                    ),
                    Text(
                      conversation['time'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AlegraColors.getTextSecondary(isDarkMode),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  conversation['lastMessage'] as String,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AlegraColors.getTextSecondary(isDarkMode),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: priorityColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        conversation['priority'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: priorityColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${conversation['messageCount']} mensajes',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: AlegraColors.getTextSecondary(isDarkMode),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AlegraColors.getTextSecondary(isDarkMode),
            ),
            onPressed: () {
              // Implementar navegación a conversación específica
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEntrenarIA(bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Entrenar Asistente IA',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AlegraColors.getTextPrimary(isDarkMode),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildTrainingSection()),
              if (isTablet) const SizedBox(width: 24),
              if (isTablet) Expanded(child: _buildResponseTemplates()),
            ],
          ),
          if (!isTablet) ...[
            const SizedBox(height: 24),
            _buildResponseTemplates(),
          ],
        ],
      ),
    );
  }

  Widget _buildTrainingSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AlegraColors.getSurface(isDarkMode),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AlegraColors.getBorder(isDarkMode), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Agregar Nueva Respuesta',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AlegraColors.getTextPrimary(isDarkMode),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              labelText: 'Pregunta/Situación del Usuario',
              hintText: 'Ej: Me siento muy ansioso',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: AlegraColors.getCard(isDarkMode),
            ),
            style: GoogleFonts.inter(
              color: AlegraColors.getTextPrimary(isDarkMode),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Respuesta Sugerida',
              hintText: 'Escribe una respuesta empática y útil...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: AlegraColors.getCard(isDarkMode),
            ),
            style: GoogleFonts.inter(
              color: AlegraColors.getTextPrimary(isDarkMode),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Categoría',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: AlegraColors.getCard(isDarkMode),
            ),
            items:
                ['Ansiedad', 'Depresión', 'Estrés', 'Motivación', 'Relaciones']
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ),
                    )
                    .toList(),
            onChanged: (value) {},
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Respuesta agregada exitosamente'),
                    backgroundColor: const Color(0xFF10B981),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D4FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Agregar Respuesta',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponseTemplates() {
    final templates = [
      {
        'category': 'Ansiedad',
        'trigger': 'me siento ansioso',
        'response':
            'Entiendo que te sientes ansioso. Es completamente normal...',
        'usage': 23,
      },
      {
        'category': 'Motivación',
        'trigger': 'no tengo ganas de nada',
        'response':
            'Comprendo que te sientes sin energía. Empecemos con pequeños pasos...',
        'usage': 18,
      },
      {
        'category': 'Estrés',
        'trigger': 'tengo mucho estrés',
        'response':
            'El estrés puede ser abrumador. Te sugiero algunas técnicas de respiración...',
        'usage': 31,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AlegraColors.getSurface(isDarkMode),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AlegraColors.getBorder(isDarkMode), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Plantillas Existentes',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AlegraColors.getTextPrimary(isDarkMode),
            ),
          ),
          const SizedBox(height: 16),
          ...templates.map((template) => _buildTemplateCard(template)).toList(),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(Map<String, dynamic> template) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AlegraColors.getCard(isDarkMode),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AlegraColors.getBorder(isDarkMode), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF00D4FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  template['category'] as String,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF00D4FF),
                  ),
                ),
              ),
              Text(
                'Usado ${template['usage']} veces',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: AlegraColors.getTextSecondary(isDarkMode),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Trigger: "${template['trigger']}"',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AlegraColors.getTextPrimary(isDarkMode),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            template['response'] as String,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AlegraColors.getTextSecondary(isDarkMode),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {},
                child: Text(
                  'Editar',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF00D4FF),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalisis(bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Análisis de Conversaciones',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AlegraColors.getTextPrimary(isDarkMode),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildSentimentAnalysis()),
              if (isTablet) const SizedBox(width: 24),
              if (isTablet) Expanded(child: _buildTopicAnalysis()),
            ],
          ),
          if (!isTablet) ...[const SizedBox(height: 24), _buildTopicAnalysis()],
          const SizedBox(height: 24),
          _buildTrendAnalysis(),
        ],
      ),
    );
  }

  Widget _buildSentimentAnalysis() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AlegraColors.getSurface(isDarkMode),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AlegraColors.getBorder(isDarkMode), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Análisis de Sentimientos',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AlegraColors.getTextPrimary(isDarkMode),
            ),
          ),
          const SizedBox(height: 24),
          _buildSentimentChart(),
        ],
      ),
    );
  }

  Widget _buildSentimentChart() {
    final sentiments = [
      {'label': 'Positivo', 'value': 35, 'color': const Color(0xFF10B981)},
      {'label': 'Neutral', 'value': 40, 'color': const Color(0xFFF59E0B)},
      {'label': 'Negativo', 'value': 25, 'color': const Color(0xFFEF4444)},
    ];

    return Column(
      children:
          sentiments.map((sentiment) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        sentiment['label'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AlegraColors.getTextPrimary(isDarkMode),
                        ),
                      ),
                      Text(
                        '${sentiment['value']}%',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: sentiment['color'] as Color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (sentiment['value'] as int) / 100,
                    backgroundColor: AlegraColors.getBorder(isDarkMode),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      sentiment['color'] as Color,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildTopicAnalysis() {
    final topics = [
      {'topic': 'Ansiedad', 'count': 45, 'trend': '+12%'},
      {'topic': 'Depresión', 'count': 32, 'trend': '-5%'},
      {'topic': 'Estrés Laboral', 'count': 28, 'trend': '+8%'},
      {'topic': 'Relaciones', 'count': 23, 'trend': '+3%'},
      {'topic': 'Autoestima', 'count': 19, 'trend': '-2%'},
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AlegraColors.getSurface(isDarkMode),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AlegraColors.getBorder(isDarkMode), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Temas Más Consultados',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AlegraColors.getTextPrimary(isDarkMode),
            ),
          ),
          const SizedBox(height: 16),
          ...topics.map((topic) => _buildTopicTile(topic)).toList(),
        ],
      ),
    );
  }

  Widget _buildTopicTile(Map<String, dynamic> topic) {
    final isPositive = (topic['trend'] as String).startsWith('+');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AlegraColors.getCard(isDarkMode),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AlegraColors.getBorder(isDarkMode), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            topic['topic'] as String,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AlegraColors.getTextPrimary(isDarkMode),
            ),
          ),
          Row(
            children: [
              Text(
                '${topic['count']}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AlegraColors.getTextPrimary(isDarkMode),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (isPositive ? Colors.green : Colors.red).withOpacity(
                    0.1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  topic['trend'] as String,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: isPositive ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendAnalysis() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AlegraColors.getSurface(isDarkMode),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AlegraColors.getBorder(isDarkMode), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tendencias Semanales',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AlegraColors.getTextPrimary(isDarkMode),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(height: 200, child: _buildTrendsChart()),
        ],
      ),
    );
  }

  Widget _buildTrendsChart() {
    final weekData = [12, 15, 18, 22, 19, 25, 28];
    final maxValue = weekData.reduce(math.max);
    final days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

    return Column(
      children: [
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(weekData.length, (index) {
              final value = weekData[index];
              final height = (value / maxValue) * 140 + 20;

              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 32,
                    height: height,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Color(0xFF10B981), Color(0xFF34D399)],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    days[index],
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AlegraColors.getTextSecondary(isDarkMode),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildAlertas(bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Alertas de Bienestar',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AlegraColors.getTextPrimary(isDarkMode),
            ),
          ),
          const SizedBox(height: 24),
          _buildAlertsList(),
        ],
      ),
    );
  }

  Widget _buildAlertsList() {
    final alerts = [
      {
        'user': 'Usuario #123',
        'alert': 'Múltiples menciones de pensamientos negativos',
        'severity': 'high',
        'time': '5 min ago',
        'messages': [
          'No puedo más con esto',
          'Todo sale mal',
          'No tengo esperanza',
        ],
      },
      {
        'user': 'Usuario #456',
        'alert': 'Signos de aislamiento social',
        'severity': 'medium',
        'time': '1 hora ago',
        'messages': [
          'No quiero salir',
          'Prefiero estar solo',
          'Cancelé todos mis planes',
        ],
      },
      {
        'user': 'Usuario #789',
        'alert': 'Posibles signos de crisis',
        'severity': 'urgent',
        'time': '30 min ago',
        'messages': [
          'Ya no encuentro salida',
          'Nada tiene sentido',
          'No sé qué hacer',
        ],
      },
    ];

    return Column(
      children: alerts.map((alert) => _buildAlertCard(alert)).toList(),
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert) {
    Color severityColor;
    IconData severityIcon;

    switch (alert['severity']) {
      case 'urgent':
        severityColor = const Color(0xFFDC2626);
        severityIcon = Icons.error;
        break;
      case 'high':
        severityColor = const Color(0xFFEA580C);
        severityIcon = Icons.warning;
        break;
      default:
        severityColor = const Color(0xFFF59E0B);
        severityIcon = Icons.info;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AlegraColors.getSurface(isDarkMode),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: severityColor.withOpacity(0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: severityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(severityIcon, color: severityColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert['user'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AlegraColors.getTextPrimary(isDarkMode),
                      ),
                    ),
                    Text(
                      alert['alert'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: severityColor,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                alert['time'] as String,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AlegraColors.getTextSecondary(isDarkMode),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Mensajes recientes:',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AlegraColors.getTextPrimary(isDarkMode),
            ),
          ),
          const SizedBox(height: 8),
          ...(alert['messages'] as List<String>)
              .map(
                (message) => Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AlegraColors.getCard(isDarkMode),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '"$message"',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: AlegraColors.getTextSecondary(isDarkMode),
                    ),
                  ),
                ),
              )
              .toList(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: severityColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Intervenir',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: severityColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Ver Conversación',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: severityColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfiguracion(bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configuración del Chat',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AlegraColors.getTextPrimary(isDarkMode),
            ),
          ),
          const SizedBox(height: 24),
          _buildConfigSection(),
        ],
      ),
    );
  }

  Widget _buildConfigSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AlegraColors.getSurface(isDarkMode),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AlegraColors.getBorder(isDarkMode), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configuraciones Generales',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AlegraColors.getTextPrimary(isDarkMode),
            ),
          ),
          const SizedBox(height: 24),
          _buildConfigItem(
            'Modo Automático',
            'Respuestas automáticas del asistente',
            true,
          ),
          _buildConfigItem(
            'Alertas de Riesgo',
            'Detectar automáticamente situaciones de riesgo',
            true,
          ),
          _buildConfigItem(
            'Análisis de Sentimientos',
            'Analizar emociones en tiempo real',
            true,
          ),
          _buildConfigItem(
            'Notificaciones Admin',
            'Recibir alertas importantes por email',
            false,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Configuración guardada'),
                    backgroundColor: const Color(0xFF10B981),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D4FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Guardar Configuración',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigItem(String title, String subtitle, bool initialValue) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AlegraColors.getTextPrimary(isDarkMode),
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AlegraColors.getTextSecondary(isDarkMode),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: initialValue,
            onChanged: (value) {},
            activeColor: const Color(0xFF00D4FF),
          ),
        ],
      ),
    );
  }
}

class AlegraColors {
  static const Color primary = Color(0xFF0EA5E9);
  static const Color secondary = Color(0xFF06B6D4);
  static const Color accent = Color(0xFFEC4899);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);

  static const Color lightBackground = Color(0xFFFAFBFF);
  static const Color lightSurface = Colors.white;
  static const Color lightCard = Color(0xFFF1F5F9);
  static const Color lightBorder = Color(0xFFE5E7EB);
  static const Color lightTextPrimary = Color(0xFF1F2937);
  static const Color lightTextSecondary = Color(0xFF6B7280);

  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkCard = Color(0xFF334155);
  static const Color darkBorder = Color(0xFF475569);
  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Color(0xFFCBD5E1);

  static Color getBackground(bool isDark) =>
      isDark ? darkBackground : lightBackground;
  static Color getSurface(bool isDark) => isDark ? darkSurface : lightSurface;
  static Color getCard(bool isDark) => isDark ? darkCard : lightCard;
  static Color getBorder(bool isDark) => isDark ? darkBorder : lightBorder;
  static Color getTextPrimary(bool isDark) =>
      isDark ? darkTextPrimary : lightTextPrimary;
  static Color getTextSecondary(bool isDark) =>
      isDark ? darkTextSecondary : lightTextSecondary;
}
