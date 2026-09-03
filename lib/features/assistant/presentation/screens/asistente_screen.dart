import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/riqsi_theme.dart';
import '../../../../state/app_state.dart';
import '../widgets/camera_simulator.dart';
import '../widgets/accessible_button.dart';

class AsistenteScreen extends StatefulWidget {
  const AsistenteScreen({super.key});

  @override
  State<AsistenteScreen> createState() => _AsistenteScreenState();
}

class _AsistenteScreenState extends State<AsistenteScreen> {
  bool _showSimPanel = false;

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final isScanning = state.assistanceState != AssistanceState.inactive;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // 1. Header Status Bar
              _buildStatusBar(state),

              // 2. Camera AI Scanner Preview
              CameraSimulator(state: state),

              // 3. Subtitles / Speech Bubble Overlay
              _buildSubtitleBubble(state),

              // 4. Quick Repeat Text Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Semantics(
                  button: true,
                  label: "Repetir última descripción hablada",
                  child: TextButton.icon(
                    onPressed: state.repeatLastSpoken,
                    icon: const Icon(Icons.volume_up_rounded, color: RiqsiTheme.accentCyan, size: 28),
                    label: const Text(
                      "Repetir última descripción",
                      style: TextStyle(
                        color: RiqsiTheme.accentCyan,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 5. Action Row (Mute, HUGE Center Button, Mute Vib)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Mute / Sound Toggle
                    AccessibleIconButton(
                      icon: state.volume > 0 ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                      label: state.volume > 0 ? "Desactivar voz" : "Activar voz",
                      onPressed: () {
                        final newVal = state.volume > 0 ? 0.0 : 0.8;
                        state.updateVolume(newVal);
                        state.speak(newVal > 0 ? "Voz activada" : "");
                      },
                      isActive: state.volume > 0,
                    ),

                    // HUGE Action Button
                    Semantics(
                      button: true,
                      label: isScanning ? "Detener asistencia de visión" : "Iniciar asistencia de visión",
                      hint: isScanning ? "Detiene el escaneo continuo" : "Inicia el escaneo con cámara del entorno",
                      child: InkWell(
                        onTap: state.toggleAssistance,
                        borderRadius: BorderRadius.circular(55),
                        child: Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            color: isScanning ? RiqsiTheme.alertHigh : RiqsiTheme.accentCyan,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (isScanning ? RiqsiTheme.alertHigh : RiqsiTheme.accentCyan).withOpacity(0.4),
                                blurRadius: 20,
                                spreadRadius: 4,
                              )
                            ],
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: Icon(
                            isScanning ? Icons.stop_rounded : Icons.play_arrow_rounded,
                            size: 64,
                            color: isScanning ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),

                    // Vibration Toggle
                    AccessibleIconButton(
                      icon: state.vibrationEnabled ? Icons.vibration_rounded : Icons.portable_wifi_off_rounded,
                      label: state.vibrationEnabled ? "Desactivar vibración" : "Activar vibración",
                      onPressed: () {
                        state.toggleVibration(!state.vibrationEnabled);
                      },
                      isActive: state.vibrationEnabled,
                    ),
                  ],
                ),
              ),
              
              // Simulation panel drawer button at bottom
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0, bottom: 8.0),
                  child: FloatingActionButton.small(
                    backgroundColor: RiqsiTheme.darkSurface,
                    foregroundColor: RiqsiTheme.accentCyan,
                    shape: const CircleBorder(side: BorderSide(color: RiqsiTheme.accentCyan, width: 1.5)),
                    onPressed: () {
                      setState(() {
                        _showSimPanel = !_showSimPanel;
                      });
                    },
                    tooltip: "Abrir simulador de estados",
                    child: Icon(_showSimPanel ? Icons.close : Icons.build_rounded),
                  ),
                ),
              ),

              // Collapsible Testing panel overlay
              if (_showSimPanel) _buildSimulationDrawer(state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBar(AppState state) {
    final statusColor = state.assistanceState == AssistanceState.riskDetected
        ? RiqsiTheme.alertHigh
        : (state.assistanceState == AssistanceState.objectDetected
            ? RiqsiTheme.accentCyan
            : Colors.green);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Connection Status
          if (!state.isConnected)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: RiqsiTheme.alertMedium.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: RiqsiTheme.alertMedium),
              ),
              child: const Row(
                children: [
                  Icon(Icons.wifi_off_rounded, size: 16, color: RiqsiTheme.alertMedium),
                  SizedBox(width: 6),
                  Text("OFFLINE", style: TextStyle(color: RiqsiTheme.alertMedium, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            )
          else
            const SizedBox.shrink(),

          // Main status indicator text
          Expanded(
            child: Text(
              state.currentStatusMessage,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: statusColor,
                    fontSize: 22,
                  ),
              textAlign: TextAlign.center,
            ),
          ),

          // Micro Indicator Dot
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitleBubble(AppState state) {
    if (state.lastSpokenDescription.isEmpty) {
      return const SizedBox(height: 70); // Placeholder space
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: RiqsiTheme.darkSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: RiqsiTheme.accentCyan.withOpacity(0.4), width: 1.5),
        ),
        child: Row(
          children: [
            const Icon(Icons.volume_up_rounded, color: RiqsiTheme.accentCyan, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                state.lastSpokenDescription,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimulationDrawer(AppState state) {
    return Container(
      color: RiqsiTheme.darkSurface,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            children: [
              Icon(Icons.tune_rounded, color: RiqsiTheme.accentCyan),
              SizedBox(width: 8),
              Text(
                "Panel de Simulación de Estados",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildSimButton(
                  "Persona",
                  Colors.green,
                  () => state.triggerObjectDetection(
                    DetectionEvent(
                      id: 'sim-person',
                      label: 'Persona',
                      relativePosition: 'Izquierda',
                      riskLevel: 'Bajo',
                      timestamp: DateTime.now(),
                      description: 'Persona a la izquierda, a dos metros.',
                    ),
                  ),
                ),
                _buildSimButton(
                  "Escalón",
                  Colors.orange,
                  () => state.triggerObjectDetection(
                    DetectionEvent(
                      id: 'sim-step',
                      label: 'Escalón',
                      relativePosition: 'Adelante',
                      riskLevel: 'Medio',
                      timestamp: DateTime.now(),
                      description: 'Escalón adelante. Preste atención.',
                    ),
                  ),
                ),
                _buildSimButton(
                  "Automóvil (CRÍTICO)",
                  Colors.red,
                  () => state.triggerHighRiskAlert(
                    DetectionEvent(
                      id: 'sim-car',
                      label: 'Automóvil',
                      relativePosition: 'Adelante',
                      riskLevel: 'Alto',
                      timestamp: DateTime.now(),
                      description: '¡Cuidado! Automóvil adelante, muy cerca.',
                    ),
                  ),
                ),
                _buildSimButton(
                  "Cámara Error",
                  Colors.purple,
                  state.simulateCameraError,
                ),
                _buildSimButton(
                  "Offline Mode",
                  Colors.blue,
                  state.simulateOffline,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimButton(String label, Color color, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.2),
          side: BorderSide(color: color),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: onTap,
        child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
