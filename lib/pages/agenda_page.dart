import 'package:flutter/material.dart';
import 'package:your_package_name/database/agenda_database.dart'; // Asegúrate de importar tu base de datos  

class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  late Future<List<Map<String, dynamic>>> _medsFuture;

  @override
  void initState() {
    super.initState();
    _medsFuture = AgendaDatabase.getAll();
  }

  @override
  Widget build(BuildContext context) {
    final Color mainColor = const Color(0xFF197A89);
    final Color cardColor = const Color(0xFFD1E4EA);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                      decoration: BoxDecoration(
                        color: mainColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'AGENDA',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          const Icon(
                            Icons.medication_outlined,
                            color: Colors.white,
                            size: 60,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded( // Lista de medicación y botón
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _medsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      final meds = snapshot.data!;
                      return Column(
                        children: [
                          Expanded( // Lista expandible
                            child: ListView.separated(
                              itemCount: meds.length,
                              separatorBuilder: (_, _) => const SizedBox(height: 8),
                              itemBuilder: (context, i) {
                                return GestureDetector(
                                  onTap: () {
                                    _showEditDialog(context, i, meds, mainColor, cardColor);
                                  },
                                  child: Card(
                                    color: cardColor,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    elevation: 3,
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 40), // Aumenta el valor si quieres más espacio
                                      leading: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          _iconoPorTipo(meds[i]['name'] ?? ''),
                                          const SizedBox(width: 40), 
                                        ],
                                      ),
                                      
                                      title: Text(
                                        meds[i]['name']!,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      subtitle: Text(
                                        meds[i]['desc']!,
                                        style: const TextStyle(
                                          color: Colors.black54,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                                              
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 0),
                            child: SizedBox(
                              width: double.infinity,
                              height: 80,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: mainColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: () {
                                  _showEditDialog(context, null, meds, mainColor, cardColor, isNew: true);
                                },
                                child: const Text(
                                  'AÑADIR',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    int? index,
    List<Map<String, String>> meds,
    Color mainColor,
    Color cardColor, {
    bool isNew = false,
  }) {
    final nameController = TextEditingController(
        text: isNew ? '' : meds[index!]['name']);
    final descController = TextEditingController(
        text: isNew ? '' : meds[index!]['desc']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isNew ? 'Añadir cita' : 'Editar cita',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: nameController.text.isNotEmpty ? nameController.text : null,
              decoration: const InputDecoration(labelText: 'Nombre'),
              items: const [
                DropdownMenuItem(value: 'CITA MÉDICA', child: Text('CITA MÉDICA')),
                DropdownMenuItem(value: 'CUMPLEAÑOS', child: Text('CUMPLEAÑOS')),
                DropdownMenuItem(value: 'ANIVERSARIO', child: Text('ANIVERSARIO')),
              ],
              onChanged: (value) {
                nameController.text = value ?? '';
              },
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Descripción'),
            ),
          ],
        ),
        actions: [
          if (!isNew)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                setState(() {
                  meds.removeAt(index!);
                });
                Navigator.of(context).pop();
              },
              child: const Text(
                'Borrar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: mainColor),
            onPressed: () {
              setState(() {
                if (isNew) {
                  meds.add({
                    'name': nameController.text,
                    'desc': descController.text,
                  });
                } else {
                  meds[index!]['name'] = nameController.text;
                  meds[index]['desc'] = descController.text;
                }
              });
              Navigator.of(context).pop();
            },
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _iconoPorTipo(String tipo) {
    switch (tipo) {
      case 'CITA MÉDICA':
        return const Icon(Icons.local_hospital, color: Color(0xFF197A89), size: 36);
      case 'CUMPLEAÑOS':
        return const Icon(Icons.cake, color: Color(0xFF197A89), size: 36);
      case 'ANIVERSARIO':
        return const Icon(Icons.favorite, color: Color(0xFF197A89), size: 36);
      default:
        return const Icon(Icons.event, color: Color(0xFF197A89), size: 36);
    }
  }
}