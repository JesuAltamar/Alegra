import 'package:flutter/material.dart';

class EducationalContentPage extends StatefulWidget {
  @override
  _EducationalContentPageState createState() => _EducationalContentPageState();
}

class _EducationalContentPageState extends State<EducationalContentPage> {
  List<String> _contentList = [
    'Manejo del estrés',
    'Respiración consciente',
    'Técnicas de afrontamiento',
  ];
  String _searchQuery = '';

  final TextEditingController _contentController = TextEditingController();

  void _addContent(String content) {
    if (content.isNotEmpty) {
      setState(() {
        _contentList.add(content);
      });
      _contentController.clear();
    }
  }

  void _deleteContent(int index) {
    setState(() {
      _contentList.removeAt(index);
    });
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Color.fromARGB(255, 245, 252, 255),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Nuevo Contenido'),
        content: TextField(
          controller: _contentController,
          decoration: InputDecoration(
            hintText: 'Título del contenido',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              _addContent(_contentController.text.trim());
              Navigator.pop(context);
            },
            child: Text('Agregar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 70, 131, 114),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _contentList
        .where((item) => item.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 70, 131, 114),
      appBar: AppBar(
        title: Text('Contenido Educativo'),
        backgroundColor: Colors.white.withOpacity(0.95),
        foregroundColor: Colors.teal[900],
        centerTitle: true,
        elevation: 2,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromARGB(255, 11, 79, 135),
        onPressed: _showAddDialog,
        child: Icon(Icons.add),
      ),
      body: Stack(
        children: [
          // Figuras decorativas
          Positioned(
            top: -60,
            left: -40,
            child: _buildAnimatedCircle(140, Colors.white.withOpacity(0.1)),
          ),
          Positioned(
            bottom: -40,
            right: -30,
            child: _buildAnimatedCircle(120, Colors.teal.shade200.withOpacity(0.3)),
          ),
          Positioned(
            top: 150,
            right: -50,
            child: _buildAnimatedCircle(80, Colors.white.withOpacity(0.12)),
          ),

          // Contenido
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar contenido...',
                      prefixIcon: Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (_, index) {
                        return Card(
                          elevation: 4,
                          margin: EdgeInsets.symmetric(vertical: 6),
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: Text(
                              filteredList[index],
                              style: TextStyle(
                                color: Color.fromARGB(255, 0, 0, 0),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => _deleteContent(index),
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
      duration: Duration(seconds: 3),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
