import 'dart:math';

import 'package:flutter/material.dart';

class ComicBorder extends Border {
  const ComicBorder({
    BorderSide top = BorderSide.none,
    BorderSide right = BorderSide.none,
    BorderSide bottom = BorderSide.none,
    BorderSide left = BorderSide.none,
  }) : super(top: top, right: right, bottom: bottom, left: left);

  factory ComicBorder.all({
    Color color = const Color(0xFF000000),
    double width = 1.0,
    BorderStyle style = BorderStyle.solid,
  }) {
    final side = BorderSide(color: color, width: width, style: style);
    return ComicBorder(top: side, right: side, bottom: side, left: side);
  }

  factory ComicBorder.fromBorderSide(BorderSide side) {
    return ComicBorder(top: side, right: side, bottom: side, left: side);
  }

  factory ComicBorder.symmetric({
    BorderSide vertical = BorderSide.none,
    BorderSide horizontal = BorderSide.none,
  }) {
    return ComicBorder(
        top: horizontal, right: vertical, bottom: horizontal, left: vertical);
  }

  static const int MAX_RANDOM_VARIANCE = 5;

  bool get _colorIsUniform {
    final topColor = top.color;
    return right.color == topColor &&
        bottom.color == topColor &&
        left.color == topColor;
  }

  bool get _widthIsUniform {
    final topWidth = top.width;
    return right.width == topWidth &&
        bottom.width == topWidth &&
        left.width == topWidth;
  }

  bool get _styleIsUniform {
    final topStyle = top.style;
    return right.style == topStyle &&
        bottom.style == topStyle &&
        left.style == topStyle;
  }

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    TextDirection? textDirection,
    BoxShape shape = BoxShape.rectangle,
    BorderRadius? borderRadius,
  }) {
    if (isUniform) {
      switch (top.style) {
        case BorderStyle.none:
          return;
        case BorderStyle.solid:
          switch (shape) {
            case BoxShape.circle:
              assert(borderRadius == null,
                  'A borderRadius can only be given for rectangular boxes.');
              ComicBorder._paintUniformBorderWithCircle(canvas, rect, top);
              break;
            case BoxShape.rectangle:
              if (borderRadius != null) {
                ComicBorder._paintUniformBorderWithRadius(
                    canvas, rect, top, borderRadius);
                return;
              }
              ComicBorder._paintUniformBorderWithRectangle(canvas, rect, top);
              break;
          }
          return;
      }
    }

    assert(() {
      if (borderRadius != null) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary(
              'A borderRadius can only be given for a uniform Border.'),
          ErrorDescription('The following is not uniform:'),
          if (!_colorIsUniform) ErrorDescription('BorderSide.color'),
          if (!_widthIsUniform) ErrorDescription('BorderSide.width'),
          if (!_styleIsUniform) ErrorDescription('BorderSide.style'),
        ]);
      }
      return true;
    }(), 'Border radius test');
    assert(() {
      if (shape != BoxShape.rectangle) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary(
              'A Border can only be drawn as a circle if it is uniform'),
          ErrorDescription('The following is not uniform:'),
          if (!_colorIsUniform) ErrorDescription('BorderSide.color'),
          if (!_widthIsUniform) ErrorDescription('BorderSide.width'),
          if (!_styleIsUniform) ErrorDescription('BorderSide.style'),
        ]);
      }
      return true;
    }(), 'Border radius test');

    paintBorder(canvas, rect,
        top: top, right: right, bottom: bottom, left: left);
  }

  static int _generateOffset() {
    final rng = Random();
    var ret = rng.nextInt(MAX_RANDOM_VARIANCE);
    if (rng.nextInt(MAX_RANDOM_VARIANCE).isOdd) {
      ret = ret * -1;
    }
    return ret;
  }

  static void _addPencilStrokes(Canvas canvas, Rect rect, Paint paint) {
    //Left border
    final offsetLeftStart = Offset(rect.topLeft.dx + _generateOffset(),
        rect.topLeft.dy + _generateOffset());
    final offsetLeftEnd = Offset(rect.bottomLeft.dx + _generateOffset(),
        rect.bottomLeft.dy + _generateOffset());
    canvas.drawLine(offsetLeftStart, offsetLeftEnd, paint);
    //Right border
    final offsetRightStart = Offset(rect.topRight.dx + _generateOffset(),
        rect.topRight.dy + _generateOffset());
    final offsetRightEnd = Offset(rect.bottomRight.dx + _generateOffset(),
        rect.bottomRight.dy + _generateOffset());
    canvas.drawLine(offsetRightStart, offsetRightEnd, paint);
    //Top border
    final offsetTopStart = Offset(rect.topLeft.dx + _generateOffset(),
        rect.topLeft.dy + _generateOffset());
    final offsetTopEnd = Offset(rect.topRight.dx + _generateOffset(),
        rect.topRight.dy + _generateOffset());
    canvas.drawLine(offsetTopStart, offsetTopEnd, paint);

    //Bottom border
    final offsetBottomStart = Offset(rect.bottomLeft.dx + _generateOffset(),
        rect.bottomLeft.dy + _generateOffset());
    final offsetBottomEnd = Offset(rect.bottomRight.dx + _generateOffset(),
        rect.bottomRight.dy + _generateOffset());
    canvas.drawLine(offsetBottomStart, offsetBottomEnd, paint);
  }

  static void _paintUniformBorderWithRadius(
      Canvas canvas, Rect rect, BorderSide side, BorderRadius borderRadius) {
    assert(side.style != BorderStyle.none,
        'side.style must not be BorderStyle.none');
    final paint = Paint()..color = side.color;
    final outer = borderRadius.toRRect(rect);
    final width = side.width;
    final innerRect = Rect.fromLTRB(outer.left, outer.top - outer.blRadiusY,
        outer.right, outer.bottom - outer.blRadiusY);
    if (width == 0.0) {
      paint
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.0;
      canvas.drawRRect(outer, paint);
      _addPencilStrokes(canvas, innerRect, paint);
    } else {
      final inner = outer.deflate(width);
      canvas.drawDRRect(outer, inner, paint);
      _addPencilStrokes(canvas, innerRect, paint);
    }
  }

  static void _paintUniformBorderWithCircle(
      Canvas canvas, Rect rect, BorderSide side) {
    assert(side.style != BorderStyle.none, 'side.style must not bet BorderStyle.none');
    final width = side.width;
    final paint = side.toPaint();
    final radius = (rect.shortestSide - width) / 2.0;
    canvas.drawCircle(rect.center, radius, paint);
  }

  static void _paintUniformBorderWithRectangle(
      Canvas canvas, Rect rect, BorderSide side) {
    assert(side.style != BorderStyle.none, 'side.style must not bet BorderStyle.none');
    final width = side.width;
    final paint = side.toPaint();
    canvas.drawRect(rect.deflate(width / 2.0), paint);
    _addPencilStrokes(canvas, rect, paint);
  }
}
