import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/riqsi_theme.dart';
import '../../../../state/app_state.dart';

class AyudaScreen extends StatelessWidget {
  const AyudaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context, listen: false);

    // List of voice commands to display
    final List<Map<String, String>> voiceCommands = [
      {"cmd": "“Iniciar asistencia”", "desc": "Activa el escaneo en tiempo real"},
      {"cmd": "“Detener asistencia”", "desc": "Pausa el escaneo de la cámara"},
      {"cmd": "“¿Qué hay delante?”", "desc": "Describe los objetos frente a ti"},
      {"cmd": "“Repetir”", "desc": "Vuelve a pronunciar la última descripción"},
      {"cmd": "“¿Qué detectaste?”", "desc": "Lista las últimas tres detecciones"},
      {"cmd": "“Configuración”", "desc": "Abre el menú de ajustes de voz"},
    ];

    // List of step-by-step instructions
    final List<String> steps = [
      "Apunta la cámara del celular hacia tu entorno.",
      "Presiona el gran botón central para iniciar la asistencia.",
      "Riqsi analizará en tiempo real lo que observa.",
      "Escucha las indicaciones de voz y siente las vibraciones.",
      "Si detecta un posible peligro, emitirá una alerta visual y auditiva.",
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Instrucciones y Ayuda",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Semantics(
          label: "Volver a la pantalla de configuración",
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: RiqsiTheme.accentCyan),
            onPressed: () {
              Navigator.pop(context);
              state.speak("Regresando a configuración.");
            },
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          children: [
            // Title 1
            const Text(
              "Instrucciones de Uso",
              style: TextStyle(
                color: RiqsiTheme.accentCyan,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),

            // Numbered Steps
            ...List.generate(steps.length, (index) {
              return Semantics(
                label: "Paso ${index + 1}: ${steps[index]}",
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 6.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: RiqsiTheme.darkSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: RiqsiTheme.textSecondary.withOpacity(0.08)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: RiqsiTheme.accentCyan,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "${index + 1}",
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          steps[index],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 28),

            // Title 2
            const Text(
              "Comandos de Voz",
              style: TextStyle(
                color: RiqsiTheme.accentCyan,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Riqsi admite comandos de voz. Toca un comando para escuchar su función.",
              style: TextStyle(color: RiqsiTheme.textSecondary, fontSize: 15),
            ),
            const SizedBox(height: 12),

            // Voice Command Cards
            ...voiceCommands.map((command) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: InkWell(
                  onTap: () {
                    state.speak("Comando: ${command['cmd']}. Sirve para: ${command['desc']}");
                    state.vibrate(60);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: RiqsiTheme.darkSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: RiqsiTheme.accentCyan.withOpacity(0.15),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                command['cmd']!,
                                style: const TextStyle(
                                  color: RiqsiTheme.accentCyan,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                command['desc']!,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.volume_up_rounded,
                          color: RiqsiTheme.accentCyan,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
