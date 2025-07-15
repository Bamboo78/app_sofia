import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'globals.dart';
import 'pages/medicacion_page.dart';
import 'pages/avisos_page.dart';
import 'pages/favoritos_page.dart';
import 'pages/agenda_page.dart';
import 'pages/contactos_page.dart';
import 'pages/frases_page.dart';
import 'pages/usuario_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sofía',
      debugShowCheckedModeBanner: false, // quita debug banner
      theme: ThemeData(
        fontFamily: 'Montserrat', 
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF197A89)),
      ),
      home: const SofiaApp(),
    );
  }
}

class SofiaApp extends StatefulWidget {
  const SofiaApp({super.key});

  @override
  State<SofiaApp> createState() => _SofiaAppState();
}

class _SofiaAppState extends State<SofiaApp> {
  double splashOpacity = 1.0;
  double homeOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    // desvanece el splash y muestra la home al mismo tiempo
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        splashOpacity = 0.0;
        homeOpacity = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFF197A89),
      body: Stack(
        children: [
          AnimatedOpacity(
            opacity: homeOpacity,
            duration: const Duration(seconds: 2),
            child: MyHomePage(title: 'Sofia Home Page'),
          ),
          
          AnimatedOpacity(
            opacity: splashOpacity,
            duration: const Duration(seconds: 2),
            child: Center(
              child: SizedBox(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/logo.png',
                      width: size.width * 0.4,
                      height: size.width * 0.4,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Sofía',
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    // Hace visible la página principal después de que se construye
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _opacity = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color mainColor = Color(0xFF197A89);
    const Color cardColor = Color(0xFFD1E4EA);
    
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: AnimatedOpacity(
        opacity: _opacity,
        duration: const Duration(seconds: 3),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const UsuarioPage()),
                        ).then((_) {
                          setState(() {}); // Para refrescar si se cambia la imagen
                        });
                      },
                      child: Container( //avatar del usuario
                        decoration: BoxDecoration(
                          color: mainColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: cardColor,
                              blurRadius: 9,
                              offset: Offset(3, 3),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(4),
                        child: userImagePath != null
                            ? ClipOval(
                                child: Image.file(
                                  File(userImagePath!),
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Icon(Icons.person, color: Color(0xFFFFFFFF), size: 60),
                      ),
                    ),
                    
                    SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: mainColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFFFFF),
                              blurRadius: 9,
                              offset: Offset(3, 3),
                            ),
                          ],
                        ),
                        child: Text( //nombre de bienvenida
                          'Hola${userName.isNotEmpty ? ' $userName' : ''}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),

                    GestureDetector( //popup de cierre
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('¿Qué deseas hacer?'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(height: 8),
                                Image.asset(
                                  'assets/logo.png',
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.contain,
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(); 
                                },
                                child: const Text('Cerrar sesión'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  exit(0);
                                },
                                child: const Text('Cerrar aplicación'),
                              ),
                            ],
                          ),
                        );
                      },
                      

                      child: Container( //icono de cerrar
                        decoration: BoxDecoration(
                          color: mainColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFFFFFFFF),
                              blurRadius: 9,
                              offset: Offset(3, 3),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Icon(Icons.close, color: Color(0xFFFFFFFF), size: 60),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                Expanded( //contenido de las terjetas
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: _MenuCard(
                                icon: Icons.error_outline,
                                label: 'AVISOS',
                                color: mainColor,
                                cardColor: cardColor,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const AvisosPage()),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _MenuCard(
                                icon: Icons.public,
                                label: 'FAVORITOS',
                                color: mainColor,
                                cardColor: cardColor,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const FavoritosPage()),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: _MenuCard(
                                icon: Icons.calendar_month,
                                label: 'AGENDA',
                                color: mainColor,
                                cardColor: cardColor,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const AgendaPage()),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _MenuCard(
                                icon: Icons.medication_outlined,
                                label: 'MEDICACIÓN',
                                color: mainColor,
                                cardColor: cardColor,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const MedicacionPage()),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: _MenuCard(
                                icon: Icons.person_outline,
                                label: 'CONTACTOS',
                                color: mainColor,
                                cardColor: cardColor,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const ContactosPage()),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _MenuCard(
                                icon: Icons.text_fields,
                                label: 'FRASE DEL DÍA',
                                color: mainColor,
                                cardColor: cardColor,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const FrasesPage()),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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

// Widget para los botones del menú
class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color cardColor;
  final VoidCallback? onTap; 

  const _MenuCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.cardColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card( //diseño de las tarjetas
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap, 
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 80),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      )
    );  
  }
}
