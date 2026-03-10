import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/volunteer/widgets/availability_toggle.dart';
import 'package:frontend/features/volunteer/widgets/badge_widget.dart';
import 'package:frontend/features/volunteer/widgets/contact_action_buttons.dart';
import 'package:frontend/features/volunteer/widgets/delivery_card.dart';
import 'package:frontend/features/volunteer/widgets/rating_star_widget.dart';
import 'package:frontend/features/volunteer/widgets/route_map.dart';
import 'package:frontend/features/volunteer/widgets/verification_form.dart';

void main() {
  group('BadgeWidget', () {
    testWidgets('renders the label text', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: BadgeWidget(label: 'Top Volunteer')),
      ));

      expect(find.text('Top Volunteer'), findsOneWidget);
      expect(find.byType(Chip), findsOneWidget);
    });
  });

  group('RatingStarWidget', () {
    testWidgets('displays rating with star symbol', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: RatingStarWidget(rating: 4.5)),
      ));

      expect(find.text('4.5 ★'), findsOneWidget);
    });

    testWidgets('displays integer rating correctly', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: RatingStarWidget(rating: 3.0)),
      ));

      expect(find.text('3.0 ★'), findsOneWidget);
    });
  });

  group('AvailabilityToggle', () {
    testWidgets('renders switch with label text', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: AvailabilityToggle()),
      ));

      expect(find.text('Available for deliveries'), findsOneWidget);
      expect(find.byType(SwitchListTile), findsOneWidget);
    });
  });

  group('ContactActionButtons', () {
    testWidgets('renders Call and Text buttons', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: ContactActionButtons()),
      ));

      expect(find.text('Call'), findsOneWidget);
      expect(find.text('Text'), findsOneWidget);
      expect(find.byIcon(Icons.call), findsOneWidget);
      expect(find.byIcon(Icons.message), findsOneWidget);
    });
  });

  group('DeliveryCard', () {
    testWidgets('renders store name and status', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: DeliveryCard(status: 'In Transit')),
      ));

      expect(find.text('Sunshine Delights'), findsOneWidget);
      expect(find.text('In Transit'), findsOneWidget);
    });

    testWidgets('shows different status texts', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: DeliveryCard(status: 'Delivered')),
      ));

      expect(find.text('Delivered'), findsOneWidget);
    });
  });

  group('RouteMap', () {
    testWidgets('renders map placeholder text', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: RouteMap()),
      ));

      expect(find.text('Map View'), findsOneWidget);
    });
  });

  group('VerificationForm', () {
    testWidgets('renders upload button and transport dropdown', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: VerificationForm()),
        ),
      ));

      expect(find.text('Upload ID Document'), findsOneWidget);
      expect(find.text('Transport Type'), findsOneWidget);
    });

    testWidgets('dropdown contains Bike and Bicycle options', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: VerificationForm()),
        ),
      ));

      // Open dropdown
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      expect(find.text('Bike'), findsOneWidget);
      expect(find.text('Bicycle'), findsOneWidget);
    });
  });
}
