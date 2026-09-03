import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/riqsi_theme.dart';
import '../../../../state/app_state.dart';
import 'ayuda_screen.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);

    // Dynamic conversion to match image labels
    final String volumePercentage = "${(state.volume * 100).toInt()}%";
    final String speedLabel = "${state.voiceSpeed.toStringAsFixed(0)}x";
    final String vibrationLabel = state.vibrationEnabled ? "Activada" : "Desactivada";

    return Scaffold(
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 20.0),
          children: [
            // Cyan uppercase category marker
            const Text(
              "CONFIGURACIÓN",
              style: TextStyle(
                color: RiqsiTheme.accentCyan,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 6),
            
            // Large bold title
            const Text(
              "Perfil",
              style: TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 16),

            // Profile row
            _buildProfileRow(context, state),
            const SizedBox(height: 16),
            const Divider(color: Color(0xFF1B2C3F), height: 1),
            const SizedBox(height: 16),

            // Preferences Section
            _buildSectionHeader("PREFERENCIAS"),
            
            _buildPreferenceRow(
              label: "Idioma",
              value: state.language,
              onTap: () {
                state.speak("Idioma fijado en Español.");
              },
            ),
            _buildPreferenceRow(
              label: "Servidor IP",
              value: state.serverIp,
              onTap: () {
                _showIpEditDialog(context, state);
              },
            ),
            _buildPreferenceRow(
              label: "Velocidad de voz",
              value: speedLabel,
              onTap: () {
                double newSpeed = 1.0;
                if (state.voiceSpeed == 1.0) {
                  newSpeed = 2.0;
                } else if (state.voiceSpeed == 2.0) {
                  newSpeed = 1.5;
                }
                state.updateVoiceSpeed(newSpeed);
                state.speak("Velocidad de voz a ${newSpeed.toStringAsFixed(1)}.");
              },
            ),
            _buildPreferenceRow(
              label: "Volumen",
              value: volumePercentage,
              onTap: () {
                double newVol = 0.5;
                if (state.volume == 0.5) {
                  newVol = 0.8;
                } else if (state.volume == 0.8) {
                  newVol = 1.0;
                }
                state.updateVolume(newVol);
                state.speak("Volumen al ${(newVol * 100).toInt()} por ciento.");
              },
            ),
            _buildPreferenceRow(
              label: "Vibración",
              value: vibrationLabel,
              onTap: () {
                state.toggleVibration(!state.vibrationEnabled);
                state.speak(!state.vibrationEnabled ? "Vibración activada." : "Vibración desactivada.");
              },
            ),
            _buildPreferenceRow(
              label: "Sensibilidad",
              value: state.sensitivity == "Alta" ? "70%" : state.sensitivity,
              onTap: () {
                String newSens = "70%";
                if (state.sensitivity == "70%" || state.sensitivity == "Alta") {
                  newSens = "90%";
                } else if (state.sensitivity == "90%") {
                  newSens = "50%";
                }
                state.updateSensitivity(newSens);
                state.speak("Sensibilidad de detección fijada al $newSens.");
              },
            ),
            _buildPreferenceRow(
              label: "Modo de accesibilidad",
              value: "Alto contraste",
              onTap: () {
                state.speak("Modo de accesibilidad fijado en alto contraste.");
              },
            ),
            
            const SizedBox(height: 16),
            const Divider(color: Color(0xFF1B2C3F), height: 1),
            const SizedBox(height: 16),

            // Support Section
            _buildSectionHeader("SOPORTE"),
            
            _buildSupportRow(
              label: "Ayuda y comandos",
              onTap: () {
                state.speak("Abriendo pantalla de ayuda.");
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AyudaScreen()),
                );
              },
            ),
            _buildSupportRow(
              label: "Acerca de VisiónAI",
              onTap: () {
                state.speak("Riqsi es un asistente inteligente de visión del entorno para la autonomía de personas con discapacidad visual.");
                _showAboutDialog(context);
              },
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: RiqsiTheme.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildProfileRow(BuildContext context, AppState state) {
    final String displayName = state.userName == "Usuario Riqsi" ? "María González" : state.userName;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF0C1622),
              shape: BoxShape.circle,
              border: Border.all(color: RiqsiTheme.accentCyan, width: 1.5),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: RiqsiTheme.accentCyan,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Usuario activo",
                  style: TextStyle(
                    color: RiqsiTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: RiqsiTheme.accentCyan, size: 20),
            onPressed: () => _showNameEditDialog(context, state),
            tooltip: "Editar nombre",
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceRow({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      label: "$label, valor actual $value",
      hint: "Toca para modificar esta preferencia",
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: RiqsiTheme.textSecondary,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSupportRow({
    required String label,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      label: label,
      hint: "Toca para abrir esta sección",
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: RiqsiTheme.accentCyan,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNameEditDialog(BuildContext context, AppState state) {
    final controller = TextEditingController(text: state.userName == "Usuario Riqsi" ? "María González" : state.userName);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: RiqsiTheme.darkSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Editar Nombre", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white, fontSize: 18),
            decoration: const InputDecoration(
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: RiqsiTheme.accentCyan)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: RiqsiTheme.accentCyan, width: 2)),
              hintText: "Escribe tu nombre",
              hintStyle: TextStyle(color: RiqsiTheme.textSecondary),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar", style: TextStyle(color: RiqsiTheme.textSecondary, fontSize: 16)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: RiqsiTheme.accentCyan),
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  state.updateUserName(controller.text);
                  state.speak("Nombre cambiado a ${controller.text}.");
                }
                Navigator.pop(context);
              },
              child: const Text("Guardar", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        );
      },
    );
  }

  void _showIpEditDialog(BuildContext context, AppState state) {
    final controller = TextEditingController(text: state.serverIp);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: RiqsiTheme.darkSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Editar IP del Servidor", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white, fontSize: 18),
            decoration: const InputDecoration(
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: RiqsiTheme.accentCyan)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: RiqsiTheme.accentCyan, width: 2)),
              hintText: "Ej: 192.168.1.15 o 10.0.2.2",
              hintStyle: TextStyle(color: RiqsiTheme.textSecondary),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar", style: TextStyle(color: RiqsiTheme.textSecondary, fontSize: 16)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: RiqsiTheme.accentCyan),
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  state.updateServerIp(controller.text);
                }
                Navigator.pop(context);
              },
              child: const Text("Guardar", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: RiqsiTheme.darkSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Acerca de VisiónAI", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          content: const Text(
            "VisiónAI (Riqsi) es un asistente visual multiplataforma diseñado para brindar autonomía y acompañamiento a personas con discapacidad visual.\n\nUtiliza la cámara y visión artificial del entorno para detectar obstáculos y riesgos en tiempo real.",
            style: TextStyle(color: Colors.white, fontSize: 16, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cerrar", style: TextStyle(color: RiqsiTheme.accentCyan, fontWeight: FontWeight.bold, fontSize: 18)),
            ),
          ],
        );
      },
    );
  }
}
