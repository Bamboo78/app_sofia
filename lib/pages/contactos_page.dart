import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:url_launcher/url_launcher.dart';
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

  Future<List<Contact>> _obtenerTodosContactos() async {
    try {
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: true,
      );
      return contacts;
    } catch (e) {
      return [];
    }
  }

  void _seleccionarContacto(Contact contact) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Seleccionar contacto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (contact.photo != null)
              CircleAvatar(
                radius: 50,
                backgroundImage: MemoryImage(contact.photo!),
              ),
            const SizedBox(height: 16),
            Text(
              contact.displayName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            if (contact.phones.isNotEmpty)
              Text(
                contact.phones.first.number,
                style: const TextStyle(fontSize: 14),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: mainColor),
            onPressed: () async {
              // Guardar contacto seleccionado
              await ContactosDatabase.insert({
                'nombre': contact.displayName,
                'telefono': contact.phones.isNotEmpty ? contact.phones.first.number : '',
                'imagenPath': null,
              });
              if (mounted) {
                setState(() {
                  _contactosFuture = ContactosDatabase.getAll();
                });
              }
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('GUARDAR'),
          ),
        ],
      ),
    );
  }

  void _mostrarSeleccionador(List<Contact> contactos) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Seleccionar contacto'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: contactos.map((contact) {
              return ListTile(
                leading: contact.photo != null
                    ? CircleAvatar(
                        backgroundImage: MemoryImage(contact.photo!),
                      )
                    : CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                title: Text(contact.displayName),
                subtitle: contact.phones.isNotEmpty
                    ? Text(contact.phones.first.number)
                    : null,
                onTap: () {
                  Navigator.of(context).pop();
                  _seleccionarContacto(contact);
                },
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CERRAR'),
          ),
        ],
      ),
    );
  }

  void _mostrarDetallesContacto(Map<String, dynamic> contactoGuardado) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(contactoGuardado['nombre'] ?? 'Sin nombre'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Teléfono: ${contactoGuardado['telefono'] ?? 'Sin teléfono'}',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CERRAR'),
          ),
          if ((contactoGuardado['telefono'] ?? '').isNotEmpty)
            ElevatedButton.icon(
              icon: const Icon(Icons.phone),
              label: const Text('LLAMAR'),
              style: ElevatedButton.styleFrom(backgroundColor: mainColor),
              onPressed: () {
                launchUrl(Uri(scheme: 'tel', path: contactoGuardado['telefono']));
                Navigator.of(context).pop();
              },
            ),
          if ((contactoGuardado['telefono'] ?? '').isNotEmpty)
            ElevatedButton.icon(
              icon: const Icon(Icons.message),
              label: const Text('WHATSAPP'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                final phone = contactoGuardado['telefono'].replaceAll(RegExp(r'[^\d]'), '');
                launchUrl(Uri.parse('https://wa.me/$phone'));
                Navigator.of(context).pop();
              },
            ),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete),
            label: const Text('ELIMINAR'),
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
              }
            },
          ),
        ],
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
            SizedBox(height: 32),

            Expanded( // Grid de contactos del teléfono
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
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
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 1.1,
                        ),
                        itemBuilder: (context, index) {
                          if (index < contactos.length) {
                            // Mostrar contacto guardado
                            final contacto = contactos[index];
                            return GestureDetector(
                              onTap: () {
                                _mostrarDetallesContacto(contacto);
                              },
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 60,
                                    backgroundColor: mainColor,
                                    backgroundImage: contacto['imagenPath'] != null
                                        ? FileImage(File(contacto['imagenPath']))
                                        : null,
                                    child: contacto['imagenPath'] == null
                                        ? const Icon(Icons.person, color: Colors.white, size: 80)
                                        : null,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    contacto['nombre'] ?? 'Sin nombre',
                                    style: TextStyle(
                                      color: mainColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          } else {
                            // Slot vacío con botón + para agregar
                            return GestureDetector(
                              onTap: () async {
                                final contacts = await _obtenerTodosContactos();
                                if (mounted) {
                                  _mostrarSeleccionador(contacts);
                                }
                              },
                              child: Card(
                                color: cardColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 3,
                                child: Center(
                                  child: Icon(Icons.add, color: mainColor, size: 60),
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
          ],
        ),
      ),
    );
  }
}