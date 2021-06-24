import 'dart:math';
import 'dart:ui';

class LineChartData {
  final List<Dataset> datasets;

  LineChartData({required this.datasets});

  double maxY(YAxisDependency dependency) {
    final values = datasetsOf(axisDependency: dependency).map((e) => e.maxY);
    return values.isEmpty ? 0 : values.reduce(max);
  }

  double minY(YAxisDependency dependency) {
    final values = datasetsOf(axisDependency: dependency).map((e) => e.minY);
    return values.isEmpty ? 0 : values.reduce(min);
  }

  double maxX(YAxisDependency dependency) {
    final values = datasetsOf(axisDependency: dependency).map((e) => e.maxX);
    return values.isEmpty ? 0 : values.reduce(max);
  }

  double minX(YAxisDependency dependency) {
    final values = datasetsOf(axisDependency: dependency).map((e) => e.minX);
    return values.isEmpty ? 0 : values.reduce(min);
  }

  List<Dataset> datasetsOf({required YAxisDependency axisDependency}) =>
      datasets
          .where((dataset) => dataset.axisDependency == axisDependency)
          .toList();

  @override
  int get hashCode => datasets.hashCode;

  @override
  bool operator ==(Object other) =>
      other is LineChartData && other.datasets == datasets;
}

enum YAxisDependency { LEFT, RIGHT }

class Dataset {
  final String label;
  final YAxisDependency axisDependency;
  final List<DataPoint> dataPoints;

  Dataset(
      {required this.label,
      this.axisDependency = YAxisDependency.LEFT,
      required this.dataPoints});

  double get maxY =>
      dataPoints.isEmpty ? 0 : dataPoints.map((e) => e.y).reduce(max);
  double get minY =>
      dataPoints.isEmpty ? 0 : dataPoints.map((e) => e.y).reduce(min);
  double get maxX =>
      dataPoints.isEmpty ? 0 : dataPoints.map((e) => e.x).reduce(max);
  double get minX =>
      dataPoints.isEmpty ? 0 : dataPoints.map((e) => e.x).reduce(min);

  @override
  int get hashCode => hashValues(label, dataPoints);

  @override
  bool operator ==(Object other) =>
      other is Dataset &&
      other.label == label &&
      other.dataPoints == dataPoints;
}

class DataPoint {
  final double x;
  final double y;
  final Object? model;

  DataPoint({required this.x, required this.y, this.model});

  Offset toOffset() => Offset(x, y);

  @override
  int get hashCode => hashValues(x, y, model);

  @override
  bool operator ==(Object other) =>
      other is DataPoint &&
      other.x == x &&
      other.y == y &&
      other.model == model;
}

class QualifiedDataPoint {
  final Dataset dataset;
  final DataPoint dataPoint;

  QualifiedDataPoint(this.dataset, this.dataPoint);

  @override
  int get hashCode => dataPoint.hashCode;

  @override
  bool operator ==(Object other) =>
      other is QualifiedDataPoint &&
      other.dataPoint == dataPoint &&
      other.dataset == dataset;
}
