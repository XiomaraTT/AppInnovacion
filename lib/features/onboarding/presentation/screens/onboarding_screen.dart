import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/riqsi_theme.dart';
import '../../../../state/app_state.dart';
import '../../../assistant/presentation/widgets/accessible_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextPage(AppState state) {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding(state);
    }
  }

  void _finishOnboarding(AppState state) {
    state.navigateToScreen(AppScreen.initialConfig);
    state.speak("Bienvenido a Riqsi. Por favor, configure sus preferencias de voz y accesibilidad.");
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context, listen: false);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button at top right (Only for screens 1 & 2)
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _currentPage < 2
                    ? TextButton(
                        onPressed: () => _finishOnboarding(state),
                        child: const Text(
                          "Omitir",
                          style: TextStyle(
                            color: RiqsiTheme.accentCyan,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : const SizedBox(height: 48),
              ),
            ),
            
            // Onboarding Pages Content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                  // Accessible announcement when switching slides
                  if (page == 0) {
                    state.speak("Paso 1: Conoce tu entorno.");
                  } else if (page == 1) {
                    state.speak("Paso 2: Escucha lo que Riqsi detecta.");
                  } else {
                    state.speak("Paso 3: Muévete con confianza.");
                  }
                },
                children: [
                  _buildPage(
                    title: "Conoce tu entorno",
                    description: "Riqsi utiliza la cámara de tu celular para identificar los elementos y objetos a tu alrededor.",
                    illustration: _buildCameraIllustration(),
                  ),
                  _buildPage(
                    title: "Escucha lo que Riqsi detecta",
                    description: "La aplicación te comunicará qué objetos o personas hay en tu entorno principalmente mediante voz y vibraciones.",
                    illustration: _buildVoiceIllustration(),
                  ),
                  _buildPage(
                    title: "Muévete con confianza",
                    description: "Riqsi te guiará reconociendo obstáculos, puertas y escalones para que te desplaces de forma segura.",
                    illustration: _buildConfidenceIllustration(),
                  ),
                ],
              ),
            ),

            // Pagination Dots indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) => _buildDot(index)),
              ),
            ),

            // Bottom Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: AccessibleButton(
                label: _currentPage == 2 ? "Comenzar" : "Continuar",
                onPressed: () => _goToNextPage(state),
                semanticHint: _currentPage == 2
                    ? "Ir a la pantalla de configuración inicial de accesibilidad"
                    : "Ir a la siguiente pantalla de información",
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage({
    required String title,
    required String description,
    required Widget illustration,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: Center(child: illustration)),
          const SizedBox(height: 32),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: RiqsiTheme.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 6),
      height: 12,
      width: _currentPage == index ? 32 : 12,
      decoration: BoxDecoration(
        color: _currentPage == index ? RiqsiTheme.accentCyan : RiqsiTheme.darkSurface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: _currentPage == index ? RiqsiTheme.accentCyan : RiqsiTheme.textSecondary.withOpacity(0.5),
          width: 1.5,
        ),
      ),
    );
  }

  // Code-only high fidelity illustrations
  Widget _buildCameraIllustration() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: RiqsiTheme.darkSurface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: RiqsiTheme.accentCyan.withOpacity(0.3), width: 3),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer radar scanner
          const Icon(
            Icons.camera_front_rounded,
            size: 80,
            color: RiqsiTheme.accentCyan,
          ),
          Positioned(
            top: 20,
            right: 20,
            child: Icon(
              Icons.blur_on_rounded,
              color: RiqsiTheme.accentCyan.withOpacity(0.5),
              size: 32,
            ),
          ),
          Positioned(
            bottom: 30,
            left: 30,
            child: Container(
              width: 14,
              height: 14,
              decoration: const BoxDecoration(
                color: RiqsiTheme.accentCyan,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceIllustration() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: RiqsiTheme.darkSurface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: RiqsiTheme.accentCyan.withOpacity(0.3), width: 3),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildSoundBar(30),
            _buildSoundBar(60),
            _buildSoundBar(90),
            _buildSoundBar(50),
            _buildSoundBar(20),
          ],
        ),
      ),
    );
  }

  Widget _buildSoundBar(double height) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        width: 10,
        height: height,
        decoration: BoxDecoration(
          color: RiqsiTheme.accentCyan,
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }

  Widget _buildConfidenceIllustration() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: RiqsiTheme.darkSurface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: RiqsiTheme.accentCyan.withOpacity(0.3), width: 3),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(
            Icons.directions_walk_rounded,
            size: 80,
            color: RiqsiTheme.accentCyan,
          ),
          Positioned(
            top: 30,
            left: 30,
            child: Icon(
              Icons.check_circle_rounded,
              color: Colors.greenAccent[400],
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}
