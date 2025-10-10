// lib/Admin/gestion_chat_admin.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GestionChatAdmin extends StatefulWidget {
  @override
  _GestionChatAdminState createState() => _GestionChatAdminState();
}

class _GestionChatAdminState extends State<GestionChatAdmin> {
  final Color deepPurple = Color(0xFF2D1B69);
  final Color vibrantPurple = Color(0xFF6366F1);
  final Color lightPurple = Color(0xFFA855F7);
  final Color darkBackground = Color(0xFF0F0A1F);
  final Color cardDark = Color(0xFF1A1335);
  final Color accentPink = Color(0xFFEC4899);
  final Color softWhite = Color(0xFFF8FAFC);
  final Color mentalhealthGreen = Color(0xFF10B981);
  final Color crisisRed = Color(0xFFEF4444);
  final Color warningOrange = Color(0xFFFF9800);

  bool isDarkMode = false;
  bool isLoading = true;
  
  Map<String, dynamic> sentimientos = {};
  List<Map<String, dynamic>> temas = [];
  List<Map<String, dynamic>> tendencias = [];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => isLoading = true);
    
    try {
      await Future.wait([
        _cargarSentimientos(),
        _cargarTemas(),
        _cargarTendencias(),
      ]);
    } catch (e) {
      print('Error cargando datos: $e');
    }
    
    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _cargarSentimientos() async {
    try {
      final response = await http.get(
        Uri.parse('https://backendproyecto-producción-4a8d.up.railway.app/api/admin/chat/sentimientos?dias=30'),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            sentimientos = data;
          });
        }
      }
    } catch (e) {
      print('Error cargando sentimientos: $e');
    }
  }

  Future<void> _cargarTemas() async {
    try {
      final response = await http.get(
        Uri.parse('https://backendproyecto-producción-4a8d.up.railway.app/api/admin/chat/temas?limit=5'),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            temas = List<Map<String, dynamic>>.from(data['temas']);
          });
        }
      }
    } catch (e) {
      print('Error cargando temas: $e');
    }
  }

  Future<void> _cargarTendencias() async {
    try {
      final response = await http.get(
        Uri.parse('https://backendproyecto-producción-4a8d.up.railway.app/api/admin/chat/tendencias'),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            tendencias = List<Map<String, dynamic>>.from(data['tendencias']);
          });
        }
      }
    } catch (e) {
      print('Error cargando tendencias: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? darkBackground : softWhite,
      appBar: AppBar(
        backgroundColor: isDarkMode ? cardDark : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDarkMode ? softWhite : deepPurple),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Gestión del Chat',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: isDarkMode ? softWhite : deepPurple,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: isDarkMode ? accentPink : vibrantPurple,
            ),
            onPressed: () => setState(() => isDarkMode = !isDarkMode),
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: vibrantPurple),
            onPressed: _cargarDatos,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [darkBackground, deepPurple.withOpacity(0.3), darkBackground],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [softWhite, vibrantPurple.withOpacity(0.05)],
                ),
        ),
        child: isLoading
            ? Center(child: CircularProgressIndicator(color: vibrantPurple))
            : RefreshIndicator(
                onRefresh: _cargarDatos,
                color: vibrantPurple,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSentimientosCard(),
                      SizedBox(height: 24),
                      _buildTemasCard(),
                      SizedBox(height: 24),
                      _buildTendenciasCard(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

 Widget _buildSentimientosCard() {
  final porcentajes = sentimientos['porcentajes'] ?? {};
  
  // Conversión segura a double
  double toDoubleValue(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  final positivo = toDoubleValue(porcentajes['positivo']);
  final neutral = toDoubleValue(porcentajes['neutral']);
  final negativo = toDoubleValue(porcentajes['negativo']);

  return Container(
    padding: EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: isDarkMode ? cardDark.withOpacity(0.95) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isDarkMode ? vibrantPurple.withOpacity(0.2) : deepPurple.withOpacity(0.1),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Análisis de Sentimientos',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDarkMode ? softWhite : deepPurple,
          ),
        ),
        SizedBox(height: 24),
        _buildSentimientoBar('Positivo', positivo, mentalhealthGreen),
        SizedBox(height: 16),
        _buildSentimientoBar('Neutral', neutral, warningOrange),
        SizedBox(height: 16),
        _buildSentimientoBar('Negativo', negativo, crisisRed),
      ],
    ),
  );
}
  Widget _buildSentimientoBar(String label, double porcentaje, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? softWhite : deepPurple,
              ),
            ),
            Text(
              '${porcentaje.toStringAsFixed(0)}%',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: porcentaje / 100,
            minHeight: 12,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildTemasCard() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode ? cardDark.withOpacity(0.95) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? vibrantPurple.withOpacity(0.2) : deepPurple.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Temas Más Consultados',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDarkMode ? softWhite : deepPurple,
            ),
          ),
          SizedBox(height: 24),
          if (temas.isEmpty)
            Center(
              child: Text(
                'No hay datos disponibles',
                style: GoogleFonts.inter(
                  color: isDarkMode ? softWhite.withOpacity(0.6) : deepPurple.withOpacity(0.6),
                ),
              ),
            )
          else
            ...temas.map((tema) => _buildTemaItem(tema)).toList(),
        ],
      ),
    );
  }

  Widget _buildTemaItem(Map<String, dynamic> tema) {
    final nombre = _capitalizarTema(tema['tema']);
    final contador = tema['contador'];
    final maxContador = temas.isNotEmpty 
        ? temas.map((t) => t['contador'] as int).reduce((a, b) => a > b ? a : b)
        : 1;
    final porcentaje = (contador / maxContador * 100).toDouble();

    // Calcular cambio (simulado para demostración)
    final cambio = (contador % 5) - 2;
    final textoCambio = cambio > 0 ? '+$cambio%' : cambio < 0 ? '$cambio%' : '0%';
    final colorCambio = cambio > 0 ? mentalhealthGreen : cambio < 0 ? crisisRed : warningOrange;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? darkBackground.withOpacity(0.5) : lightPurple.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? vibrantPurple.withOpacity(0.2) : deepPurple.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      nombre,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? softWhite : deepPurple,
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorCambio.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        textoCambio,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colorCambio,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: porcentaje / 100,
                    minHeight: 6,
                    backgroundColor: vibrantPurple.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(vibrantPurple),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
          Text(
            '$contador',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: vibrantPurple,
            ),
          ),
        ],
      ),
    );
  }

  String _capitalizarTema(String tema) {
    return tema.split('_').map((palabra) {
      return palabra[0].toUpperCase() + palabra.substring(1);
    }).join(' ');
  }

  Widget _buildTendenciasCard() {
    if (tendencias.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode ? cardDark.withOpacity(0.95) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? vibrantPurple.withOpacity(0.2) : deepPurple.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tendencias Semanales',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDarkMode ? softWhite : deepPurple,
            ),
          ),
          SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: _buildTendenciasChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildTendenciasChart() {
    final spots = tendencias
        .asMap()
        .entries
        .map((entry) => FlSpot(
              entry.key.toDouble(),
              (entry.value['total_mensajes'] ?? 0).toDouble(),
            ))
        .toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < tendencias.length) {
                  return Text(
                    tendencias[value.toInt()]['dia'],
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isDarkMode
                          ? softWhite.withOpacity(0.6)
                          : deepPurple.withOpacity(0.6),
                    ),
                  );
                }
                return Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: mentalhealthGreen,
            barWidth: 3,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: mentalhealthGreen.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }
}