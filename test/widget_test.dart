import 'package:expense_tracker_mobile_app/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ExpenseTrackerApp renders LoginScreen or HomeScreen without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const ExpenseTrackerApp());
    await tester.pumpAndSettle();

    expect(find.text('Expense Tracker'), findsWidgets);
  });
}
