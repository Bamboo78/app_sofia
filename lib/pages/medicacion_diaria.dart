import 'package:flutter/material.dart';
import 'medicacion_listado.dart';

class MedicacionDiariaPage extends StatefulWidget {
  const MedicacionDiariaPage({super.key});

  @override
  State<MedicacionDiariaPage> createState() => _MedicacionDiariaPageState();
}

class _MedicacionDiariaPageState extends State<MedicacionDiariaPage> {
  final List<Map<String, String>> meds = [
    {'name': 'PARACETAMOL', 'desc': 'cada 8 horas', 'hora': '08:00'},
    {'name': 'SINTRON', 'desc': 'sábados', 'hora': '09:30'},
    {'name': 'AMOXICILINA', 'desc': 'tardes', 'hora': '14:00'},
    {'name': 'ENANTIUM', 'desc': 'Subhead', 'hora': '18:00'},
    {'name': 'OMEPRAZOL', 'desc': '2 al día', 'hora': '20:00'},
  ];

  @override
  Widget build(BuildContext context) {
    final Color mainColor = const Color(0xFF197A89);
    final Color cardColor = const Color(0xFFD1E4EA);

    List<Map<String, String>> medsOrdenados = List.from(meds);
    medsOrdenados.sort((a, b) => a['hora']!.compareTo(b['hora']!));

    // Genera una lista de horas del día en formato HH:mm
    // List<String> horasDelDia = List.generate(24, (index) {
    //   final hora = index < 10 ? '0$index:00' : '$index:00';
    //   return hora;
    // });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
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
                            'MEDICACIÓN',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          const Icon(
                            Icons.medication_outlined,
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
            
            Expanded( // Lista de medicación y botón
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal:24),
                child: Column(
                  children: [
                    
                    Expanded( // Lista horaria
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0),
                        child: ListView.builder(
                          itemCount: medsOrdenados.length,
                          itemBuilder: (context, i) {
                            final med = medsOrdenados[i];
                            final hora = med['hora'] ?? '';
                            return Card(
                              color: cardColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 3,
                              child: ListTile(
                                leading: Text(
                                  hora,
                                  style: TextStyle(
                                    color: mainColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                title: Text(
                                  med['name'] ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                subtitle: Text(
                                  med['desc'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                                        
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 80,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mainColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const MedicacionListadoPage()),
                            );
                          },
                          child: const Text(
                            'LISTADO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
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