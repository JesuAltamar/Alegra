import 'package:flutter/material.dart';

class SoporteScreen extends StatefulWidget {
  @override
  _SoporteTecnicoState createState() => _SoporteTecnicoState();
}

class _SoporteTecnicoState extends State<SoporteScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> supportMessages = [];

  void _sendSupportMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        supportMessages.add({'message': text, 'resolved': false});
        _messageController.clear();
      });
    }
  }

  void _toggleResolved(int index) {
    setState(() {
      supportMessages[index]['resolved'] = !supportMessages[index]['resolved'];
    });
  }

  void _deleteMessage(int index) {
    setState(() {
      supportMessages.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Soporte Técnico"),
        centerTitle: true,
        foregroundColor: const Color(0xFF024731),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Fondo degradado como el main
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE8F5F7), Color(0xFFF1FDF2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Figuras decorativas estilo main
          Positioned(
            top: 40,
            left: -20,
            child: _buildAnimatedCircle(
              100,
              Colors.cyanAccent.withOpacity(0.3),
            ),
          ),
          Positioned(
            bottom: 100,
            right: -30,
            child: _buildAnimatedCircle(
              90,
              Colors.orangeAccent.withOpacity(0.3),
            ),
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
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Soporte Técnico',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D221B),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Describe tu problema o consulta:',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _messageController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Escribe aquí...',
                      hintStyle: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _sendSupportMessage,
                    icon: const Icon(Icons.send),
                    label: const Text('Enviar mensaje'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      elevation: 3,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Historial de mensajes:',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black.withOpacity(0.7),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child:
                        supportMessages.isEmpty
                            ? Center(
                              child: Text(
                                'No hay mensajes aún.',
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.black.withOpacity(0.6),
                                ),
                              ),
                            )
                            : ListView.builder(
                              itemCount: supportMessages.length,
                              itemBuilder: (context, index) {
                                final msg = supportMessages[index];
                                return Card(
                                  color:
                                      msg['resolved']
                                          ? Colors.green[50]
                                          : Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 3,
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      msg['message'],
                                      style: const TextStyle(
                                        color: Colors.black87,
                                      ),
                                    ),
                                    subtitle: Text(
                                      msg['resolved']
                                          ? 'Resuelto'
                                          : 'Pendiente',
                                      style: TextStyle(
                                        color:
                                            msg['resolved']
                                                ? Colors.green
                                                : Colors.orange,
                                      ),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            Icons.check_circle,
                                            color:
                                                msg['resolved']
                                                    ? Colors.green
                                                    : Colors.grey,
                                          ),
                                          onPressed:
                                              () => _toggleResolved(index),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.redAccent,
                                          ),
                                          onPressed:
                                              () => _deleteMessage(index),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              ),
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
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
