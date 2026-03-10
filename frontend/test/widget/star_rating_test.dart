import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/buyer/widgets/star_rating_widget.dart';

void main() {
  group('StarRatingWidget', () {
    testWidgets('renders 5 stars', (tester) async {
      int selected = 0;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: StarRatingWidget(
            onRatingChanged: (v) => selected = v,
          ),
        ),
      ));

      // 5 star_outline icons initially (rating = 0)
      expect(find.byIcon(Icons.star_outline), findsNWidgets(5));
    });

    testWidgets('shows initial rating as filled stars', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: StarRatingWidget(
            initialRating: 3,
            onRatingChanged: (_) {},
          ),
        ),
      ));

      expect(find.byIcon(Icons.star), findsNWidgets(3));
      expect(find.byIcon(Icons.star_outline), findsNWidgets(2));
    });

    testWidgets('tapping a star updates rating', (tester) async {
      int selectedRating = 0;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: StarRatingWidget(
            onRatingChanged: (v) => selectedRating = v,
          ),
        ),
      ));

      // Tap the 4th star (index 3)
      final stars = find.byIcon(Icons.star_outline);
      await tester.tap(stars.at(3));
      await tester.pumpAndSettle();

      expect(selectedRating, 4);
      expect(find.byIcon(Icons.star), findsNWidgets(4));
      expect(find.byIcon(Icons.star_outline), findsNWidgets(1));
    });

    testWidgets('non-interactive mode does not respond to taps',
        (tester) async {
      int selectedRating = 0;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: StarRatingWidget(
            initialRating: 2,
            interactive: false,
            onRatingChanged: (v) => selectedRating = v,
          ),
        ),
      ));

      // Tap on a star_outline (the 4th star)
      final outlineStars = find.byIcon(Icons.star_outline);
      await tester.tap(outlineStars.at(0));
      await tester.pumpAndSettle();

      // Rating should not change
      expect(selectedRating, 0);
      expect(find.byIcon(Icons.star), findsNWidgets(2));
    });
  });

  group('DisplayStarRating', () {
    testWidgets('renders 5 star icons', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: DisplayStarRating(rating: 4.0),
        ),
      ));

      // 4 filled + 1 outline = 5 total
      expect(find.byIcon(Icons.star), findsNWidgets(4));
      expect(find.byIcon(Icons.star_outline), findsNWidgets(1));
    });

    testWidgets('shows rating label when showLabel is true', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: DisplayStarRating(rating: 3.5, showLabel: true),
        ),
      ));

      expect(find.text('3.5'), findsOneWidget);
    });

    testWidgets('hides rating label when showLabel is false', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: DisplayStarRating(rating: 3.5, showLabel: false),
        ),
      ));

      expect(find.text('3.5'), findsNothing);
    });
  });
}
