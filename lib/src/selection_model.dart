import 'package:flutter/material.dart';

import '../simple_line_chart.dart';
import 'line_chart_data.dart';
import 'projection.dart';

class SelectionModel extends ChangeNotifier {
  final LineChartStyle style;
  final LineChartData data;
  final Size size;
  Projection? _projection;
  List<QualifiedDataPoint> _selection = [];

  List<QualifiedDataPoint> get selection => _selection;
  set selection(List<QualifiedDataPoint> newSelection) {
    if (_selection != newSelection) {
      _selection = newSelection;
      notifyListeners();
    }
  }

  Projection get projection {
    if (_projection == null) {
      _projection = Projection(style, size, data);
    }
    return _projection!;
  }

  SelectionModel(this.style, this.data, this.size);

  void onTapUp(Offset? localPosition) => _udpateSelection(localPosition);

  onDrag(Offset? localPosition) => _udpateSelection(localPosition);

  void _udpateSelection(Offset? localPosition) {
    if (localPosition == null) {
      selection = [];
    } else {
      selection = projection.fromPixel(position: localPosition);
    }
  }
}
