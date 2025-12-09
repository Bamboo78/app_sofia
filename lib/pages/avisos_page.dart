import 'package:flutter/material.dart';
import '../db/avisos_database.dart';

class AvisosPage extends StatefulWidget {
  const AvisosPage({super.key});

  @override
  State<AvisosPage> createState() => _AvisosPageState();
}

class _AvisosPageState extends State<AvisosPage> {
  bool activado = false;
  TimeOfDay? horaInicio;
  TimeOfDay? horaFinal;
  int? intervalo;

  final TextEditingController _nombreContactoController = TextEditingController();
  final TextEditingController _telefonoContactoController = TextEditingController();
  final TextEditingController _mensajeController = TextEditingController();

  @override
  void dispose() {
    _nombreContactoController.dispose();
    _telefonoContactoController.dispose();
    _mensajeController.dispose();
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
                        const SizedBox(height: 80),
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
                          maxLines: 4,
                        ),
                        const SizedBox(height: 16),
                        _TimePickerField(
                          label: 'HORA INICIO',
                          selectedTime: horaInicio,
                          onTimeChanged: (time) {
                            setState(() {
                              horaInicio = time;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        _TimePickerField(
                          label: 'HORA FINAL',
                          selectedTime: horaFinal,
                          onTimeChanged: (time) {
                            setState(() {
                              horaFinal = time;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        _IntervalDropdown(
                          selectedInterval: intervalo,
                          onIntervalChanged: (value) {
                            setState(() {
                              intervalo = value;
                            });
                          },
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
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
                  onPressed: () async {
                    if (horaInicio == null || horaFinal == null || intervalo == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Por favor completa todos los campos')),
                      );
                      return;
                    }

                    setState(() {
                      activado = !activado;
                    });

                    // Guardar en base de datos
                    await AvisosDatabase.insert({
                      'nombreContacto': _nombreContactoController.text,
                      'telefonoContacto': _telefonoContactoController.text,
                      'mensaje': _mensajeController.text,
                      'horaInicio': '${horaInicio!.hour.toString().padLeft(2, '0')}:${horaInicio!.minute.toString().padLeft(2, '0')}',
                      'horaFinal': '${horaFinal!.hour.toString().padLeft(2, '0')}:${horaFinal!.minute.toString().padLeft(2, '0')}',
                      'intervalo': intervalo,
                      'activado': activado ? 1 : 0,
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

class _TimePickerField extends StatelessWidget {
  final String label;
  final TimeOfDay? selectedTime;
  final Function(TimeOfDay) onTimeChanged;

  const _TimePickerField({
    required this.label,
    required this.selectedTime,
    required this.onTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    const Color mainColor = Color(0xFF197A89);
    
    return GestureDetector(
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: selectedTime ?? TimeOfDay.now(),
        );
        if (time != null) {
          onTimeChanged(time);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: mainColor, width: 1),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        child: Row(
          children: [
            Icon(Icons.schedule, size: 20, color: mainColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selectedTime != null
                    ? '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}'
                    : label,
                style: TextStyle(
                  color: selectedTime != null ? Colors.black87 : Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
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
        items: List.generate(6, (index) {
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