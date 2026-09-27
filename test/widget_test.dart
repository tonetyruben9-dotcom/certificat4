import 'package:certificat4/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app renders login screen by default', (tester) async {
    await tester.pumpWidget(MyApp(appState: AppState()));

    expect(find.text('Connexion'), findsOneWidget);
    expect(find.text('Se connecter'), findsOneWidget);
  });
}
