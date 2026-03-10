import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/shared/widgets/animated_toast.dart';

void main() {
  Widget buildToast({
    String message = 'Test message',
    ToastType type = ToastType.info,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: AnimatedToast(
          message: message,
          type: type,
          onDismiss: () {},
        ),
      ),
    );
  }

  // AnimatedToast schedules a 3-second Future.delayed in initState.
  // We must pump past it to avoid "Timer still pending" errors.
  Future<void> drainTimers(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 4));
    await tester.pump(const Duration(milliseconds: 600));
  }

  group('AnimatedToast', () {
    testWidgets('displays the message text', (tester) async {
      await tester.pumpWidget(buildToast(message: 'Order placed!'));
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('Order placed!'), findsOneWidget);

      await drainTimers(tester);
    });

    testWidgets('shows check_circle icon for success type', (tester) async {
      await tester.pumpWidget(buildToast(type: ToastType.success));
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.byIcon(Icons.check_circle), findsOneWidget);

      await drainTimers(tester);
    });

    testWidgets('shows error icon for error type', (tester) async {
      await tester.pumpWidget(buildToast(type: ToastType.error));
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.byIcon(Icons.error), findsOneWidget);

      await drainTimers(tester);
    });

    testWidgets('shows info icon for info type', (tester) async {
      await tester.pumpWidget(buildToast(type: ToastType.info));
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.byIcon(Icons.info), findsOneWidget);

      await drainTimers(tester);
    });

    testWidgets('has a close button', (tester) async {
      await tester.pumpWidget(buildToast());
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.byIcon(Icons.close), findsOneWidget);

      await drainTimers(tester);
    });
  });
}
