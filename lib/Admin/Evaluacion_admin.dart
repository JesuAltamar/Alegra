import 'package:flutter/material.dart';

class EvaluationScreen extends StatefulWidget {
  @override
  EvaluationScreenState createState() => EvaluationScreenState();
}

class EvaluationScreenState extends State<EvaluationScreen> {
  Map<String, List<String>> patientNotes = {
    'Laura Martínez': [],
    'Pedro Gómez': [],
    'Lucía Torres': [],
  };

  String selectedPatient = 'Laura Martínez';
  final TextEditingController _noteController = TextEditingController();
  int? editingIndex;

  @override
  Widget build(BuildContext context) {
    final List<String> notes = patientNotes[selectedPatient] ?? [];

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 70, 131, 114),
      appBar: AppBar(
        title: Text('Seguimiento de Usuario'),
        backgroundColor: Colors.white,
        foregroundColor: Color.fromARGB(255, 13, 34, 27),
      ),
      body: Stack(
        children: [
          // Figuras decorativas animadas
          Positioned(
            top: -40,
            left: -30,
            child: _buildAnimatedCircle(120, Colors.white.withOpacity(0.1)),
          ),
          Positioned(
            bottom: -50,
            right: -30,
            child: _buildAnimatedCircle(130, Colors.white.withOpacity(0.15)),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selecciona un usuario:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                SizedBox(
                  height: 110,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: patientNotes.keys.map((String patient) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedPatient = patient;
                            editingIndex = null;
                            _noteController.clear();
                          });
                        },
                        child: Card(
                          color: selectedPatient == patient
                              ? Color.fromARGB(255, 128, 170, 209)
                              : Colors.white,
                          elevation: 4,
                          margin: EdgeInsets.symmetric(horizontal: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Container(
                            width: 150,
                            padding: EdgeInsets.all(12),
                            child: Center(
                              child: Text(
                                patient,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: selectedPatient == patient
                                      ? Colors.white
                                      : Color.fromARGB(255, 11, 79, 135),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Notas para $selectedPatient:',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: notes.isEmpty
                      ? Text(
                          "Sin notas aún.",
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.white70,
                          ),
                        )
                      : ListView.builder(
                          itemCount: notes.length,
                          itemBuilder: (context, index) {
                            return Card(
                              color: Colors.white,
                              elevation: 3,
                              margin: EdgeInsets.symmetric(vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListTile(
                                title: Text(
                                  notes[index],
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 50, 50, 80),
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit,
                                          color: Colors.orangeAccent),
                                      onPressed: () {
                                        setState(() {
                                          editingIndex = index;
                                          _noteController.text = notes[index];
                                        });
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete,
                                          color: Colors.redAccent),
                                      onPressed: () {
                                        setState(() {
                                          notes.removeAt(index);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                TextField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    hintText: editingIndex == null
                        ? 'Escribe una nueva nota'
                        : 'Editando nota...',
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 128, 167, 209),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    if (_noteController.text.trim().isNotEmpty) {
                      setState(() {
                        if (editingIndex != null) {
                          notes[editingIndex!] =
                              _noteController.text.trim();
                          editingIndex = null;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Nota actualizada exitosamente'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else {
                          notes.add(_noteController.text.trim());
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Nota agregada exitosamente'),
                              backgroundColor: Colors.blue,
                            ),
                          );
                        }
                        _noteController.clear();
                      });
                    }
                  },
                  icon: Icon(
                      editingIndex == null ? Icons.note_add : Icons.save),
                  label: Text(
                    editingIndex == null ? 'Agregar Nota' : 'Guardar Nota',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedCircle(double size, Color color) {
    return AnimatedContainer(
      duration: const Duration(seconds: 3),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
