import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/auth/pages/role_selection_page.dart';

void main() {
  group('RoleSelectionPage', () {
    testWidgets('renders page title "Select Role"', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: RoleSelectionPage(),
      ));

      expect(find.text('Select Role'), findsOneWidget);
    });

    testWidgets('renders all three role options', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: RoleSelectionPage(),
      ));

      expect(find.text('Buyer'), findsOneWidget);
      expect(find.text('Seller'), findsOneWidget);
      expect(find.text('Volunteer'), findsOneWidget);
    });

    testWidgets('renders correct icons for each role', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: RoleSelectionPage(),
      ));

      expect(find.byIcon(Icons.shopping_bag), findsOneWidget);
      expect(find.byIcon(Icons.store), findsOneWidget);
      expect(find.byIcon(Icons.volunteer_activism), findsOneWidget);
    });

    testWidgets('tapping a role navigates to register page', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: RoleSelectionPage(),
      ));

      await tester.tap(find.text('Buyer'));
      await tester.pumpAndSettle();

      // Should have navigated away from RoleSelectionPage
      expect(find.byType(RoleSelectionPage), findsNothing);
    });
  });
}
