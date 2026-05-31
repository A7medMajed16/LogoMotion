import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logo_motion/logo_motion.dart';

void main() {
  testWidgets('LogoMotion.string renders correctly', (WidgetTester tester) async {
    const svgString = '''
      <svg viewBox="0 0 100 100">
        <path d="M 10 10 L 90 10 L 90 90 L 10 90 Z" />
      </svg>
    ''';

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LogoMotion.string(
            svgString,
            size: 100,
            color: Colors.red,
            repeat: false,
          ),
        ),
      ),
    );

    // Initial state might be loading frame
    await tester.pump(); 

    // Find the LogoMotion widget
    expect(find.byType(LogoMotion), findsOneWidget);
    
    // Pump animation frames
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(seconds: 3));
  });
}
