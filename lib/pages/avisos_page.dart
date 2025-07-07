import 'package:flutter/material.dart';

class AvisosPage extends StatefulWidget {
  const AvisosPage({super.key});

  @override
  State<AvisosPage> createState() => _AvisosPageState();
}

class _AvisosPageState extends State<AvisosPage> {
  bool activado = false;

  @override
  Widget build(BuildContext context) {
    const Color mainColor = Color(0xFF197A89);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              
              Expanded( // Header y campos en un Expanded
                  child: Column(
                    children: [
                      Row(
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
                                    'AVISOS',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  const Icon(Icons.info_outline, color: Colors.white, size: 60),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 80),
                      _AvisosTextField(label: 'NOMBRE CONTACTO'),
                      const SizedBox(height: 16),
                      _AvisosTextField(label: 'TELÉFONO CONTACTO'),
                      const SizedBox(height: 16),
                      _AvisosTextField(
                        label: 'MENSAJE',
                        maxLines: 4,
                      ),
                      const SizedBox(height: 16),
                      _AvisosTextField(label: 'HORA INICIO'),
                      const SizedBox(height: 16),
                      _AvisosTextField(label: 'HORA FINAL'),
                      const SizedBox(height: 32),
                    ],
                  ),
              ),
              
              SizedBox( // Botón abajo del todo
                width: double.infinity,
                height: 80,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: activado ? Colors.grey : mainColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    shadowColor: Colors.black26,
                  ),
                  onPressed: () {
                    setState(() {
                      activado = !activado;
                    });
                  },
                  child: Text(
                    activado ? 'APAGADO' : 'ACTIVADO',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvisosTextField extends StatelessWidget {
  final String label;
  final int maxLines;
  const _AvisosTextField({required this.label, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    const Color mainColor = Color(0xFF197A89);
    return TextField(
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: mainColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: mainColor, width: 1),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: mainColor, width: 4),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      cursorColor: mainColor,
    );
  }
}