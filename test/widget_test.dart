import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/app/app.dart';

void main() {
  testWidgets('App smoke test with TodoApplication', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: TodoApplication(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Today'), findsWidgets);
    expect(find.text("Today's Schedule"), findsOneWidget);
  });
}
