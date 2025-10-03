import 'package:flutter/material.dart';

class EstrategiasPage extends StatelessWidget {
  final List<Map<String, dynamic>> estrategias = [
    {
      "titulo": "Respiración Profunda",
      "descripcion": "Una técnica simple para calmar tu sistema nervioso.",
      "icono": Icons.air,
      "contenido": """
Encuentra un lugar tranquilo. Siéntate o acuéstate cómodamente.

1. Cierra los ojos suavemente.
2. Inhala lentamente por la nariz contando hasta 4. Siente cómo tu abdomen se expande.
3. Sostén la respiración contando hasta 4.
4. Exhala lentamente por la boca contando hasta 6. Siente cómo tu abdomen se contrae.
5. Repite este ciclo durante 3-5 minutos.

Concéntrate en el ritmo de tu respiración y deja que tus pensamientos pasen sin juzgarlos.
""",
    },
    {
      "titulo": "Anclaje 5-4-3-2-1",
      "descripcion": "Conéctate con el presente a través de tus sentidos.",
      "icono": Icons.center_focus_strong,
      "contenido": """
Cuando sientas ansiedad o desconexión, utiliza tus sentidos:

1. Observa 5 cosas que puedas ver a tu alrededor.
2. Toca 4 cosas que puedas sentir con tus manos.
3. Escucha 3 sonidos en el ambiente.
4. Huele 2 aromas cercanos.
5. Prueba 1 cosa que puedas saborear.

Esta técnica ayuda a traer tu mente al momento presente y disminuir la ansiedad.
""",
    },
    {
      "titulo": "Afirmaciones Positivas",
      "descripcion": "Refuerza una mentalidad positiva y de autoestima.",
      "icono": Icons.emoji_emotions,
      "contenido": """
Repite frases que refuercen tu confianza y bienestar:

- "Soy capaz de superar los retos".
- "Merezco tranquilidad y paz".
- "Confío en mi capacidad de seguir adelante".

Hazlo frente al espejo o en voz baja, al menos 5 minutos al día.
""",
    },
    {
      "titulo": "Escucha Activa de Sonidos",
      "descripcion": "Enfoca tu mente en los sonidos a tu alrededor.",
      "icono": Icons.headphones,
      "contenido": """
Busca un lugar tranquilo y cierra los ojos:

1. Concéntrate en los sonidos a tu alrededor, cercanos o lejanos.
2. Identifica al menos 5 sonidos distintos.
3. No juzgues ni intentes cambiar lo que escuchas, solo obsérvalo.
4. Permanece en este ejercicio de 3 a 5 minutos.

Este ejercicio ayuda a calmar la mente y a mejorar la concentración.
""",
    },
  ];

  void _mostrarPractica(BuildContext context, String titulo, String contenido) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Icon(Icons.tips_and_updates, color: Colors.blue, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    titulo,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20, // título más grande
                    ),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Text(
                contenido,
                style: const TextStyle(
                  fontSize: 16, // texto más grande
                  height: 1.6,
                ),
              ),
            ),
            actions: [
              TextButton(
                child: const Text(
                  "Cerrar",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Estrategias de Afrontamiento")),
      body: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = constraints.maxWidth < 600 ? 1 : 2;

          // 👇 Ajuste de tamaño de tarjetas según pantalla
          double childAspectRatio =
              constraints.maxWidth < 600 ? 1.2 : 1.8; // más pequeñas en PC

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: childAspectRatio,
            ),
            itemCount: estrategias.length,
            itemBuilder: (context, index) {
              final estrategia = estrategias[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(estrategia["icono"], size: 36, color: Colors.blue),
                      Text(
                        estrategia["titulo"],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        estrategia["descripcion"],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      ElevatedButton(
                        onPressed:
                            () => _mostrarPractica(
                              context,
                              estrategia["titulo"],
                              estrategia["contenido"],
                            ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(120, 36),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Practicar ahora",
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
