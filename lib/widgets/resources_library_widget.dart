// widgets/resources_library_widget.dart
import 'package:flutter/material.dart';
import '../services/local_storage_service.dart';

class ResourcesLibraryWidget extends StatefulWidget {
  final bool isDarkMode;
  final Color deepPurple;
  final Color vibrantPurple;
  final Color lightPurple;
  final Color darkBackground;
  final Color cardDark;
  final Color accentPink;
  final Color softWhite;
  final Color mentalhealthGreen;
  final Color cloudBlue;

  const ResourcesLibraryWidget({
    super.key,
    required this.isDarkMode,
    required this.deepPurple,
    required this.vibrantPurple,
    required this.lightPurple,
    required this.darkBackground,
    required this.cardDark,
    required this.accentPink,
    required this.softWhite,
    required this.mentalhealthGreen,
    required this.cloudBlue,
  });

  @override
  State<ResourcesLibraryWidget> createState() => _ResourcesLibraryWidgetState();
}

class _ResourcesLibraryWidgetState extends State<ResourcesLibraryWidget>
    with SingleTickerProviderStateMixin {
  String _selectedCategory = 'Todo';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  Set<String> _completedResources = {};

  final List<String> categories = [
    'Todo',
    'Técnicas',
    'Lectura',
    'Ejercicios'
  ];

  final List<Map<String, dynamic>> resources = [
    // Técnicas de Respiración
    {
      'id': 'tec_1',
      'title': 'Respiración 4-7-8',
      'subtitle': 'Técnica para reducir ansiedad',
      'duration': '5 min',
      'category': 'Técnicas',
      'icon': Icons.air,
      'color': Color(0xFF06B6D4),
      'type': 'technique',
      'content': '''Esta técnica de respiración ayuda a calmar el sistema nervioso.

**Pasos:**
1. Exhala completamente por la boca
2. Inhala por la nariz contando hasta 4
3. Mantén la respiración contando hasta 7
4. Exhala por la boca contando hasta 8
5. Repite el ciclo 3-4 veces

**Beneficios:**
- Reduce ansiedad inmediata
- Mejora la calidad del sueño
- Calma el sistema nervioso
- Ayuda con ataques de pánico

**Cuándo usarla:**
- Antes de dormir
- Durante momentos de estrés
- Al sentir ansiedad
- Para prepararte antes de situaciones difíciles''',
    },
    {
      'id': 'tec_2',
      'title': 'Grounding 5-4-3-2-1',
      'subtitle': 'Conecta con el presente',
      'duration': '5 min',
      'category': 'Técnicas',
      'icon': Icons.accessibility_new,
      'color': Color(0xFF10B981),
      'type': 'technique',
      'content': '''Técnica de grounding para anclarte al momento presente.

**Cómo practicarla:**

**5 cosas que puedes VER:**
Mira a tu alrededor e identifica 5 objetos. Nota sus colores, formas y detalles.

**4 cosas que puedes TOCAR:**
Siente 4 texturas diferentes. Puede ser tu ropa, una mesa, tu cabello, etc.

**3 cosas que puedes ESCUCHAR:**
Identifica 3 sonidos en tu entorno, cercanos o lejanos.

**2 cosas que puedes OLER:**
Reconoce 2 aromas. Si no hay ninguno obvio, huele tu piel o tu ropa.

**1 cosa que puedes SABOREAR:**
Nota el sabor en tu boca o toma un sorbo de agua.

**¿Por qué funciona?**
Esta técnica interrumpe el ciclo de pensamientos ansiosos al enfocar tu atención en experiencias sensoriales concretas del presente.''',
    },
    {
      'id': 'tec_3',
      'title': 'Relajación Muscular',
      'subtitle': 'Libera tensión física',
      'duration': '15 min',
      'category': 'Técnicas',
      'icon': Icons.spa,
      'color': Color(0xFFA855F7),
      'type': 'technique',
      'content': '''Técnica de Jacobson para liberar tensión muscular.

**Proceso:**

1. **Preparación:**
   • Encuentra un lugar cómodo
   • Siéntate o acuéstate
   • Respira profundamente 3 veces

2. **Secuencia (de pies a cabeza):**
   • **Pies:** Tensa 5 segundos, relaja 10 segundos
   • **Pantorrillas:** Tensa 5 segundos, relaja 10 segundos
   • **Muslos:** Tensa 5 segundos, relaja 10 segundos
   • **Abdomen:** Tensa 5 segundos, relaja 10 segundos
   • **Manos:** Cierra puños, tensa 5 seg, relaja 10 seg
   • **Brazos:** Tensa 5 segundos, relaja 10 segundos
   • **Hombros:** Levanta hacia las orejas, relaja
   • **Cuello:** Tensa suavemente, relaja
   • **Rostro:** Frunce, relaja

3. **Finalización:**
   • Respira profundamente
   • Nota la diferencia entre tensión y relajación
   • Disfruta la sensación de calma

**Ideal para:** Estrés físico, insomnio, dolores por tensión.''',
    },

    // Artículos Educativos
    {
      'id': 'read_1',
      'title': 'Entendiendo la Ansiedad',
      'subtitle': 'Qué es y cómo manejarla',
      'duration': '5 min',
      'category': 'Lectura',
      'icon': Icons.menu_book,
      'color': Color(0xFFF97316),
      'type': 'article',
      'content': '''**¿Qué es la ansiedad?**

La ansiedad es una respuesta natural del cuerpo ante situaciones percibidas como amenazantes. Es normal y nos ayuda a mantenernos alerta.

**Síntomas comunes:**
- Palpitaciones o ritmo cardíaco acelerado
- Sudoración excesiva
- Temblores o sacudidas
- Sensación de ahogo
- Pensamientos acelerados
- Tensión muscular
- Dificultad para concentrarse
- Problemas para dormir

**Tipos de ansiedad:**
1. **Ansiedad generalizada:** Preocupación constante
2. **Ansiedad social:** Miedo a situaciones sociales
3. **Ataques de pánico:** Episodios intensos de miedo
4. **Fobias:** Miedo intenso a algo específico

**Estrategias de manejo:**

**Inmediatas:**
- Respiración profunda (4-7-8)
- Técnica de grounding
- Caminar o movimiento físico
- Llamar a alguien de confianza

**A largo plazo:**
- Ejercicio regular (30 min, 3-5 veces/semana)
- Sueño adecuado (7-9 horas)
- Limitar cafeína y alcohol
- Meditación o mindfulness
- Terapia profesional (TCC es muy efectiva)

**Recuerda:** La ansiedad es tratable. No estás solo/a.''',
    },
    {
      'id': 'read_2',
      'title': 'Depresión: Señales',
      'subtitle': 'Reconoce los síntomas',
      'duration': '4 min',
      'category': 'Lectura',
      'icon': Icons.psychology,
      'color': Color(0xFFEC4899),
      'type': 'article',
      'content': '''**¿Qué es la depresión?**

La depresión es más que sentirse triste ocasionalmente. Es una condición médica que afecta cómo te sientes, piensas y manejas las actividades diarias.

**Señales de alerta:**

**Emocionales:**
- Tristeza persistente (más de 2 semanas)
- Pérdida de interés en actividades que antes disfrutabas
- Sentimientos de vacío o desesperanza
- Irritabilidad o frustración constante
- Sentimientos de culpa o inutilidad

**Físicos:**
- Cambios en apetito (aumento o disminución)
- Cambios en el sueño (dormir mucho o muy poco)
- Fatiga constante sin causa aparente
- Dolores físicos sin explicación médica
- Movimientos lentos o agitación

**Cognitivos:**
- Dificultad para concentrarse
- Problemas para tomar decisiones
- Pensamientos negativos recurrentes
- Pensamientos sobre muerte o suicidio

**Cuándo buscar ayuda:**
- Síntomas duran más de 2 semanas
- Interfieren con tu vida diaria
- Pensamientos de hacerte daño
- No puedes realizar actividades básicas

**Pasos para buscar ayuda:**
1. Habla con alguien de confianza
2. Consulta a un médico o psicólogo
3. Mantén rutinas básicas (comer, dormir, higiene)
4. No te aísles completamente
5. Sé paciente contigo mismo/a

**Tratamientos efectivos:**
- Terapia (TCC, terapia interpersonal)
- Medicación (si es necesario)
- Cambios en estilo de vida
- Grupos de apoyo

**Recuerda:** La depresión es una condición médica tratable. No es debilidad. Buscar ayuda es un acto de valentía.''',
    },
    {
      'id': 'read_3',
      'title': 'Manejo del Estrés',
      'subtitle': 'Estrategias prácticas',
      'duration': '6 min',
      'category': 'Lectura',
      'icon': Icons.trending_down,
      'color': Color(0xFF8B5CF6),
      'type': 'article',
      'content': '''**Estrés: Lo bueno y lo malo**

El estrés agudo (corto plazo) puede ser útil, pero el estrés crónico afecta tu salud física y mental.

**Señales de estrés crónico:**
- Dolores de cabeza frecuentes
- Tensión muscular constante
- Problemas digestivos
- Cambios en el apetito
- Dificultad para dormir
- Irritabilidad
- Dificultad para concentrarse
- Enfermarte con frecuencia

**Técnicas efectivas de manejo:**

**1. Gestión del tiempo:**
- Prioriza tareas importantes
- Divide proyectos grandes en pasos pequeños
- Aprende a decir "no"
- Toma descansos regulares (técnica Pomodoro: 25 min trabajo, 5 min descanso)
- Delega cuando sea posible

**2. Autocuidado físico:**
- Ejercicio regular (30 min, 3-5 veces/semana)
- Alimentación balanceada
- Hidratación adecuada (8 vasos de agua al día)
- Sueño suficiente (7-9 horas)
- Limitar cafeína y alcohol

**3. Técnicas de relajación:**
- Meditación diaria (10-20 min)
- Respiración consciente
- Yoga o estiramientos
- Paseos en la naturaleza
- Escuchar música relajante

**4. Conexiones sociales:**
- Mantén relaciones significativas
- Pide ayuda cuando la necesites
- Comparte tus preocupaciones
- Participa en actividades grupales
- Limita relaciones tóxicas

**5. Pensamiento saludable:**
- Identifica pensamientos negativos
- Cuestiona su validez
- Reemplázalos con pensamientos realistas
- Practica gratitud diaria
- Enfócate en lo que puedes controlar

**6. Establece límites:**
- Entre trabajo y vida personal
- Con dispositivos electrónicos
- En tus compromisos
- Con personas demandantes

**Plan de acción anti-estrés:**
1. Identifica tus estresores principales
2. Elige 2-3 técnicas para probar
3. Practica diariamente durante 2 semanas
4. Evalúa qué funciona para ti
5. Ajusta según necesites

**Señales para buscar ayuda profesional:**
- El estrés interfiere con tu vida diaria
- Sientes que no puedes manejarlo solo/a
- Recurres a sustancias para afrontar
- Tienes síntomas físicos persistentes''',
    },

    // Ejercicios Prácticos
    {
      'id': 'ex_1',
      'title': 'Diario de Gratitud',
      'subtitle': 'Cultiva la apreciación',
      'duration': '10 min',
      'category': 'Ejercicios',
      'icon': Icons.favorite,
      'color': Color(0xFFEC4899),
      'type': 'worksheet',
      'content': '''**¿Por qué funciona?**

Practicar gratitud regularmente:
- Mejora el estado de ánimo
- Reduce síntomas de depresión
- Aumenta la satisfacción con la vida
- Mejora las relaciones
- Fortalece la resiliencia

**Instrucciones:**

Cada noche antes de dormir, escribe 3 cosas por las que estás agradecido/a.

**Reglas importantes:**
1. **Sé específico/a:** 
   ❌ "Mi familia"
   ✓ "La cena que compartí con mi familia, especialmente cuando mi hermana contó esa historia graciosa"

2. **Incluye lo pequeño:**
   • Un café delicioso
   • Una sonrisa de un extraño
   • El sol en tu cara
   • Una canción que te gustó

3. **Profundiza:**
   No solo "qué", sino "por qué" estás agradecido/a

4. **Varía:**
   Busca cosas nuevas cada día

**Plantilla diaria:**

📅 Fecha: _____________

**Hoy agradezco por:**

1. _________________________
   ¿Por qué es importante para mí?
   _________________________
   
2. _________________________
   ¿Cómo me hizo sentir?
   _________________________
   
3. _________________________
   ¿Qué aprendí de esto?
   _________________________

**Mi estado de ánimo:**
Antes: 😢 😐 😊 😄
Después: 😢 😐 😊 😄

**Consejo:** Hazlo a la misma hora cada día para crear un hábito. Estudios muestran que 21 días de práctica constante pueden formar un nuevo hábito.''',
    },
    {
      'id': 'ex_2',
      'title': 'Registro de Pensamientos',
      'subtitle': 'Reestructura patrones negativos',
      'duration': '15 min',
      'category': 'Ejercicios',
      'icon': Icons.edit_note,
      'color': Color(0xFF6366F1),
      'type': 'worksheet',
      'content': '''**Técnica de TCC (Terapia Cognitivo-Conductual)**

Esta técnica te ayuda a identificar y cambiar pensamientos negativos automáticos.

**Los 5 pasos:**

**1. Situación**
¿Qué pasó? (Solo hechos, sin interpretaciones)

**2. Pensamiento Automático**
¿Qué pensé inmediatamente?

**3. Emoción**
¿Qué sentí? ¿Qué intensidad? (0-10)

**4. Evidencia**
A favor: ¿Qué apoya este pensamiento?
En contra: ¿Qué contradice este pensamiento?

**5. Pensamiento Alternativo**
¿Hay otra forma más realista de ver esto?
¿Qué le dirías a un amigo en esta situación?

**Ejemplo completo:**

**Situación:**
"Envié un mensaje a mi amiga hace 4 horas y no ha respondido"

**Pensamiento automático:**
"No le importo. Está enojada conmigo. Voy a perder esta amistad"

**Emoción:**
Tristeza (8/10), Ansiedad (7/10)

**Evidencia a favor:**
- No ha respondido en 4 horas
- A veces tarda en responder

**Evidencia en contra:**
- Ayer tuvimos una conversación muy agradable
- Me escribió primero el fin de semana
- Mencionó que tenía un día ocupado hoy
- Siempre responde eventualmente
- Me invitó a salir la semana pasada

**Pensamiento alternativo:**
"Está ocupada como mencionó. No responder rápido no significa que no le importo. Responderá cuando pueda, como siempre lo hace"

**Nueva emoción:**
Tristeza (2/10), Ansiedad (3/10)

**Distorsiones cognitivas comunes:**

- **Todo o nada:** Ver las cosas en blanco y negro
- **Generalización:** "Siempre", "nunca", "todos"
- **Catastrofizar:** Esperar el peor escenario
- **Lectura de mente:** Asumir lo que otros piensan
- **Personalización:** Culparte de todo
- **Filtro mental:** Solo ver lo negativo

**Practica diariamente para mejores resultados.**''',
    },
    {
      'id': 'ex_3',
      'title': 'Plan de Autocuidado',
      'subtitle': 'Diseña tu rutina de bienestar',
      'duration': '20 min',
      'category': 'Ejercicios',
      'icon': Icons.self_improvement,
      'color': Color(0xFF10B981),
      'type': 'worksheet',
      'content': '''**¿Qué es el autocuidado?**

No es egoísmo. Es cuidar tu bienestar físico, mental y emocional para poder funcionar mejor y cuidar de otros.

**Dimensiones del autocuidado:**

**1. FÍSICO**
- Dormir 7-9 horas
- Comer nutritivamente
- Ejercicio regular
- Hidratación
- Higiene personal
- Chequeos médicos

**2. EMOCIONAL**
- Expresar sentimientos
- Establecer límites
- Buscar apoyo
- Practicar autocompasión
- Permitirte sentir

**3. MENTAL**
- Aprender cosas nuevas
- Leer
- Practicar mindfulness
- Estimular creatividad
- Resolver problemas

**4. SOCIAL**
- Tiempo con seres queridos
- Hacer nuevas amistades
- Participar en comunidad
- Pedir y ofrecer ayuda

**5. ESPIRITUAL**
- Conexión con valores
- Tiempo en naturaleza
- Meditación o reflexión
- Prácticas de gratitud
- Sentido de propósito

**Crea tu plan personalizado:**

**DIARIO (15-30 min):**
□ _____________________
□ _____________________
□ _____________________

**SEMANAL (1-2 horas):**
□ _____________________
□ _____________________

**MENSUAL (medio día):**
□ _____________________
□ _____________________

**Ejemplos concretos:**

**Diario:**
- 10 min de meditación al despertar
- Desayuno nutritivo sin prisa
- Caminar 20 minutos
- Ducha relajante
- Diario de gratitud antes de dormir

**Semanal:**
- Café con un amigo
- Clase de yoga o baile
- Tarde de hobby (pintura, jardinería)
- Desconexión digital un día

**Mensual:**
- Día de spa casero
- Excursión a la naturaleza
- Visita al museo o cine
- Curso o taller nuevo

**Recordatorios importantes:**
- El autocuidado no es opcional, es necesario
- Empieza pequeño y sé constante
- No es egoísta, es responsable
- Ajusta según tus necesidades
- No te culpes si te saltas un día

**Señales de que necesitas más autocuidado:**
- Irritabilidad constante
- Fatiga sin causa médica
- Enfermarte frecuentemente
- Dificultad para concentrarte
- Sentirte abrumado/a
- Descuidar necesidades básicas''',
    },
    {
      'id': 'ex_4',
      'title': 'Establecer Límites',
      'subtitle': 'Protege tu energía',
      'duration': '10 min',
      'category': 'Ejercicios',
      'icon': Icons.shield,
      'color': Color(0xFF8B5CF6),
      'type': 'worksheet',
      'content': '''**¿Qué son los límites?**

Los límites son reglas que estableces sobre cómo quieres que te traten y cómo usas tu tiempo y energía.

**Por qué son importantes:**
- Protegen tu salud mental
- Previenen resentimiento
- Mejoran relaciones
- Aumentan autoestima
- Te dan control sobre tu vida

**Tipos de límites:**

**1. Físicos:**
- Espacio personal
- Contacto físico
- Privacidad

**2. Emocionales:**
- Qué compartes
- Responsabilidad por sentimientos
- Tolerancia al maltrato

**3. Tiempo:**
- Horarios disponibles
- Compromisos que aceptas
- Tiempo para ti

**4. Mentales:**
- Respeto por tus ideas
- Derecho a tu opinión
- Valores personales

**5. Materiales:**
- Dinero
- Pertenencias
- Recursos

**Cómo establecer límites:**

**Paso 1: Identifica tus necesidades**
¿Qué te hace sentir incómodo/a?
¿Qué te drena energía?
¿Qué patrones te molestan?

**Paso 2: Sé claro y directo**
❌ "Tal vez podría..."
✓ "No puedo hacer eso"

**Paso 3: Di "no" sin justificar excesivamente**
❌ "No puedo porque tengo que lavar, luego cocinar, y mi prima viene..."
✓ "No puedo en este momento"

**Frases útiles:**
- "Necesito pensarlo"
- "No es un buen momento para mí"
- "Entiendo, pero no puedo"
- "Eso no funciona para mí"
- "Aprecio que pienses en mí, pero debo declinar"
- "No me siento cómodo/a con eso"

**Ejercicio práctico:**

**Identifica un límite que necesitas establecer:**
Con quién: _______________
Sobre qué: _______________

**¿Cómo lo dirás?**
___________________________
___________________________

**Consecuencia si no se respeta:**
___________________________

**Señales de límites poco saludables:**
- Te sientes culpable por decir "no"
- Priorizas necesidades de otros sobre las tuyas
- Aceptas maltrato
- Te sientes resentido/a frecuentemente
- No tienes tiempo para ti

**Recuerda:**
- Establecer límites no es egoísta
- Puedes amar a alguien y aún tener límites
- "No" es una oración completa
- Los límites saludables benefician ambas partes
- Está bien si otros se molestan (sus emociones son su responsabilidad)''',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    _animationController.forward();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final completed = await LocalStorageService.getCompletedResources();
    if (mounted) {
      setState(() {
        _completedResources = completed;
      });
    }
  }

  List<Map<String, dynamic>> get filteredResources {
    if (_selectedCategory == 'Todo') {
      return resources;
    }
    return resources.where((r) => r['category'] == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(isMobile ? 20 : 24),
        decoration: BoxDecoration(
          color: widget.isDarkMode
              ? widget.cardDark.withOpacity(0.9)
              : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: widget.vibrantPurple.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: widget.vibrantPurple.withOpacity(0.2),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(isMobile),
            const SizedBox(height: 20),
            _buildCategoryFilters(),
            const SizedBox(height: 20),
            _buildResourcesList(isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [widget.cloudBlue, widget.lightPurple],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: widget.cloudBlue.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(Icons.local_library, color: widget.softWhite, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Biblioteca de Recursos',
                style: TextStyle(
                  fontSize: isMobile ? 18 : 20,
                  fontWeight: FontWeight.w700,
                  color: widget.isDarkMode
                      ? widget.softWhite
                      : widget.deepPurple,
                ),
              ),
              Text(
                'Herramientas para tu bienestar',
                style: TextStyle(
                  fontSize: 14,
                  color: widget.isDarkMode
                      ? Colors.grey[300]
                      : widget.deepPurple.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: widget.mentalhealthGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: widget.mentalhealthGreen.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.star, color: widget.mentalhealthGreen, size: 16),
              const SizedBox(width: 4),
              Text(
                '${_completedResources.length}/${resources.length}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: widget.mentalhealthGreen,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilters() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == _selectedCategory;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [widget.vibrantPurple, widget.lightPurple],
                        )
                      : null,
                  color: isSelected
                      ? null
                      : widget.isDarkMode
                          ? widget.cardDark.withOpacity(0.5)
                          : widget.vibrantPurple.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : widget.vibrantPurple.withOpacity(0.2),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: widget.vibrantPurple.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? widget.softWhite
                        : widget.isDarkMode
                            ? Colors.grey[300]
                            : widget.deepPurple.withOpacity(0.7),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResourcesList(bool isMobile) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: filteredResources.map((resource) {
        return _buildResourceCard(resource, isMobile);
      }).toList(),
    );
  }

  Widget _buildResourceCard(Map<String, dynamic> resource, bool isMobile) {
    final isCompleted = _completedResources.contains(resource['id']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: widget.isDarkMode
            ? widget.darkBackground.withOpacity(0.5)
            : widget.vibrantPurple.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? widget.mentalhealthGreen.withOpacity(0.5)
              : (resource['color'] as Color).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showResourceDetail(resource),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: (resource['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: (resource['color'] as Color).withOpacity(0.3),
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        resource['icon'] as IconData,
                        color: resource['color'] as Color,
                        size: 24,
                      ),
                      if (isCompleted)
                        Positioned(
                          right: -2,
                          bottom: -2,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: widget.mentalhealthGreen,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: widget.isDarkMode
                                    ? widget.cardDark
                                    : Colors.white,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.check,
                              size: 12,
                              color: widget.softWhite,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resource['title'] as String,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: widget.isDarkMode
                              ? widget.softWhite
                              : widget.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        resource['subtitle'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          color: widget.isDarkMode
                              ? Colors.grey[400]
                              : widget.deepPurple.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: (resource['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: resource['color'] as Color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        resource['duration'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: resource['color'] as Color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showResourceDetail(Map<String, dynamic> resource) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ResourceDetailModal(
        resource: resource,
        isDarkMode: widget.isDarkMode,
        deepPurple: widget.deepPurple,
        vibrantPurple: widget.vibrantPurple,
        lightPurple: widget.lightPurple,
        darkBackground: widget.darkBackground,
        cardDark: widget.cardDark,
        accentPink: widget.accentPink,
        softWhite: widget.softWhite,
        mentalhealthGreen: widget.mentalhealthGreen,
        onComplete: (resourceId) async {
          await LocalStorageService.markResourceAsCompleted(resourceId);
          await _loadProgress();
        },
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

// Modal de detalle del recurso
class _ResourceDetailModal extends StatefulWidget {
  final Map<String, dynamic> resource;
  final bool isDarkMode;
  final Color deepPurple;
  final Color vibrantPurple;
  final Color lightPurple;
  final Color darkBackground;
  final Color cardDark;
  final Color accentPink;
  final Color softWhite;
  final Color mentalhealthGreen;
  final Function(String) onComplete;

  const _ResourceDetailModal({
    required this.resource,
    required this.isDarkMode,
    required this.deepPurple,
    required this.vibrantPurple,
    required this.lightPurple,
    required this.darkBackground,
    required this.cardDark,
    required this.accentPink,
    required this.softWhite,
    required this.mentalhealthGreen,
    required this.onComplete,
  });

  @override
  State<_ResourceDetailModal> createState() => _ResourceDetailModalState();
}

class _ResourceDetailModalState extends State<_ResourceDetailModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 100),
          child: Container(
            height: screenHeight * 0.85,
            decoration: BoxDecoration(
              color: widget.isDarkMode ? widget.cardDark : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.vibrantPurple.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, -10),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: widget.vibrantPurple.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailHeader(),
                        const SizedBox(height: 24),
                        _buildContent(),
                        const SizedBox(height: 24),
                        _buildActionButtons(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailHeader() {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                (widget.resource['color'] as Color),
                (widget.resource['color'] as Color).withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: (widget.resource['color'] as Color).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            widget.resource['icon'] as IconData,
            color: widget.softWhite,
            size: 30,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.resource['title'] as String,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: widget.isDarkMode ? widget.softWhite : widget.deepPurple,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.resource['subtitle'] as String,
                style: TextStyle(
                  fontSize: 14,
                  color: widget.isDarkMode
                      ? Colors.grey[400]
                      : widget.deepPurple.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (widget.resource['color'] as Color).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (widget.resource['color'] as Color).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: widget.resource['color'] as Color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.resource['duration'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: widget.resource['color'] as Color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.isDarkMode
            ? widget.darkBackground.withOpacity(0.5)
            : widget.vibrantPurple.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.vibrantPurple.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: widget.vibrantPurple,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Contenido',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: widget.isDarkMode ? widget.softWhite : widget.deepPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.resource['content'] as String,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: widget.isDarkMode
                  ? Colors.grey[300]
                  : widget.deepPurple.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [widget.mentalhealthGreen, widget.mentalhealthGreen.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: widget.mentalhealthGreen.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                widget.onComplete(widget.resource['id'] as String);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: widget.mentalhealthGreen),
                        const SizedBox(width: 8),
                        const Text('¡Recurso completado!'),
                      ],
                    ),
                    backgroundColor: widget.isDarkMode ? widget.cardDark : Colors.white,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
                Navigator.pop(context);
              },
              icon: Icon(Icons.check_circle, color: widget.softWhite),
              label: Text(
                'Marcar como Completado',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: widget.softWhite,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cerrar',
            style: TextStyle(
              fontSize: 14,
              color: widget.isDarkMode
                  ? Colors.grey[400]
                  : widget.deepPurple.withOpacity(0.7),
            ),
          ),
        ),
      ],
    );
  }
}