import 'package:flutter_test/flutter_test.dart';
import 'package:venidng_coffee/main.dart';

void main() {
  testWidgets('app starts with splash', (WidgetTester tester) async {
    await tester.pumpWidget(const VendingCoffeeApp());
    await tester.pump();
    expect(find.text('قهوه‌ات رو انتخاب کن'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
  });
}
