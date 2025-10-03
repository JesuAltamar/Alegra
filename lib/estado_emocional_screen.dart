import 'package:flutter/material.dart';
import 'Registros_usuarios_y_evaluaciones/evaluacion_model.dart';
import 'Registros_usuarios_y_evaluaciones/evaluacion_service.dart';

class EstadoEmocionalScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Evaluaciones de Riesgo')),
      body: FutureBuilder<List<Evaluacion>>(
        future: fetchEvaluaciones(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay evaluaciones registradas.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final evaluacion = snapshot.data![index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text('Usuario ID: ${evaluacion.usuarioId}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nivel de riesgo: ${evaluacion.nivelRiesgo}'),
                        Text('Estado emocional: ${evaluacion.estadoEmocional}'),
                        Text('Fecha: ${evaluacion.fechaEvaluacion}'),
                        Text('Observaciones: ${evaluacion.observaciones}'),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
