import 'dart:ui';
import 'package:svg_path_parser/svg_path_parser.dart';
import 'package:xml/xml.dart';

class SvgPathData {
  final Path combinedPath;
  final double viewBoxWidth;
  final double viewBoxHeight;
  final double totalLength;

  const SvgPathData({
    required this.combinedPath,
    required this.viewBoxWidth,
    required this.viewBoxHeight,
    required this.totalLength,
  });

  /// An empty path data for fallback or initial state
  static final SvgPathData empty = SvgPathData(
    combinedPath: Path(),
    viewBoxWidth: 100,
    viewBoxHeight: 100,
    totalLength: 0,
  );
}

class SvgParser {
  /// Parses an SVG string and returns a composite [SvgPathData].
  static SvgPathData parse(String svgString) {
    try {
      final document = XmlDocument.parse(svgString);

      // Parse viewBox for scaling (fallback to 100x100 if not found)
      double viewBoxWidth = 100.0;
      double viewBoxHeight = 100.0;

      final svgElement = document.findElements('svg').firstOrNull;
      if (svgElement != null) {
        final viewBox = svgElement.getAttribute('viewBox');
        if (viewBox != null) {
          final parts = viewBox.split(RegExp(r'\s+|,'));
          if (parts.length >= 4) {
            viewBoxWidth = double.tryParse(parts[2]) ?? 100.0;
            viewBoxHeight = double.tryParse(parts[3]) ?? 100.0;
          }
        } else {
          // fallback to width/height attrs
          viewBoxWidth = double.tryParse(svgElement.getAttribute('width')?.replaceAll(RegExp(r'[^0-9.]'), '') ?? '') ?? 100.0;
          viewBoxHeight = double.tryParse(svgElement.getAttribute('height')?.replaceAll(RegExp(r'[^0-9.]'), '') ?? '') ?? 100.0;
        }
      }

      // Combine all paths
      final combinedPath = Path();
      final paths = document.findAllElements('path');

      for (var pathElement in paths) {
        final String? d = pathElement.getAttribute('d');
        if (d != null && d.isNotEmpty) {
          final path = parseSvgPath(d);
          
          // Note: Full SVG parsing requires handling transforms, groups, etc.
          // This parser is simplified for the logo_motion use case where logos
          // typically use simple <path d="..."> definitions or all transforms
          // are baked into the path.
          
          combinedPath.addPath(path, Offset.zero);
        }
      }

      // Compute total length
      double totalLength = 0.0;
      for (final PathMetric metric in combinedPath.computeMetrics()) {
        totalLength += metric.length;
      }

      return SvgPathData(
        combinedPath: combinedPath,
        viewBoxWidth: viewBoxWidth,
        viewBoxHeight: viewBoxHeight,
        totalLength: totalLength,
      );
    } catch (e) {
      // Return empty on error
      return SvgPathData.empty;
    }
  }
}
