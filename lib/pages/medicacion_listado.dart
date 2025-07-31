import 'package:flutter/material.dart';
import 'medicacion_diaria.dart';

class MedicacionListadoPage extends StatefulWidget {
  const MedicacionListadoPage({super.key});

  @override
  State<MedicacionListadoPage> createState() => _MedicacionListadoPageState();
}

class _MedicacionListadoPageState extends State<MedicacionListadoPage> {
  final List<Map<String, String>> meds = [
    {'name': 'PARACETAMOL', 'desc': 'cada 8 horas'},
    {'name': 'SINTRON', 'desc': 'sábados'},
    {'name': 'AMOXICILINA', 'desc': 'tardes'},
    {'name': 'ENANTIUM', 'desc': 'Subhead'},
    {'name': 'OMEPRAZOL', 'desc': '2 al día'},
    {'name': 'AMOXICILINA', 'desc': 'tardes'},
    {'name': 'ENANTIUM', 'desc': 'Subhead'},
  ];

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
                            'MEDICACIÓN',
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
            // Lista de medicación y botón
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // Lista expandible
                    Expanded(
                      child: ListView.separated(
                        itemCount: meds.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 16),
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
                                leading: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  child: Text(
                                    meds[i]['name']![0],
                                    style: TextStyle(
                                      color: mainColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
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
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.warning_amber_rounded, color: Colors.grey[300], size: 28),
                                    const SizedBox(width: 8),
                                    Icon(Icons.settings, color: Colors.grey[300], size: 28),
                                  ],
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
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const MedicacionDiariaPage()),
                            );
                          },
                          child: const Text(
                            'HORARIO',
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
          isNew ? 'Añadir medicación' : 'Editar medicación',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
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
}