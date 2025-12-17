import 'package:flutter/material.dart';
import 'dart:async';
import '../db/avisos_database.dart';

class AvisosPage extends StatefulWidget {
  const AvisosPage({super.key});

  @override
  State<AvisosPage> createState() => _AvisosPageState();
}

class _AvisosPageState extends State<AvisosPage> {
  bool activado = false;
  int? horaInicio;
  int? horaFinal;
  int? intervalo;
  int? avisoId; // Para guardar el ID del aviso si está editando
  Timer? _saveTimer; // Timer para guardar automáticamente

  final TextEditingController _nombreContactoController = TextEditingController();
  final TextEditingController _telefonoContactoController = TextEditingController();
  final TextEditingController _mensajeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Listener para guardar automáticamente cuando se cambian los campos de texto
    _nombreContactoController.addListener(_onFieldChanged);
    _telefonoContactoController.addListener(_onFieldChanged);
    _mensajeController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    // Cancelar timer anterior si existe
    _saveTimer?.cancel();
    
    // Crear nuevo timer para guardar después de 1 segundo de inactividad
    _saveTimer = Timer(const Duration(seconds: 1), _saveToDatabase);
  }

  Future<void> _saveToDatabase() async {
    if (horaInicio == null || horaFinal == null || intervalo == null) {
      return; // No guardar si faltan campos requeridos
    }

    if (_nombreContactoController.text.isEmpty || 
        _telefonoContactoController.text.isEmpty ||
        _mensajeController.text.isEmpty) {
      return; // No guardar si hay campos vacíos
    }

    try {
      if (avisoId == null) {
        await AvisosDatabase.insert({
          'nombreContacto': _nombreContactoController.text,
          'telefonoContacto': _telefonoContactoController.text,
          'mensaje': _mensajeController.text,
          'horaInicio': '${horaInicio!.toString().padLeft(2, '0')}:00',
          'horaFinal': '${horaFinal!.toString().padLeft(2, '0')}:00',
          'intervalo': intervalo,
          'activado': activado ? 1 : 0,
          'lastUsedTime': DateTime.now().toIso8601String(),
        });
      } else {
        await AvisosDatabase.update(avisoId!, {
          'nombreContacto': _nombreContactoController.text,
          'telefonoContacto': _telefonoContactoController.text,
          'mensaje': _mensajeController.text,
          'horaInicio': '${horaInicio!.toString().padLeft(2, '0')}:00',
          'horaFinal': '${horaFinal!.toString().padLeft(2, '0')}:00',
          'intervalo': intervalo,
          'activado': activado ? 1 : 0,
        });
      }
    } catch (e) {
      // Silenciar errores de guardado automático
    }
  }

  @override
  void dispose() {
    _nombreContactoController.dispose();
    _telefonoContactoController.dispose();
    _mensajeController.dispose();
    _saveTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color mainColor = Color(0xFF197A89);

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              
              Expanded( // Header y campos en un Expanded
                  child: SingleChildScrollView(
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
                        const SizedBox(height: 40),
                        _AvisosTextField(
                          label: 'NOMBRE CONTACTO',
                          controller: _nombreContactoController,
                        ),
                        const SizedBox(height: 16),
                        _AvisosTextField(
                          label: 'TELÉFONO CONTACTO',
                          controller: _telefonoContactoController,
                        ),
                        const SizedBox(height: 16),
                        _AvisosTextField(
                          label: 'MENSAJE',
                          controller: _mensajeController,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 32),
                        _HourDropdown(
                          label: 'HORA INICIO',
                          selectedHour: horaInicio,
                          onHourChanged: (value) {
                            setState(() {
                              horaInicio = value;
                            });
                            _onFieldChanged();
                          },
                        ),
                        const SizedBox(height: 16),
                        _HourDropdown(
                          label: 'HORA FINAL',
                          selectedHour: horaFinal,
                          onHourChanged: (value) {
                            setState(() {
                              horaFinal = value;
                            });
                            _onFieldChanged();
                          },
                        ),
                        const SizedBox(height: 16),
                        _IntervalDropdown(
                          selectedInterval: intervalo,
                          onIntervalChanged: (value) {
                            setState(() {
                              intervalo = value;
                            });
                            _onFieldChanged();
                          },
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
              ),
              
              SizedBox( // Switch ACTIVADO/DESACTIVADO con deslizante
                width: double.infinity,
                height: 60,
                child: Card(
                  color: const Color(0xFFD1E4EA),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          activado ? 'ACTIVADO' : 'DESACTIVADO',
                          style: TextStyle(
                            color: activado ? mainColor : Colors.grey,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Switch(
                          value: activado,
                          onChanged: (value) async {
                            if (horaInicio == null || horaFinal == null || intervalo == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Por favor completa todos los campos')),
                              );
                              return;
                            }

                            if (_nombreContactoController.text.isEmpty || 
                                _telefonoContactoController.text.isEmpty ||
                                _mensajeController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Por favor completa todos los campos')),
                              );
                              return;
                            }

                            setState(() {
                              activado = value;
                            });

                            // Guardar o actualizar en base de datos automáticamente
                            if (avisoId == null) {
                              await AvisosDatabase.insert({
                                'nombreContacto': _nombreContactoController.text,
                                'telefonoContacto': _telefonoContactoController.text,
                                'mensaje': _mensajeController.text,
                                'horaInicio': '${horaInicio!.toString().padLeft(2, '0')}:00',
                                'horaFinal': '${horaFinal!.toString().padLeft(2, '0')}:00',
                                'intervalo': intervalo,
                                'activado': value ? 1 : 0,
                                'lastUsedTime': DateTime.now().toIso8601String(),
                              });
                            } else {
                              await AvisosDatabase.update(avisoId!, {
                                'nombreContacto': _nombreContactoController.text,
                                'telefonoContacto': _telefonoContactoController.text,
                                'mensaje': _mensajeController.text,
                                'horaInicio': '${horaInicio!.toString().padLeft(2, '0')}:00',
                                'horaFinal': '${horaFinal!.toString().padLeft(2, '0')}:00',
                                'intervalo': intervalo,
                                'activado': value ? 1 : 0,
                              });
                            }
                          },
                          activeThumbColor: mainColor,
                          inactiveThumbColor: Colors.grey,
                          inactiveTrackColor: Colors.grey[300],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Botón VOLVER en la parte inferior absoluta
              SizedBox(
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
  final TextEditingController? controller;
  const _AvisosTextField({
    required this.label,
    this.maxLines = 1,
    this.controller,
  });

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

class _HourDropdown extends StatelessWidget {
  final String label;
  final int? selectedHour;
  final Function(int) onHourChanged;

  const _HourDropdown({
    required this.label,
    required this.selectedHour,
    required this.onHourChanged,
  });

  @override
  Widget build(BuildContext context) {
    const Color mainColor = Color(0xFF197A89);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: mainColor, width: 1),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: DropdownButton<int>(
        isExpanded: true,
        underline: const SizedBox(),
        hint: Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 16),
        ),
        value: selectedHour,
        items: List.generate(24, (index) {
          final hour = index + 1;
          return DropdownMenuItem<int>(
            value: hour,
            child: Text(
              '${hour.toString().padLeft(2, '0')}:00',
              style: const TextStyle(fontSize: 16),
            ),
          );
        }),
        onChanged: (value) {
          if (value != null) {
            onHourChanged(value);
          }
        },
      ),
    );
  }
}

class _IntervalDropdown extends StatelessWidget {
  final int? selectedInterval;
  final Function(int) onIntervalChanged;

  const _IntervalDropdown({
    required this.selectedInterval,
    required this.onIntervalChanged,
  });

  @override
  Widget build(BuildContext context) {
    const Color mainColor = Color(0xFF197A89);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: mainColor, width: 1),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: DropdownButton<int>(
        isExpanded: true,
        underline: const SizedBox(),
        hint: const Text(
          'INTERVALO',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
        value: selectedInterval,
        items: List.generate(4, (index) {
          final hours = index + 1;
          return DropdownMenuItem<int>(
            value: hours,
            child: Text(
              '$hours ${hours == 1 ? 'hora' : 'horas'}',
              style: const TextStyle(fontSize: 16),
            ),
          );
        }),
        onChanged: (value) {
          if (value != null) {
            onIntervalChanged(value);
          }
        },
      ),
    );
  }
}