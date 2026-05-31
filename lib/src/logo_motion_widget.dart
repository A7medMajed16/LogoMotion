import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'logo_painter.dart';
import 'svg_parser.dart';

enum _LogoSource { string, asset, network }

/// A customizable SVG logo loading animation widget.
class LogoMotion extends StatefulWidget {
  /// The size (width and height) of the widget.
  final double size;

  /// The color of the stroke and fill. Defaults to Color(0xFF0071AA).
  final Color? color;

  /// The duration of one complete animation cycle.
  final Duration duration;

  /// The width of the drawing stroke.
  final double strokeWidth;

  /// Whether the animation should repeat infinitely. If false, plays once.
  final bool repeat;

  final String _sourceValue;
  final _LogoSource _sourceType;

  /// Creates a [LogoMotion] widget from a raw SVG string.
  const LogoMotion.string(
    String svgString, {
    super.key,
    this.size = 50.0,
    this.color,
    this.duration = const Duration(seconds: 3),
    this.strokeWidth = 1.8,
    this.repeat = true,
  }) : _sourceValue = svgString,
       _sourceType = _LogoSource.string;

  /// Creates a [LogoMotion] widget from a Flutter asset path.
  const LogoMotion.asset(
    String assetPath, {
    super.key,
    this.size = 50.0,
    this.color,
    this.duration = const Duration(seconds: 3),
    this.strokeWidth = 1.8,
    this.repeat = true,
  }) : _sourceValue = assetPath,
       _sourceType = _LogoSource.asset;

  @override
  State<LogoMotion> createState() => _LogoMotionState();
}

class _LogoMotionState extends State<LogoMotion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _drawAnimation;
  late final Animation<double> _fillAnimation;
  late final Animation<double> _fadeOutAnimation;

  SvgPathData? _pathData;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: widget.duration);

    if (widget.repeat) {
      _controller.repeat();
    }

    _drawAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.65, curve: Curves.easeInOut),
      ),
    );

    _fillAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.55, 0.75, curve: Curves.easeIn),
      ),
    );

    _fadeOutAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.80, 1.0, curve: Curves.easeOut),
      ),
    );

    if (!widget.repeat) {
      _fillAnimation.addListener(_onFillComplete);
    }

    _loadSvg();
  }

  @override
  void didUpdateWidget(covariant LogoMotion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
      if (widget.repeat) {
        _controller.repeat();
      } else {
        _controller.forward();
      }
    }
    if (oldWidget.repeat != widget.repeat) {
      if (widget.repeat) {
        _controller.repeat();
      } else {
        _controller.forward(from: _controller.value);
      }
    }
    if (oldWidget._sourceValue != widget._sourceValue ||
        oldWidget._sourceType != widget._sourceType) {
      _loadSvg();
    }
  }

  Future<void> _loadSvg() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      String svgString;
      switch (widget._sourceType) {
        case _LogoSource.string:
          svgString = widget._sourceValue;
          break;
        case _LogoSource.asset:
          svgString = await rootBundle.loadString(widget._sourceValue);
          break;
        case _LogoSource.network:
          final response = await http.get(Uri.parse(widget._sourceValue));
          if (response.statusCode == 200) {
            svgString = response.body;
          } else {
            throw Exception('Failed to load SVG: ${response.statusCode}');
          }
          break;
      }

      final pathData = SvgParser.parse(svgString);

      if (mounted) {
        setState(() {
          _pathData = pathData;
          _isLoading = false;
        });

        if (!widget.repeat && _controller.isDismissed) {
          _controller.forward();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  void _onFillComplete() {
    if (_fillAnimation.value >= 1.0 && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _fillAnimation.removeListener(_onFillComplete);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(width: widget.size, height: widget.size);
    }

    if (_hasError || _pathData == null) {
      // You could return an error icon, but for a loading indicator,
      // empty space or a fallback is usually better.
      return SizedBox(width: widget.size, height: widget.size);
    }

    return Center(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              size: Size(widget.size, widget.size),
              painter: LogoPainter(
                drawProgress: _drawAnimation.value,
                fillOpacity: _fillAnimation.value,
                fadeOut: widget.repeat ? _fadeOutAnimation.value : 1.0,
                color: widget.color ?? const Color(0xFF0071AA),
                combinedPath: _pathData!.combinedPath,
                viewBoxWidth: _pathData!.viewBoxWidth,
                viewBoxHeight: _pathData!.viewBoxHeight,
                totalLength: _pathData!.totalLength,
                strokeWidth: widget.strokeWidth,
              ),
            );
          },
        ),
      ),
    );
  }
}
