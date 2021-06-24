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

class _LineChartDataSeriesState extends State<LineChartDataSeries>
    with SingleTickerProviderStateMixin {
  final LineChartData data;
  final LineChartStyle style;
  late final _LineChartDataSeriesPainter painter;
  late final AnimationController _controller;
  late final Animation<double> _animation;

  _LineChartDataSeriesState(this.data, this.style);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: style.animationDuration ?? Duration(seconds: 0), vsync: this);
    final curve =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutSine);
    _animation = Tween<double>(begin: 0, end: 1.0).animate(curve)
      ..addListener(() {
        setState(() {});
      });
    painter = _LineChartDataSeriesPainter(data, style, _animation);
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
        key: Key('${widget.key}_LineChartDataSeriesState${_animation.value}'),
        painter: painter,
        willChange: !_animation.isCompleted);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}

class _LineChartDataSeriesPainter extends CustomPainter {
  final LineChartData data;
  final LineChartStyle style;
  final Animation<double> animation;
  Projection? projection;

  _LineChartDataSeriesPainter(this.data, this.style, this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    Projection projection = _projection(size);
    data.datasets.asMap().forEach((index, dataset) {
      final datasetStyle = style.datasetStyleOfIndex(index);
      _paint(canvas, projection.yTransform(animation.value), datasetStyle,
          dataset);
    });
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return !animation.isCompleted;
  }

  void _paint(Canvas canvas, Projection projection, DatasetStyle datasetStyle,
      Dataset dataset) {
    final linePaint = Paint()
      ..color = datasetStyle.color
      ..strokeWidth = datasetStyle.lineSize
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke;
    if (dataset.dataPoints.length <= 1) {
      return;
    }
    Path path = Path();
    final points = dataset.dataPoints
        .map((e) => e.toOffset())
        .map((e) => projection.toPixel(data: e))
        .toList();
    final intensity = datasetStyle.cubicIntensity;
    for (var index = 0; index < points.length; ++index) {
      final end = points[index];
      if (index == 0) {
        path.moveTo(end.dx, end.dy);
      } else if (index == 1 && points.length == 2) {
        path.lineTo(end.dx, end.dy);
      } else {
        final start = points[index - 1];
        final previousStart = index < 2 ? start : points[index - 2];
        final next = (index + 1 == points.length) ? end : points[index + 1];
        final delta1 =
            _toDelta(right: end, left: previousStart, intensity: intensity);
        final delta2 = _toDelta(right: next, left: start, intensity: intensity);
        path.cubicTo(start.dx + delta1.dx, (start.dy + delta1.dy),
            end.dx - delta2.dx, (end.dy - delta2.dy), end.dx, end.dy);
      }
    }
    canvas.drawPath(path, linePaint);

    final last = projection.toPixel(data: dataset.dataPoints.last.toOffset());
    final first = projection.toPixel(data: dataset.dataPoints.first.toOffset());
    final fillLine = projection.toPixel(data: Offset(0, 0));
    path.lineTo(last.dx, fillLine.dy);
    path.lineTo(first.dx, fillLine.dy);
    path.close();

    final fillPaint = Paint()
      ..color = datasetStyle.color.withOpacity(datasetStyle.fillOpacity)
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);
  }

  Offset _toDelta(
          {required Offset right,
          required Offset left,
          required double intensity}) =>
      Offset(
          (right.dx - left.dx) * intensity, (right.dy - left.dy) * intensity);

  Projection _projection(Size size) {
    Projection? projection = this.projection;
    if (projection == null || projection.size != size) {
      projection = Projection(style, size, data);
      this.projection = projection;
    }
    return projection;
  }
}
