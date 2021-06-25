import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'selection_model.dart';

class LineChartSelection extends StatelessWidget {
  LineChartSelection();

  @override
  Widget build(BuildContext context) {
    return Consumer<SelectionModel>(
        builder: (context, selectionModel, child) =>
            CustomPaint(painter: _SelectionPainter(selectionModel)));
  }
}

class _SelectionPainter extends CustomPainter {
  final SelectionModel selectionModel;

  _SelectionPainter(this.selectionModel);

  @override
  void paint(Canvas canvas, Size size) {
    final style = selectionModel.style.highlightStyle;
    if (style != null) {
      selectionModel.selection.forEach((selected) {
        final linePaint = Paint()
          ..color = style.color
          ..strokeWidth = style.lineSize
          ..isAntiAlias = true
          ..style = PaintingStyle.stroke;
        final point = selectionModel.projection.toPixel(
            axisDependency: selected.dataset.axisDependency,
            data: selected.dataPoint.toOffset());
        if (style.horizontal) {
          canvas.drawLine(
              Offset(0, point.dy), Offset(size.width, point.dy), linePaint);
        }
        if (style.vertical) {
          canvas.drawLine(
              Offset(point.dx, 0), Offset(point.dx, size.height), linePaint);
        }
      });
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
