import 'package:flutter/material.dart';

class ContactosPage extends StatelessWidget {
  const ContactosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contactos'),
      ),
      body: const Center(
        child: Text('Página de Contactos'),
      ),
    );
  }
}