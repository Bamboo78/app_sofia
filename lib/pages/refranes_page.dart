import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RefranesPage extends StatefulWidget {
  const RefranesPage({super.key});

  @override
  State<RefranesPage> createState() => _RefranesPageState();
}

class _RefranesPageState extends State<RefranesPage> {
  double fontSize = 24;
  String refran = 'Cargando...';

  @override
  void initState() {
    super.initState();
    cargarRefran();
  }

  Future<void> cargarRefran() async {
    final url = Uri.parse('https://zenquotes.io/api/today');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          refran = '"${data[0]['q']}"\n- ${data[0]['a']}';
        });
      } else {
        setState(() {
          refran = 'No se pudo cargar el refrán';
        });
      }
    } catch (e) {
      setState(() {
        refran = 'Error de conexión';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color mainColor = Color(0xFF197A89);
    const Color cardColor = Color(0xFFD1E4EA);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                      decoration: BoxDecoration(
                        color: mainColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'REFRANES',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              letterSpacing: 2,
                            ),
                          ),
                          const Icon(
                            Icons.text_fields,
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

            const SizedBox(height: 40),

            Padding( // Tarjeta del refrán
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 9,
                      offset: Offset(3, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    refran,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: fontSize,
                      color: const Color(0xFF000000),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const Spacer(),
            // Elementos decorativos e imagen abajo
            SizedBox(
              height: 300, 
              child: Padding(
                padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
                child: Stack(
                  children: [
                    // Cuadrados decorativos
                    Positioned(
                      left: 220,
                      bottom: 130,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 160,
                      bottom: 100,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                     
                    Align( // Imagen de usuario
                      alignment: Alignment.bottomLeft,
                      child: Image.asset(
                        'assets/logo.png', // Cambia por la ruta de tu asset
                        width: 160,
                        height: 160,
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
}