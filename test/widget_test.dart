// This is a basic Flutter widget test.
import 'package:flutter_test/flutter_test.dart';
import 'package:ats_resume_builder/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const ATSResumeApp());
    expect(find.text('ATS Resume Builder'), findsOneWidget);
  });
}
