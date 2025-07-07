import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ContactoFichaDialog extends StatefulWidget {
  final String? nombreInicial;
  final String? telefonoInicial;
  final VoidCallback? onEliminar;
  final void Function(String nombre, String telefono)? onGuardar;

  const ContactoFichaDialog({
    super.key,
    this.nombreInicial,
    this.telefonoInicial,
    this.onEliminar,
    this.onGuardar,
  });

  @override
  State<ContactoFichaDialog> createState() => _ContactoFichaDialogState();
}

class _ContactoFichaDialogState extends State<ContactoFichaDialog> {
  late TextEditingController nombreController;
  late TextEditingController telefonoController;
  File? _imagenSeleccionada;

  @override
  void initState() {
    super.initState();
    nombreController = TextEditingController(text: widget.nombreInicial ?? '');
    telefonoController = TextEditingController(text: widget.telefonoInicial ?? '');
  }

  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagenSeleccionada = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const mainColor = Color(0xFF197A89);

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icono de usuario
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: mainColor,
                borderRadius: BorderRadius.circular(32),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(32),
                onTap: _seleccionarImagen,
                child: _imagenSeleccionada == null
                    ? const Center(
                        child: Icon(Icons.person, color: Colors.white, size: 90),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: Image.file(
                          _imagenSeleccionada!,
                          width: 140,
                          height: 140,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
            // Campo nombre
            TextField(
              controller: nombreController,
              decoration: InputDecoration(
                labelText: 'NOMBRE',
                labelStyle: const TextStyle(color: mainColor, fontWeight: FontWeight.bold),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: mainColor, width: 2),
                  borderRadius: BorderRadius.circular(6),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: mainColor, width: 2.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              cursorColor: mainColor,
            ),
            const SizedBox(height: 12),
            // Campo teléfono
            TextField(
              controller: telefonoController,
              decoration: InputDecoration(
                labelText: 'TELÉFONO',
                labelStyle: const TextStyle(color: mainColor, fontWeight: FontWeight.bold),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: mainColor, width: 2),
                  borderRadius: BorderRadius.circular(6),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: mainColor, width: 2.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              cursorColor: mainColor,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),
            // Botón añadir/eliminar
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 6,
                  shadowColor: Colors.black26,
                ),
                onPressed: () {
                  if (widget.onGuardar != null) {
                    widget.onGuardar!(
                      nombreController.text,
                      telefonoController.text,
                    );
                  }
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'GUARDAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}