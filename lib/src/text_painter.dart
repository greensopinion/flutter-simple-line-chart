import 'package:flutter/widgets.dart';

TextPainter createTextPainter(TextStyle style, String text) => TextPainter(
    text: TextSpan(style: style, text: text),
    textAlign: TextAlign.center,
    textDirection: TextDirection.ltr)
  ..layout();
