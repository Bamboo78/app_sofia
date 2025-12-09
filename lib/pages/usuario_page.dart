import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sofia/db/usuario_database.dart';
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
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _nombreContactoController = TextEditingController();
  final TextEditingController _telefonoContactoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final usuario = await UsuarioDatabase.getUsuario();
    if (usuario != null && mounted) {
      setState(() {
        _nombreController.text = usuario['nombre'] ?? '';
        _telefonoController.text = usuario['telefono'] ?? '';
        _direccionController.text = usuario['direccion'] ?? '';
        _nombreContactoController.text = usuario['nombreContacto'] ?? '';
        _telefonoContactoController.text = usuario['telefonoContacto'] ?? '';
        if (usuario['imagenPath'] != null) {
          _image = File(usuario['imagenPath']);
        }
        userImagePath = usuario['imagenPath'];
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        userImagePath = pickedFile.path;
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
                _CustomTextField(label: 'TELÉFONO', controller: _telefonoController),
                const SizedBox(height: 16),
                _CustomTextField(label: 'DIRECCIÓN', controller: _direccionController, maxLines: 2),
                const SizedBox(height: 40),
                _CustomTextField(label: 'NOMBRE CONTACTO', controller: _nombreContactoController),
                const SizedBox(height: 16),
                _CustomTextField(label: 'TELÉFONO CONTACTO', controller: _telefonoContactoController),
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
                    onPressed: () async {
                      // Guardar datos en BD
                      await UsuarioDatabase.saveUsuario({
                        'nombre': _nombreController.text,
                        'telefono': _telefonoController.text,
                        'direccion': _direccionController.text,
                        'nombreContacto': _nombreContactoController.text,
                        'telefonoContacto': _telefonoContactoController.text,
                        'imagenPath': userImagePath,
                      });
                      userName = _nombreController.text;
                      if (context.mounted) {
                        Navigator.of(context).pop(true);
                      }
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
  final int maxLines;
  const _CustomTextField({required this.label, this.controller, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    const Color mainColor = Color(0xFF197A89);
    return TextField(
      controller: controller,
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