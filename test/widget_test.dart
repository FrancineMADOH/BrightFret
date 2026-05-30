import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brightfret/main.dart';

void main() {
  testWidgets('BrightFretApp renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: BrightFretApp()));
    expect(find.text('BrightFret'), findsOneWidget);
  });
}
