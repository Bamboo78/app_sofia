import 'package:flutter/material.dart';
import 'favoritosficha.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

class FavoritosPage extends StatefulWidget {
  const FavoritosPage({super.key});

  @override
  State<FavoritosPage> createState() => _FavoritosPageState();
}

class _FavoritosPageState extends State<FavoritosPage> {
  final Color mainColor = const Color(0xFF197A89);

  List<Map<String, dynamic>> contactos = List.generate(
    6,
    (_) => {'nombre': 'nombre', 'imagen': null, 'favorito': ''},
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
                            'FAVORITOS',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              letterSpacing: 2,
                            ),
                          ),
                          const Icon(Icons.public, color: Colors.white, size: 40),
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
                          onTap: () async {
                            final url = contactos[index]['favorito'] ?? '';
                            if (url.isNotEmpty) {
                              final uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                              }
                            }
                          },
                          onLongPress: () {
                            Timer(const Duration(seconds: 2), () {
                              showDialog(
                                context: context,
                                builder: (context) => FavoritosFichaDialog(
                                  nombreInicial: contactos[index]['nombre'] ?? '',
                                  favoritoInicial: contactos[index]['favorito'] ?? '',
                                  onGuardar: (nombre, favorito, [imagen]) {
                                    setState(() {
                                      contactos[index]['nombre'] = nombre;
                                      contactos[index]['favorito'] = favorito;
                                      if (imagen != null) {
                                        contactos[index]['imagen'] = imagen;
                                      }
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
                                ? const Icon(Icons.public, color: Colors.white, size: 80)
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