import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import '../db/agenda_database.dart';  

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
                      final meds = snapshot.data ?? [];
                      
                      return Column(
                        children: [
                          Expanded( // Lista de citas en columna
                            child: ListView.separated(
                              itemCount: meds.isNotEmpty ? meds.length + 1 : 1,
                              separatorBuilder: (_, _) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                // Último item es el botón de añadir
                                if (index == meds.length) {
                                  return GestureDetector(
                                    onTap: () {
                                      _showEditDialog(context, null, meds, mainColor, cardColor, isNew: true);
                                    },
                                    child: Card(
                                      color: Colors.grey[200],
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      elevation: 3,
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.add, color: mainColor, size: 32),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Añadir nueva cita',
                                                style: TextStyle(color: mainColor, fontSize: 16, fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                
                                final item = meds[index];
                                
                                return GestureDetector(
                                  onTap: () {
                                    _showEditDialog(context, index, meds, mainColor, cardColor, isNew: false);
                                  },
                                  child: Card(
                                    color: const Color(0xFFD1E4EA),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    elevation: 3,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              _iconoPorTipo(item['name'] ?? ''),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  item['name'] ?? '',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            item['desc'] ?? '',
                                            style: const TextStyle(
                                              color: Colors.black54,
                                              fontSize: 14,
                                            ),
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Icon(Icons.calendar_today, size: 14, color: mainColor),
                                              const SizedBox(width: 6),
                                              Text(
                                                item['fecha'] ?? 'Sin fecha',
                                                style: TextStyle(
                                                  color: mainColor,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Icon(Icons.schedule, size: 14, color: mainColor),
                                              const SizedBox(width: 6),
                                              Text(
                                                item['hora'] ?? 'Sin hora',
                                                style: TextStyle(
                                                  color: mainColor,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
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
    List<Map<String, dynamic>> meds,
    Color mainColor,
    Color cardColor, {
    bool isNew = false,
  }) {
    String name = '';
    String desc = '';
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    if (!isNew && index != null && index < meds.length) {
      name = meds[index]['name'] ?? '';
      desc = meds[index]['desc'] ?? '';
      if (meds[index]['fecha'] != null && meds[index]['fecha']!.isNotEmpty) {
        selectedDate = _parseDate(meds[index]['fecha']);
      }
      if (meds[index]['hora'] != null && meds[index]['hora']!.isNotEmpty) {
        selectedTime = _parseTime(meds[index]['hora']);
      }
    }

    final nameController = TextEditingController(text: name);
    final descController = TextEditingController(text: desc);
    final fechaController = TextEditingController(
        text: selectedDate != null ? DateFormat('dd/MM/yyyy').format(selectedDate) : '');
    final horaController = TextEditingController(
        text: selectedTime != null
            ? '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}'
            : '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isNew ? 'Añadir cita' : 'Editar cita',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: name.isNotEmpty ? name : null,
                decoration: const InputDecoration(
                  labelText: 'Tipo',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'CITA MÉDICA', child: Text('CITA MÉDICA')),
                  DropdownMenuItem(value: 'CUMPLEAÑOS', child: Text('CUMPLEAÑOS')),
                  DropdownMenuItem(value: 'ANIVERSARIO', child: Text('ANIVERSARIO')),
                ],
                onChanged: (value) {
                  nameController.text = value ?? '';
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () async {
                  if (!context.mounted) return;
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    selectedDate = date;
                    fechaController.text = DateFormat('dd/MM/yyyy').format(date);
                  }
                },
                child: TextField(
                  controller: fechaController,
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: 'Fecha',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.calendar_today),
                    suffixIcon: fechaController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              fechaController.clear();
                              selectedDate = null;
                            },
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () async {
                  if (!context.mounted) return;
                  final time = await showTimePicker(
                    context: context,
                    initialTime: selectedTime ?? TimeOfDay.now(),
                  );
                  if (time != null) {
                    selectedTime = time;
                    horaController.text =
                        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                  }
                },
                child: TextField(
                  controller: horaController,
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: 'Hora',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.schedule),
                    suffixIcon: horaController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              horaController.clear();
                              selectedTime = null;
                            },
                          )
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCELAR'),
          ),
          if (!isNew)
            ElevatedButton.icon(
              icon: const Icon(Icons.delete),
              label: const Text('BORRAR'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () async {
                if (index != null && index < meds.length) {
                  int id = meds[index]['id'] as int;
                  await AgendaDatabase.delete(id);
                  if (mounted) {
                    setState(() {
                      _medsFuture = AgendaDatabase.getAll();
                    });
                  }
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                }
              },
            ),
          ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: const Text('GUARDAR'),
            style: ElevatedButton.styleFrom(
              backgroundColor: mainColor,
            ),
            onPressed: () async {
              if (nameController.text.isEmpty) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('El tipo de cita no puede estar vacío')),
                  );
                }
                return;
              }
              if (!context.mounted) return;
              if (isNew) {
                await AgendaDatabase.insert({
                  'name': nameController.text,
                  'desc': descController.text,
                  'fecha': fechaController.text,
                  'hora': horaController.text,
                });
              } else if (index != null && index < meds.length) {
                int id = meds[index]['id'] as int;
                await AgendaDatabase.update(id, {
                  'name': nameController.text,
                  'desc': descController.text,
                  'fecha': fechaController.text,
                  'hora': horaController.text,
                });
              }

              if (mounted) {
                setState(() {
                  _medsFuture = AgendaDatabase.getAll();
                });
              }
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  DateTime? _parseDate(String dateStr) {
    try {
      return DateFormat('dd/MM/yyyy').parse(dateStr);
    } catch (e) {
      return null;
    }
  }

  TimeOfDay? _parseTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (e) {
      return null;
    }
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
