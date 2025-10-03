import 'package:flutter/material.dart';

class AprenderPage extends StatelessWidget {
  const AprenderPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[700], size: 24),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Ánimo',
          style: TextStyle(
            color: Colors.blue[300],
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.orange[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: Icon(Icons.person, color: Colors.white),
              onPressed: () {},
            ),
          ),
          IconButton(
            icon: Icon(Icons.menu, color: Colors.grey[600]),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Biblioteca Educativa',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Conocimiento para empoderarte a ti y a\nquienes te rodean.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),

              // Card 1: Entendiendo la Depresión
              _buildEducationalCard(
                context,
                LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue[300]!, Colors.indigo[400]!],
                ),
                Icons.psychology,
                'Entendiendo la Depresión',
                'Aprende sobre los síntomas, causas y tratamientos\nde la depresión.',
                () => _showDepressionInfo(context),
              ),
              SizedBox(height: 16),

              // Card 2: La Importancia del Autocuidado
              _buildEducationalCard(
                context,
                LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.green[300]!, Colors.teal[400]!],
                ),
                Icons.self_improvement,
                'La Importancia del Autocuidado',
                'Descubre por qué cuidarte a ti mismo es\nfundamental para tu salud mental.',
                () => _showSelfCareInfo(context),
              ),
              SizedBox(height: 16),

              // Card 3: Cómo Apoyar a un Ser Querido
              _buildEducationalCard(
                context,
                LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.orange[300]!, Colors.deepOrange[400]!],
                ),
                Icons.favorite,
                'Cómo Apoyar a un Ser Querido',
                'Consejos para ofrecer apoyo de manera efectiva y\ncompasiva.',
                () => _showSupportInfo(context),
              ),
              SizedBox(height: 16),

              // Card 4: Mitos y Realidades de la Terapia
              _buildEducationalCard(
                context,
                LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.purple[300]!, Colors.deepPurple[400]!],
                ),
                Icons.healing,
                'Mitos y Realidades de la Terapia',
                'Derribando estigmas y misconcepciones sobre la\nterapia psicológica.',
                () => _showTherapyInfo(context),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEducationalCard(
    BuildContext context,
    LinearGradient gradient,
    IconData icon,
    String title,
    String description,
    VoidCallback onPressed,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gradiente decorativo
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: gradient,
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 80,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black87,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.menu_book, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Leer más',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDepressionInfo(BuildContext context) {
    _showDetailModal(
      context,
      'Entendiendo la Depresión',
      '''La depresión es mucho más que sentirse triste ocasionalmente. Es un trastorno del estado de ánimo que afecta cómo te sientes, piensas y manejas las actividades diarias. 🧠

**Síntomas principales:**
😢 Tristeza persistente o sensación de vacío
🚫 Pérdida de interés en actividades que antes disfrutabas
🍽️ Cambios en el apetito y el peso
😴 Problemas para dormir o dormir demasiado
⚡ Fatiga y pérdida de energía
💭 Sentimientos de inutilidad o culpa excesiva
🤔 Dificultad para concentrarse
☁️ Pensamientos de muerte o suicidio

**Causas comunes:**
La depresión puede ser causada por una combinación de factores genéticos 🧬, biológicos 🔬, ambientales 🌍 y psicológicos 🧠. Eventos traumáticos, estrés crónico, ciertos medicamentos y condiciones médicas también pueden contribuir.

**Tratamientos efectivos:**
💬 Terapia psicológica (cognitivo-conductual, interpersonal)
💊 Medicamentos antidepresivos cuando son necesarios
🏃‍♀️ Cambios en el estilo de vida (ejercicio, nutrición, sueño)
🧘‍♀️ Técnicas de mindfulness y relajación
🤝 Apoyo social y grupos de autoayuda

**Recuerda:** La depresión es tratable ✅. Si experimentas varios de estos síntomas durante más de dos semanas, es importante buscar ayuda profesional 👩‍⚕️. No estás solo en esto 💙.''',
    );
  }

  void _showSelfCareInfo(BuildContext context) {
    _showDetailModal(
      context,
      'La Importancia del Autocuidado',
      '''El autocuidado no es un lujo, es una necesidad fundamental para mantener tu bienestar mental, físico y emocional. 💖

**¿Qué es el autocuidado?**
Son las acciones deliberadas que tomas para cuidar tu salud mental, emocional y física. No es egoísmo, es responsabilidad personal. 🌟

**Dimensiones del autocuidado:**

**Físico:**
🏃‍♀️ Mantener una rutina de ejercicio regular
🥗 Comer alimentos nutritivos
😴 Dormir 7-9 horas por noche
💧 Hidratarse adecuadamente
🩺 Realizar chequeos médicos regulares

**Mental:**
🧘‍♀️ Practicar mindfulness o meditación
📚 Leer libros que nutran tu mente
🎯 Aprender nuevas habilidades
📺 Limitar el consumo de noticias negativas
📱 Desconectarte de dispositivos regularmente

**Emocional:**
💬 Expresar tus sentimientos de manera saludable
🚧 Establecer límites claros con otros
🤗 Practicar la autocompasión
🛋️ Buscar terapia cuando sea necesario
❤️ Cultivar relaciones positivas

**Social:**
👥 Mantener conexiones significativas
🗣️ Comunicarte abiertamente
🤲 Pedir ayuda cuando la necesites
🏘️ Participar en actividades comunitarias
🤝 Establecer relaciones saludables

**Beneficios del autocuidado:**
😌 Reduce el estrés y la ansiedad
✨ Mejora la autoestima y confianza
⚡ Aumenta la energía y productividad
🛡️ Fortalece el sistema inmunológico
💞 Mejora las relaciones interpersonales

**Consejos prácticos:**
⏰ Programa tiempo para ti mismo diariamente
🙅‍♀️ Aprende a decir "no" sin sentirte culpable
🔋 Identifica qué actividades te recargan
📅 Crea rutinas que disfrutes
⚖️ Sé consistente pero flexible contigo mismo

Recuerda: Cuidarte no es egoísta, es esencial para poder cuidar a otros y vivir una vida plena. 🌈''',
    );
  }

  void _showSupportInfo(BuildContext context) {
    _showDetailModal(
      context,
      'Cómo Apoyar a un Ser Querido',
      '''Apoyar a alguien que está pasando por dificultades emocionales requiere empatía, paciencia y las herramientas adecuadas. 🤗

**Principios fundamentales:**

**1. Escucha sin juzgar** 👂
👁️ Presta atención completa cuando hablen
🚫 No interrumpas ni ofrezcas soluciones inmediatas
✅ Valida sus sentimientos: "Entiendo que esto debe ser muy difícil"
❌ Evita frases como "al menos..." o "podrías intentar..."

**2. Ofrece presencia, no consejos** 🤲
🫂 A veces solo necesitan que alguien esté ahí
❓ Pregunta: "¿Necesitas que te escuche o quieres consejos?"
💎 Tu presencia puede ser más valiosa que cualquier palabra

**3. Respeta sus tiempos y procesos** ⏳
🚫 No presiones para que "se mejoren" rápidamente
🐌 Cada persona tiene su ritmo de sanación
📈 Mantén la consistencia en tu apoyo

**Qué SÍ hacer:**
❓ Pregunta específicamente: "¿Cómo puedo ayudarte?"
🍲 Ofrece ayuda práctica: cocinar, limpiar, acompañar a citas
📞 Mantén el contacto regular pero no invasivo
🎮 Comparte actividades que disfruten juntos
📖 Infórmate sobre lo que están viviendo
💚 Cuida también tu propio bienestar

**Qué NO hacer:**
🚫 No minimices sus sentimientos
🚫 No hagas comparaciones con otros
🚫 No asumas que sabes lo que necesitan
🚫 No tomes su comportamiento como algo personal
🚫 No los presiones para hablar si no quieren

**Señales de alarma:** 🚨
Si mencionan autolesión o pensamientos suicidas, tómalo en serio y busca ayuda profesional inmediatamente.

**Recursos útiles:**
📞 Líneas de crisis emocional
👩‍⚕️ Profesionales de salud mental
👥 Grupos de apoyo
🏥 Organizaciones de salud mental

Recuerda: No eres responsable de "arreglar" a la otra persona, pero tu apoyo puede marcar una gran diferencia. 💫''',
    );
  }

  void _showTherapyInfo(BuildContext context) {
    _showDetailModal(
      context,
      'Mitos y Realidades de la Terapia',
      '''La terapia psicológica está rodeada de muchos mitos que impiden que las personas busquen la ayuda que necesitan. Vamos a aclarar estos conceptos erróneos. 🧩

**MITOS vs REALIDADES:**

**Mito:** "La terapia es solo para personas con problemas graves" ❌
**Realidad:** La terapia beneficia a cualquier persona que quiera mejorar su bienestar, desarrollar habilidades o enfrentar desafíos de la vida. ✅

**Mito:** "Si voy a terapia, significa que soy débil" ❌
**Realidad:** Buscar terapia requiere valentía y es una muestra de fortaleza y autoconocimiento. 💪

**Mito:** "El terapeuta me va a juzgar" ❌
**Realidad:** Los terapeutas están entrenados para ofrecer un espacio libre de juicios, seguro y confidencial. 🤐

**Mito:** "La terapia dura para siempre" ❌
**Realidad:** La duración varía según las necesidades individuales. Algunas personas ven mejoras en pocas sesiones. ⏰

**Mito:** "Hablar con amigos es lo mismo que terapia" ❌
**Realidad:** Aunque el apoyo de amigos es valioso, los terapeutas tienen entrenamiento especializado y técnicas específicas. 🎓

**Beneficios reales de la terapia:**
🛠️ Desarrollar estrategias de afrontamiento efectivas
✨ Mejorar la autoestima y autoconocimiento
🎭 Aprender a manejar emociones difíciles
💞 Mejorar relaciones interpersonales
🩹 Procesar traumas y experiencias dolorosas
🎯 Establecer metas y crear cambios positivos

**Tipos de terapia:**
🧠 Cognitivo-conductual (CBT)
🌱 Terapia humanística
🔍 Terapia psicodinámica
👨‍👩‍👧‍👦 Terapia familiar y de pareja
👥 Terapia de grupo

**Cómo elegir un terapeuta:**
📋 Verifica sus credenciales y especialidades
😊 Busca alguien con quien te sientas cómodo
🎯 Considera el tipo de terapia que mejor se adapte a ti
🔄 No tengas miedo de cambiar si no es la persona adecuada

**Cuándo considerar terapia:**
⚠️ Cuando sientes que tus problemas interfieren con tu vida diaria
🌊 Si experimentas emociones intensas que no puedes manejar
📈 Para crecer personalmente y mejorar relaciones
💥 Después de eventos traumáticos o cambios importantes
🔧 Cuando otros métodos de afrontamiento no han funcionado

La terapia es una inversión en tu bienestar y calidad de vida. No hay vergüenza en buscar ayuda profesional. 🌟''',
    );
  }

  void _showDetailModal(BuildContext context, String title, String content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 50,
              height: 5,
              margin: EdgeInsets.only(top: 15),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            
            // Header mejorado
            Container(
              padding: EdgeInsets.all(25),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey[200]!, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.blue[200]!, width: 1),
                          ),
                          child: Text(
                            'Guía Educativa',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: Colors.grey[600], size: 22),
                      splashRadius: 20,
                    ),
                  ),
                ],
              ),
            ),
            
            // Contenido mejorado
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(25),
                child: _buildFormattedContent(content),
              ),
            ),
            
            // Footer mejorado
            Container(
              padding: EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(
                  top: BorderSide(color: Colors.grey[200]!, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[500],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 18),
                        elevation: 2,
                        shadowColor: Colors.blue[200],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Entendido',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormattedContent(String content) {
    List<String> lines = content.split('\n');
    List<Widget> widgets = [];
    
    for (String line in lines) {
      if (line.trim().isEmpty) {
        widgets.add(SizedBox(height: 12));
      } else if (line.startsWith('**') && line.endsWith('**')) {
        // Títulos principales
        widgets.add(
          Container(
            margin: EdgeInsets.only(top: 20, bottom: 12),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[50]!, Colors.indigo[50]!],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[100]!, width: 1),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.blue[600], size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    line.replaceAll('**', ''),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (line.startsWith('• ')) {
        // Items de lista
        widgets.add(
          Container(
            margin: EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 8, right: 12),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.blue[400],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                Expanded(
                  child: Text(
                    line.substring(2),
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (line.contains('Mito:') || line.contains('Realidad:')) {
        // Mitos y realidades
        bool isMito = line.contains('Mito:');
        widgets.add(
          Container(
            margin: EdgeInsets.only(bottom: 12),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isMito ? Colors.red[50] : Colors.green[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isMito ? Colors.red[200]! : Colors.green[200]!,
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isMito ? Icons.cancel_outlined : Icons.check_circle_outline,
                  color: isMito ? Colors.red[600] : Colors.green[600],
                  size: 20,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    line,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.4,
                      color: isMito ? Colors.red[800] : Colors.green[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        // Texto normal
        widgets.add(
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Text(
              line,
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color: Colors.grey[800],
              ),
            ),
          ),
        );
      }
    }
    
    // Agregar nota final
    widgets.add(
      Container(
        margin: EdgeInsets.only(top: 30),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.amber[50]!, Colors.orange[50]!],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange[200]!, width: 1),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Esta información es educativa. Para casos específicos, consulta siempre con un profesional de la salud mental.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.orange[800],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
}