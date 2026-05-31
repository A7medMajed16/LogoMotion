import 'package:flutter_test/flutter_test.dart';
import 'package:logo_motion/src/svg_parser.dart';

void main() {
  group('SvgParser', () {
    test('parses simple valid SVG with one path', () {
      const svgString = '''
        <svg viewBox="0 0 100 100">
          <path d="M 10 10 L 90 10 L 90 90 L 10 90 Z" />
        </svg>
      ''';

      final result = SvgParser.parse(svgString);

      expect(result.viewBoxWidth, 100.0);
      expect(result.viewBoxHeight, 100.0);
      expect(result.totalLength, greaterThan(0));
    });

    test('parses multiple paths and computes total length', () {
      const svgString = '''
        <svg viewBox="0 0 50 50">
          <path d="M 0 0 L 10 0" />
          <path d="M 0 10 L 10 10" />
        </svg>
      ''';

      final result = SvgParser.parse(svgString);

      // Total length should be approx 20
      expect(result.totalLength, closeTo(20.0, 0.1));
    });

    test('falls back to empty path data on invalid SVG string', () {
      const invalidSvg = '<invalid> no path here </invalid>';
      final result = SvgParser.parse(invalidSvg);

      expect(result.totalLength, 0.0);
      expect(result.viewBoxWidth, 100.0); // default
      expect(result.viewBoxHeight, 100.0); // default
    });

    test('extracts width and height if viewBox is missing', () {
      const svgString = '''
        <svg width="200" height="300">
          <path d="M 10 10 L 20 20" />
        </svg>
      ''';

      final result = SvgParser.parse(svgString);

      expect(result.viewBoxWidth, 200.0);
      expect(result.viewBoxHeight, 300.0);
    });
  });
}
