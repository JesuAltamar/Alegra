import 'package:flutter/material.dart';

class ConfiguracionSistemaScreen extends StatefulWidget {
  @override
  _ConfiguracionSistemaScreenState createState() =>
      _ConfiguracionSistemaScreenState();
}

class _ConfiguracionSistemaScreenState
    extends State<ConfiguracionSistemaScreen> {
  bool notificacionesHabilitadas = true;
  bool copiasAutomaticas = false;
  String frecuenciaCopia = 'Semanal';
  final List<String> opcionesFrecuencia = ['Diaria', 'Semanal', 'Mensual'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Configuración del sistema"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF024731),
      ),
      body: Stack(
        children: [
          // Fondo degradado igual que el main
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE8F5F7), Color(0xFFF1FDF2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Circulitos decorativos como en el main
          Positioned(
            top: 50,
            left: -20,
            child: _buildAnimatedCircle(
              100,
              Colors.cyanAccent.withOpacity(0.3),
            ),
          ),
          Positioned(
            right: 20,
            top: 150,
            child: _buildAnimatedCircle(80, Colors.amber.withOpacity(0.3)),
          ),
          Positioned(
            bottom: 30,
            left: 80,
            child: _buildAnimatedCircle(
              70,
              Colors.purpleAccent.withOpacity(0.3),
            ),
          ),

          // Contenido
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSectionTitle('Información del sistema'),
                _buildInfoCard('Versión de la app', '1.0.0'),
                _buildInfoCard('Última actualización', 'Abril 2025'),
                const SizedBox(height: 20),

                _buildSectionTitle('Parámetros del sistema'),
                SwitchListTile(
                  title: const Text('Notificaciones habilitadas'),
                  value: notificacionesHabilitadas,
                  onChanged: (value) {
                    setState(() {
                      notificacionesHabilitadas = value;
                    });
                  },
                  activeColor: Colors.teal,
                ),
                const SizedBox(height: 10),

                _buildSectionTitle('Seguridad'),
                ListTile(
                  leading: const Icon(Icons.lock, color: Colors.teal),
                  title: const Text('Cambiar contraseña de administrador'),
                  onTap: () {
                    _mostrarDialogo('Función no disponible aún');
                  },
                ),
                const Divider(),

                _buildSectionTitle('Respaldo de datos'),
                SwitchListTile(
                  title: const Text(
                    'Habilitar copias de seguridad automáticas',
                  ),
                  value: copiasAutomaticas,
                  onChanged: (value) {
                    setState(() {
                      copiasAutomaticas = value;
                    });
                  },
                  activeColor: Colors.teal,
                ),
                if (copiasAutomaticas)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DropdownButtonFormField<String>(
                      value: frecuenciaCopia,
                      decoration: InputDecoration(
                        labelText: 'Frecuencia de copia',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items:
                          opcionesFrecuencia
                              .map(
                                (opcion) => DropdownMenuItem(
                                  value: opcion,
                                  child: Text(opcion),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          frecuenciaCopia = value!;
                        });
                      },
                    ),
                  ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.cloud_download),
                  label: const Text('Realizar copia de seguridad ahora'),
                  onPressed: () {
                    _mostrarDialogo('Copia de seguridad iniciada');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
                const SizedBox(height: 10),

                _buildSectionTitle('Restaurar datos'),
                ElevatedButton.icon(
                  icon: const Icon(Icons.restore),
                  label: const Text('Restaurar desde copia'),
                  onPressed: () {
                    _mostrarDialogo('Funcionalidad en desarrollo');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ],
            ),
          ),

          // Botón flotante de regreso
          Positioned(
            bottom: 20,
            left: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              foregroundColor: Colors.teal,
              onPressed: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedCircle(double size, Color color) {
    return AnimatedContainer(
      duration: const Duration(seconds: 3),
      curve: Curves.easeInOut,
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          color: Colors.black87,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String content) {
    return Card(
      color: Colors.white.withOpacity(0.9),
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: const Icon(Icons.info_outline, color: Colors.teal),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(content),
      ),
    );
  }

  void _mostrarDialogo(String mensaje) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Información'),
            content: Text(mensaje),
            actions: [
              TextButton(
                child: const Text('Cerrar'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
    );
  }
}
