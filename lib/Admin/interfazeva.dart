import 'package:flutter/material.dart';
import 'apiregis.dart';

class EvaluacionForm extends StatefulWidget {
  const EvaluacionForm({super.key});

  @override
  State<EvaluacionForm> createState() => _EvaluacionFormState();
}

class _EvaluacionFormState extends State<EvaluacionForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController usuarioIdController = TextEditingController();
  final TextEditingController estadoEmocionalController =
      TextEditingController();
  final TextEditingController fechaEvaluacionController =
      TextEditingController();
  final TextEditingController observacionesController = TextEditingController();

  String nivelRiesgo = 'Bajo';
  final List<String> niveles = ['Bajo', 'Medio', 'Alto', 'Crítico'];

  void enviarEvaluacion() async {
    if (_formKey.currentState!.validate()) {
      try {
        await ApiService.enviarEvaluacionDesdeUrl(
          usuarioId: int.parse(usuarioIdController.text),
          nivelRiesgo: nivelRiesgo,
          estadoEmocional: estadoEmocionalController.text,
          fechaEvaluacion: fechaEvaluacionController.text,
          observaciones: observacionesController.text,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Evaluación enviada correctamente')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌ Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBFDCE5),
      appBar: AppBar(
        title: const Text("Registrar Evaluación"),
        backgroundColor: Colors.white,
        foregroundColor: const Color.fromARGB(255, 13, 34, 27),
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned(
            top: -40,
            left: -30,
            child: _buildAnimatedCircle(130, Colors.white.withOpacity(0.1)),
          ),
          Positioned(
            bottom: -50,
            right: -30,
            child: _buildAnimatedCircle(120, Colors.white.withOpacity(0.15)),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  _buildInputField(
                    controller: usuarioIdController,
                    label: 'ID de Usuario',
                    keyboardType: TextInputType.number,
                  ),
                  _buildDropdownField(),
                  _buildInputField(
                    controller: estadoEmocionalController,
                    label: 'Estado Emocional',
                  ),
                  _buildInputField(
                    controller: fechaEvaluacionController,
                    label: 'Fecha Evaluación (YYYY-MM-DDTHH:MM)',
                  ),
                  _buildInputField(
                    controller: observacionesController,
                    label: 'Observaciones',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton.icon(
                    onPressed: enviarEvaluacion,
                    icon: const Icon(Icons.send),
                    label: const Text('Enviar Evaluación'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A90A4),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(fontSize: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      foregroundColor: Colors.white,
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(color: Color.fromARGB(255, 20, 36, 35)),
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
      ),
    );
  }

  Widget _buildDropdownField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: nivelRiesgo,
        decoration: InputDecoration(
          labelText: 'Nivel de Riesgo',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onChanged: (value) => setState(() => nivelRiesgo = value!),
        items:
            niveles
                .map(
                  (nivel) => DropdownMenuItem(value: nivel, child: Text(nivel)),
                )
                .toList(),
      ),
    );
  }

  Widget _buildAnimatedCircle(double size, Color color) {
    return AnimatedContainer(
      duration: const Duration(seconds: 3),
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
