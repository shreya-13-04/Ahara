import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/utils/responsive_layout.dart';

void main() {
  group('ResponsiveLayout', () {
    testWidgets('shows mobile widget on narrow screens', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MaterialApp(
        home: ResponsiveLayout(
          mobile: Text('Mobile'),
          tablet: Text('Tablet'),
          desktop: Text('Desktop'),
        ),
      ));

      expect(find.text('Mobile'), findsOneWidget);
      expect(find.text('Tablet'), findsNothing);
      expect(find.text('Desktop'), findsNothing);
    });

    testWidgets('shows tablet widget on medium screens', (tester) async {
      tester.view.physicalSize = const Size(800, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MaterialApp(
        home: ResponsiveLayout(
          mobile: Text('Mobile'),
          tablet: Text('Tablet'),
          desktop: Text('Desktop'),
        ),
      ));

      expect(find.text('Tablet'), findsOneWidget);
      expect(find.text('Mobile'), findsNothing);
      expect(find.text('Desktop'), findsNothing);
    });

    testWidgets('shows desktop widget on wide screens', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MaterialApp(
        home: ResponsiveLayout(
          mobile: Text('Mobile'),
          tablet: Text('Tablet'),
          desktop: Text('Desktop'),
        ),
      ));

      expect(find.text('Desktop'), findsOneWidget);
      expect(find.text('Mobile'), findsNothing);
      expect(find.text('Tablet'), findsNothing);
    });

    testWidgets('falls back to mobile when tablet is null', (tester) async {
      tester.view.physicalSize = const Size(800, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MaterialApp(
        home: ResponsiveLayout(
          mobile: Text('Mobile'),
        ),
      ));

      expect(find.text('Mobile'), findsOneWidget);
    });
  });

  group('ResponsiveLayout static helpers', () {
    testWidgets('isMobile returns true for width < 600', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      late bool result;
      await tester.pumpWidget(MaterialApp(
        home: Builder(builder: (context) {
          result = ResponsiveLayout.isMobile(context);
          return const SizedBox();
        }),
      ));

      expect(result, isTrue);
    });

    testWidgets('isDesktop returns true for width >= 1100', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      late bool result;
      await tester.pumpWidget(MaterialApp(
        home: Builder(builder: (context) {
          result = ResponsiveLayout.isDesktop(context);
          return const SizedBox();
        }),
      ));

      expect(result, isTrue);
    });
  });
}
