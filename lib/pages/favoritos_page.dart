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

  void _mostrarOpcionesFavorito(Map<String, dynamic> favorito, int posicion) {
    const Color cardColor = Color(0xFFD1E4EA);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(favorito['nombre'] ?? 'Favorito'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (favorito['imagenPath'] != null && (favorito['imagenPath'] as String).isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(favorito['imagenPath']),
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              if (favorito['imagenPath'] != null && (favorito['imagenPath'] as String).isNotEmpty)
                const SizedBox(height: 16),
              Text(
                favorito['url'] ?? '',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        actions: [
          // Botón ABRIR
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.open_in_browser, size: 20),
              label: const Text('ABRIR', style: TextStyle(fontSize: 14, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: mainColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final url = favorito['url'] ?? '';
                if (url.isNotEmpty) {
                  final uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
                  try {
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('No se pudo abrir la URL')),
                        );
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                }
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
          ),
          const SizedBox(height: 8),
          // Botón MODIFICAR
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.edit, size: 20),
              label: const Text('MODIFICAR', style: TextStyle(fontSize: 14, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                showDialog(
                  context: context,
                  builder: (context) => FavoritosFichaDialog(
                    nombreInicial: favorito['nombre'] ?? '',
                    favoritoInicial: favorito['url'] ?? '',
                    onGuardar: (nombre, url, imagen) async {
                      await FavoritosDatabase.update(posicion, {
                        'nombre': nombre,
                        'url': url,
                        'imagenPath': imagen?.path ?? favorito['imagenPath'],
                      });
                      if (mounted) {
                        setState(() {
                          _favoritosFuture = FavoritosDatabase.getAll();
                        });
                      }
                      if (context.mounted) {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // Botón BORRAR
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.delete, size: 20),
              label: const Text('BORRAR', style: TextStyle(fontSize: 14, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: cardColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    title: const Text('Confirmar eliminación'),
                    content: Text('¿Estás seguro de que deseas eliminar a ${favorito['nombre']}?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('CANCELAR'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () async {
                          await FavoritosDatabase.delete(posicion);
                          if (mounted) {
                            setState(() {
                              _favoritosFuture = FavoritosDatabase.getAll();
                            });
                          }
                          if (context.mounted) {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          }
                        },
                        child: const Text('BORRAR', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // Botón CERRAR
          SizedBox(
            width: double.infinity,
            height: 48,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CERRAR', style: TextStyle(fontSize: 14, color: Color(0xFF197A89))),
            ),
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
                      final favoritos = List<Map<String, dynamic>>.from(snapshot.data ?? []);
                      
                      // Crear un mapa de favoritos por posición (1-6)
                      final favoritosPorPosicion = <int, Map<String, dynamic>>{};
                      for (var favorito in favoritos) {
                        favoritosPorPosicion[favorito['posicion']] = favorito;
                      }
                      
                      return GridView.builder(
                        itemCount: 6,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.9,
                        ),
                        itemBuilder: (context, index) {
                          final posicion = index + 1; // Posiciones 1-6
                          final item = favoritosPorPosicion[posicion];
                          final isEmpty = item == null;
                          
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
                                        'posicion': posicion,
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
                                        Navigator.of(context).pop();
                                      }
                                    },
                                  ),
                                );
                              } else {
                                // Mostrar diálogo con opciones
                                _mostrarOpcionesFavorito(item, posicion);
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
            // Botón VOLVER en la parte inferior absoluta
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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