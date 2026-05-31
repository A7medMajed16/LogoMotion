import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Paints the logo with a draw-on stroke animation followed by a fill reveal.
///
/// Three layers, composited with [fadeOut] controlling overall visibility:
///   1. **Stroke trace** — a partial stroke of the path, length grows with
///      [drawProgress]. Visible until the fill takes over.
///   2. **Solid fill** — fades in via [fillOpacity] once the stroke is
///      nearly complete.
///   3. **Fade out** — both layers fade to transparent at the end of the
///      cycle so the next iteration starts clean.
class LogoPainter extends CustomPainter {
  const LogoPainter({
    required this.drawProgress,
    required this.fillOpacity,
    required this.fadeOut,
    required this.color,
    required this.combinedPath,
    required this.viewBoxWidth,
    required this.viewBoxHeight,
    required this.totalLength,
    required this.strokeWidth,
  });

  final double drawProgress;
  final double fillOpacity;
  final double fadeOut;
  final Color color;
  final Path combinedPath;
  final double viewBoxWidth;
  final double viewBoxHeight;
  final double totalLength;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (totalLength == 0) return;

    final double scaleX = size.width / viewBoxWidth;
    final double scaleY = size.height / viewBoxHeight;
    final double scale = scaleX < scaleY ? scaleX : scaleY;

    final double offsetX = (size.width - viewBoxWidth * scale) / 2;
    final double offsetY = (size.height - viewBoxHeight * scale) / 2;

    canvas.save();
    canvas.translate(offsetX, offsetY);
    canvas.scale(scale, scale);

    // --- Layer 1: stroke trace ---
    if (drawProgress > 0.0) {
      final double strokeAlpha = fadeOut * (1.0 - fillOpacity);
      if (strokeAlpha > 0.0) {
        final Path partial = _extractSubPath(
          combinedPath,
          totalLength * drawProgress,
        );
        canvas.drawPath(
          partial,
          Paint()
            ..color = color.withValues(alpha: strokeAlpha)
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round,
        );
      }
    }

    // --- Layer 2: solid fill ---
    if (fillOpacity > 0.0) {
      canvas.drawPath(
        combinedPath,
        Paint()
          ..color = color.withValues(alpha: fillOpacity * fadeOut)
          ..style = PaintingStyle.fill,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(LogoPainter old) {
    return old.drawProgress != drawProgress ||
        old.fillOpacity != fillOpacity ||
        old.fadeOut != fadeOut ||
        old.color != color ||
        old.combinedPath != combinedPath ||
        old.viewBoxWidth != viewBoxWidth ||
        old.viewBoxHeight != viewBoxHeight ||
        old.totalLength != totalLength ||
        old.strokeWidth != strokeWidth;
  }

  // ---------------------------------------------------------------------------
  // Path helpers
  // ---------------------------------------------------------------------------

  static Path _extractSubPath(Path path, double length) {
    final Path result = Path();
    for (final ui.PathMetric metric in path.computeMetrics()) {
      if (length <= 0) break;
      final double end = length.clamp(0.0, metric.length);
      result.addPath(metric.extractPath(0.0, end), Offset.zero);
      length -= metric.length;
    }
    return result;
  }
}
