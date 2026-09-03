import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:riqsi/main.dart';
import 'package:riqsi/state/app_state.dart';

void main() {
  testWidgets('Riqsi app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: const RiqsiApp(),
      ),
    );

    // Verify that Splash screen has the title text "RIQSI" and slogan.
    expect(find.text('RIQSI'), findsOneWidget);
    expect(find.text('Conoce tu entorno. Muévete con confianza.'), findsOneWidget);
  });
}
