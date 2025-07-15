import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../frases.dart';

class FrasesPage extends StatefulWidget {
  const FrasesPage({super.key});

  @override
  State<FrasesPage> createState() => _RefranesPageState();
}

class _RefranesPageState extends State<FrasesPage> {
  double fontSize = 24;
  String refran = 'Cargando...';

  @override
  void initState() {
    super.initState();
    cargarRefran();
  }

  void cargarRefran() {
    final now = DateTime.now();
    final index = int.parse(DateFormat("D").format(now)) % frases.length;
    setState(() {
      refran = frases[index]['frase'] ?? 'Frase no disponible';
    });
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
                            'FRASE DEL DÍA',
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      refran,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: fontSize,
                        color: const Color(0xFF000000),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      frases[int.parse(DateFormat("D").format(DateTime.now())) % frases.length]['autor'] ?? '',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        color: Color(0xFF197A89),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
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
                        'assets/logo.png', 
                        width: 180,
                        height: 180,
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