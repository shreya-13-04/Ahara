import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/features/buyer/widgets/review_widgets.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('ReviewTagChip', () {
    testWidgets('renders tag label in selectable mode', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ReviewTagChip(
            tag: 'Great Taste',
            onSelected: (_) {},
          ),
        ),
      ));

      expect(find.text('Great Taste'), findsOneWidget);
      expect(find.byType(FilterChip), findsOneWidget);
    });

    testWidgets('toggling selection calls onSelected', (tester) async {
      bool wasSelected = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ReviewTagChip(
            tag: 'Fresh Food',
            onSelected: (v) => wasSelected = v,
          ),
        ),
      ));

      await tester.tap(find.text('Fresh Food'));
      await tester.pumpAndSettle();

      expect(wasSelected, isTrue);
    });

    testWidgets('renders as plain Chip when not selectable', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ReviewTagChip(
            tag: 'Hygienic',
            selectable: false,
            onSelected: (_) {},
          ),
        ),
      ));

      expect(find.text('Hygienic'), findsOneWidget);
      expect(find.byType(Chip), findsOneWidget);
      expect(find.byType(FilterChip), findsNothing);
    });

    testWidgets('starts selected when isSelected is true', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ReviewTagChip(
            tag: 'On Time',
            isSelected: true,
            onSelected: (_) {},
          ),
        ),
      ));

      final chip = tester.widget<FilterChip>(find.byType(FilterChip));
      expect(chip.selected, isTrue);
    });
  });

  group('ReviewCard', () {
    testWidgets('renders reviewer name, rating, and comment', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ReviewCard(
              reviewerName: 'Ravi Kumar',
              rating: 4.0,
              comment: 'Amazing biryani!',
              tags: ['Tasty', 'Fresh'],
              createdAt: DateTime.now().subtract(const Duration(hours: 2)),
            ),
          ),
        ),
      ));

      expect(find.text('Ravi Kumar'), findsOneWidget);
      expect(find.text('4.0'), findsOneWidget);
      expect(find.text('Amazing biryani!'), findsOneWidget);
    });

    testWidgets('shows Verified badge when isVerified is true',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ReviewCard(
              reviewerName: 'Anita',
              rating: 5.0,
              comment: 'Excellent',
              tags: [],
              createdAt: DateTime.now(),
              isVerified: true,
            ),
          ),
        ),
      ));

      expect(find.text('Verified'), findsOneWidget);
    });
  });
}
