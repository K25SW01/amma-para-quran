
import 'package:flutter_test/flutter_test.dart';
import 'package:amma_para_quran/main.dart';

void main() {
  testWidgets('Amma Para app opens successfully', (tester) async {
    await tester.pumpWidget(const AmmaParaApp());

    expect(find.text('Amma Para Quran'), findsOneWidget);
    expect(find.text('Welcome to Amma Para'), findsOneWidget);
    expect(find.text('Read Quran'), findsOneWidget);
    expect(find.text('Listen to Tilawat'), findsOneWidget);
  });
}
