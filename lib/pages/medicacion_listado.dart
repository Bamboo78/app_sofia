import 'package:flutter/material.dart';
import 'medicacion_diaria.dart';
import '../db/medicacion_database.dart';

class MedicacionListadoPage extends StatefulWidget {
  const MedicacionListadoPage({super.key});

  @override
  State<MedicacionListadoPage> createState() => _MedicacionListadoPageState();
}

class _MedicacionListadoPageState extends State<MedicacionListadoPage> {
  late Future<List<Map<String, dynamic>>> _medicacionesFuture;

  @override
  void initState() {
    super.initState();
    _medicacionesFuture = MedicacionDatabase.getAll();
  }

  void _actualizarLista() {
    setState(() {
      _medicacionesFuture = MedicacionDatabase.getAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color mainColor = const Color(0xFF197A89);
    final Color cardColor = const Color(0xFFD1E4EA);

    return Scaffold(
      backgroundColor: Colors.white,
      body: PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            return;
          }
          Navigator.of(context).pop();
        },
        child: SafeArea(
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
                      child: FutureBuilder<List<Map<String, dynamic>>>(
                        future: _medicacionesFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(child: Text('Error: ${snapshot.error}'));
                          } else {
                            final meds = snapshot.data ?? [];
                            return ListView.separated(
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
                                          (meds[i]['nombre'] as String)[0],
                                          style: TextStyle(
                                            color: mainColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        meds[i]['nombre'] ?? '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      subtitle: Text(
                                        meds[i]['descripcion'] ?? '',
                                        style: const TextStyle(
                                          color: Colors.black54,
                                          fontSize: 14,
                                        ),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          GestureDetector(
                                            onTap: () async {
                                              await MedicacionDatabase.delete(meds[i]['id']);
                                              _actualizarLista();
                                            },
                                            child: Icon(Icons.delete, color: Colors.red[400], size: 28),
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(Icons.settings, color: Colors.grey[300], size: 28),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                        },
                      ),
                    ),
                                        
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mainColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () async {
                            _showEditDialog(context, null, [], mainColor, cardColor, isNew: true);
                          },
                          child: const Text(
                            'NUEVO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
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
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    int? index,
    List<Map<String, dynamic>> meds,
    Color mainColor,
    Color cardColor, {
    bool isNew = false,
  }) {
    final nameController = TextEditingController(
        text: isNew ? '' : meds[index!]['nombre']);
    final descController = TextEditingController(
        text: isNew ? '' : meds[index!]['descripcion']);
    final horaController = TextEditingController(
        text: isNew ? '' : meds[index!]['hora']);

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
            TextField(
              controller: horaController,
              decoration: const InputDecoration(labelText: 'Hora (HH:mm)'),
            ),
          ],
        ),
        actions: [
          if (!isNew)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () async {
                await MedicacionDatabase.delete(meds[index!]['id']);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  _actualizarLista();
                }
              },
              child: const Text(
                'Borrar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: mainColor),
            onPressed: () async {
              if (isNew) {
                await MedicacionDatabase.insert({
                  'nombre': nameController.text,
                  'descripcion': descController.text,
                  'hora': horaController.text,
                });
              } else {
                await MedicacionDatabase.update(meds[index!]['id'], {
                  'nombre': nameController.text,
                  'descripcion': descController.text,
                  'hora': horaController.text,
                });
              }
              if (context.mounted) {
                Navigator.of(context).pop();
                _actualizarLista();
              }
            },
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
