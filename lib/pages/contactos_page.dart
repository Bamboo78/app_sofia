import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import '../db/contactos_database.dart';
import 'dart:io';

class ContactosPage extends StatefulWidget {
  const ContactosPage({super.key});

  @override
  State<ContactosPage> createState() => _ContactosPageState();
}

class _ContactosPageState extends State<ContactosPage> {
  final Color mainColor = const Color(0xFF197A89);
  final Color cardColor = const Color(0xFFD1E4EA);
  late Future<List<Map<String, dynamic>>> _contactosFuture;

  @override
  void initState() {
    super.initState();
    _contactosFuture = ContactosDatabase.getAll();
  }

  void _mostrarAgregarContactoManual() {
    String nombre = '';
    String telefono = '';
    File? imagenSeleccionada;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Agregar contacto'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      setState(() {
                        imagenSeleccionada = File(image.path);
                      });
                    }
                  },
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: mainColor,
                    backgroundImage: imagenSeleccionada != null
                        ? FileImage(imagenSeleccionada!)
                        : null,
                    child: imagenSeleccionada == null
                        ? const Icon(Icons.add_a_photo, color: Colors.white, size: 40)
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    border: OutlineInputBorder(),
                    hintText: 'Ej: Mamá',
                  ),
                  onChanged: (value) {
                    nombre = value;
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Teléfono',
                    border: OutlineInputBorder(),
                    hintText: 'Ej: +34 123 45 67 89',
                  ),
                  keyboardType: TextInputType.phone,
                  onChanged: (value) {
                    telefono = value;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CANCELAR'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: mainColor),
              onPressed: () async {
                if (nombre.isEmpty) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('El nombre no puede estar vacío')),
                    );
                  }
                  return;
                }
                await ContactosDatabase.insert({
                  'nombre': nombre,
                  'telefono': telefono,
                  'imagenPath': imagenSeleccionada?.path,
                });
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
                // Actualizar la página principal después de cerrar el diálogo
                if (mounted) {
                  setState(() {
                    _contactosFuture = ContactosDatabase.getAll();
                  });
                }
              },
              child: const Text('GUARDAR', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDetallesContacto(Map<String, dynamic> contactoGuardado) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: mainColor,
                backgroundImage: contactoGuardado['imagenPath'] != null && contactoGuardado['imagenPath']!.isNotEmpty
                    ? FileImage(File(contactoGuardado['imagenPath']))
                    : null,
                child: contactoGuardado['imagenPath'] == null || contactoGuardado['imagenPath']!.isEmpty
                    ? const Icon(Icons.person, color: Colors.white, size: 80)
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                contactoGuardado['nombre'] ?? 'Sin nombre',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                contactoGuardado['telefono'] ?? 'Sin teléfono',
                style: TextStyle(
                  fontSize: 18,
                  color: mainColor,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if ((contactoGuardado['telefono'] ?? '').isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.phone, size: 28),
                    label: const Text('LLAMAR', style: TextStyle(fontSize: 18, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      launchUrl(Uri(scheme: 'tel', path: contactoGuardado['telefono']));
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              if ((contactoGuardado['telefono'] ?? '').isNotEmpty) const SizedBox(height: 12),
              if ((contactoGuardado['telefono'] ?? '').isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.message, size: 24),
                    label: const Text('WHATSAPP', style: TextStyle(fontSize: 16, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      final phone = contactoGuardado['telefono'].replaceAll(RegExp(r'[^\d]'), '');
                      launchUrl(Uri.parse('https://wa.me/$phone'));
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.delete, size: 24),
                  label: const Text('ELIMINAR', style: TextStyle(fontSize: 16, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: cardColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: const Text('Confirmar eliminación'),
                        content: Text('¿Estás seguro de que deseas eliminar a ${contactoGuardado['nombre']}?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('CANCELAR'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            onPressed: () async {
                              final id = contactoGuardado['id'];
                              await ContactosDatabase.delete(id);
                              if (mounted) {
                                setState(() {
                                  _contactosFuture = ContactosDatabase.getAll();
                                });
                              }
                              if (context.mounted) {
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              }
                            },
                            child: const Text('ELIMINAR', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('CERRAR', style: TextStyle(fontSize: 16, color: Color(0xFF197A89))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding( // Header
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
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
                            'CONTACTOS',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              letterSpacing: 2,
                            ),
                          ),
                          const Icon(Icons.person, color: Colors.white, size: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            Expanded( // Grid de contactos del teléfono
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _contactosFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      final contactos = snapshot.data ?? [];
                      // Mostrar máximo 6 contactos en grid 2x3
                      return GridView.builder(
                        itemCount: 6,
                        padding: EdgeInsets.zero,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.0,
                        ),
                        itemBuilder: (context, index) {
                          if (index < contactos.length) {
                            // Mostrar contacto guardado
                            final contacto = contactos[index];
                            return GestureDetector(
                              onTap: () {
                                _mostrarDetallesContacto(contacto);
                              },
                              child: Card(
                                color: Colors.blue[50],
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 3,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Center(
                                        child: CircleAvatar(
                                          radius: 70,
                                          backgroundColor: mainColor,
                                          backgroundImage: contacto['imagenPath'] != null
                                              ? FileImage(File(contacto['imagenPath']))
                                              : null,
                                          child: contacto['imagenPath'] == null
                                              ? const Icon(Icons.person, color: Colors.white, size: 100)
                                              : null,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          contacto['nombre'] ?? 'Sin nombre',
                                          style: TextStyle(
                                            color: mainColor,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            // Slot vacío con botón + para agregar
                            return GestureDetector(
                              onTap: () {
                                _mostrarAgregarContactoManual();
                              },
                              child: Card(
                                color: cardColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 3,
                                child: Center(
                                  child: Icon(Icons.add, color: mainColor, size: 80),
                                ),
                              ),
                            );
                          }
                        },
                      );
                    }
                  },
                ),
              ),
            ),
            // Botón VOLVER en la parte inferior absoluta
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('VOLVER', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}