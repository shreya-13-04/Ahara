import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/shared/widgets/phone_input_field.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget buildField({
    TextEditingController? controller,
    String label = 'Phone Number',
    String hintText = 'Enter phone number',
    String? Function(String?)? validator,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: PhoneInputField(
            controller: controller ?? TextEditingController(),
            label: label,
            hintText: hintText,
            validator: validator,
          ),
        ),
      ),
    );
  }

  group('PhoneInputField', () {
    testWidgets('renders the label text', (tester) async {
      await tester.pumpWidget(buildField(label: 'Mobile Number'));
      await tester.pumpAndSettle();

      expect(find.text('Mobile Number'), findsOneWidget);
    });

    testWidgets('shows hint text in the input', (tester) async {
      await tester.pumpWidget(buildField(hintText: 'Type here'));
      await tester.pumpAndSettle();

      expect(find.text('Type here'), findsOneWidget);
    });

    testWidgets('shows default country code +91', (tester) async {
      await tester.pumpWidget(buildField());
      await tester.pumpAndSettle();

      expect(find.text('+91'), findsOneWidget);
    });

    testWidgets('accepts digit input', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(buildField(controller: controller));
      await tester.pumpAndSettle();

      final textField = find.byType(TextFormField);
      await tester.enterText(textField, '9876543210');
      await tester.pumpAndSettle();

      expect(controller.text, '9876543210');
    });
  });
}
