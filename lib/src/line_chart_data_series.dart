import 'package:flutter/material.dart';
import 'package:simple_line_chart/src/projection.dart';

import 'line_chart_data.dart';
import 'style.dart';

class LineChartDataSeries extends StatefulWidget {
  final LineChartData data;
  final LineChartStyle style;

  const LineChartDataSeries({Key? key, required this.data, required this.style})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _LineChartDataSeriesState(data, style);
  }
}

class _LineChartDataSeriesState extends State<LineChartDataSeries> {
  final LineChartData data;
  final LineChartStyle style;
  late final _LineChartDataSeriesPainter painter;

  _LineChartDataSeriesState(this.data, this.style);

  @override
  void initState() {
    super.initState();
    painter = _LineChartDataSeriesPainter(data, style);
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: painter);
  }
}

class _LineChartDataSeriesPainter extends CustomPainter {
  final LineChartData data;
  final LineChartStyle style;
  Projection? projection;

  _LineChartDataSeriesPainter(this.data, this.style);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    Projection projection = _projection(size);
    data.datasets.asMap().forEach((index, dataset) {
      final datasetStyle = style.datasetStyleOfIndex(index);
      _paint(canvas, projection, datasetStyle, dataset);
    });
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  void _paint(Canvas canvas, Projection projection, DatasetStyle datasetStyle,
      Dataset dataset) {
    Path path = Path();
    dataset.dataPoints.asMap().forEach((index, point) {
      final offset = projection.toPixel(data: point.toOffset());
      if (index == 0) {
        path.moveTo(offset.dx, offset.dy);
      } else {
        path.lineTo(offset.dx, offset.dy);
      }
    });
    final linePaint = Paint()
      ..color = datasetStyle.color
      ..strokeWidth = datasetStyle.lineSize
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, linePaint);
  }

  Projection _projection(Size size) {
    Projection? projection = this.projection;
    if (projection == null || projection.size != size) {
      projection = Projection(style, size, data);
      this.projection = projection;
    }
    return projection;
  }
}
