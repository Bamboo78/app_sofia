import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../globals.dart';

class UsuarioPage extends StatefulWidget {
  const UsuarioPage({super.key});

  @override
  State<UsuarioPage> createState() => _UsuarioPageState();
}

class _UsuarioPageState extends State<UsuarioPage> {
  File? _image;
  final TextEditingController _nombreController = TextEditingController();

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        userImagePath = pickedFile.path; // guarda la ruta globalmente
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color mainColor = Color(0xFF197A89);
    const Color cardColor = Color(0xFFD1E4EA);

    return Scaffold(
      backgroundColor: cardColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              children: [
                const SizedBox(height: 40),
                // Avatar como botón
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 80,
                    backgroundColor: mainColor,
                    backgroundImage: _image != null ? FileImage(_image!) : null,
                    child: _image == null
                        ? Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 80,
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 40),
                // Campos de texto
                _CustomTextField(label: 'NOMBRE', controller: _nombreController),
                const SizedBox(height: 16),
                _CustomTextField(label: 'TELÉFONO'),
                const SizedBox(height: 16),
                _CustomTextField(label: 'DIRECCIÓN'),
                const SizedBox(height: 40),
                _CustomTextField(label: 'NOMBRE CONTACTO'),
                const SizedBox(height: 16),
                _CustomTextField(label: 'TELÉFONO CONTACTO'),
                const SizedBox(height: 40),
                // Botón confirmar
                SizedBox(
                  width: double.infinity,
                  height: 80,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      shadowColor: Colors.black26,
                    ),
                    onPressed: () {
                      userName = _nombreController.text;
                      Navigator.of(context).pop(true); // Devuelve true para refrescar la barra
                    },
                    child: const Text(
                      'CONFIRMAR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
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
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  const _CustomTextField({required this.label, this.controller});

  @override
  Widget build(BuildContext context) {
    const Color mainColor = Color(0xFF197A89);
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: mainColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: mainColor, width: 1),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: mainColor, width: 4),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      cursorColor: mainColor,
    );
  }
}