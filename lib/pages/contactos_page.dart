import 'package:flutter/material.dart';
import 'contactosficha.dart'; // Asegúrate de importar tu widget de ficha
import 'dart:async';

class ContactosPage extends StatefulWidget {
  const ContactosPage({super.key});

  @override
  State<ContactosPage> createState() => _ContactosPageState();
}

class _ContactosPageState extends State<ContactosPage> {
  final Color mainColor = const Color(0xFF197A89);

  List<Map<String, dynamic>> contactos = List.generate(
    6,
    (_) => {'nombre': 'nombre', 'imagen': null},
  );



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

            Expanded( // Grid de contactos
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GridView.builder(
                  itemCount: contactos.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.1,
                  ),
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        GestureDetector(
                          onLongPress: () {
                            Timer(const Duration(seconds: 2), () {
                              showDialog(
                                context: context,
                                builder: (context) => ContactoFichaDialog(
                                  nombreInicial: contactos[index]['nombre'] ?? '',
                                  telefonoInicial: contactos[index]['telefono'] ?? '',
                                  onGuardar: (nombre, telefono) {
                                    setState(() {
                                      contactos[index]['nombre'] = nombre;
                                      contactos[index]['telefono'] = telefono;
                                    });
                                  },
                                  onEliminar: () {
                                    setState(() {
                                      contactos.removeAt(index);
                                    });
                                    Navigator.of(context).pop();
                                  },
                                ),
                              );
                            });
                          },
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: mainColor,
                            backgroundImage: contactos[index]['imagen'] != null
                                ? FileImage(contactos[index]['imagen'])
                                : null,
                            child: contactos[index]['imagen'] == null
                                ? const Icon(Icons.person, color: Colors.white, size: 80)
                                : null,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          contactos[index]['nombre'],
                          style: TextStyle(
                            color: mainColor,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
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