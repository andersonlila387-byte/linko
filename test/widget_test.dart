import 'package:flutter_test/flutter_test.dart';
import 'package:linko/main.dart';

void main() {
  testWidgets('LinkoApp basic widget test', (WidgetTester tester) async {
    await tester.pumpWidget(const LinkoApp());
    expect(find.textContaining('Linko'), findsOneWidget);
  });
}
