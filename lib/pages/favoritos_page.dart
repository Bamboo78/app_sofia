import 'package:flutter/material.dart';
import 'package:sofia/db/favoritos_database.dart';
import 'favoritosficha.dart';
import 'dart:async';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

class FavoritosPage extends StatefulWidget {
  const FavoritosPage({super.key});

  @override
  State<FavoritosPage> createState() => _FavoritosPageState();
}

class _FavoritosPageState extends State<FavoritosPage> {
  final Color mainColor = const Color(0xFF197A89);
  late Future<List<Map<String, dynamic>>> _favoritosFuture;

  @override
  void initState() {
    super.initState();
    _favoritosFuture = FavoritosDatabase.getAll();
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

            Expanded( // Grid de webs favoritas
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _favoritosFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      final favoritos = snapshot.data ?? [];
                      // Crear una lista de 6 items (los existentes + slots vacíos)
                      final totalSlots = 6;
                      final displayFavoritos = [...favoritos];
                      while (displayFavoritos.length < totalSlots) {
                        displayFavoritos.add({'id': null, 'nombre': '', 'url': '', 'imagenPath': null});
                      }
                      
                      return GridView.builder(
                        itemCount: displayFavoritos.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.9,
                        ),
                        itemBuilder: (context, index) {
                          final item = displayFavoritos[index];
                          final isEmpty = item['id'] == null;
                          
                          return GestureDetector(
                            onTap: () async {
                              if (isEmpty) {
                                // Mostrar diálogo para agregar
                                showDialog(
                                  context: context,
                                  builder: (context) => FavoritosFichaDialog(
                                    nombreInicial: '',
                                    favoritoInicial: '',
                                    onGuardar: (nombre, url, imagen) async {
                                      await FavoritosDatabase.insert({
                                        'nombre': nombre,
                                        'url': url,
                                        'imagenPath': imagen?.path,
                                      });
                                      if (mounted) {
                                        setState(() {
                                          _favoritosFuture = FavoritosDatabase.getAll();
                                        });
                                      }
                                      if (context.mounted) {
                                        Navigator.of(context).pop();
                                      }
                                    },
                                  ),
                                );
                              } else {
                                // Abrir URL del favorito
                                final url = item['url'] ?? '';
                                if (url.isNotEmpty) {
                                  final uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                                  }
                                }
                              }
                            },
                            onLongPress: () {
                              if (!isEmpty && context.mounted) {
                                Timer(const Duration(seconds: 2), () {
                                  if (!context.mounted) return;
                                  showDialog(
                                    context: context,
                                    builder: (context) => FavoritosFichaDialog(
                                      nombreInicial: item['nombre'] ?? '',
                                      favoritoInicial: item['url'] ?? '',
                                      onGuardar: (nombre, url, imagen) async {
                                        final id = item['id'];
                                        await FavoritosDatabase.update(id, {
                                          'nombre': nombre,
                                          'url': url,
                                          'imagenPath': imagen?.path,
                                        });
                                        if (mounted) {
                                          setState(() {
                                            _favoritosFuture = FavoritosDatabase.getAll();
                                          });
                                        }
                                        if (context.mounted) {
                                          Navigator.of(context).pop();
                                        }
                                      },
                                      onEliminar: () async {
                                        final id = item['id'];
                                        await FavoritosDatabase.delete(id);
                                        if (mounted) {
                                          setState(() {
                                            _favoritosFuture = FavoritosDatabase.getAll();
                                          });
                                        }
                                        if (context.mounted) {
                                          Navigator.of(context).pop();
                                        }
                                      },
                                    ),
                                  );
                                });
                              }
                            },
                            child: Card(
                              color: isEmpty ? Colors.grey[200] : Colors.blue[50],
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 3,
                              child: isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add, color: mainColor, size: 48),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Añadir',
                                            style: TextStyle(color: mainColor, fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          CircleAvatar(
                                            radius: 50,
                                            backgroundColor: mainColor,
                                            backgroundImage: item['imagenPath'] != null && item['imagenPath']!.isNotEmpty
                                                ? FileImage(File(item['imagenPath']!))
                                                : null,
                                            child: item['imagenPath'] == null || item['imagenPath']!.isEmpty
                                                ? const Icon(Icons.public, color: Colors.white, size: 60)
                                                : null,
                                          ),
                                          const SizedBox(height: 8),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8),
                                            child: Text(
                                              item['nombre'] ?? 'Sin nombre',
                                              style: TextStyle(
                                                color: mainColor,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
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
            ),
          ],
        ),
      ),
    );
  }
}