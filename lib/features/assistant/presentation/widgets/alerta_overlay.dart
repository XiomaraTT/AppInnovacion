import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/riqsi_theme.dart';
import '../../../../state/app_state.dart';

class AlertaOverlay extends StatefulWidget {
  const AlertaOverlay({super.key});

  @override
  State<AlertaOverlay> createState() => _AlertaOverlayState();
}

class _AlertaOverlayState extends State<AlertaOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _colorController;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _colorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);

    _colorAnimation = ColorTween(
      begin: const Color(0xFF0F0000), // Deep black-red
      end: RiqsiTheme.alertHigh, // Vibrant alert red
    ).animate(_colorController);
  }

  @override
  void dispose() {
    _colorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        final state = Provider.of<AppState>(context);
        final detection = state.activeDetection;
        final label = detection?.label ?? "Objeto";
        final pos = detection?.relativePosition ?? "Adelante";
        final displayText = pos == "Adelante" ? "$label adelante" : "$label a la $pos";

        return Scaffold(
          backgroundColor: _colorAnimation.value,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  
                  // Massive Glowing Warning Icon
                  Semantics(
                    label: "Icono de alerta de peligro",
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black45,
                            blurRadius: 20,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.report_gmailerrorred_rounded,
                        size: 96,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Danger Title (Flash/Alert)
                  Text(
                    "¡CUIDADO!",
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Object name
                  Text(
                    displayText,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  // Proximity / Details
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "MUY CERCA",
                      style: TextStyle(
                        color: RiqsiTheme.accentCyan,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  
                  const Spacer(),

                  // Giant Accessible Dismiss Button
                  Semantics(
                    button: true,
                    label: "Entendido, descartar alerta y reanudar asistencia",
                    child: Container(
                      width: double.infinity,
                      height: 80, // Very large height for quick tapping
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ElevatedButton(
                        onPressed: () {
                          final state = Provider.of<AppState>(context, listen: false);
                          state.dismissAlert();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 6,
                        ),
                        child: const Text(
                          "Entendido",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
