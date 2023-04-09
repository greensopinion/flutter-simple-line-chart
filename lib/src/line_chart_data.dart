import 'dart:math';
import 'dart:ui';

class LineChartData {
  final List<Dataset> datasets;

  LineChartData({required this.datasets});

  double maxY(YAxisDependency dependency) =>
      datasetsOf(axisDependency: dependency).maxY();

  double minY(YAxisDependency dependency) =>
      datasetsOf(axisDependency: dependency).minY();

  double maxX(YAxisDependency dependency) =>
      datasetsOf(axisDependency: dependency).maxX();

  double minX(YAxisDependency dependency) =>
      datasetsOf(axisDependency: dependency).minX();

  List<Dataset> datasetsOf({required YAxisDependency axisDependency}) =>
      datasets
          .where((dataset) => dataset.axisDependency == axisDependency)
          .toList();

  @override
  int get hashCode => datasets.hashCode;

  @override
  bool operator ==(Object other) =>
      other is LineChartData && other.datasets == datasets;

  @override
  String toString() =>
      'LineChartData(datasets=${datasets.map((e) => e.label).join(", ")})';
}

extension DatasetListExtension on List<Dataset> {
  double maxX() {
    final values = map((e) => e.maxX);
    return values.isEmpty ? 0 : values.reduce(max);
  }

  double minX() {
    final values = map((e) => e.minX);
    return values.isEmpty ? 0 : values.reduce(min);
  }

  double maxY() {
    final values = map((e) => e.maxY);
    return values.isEmpty ? 0 : values.reduce(max);
  }

  double minY() {
    final values = map((e) => e.minY);
    return values.isEmpty ? 0 : values.reduce(min);
  }
}

enum YAxisDependency { LEFT, RIGHT }

class Dataset {
  final String label;
  final String shortLabel;
  final YAxisDependency axisDependency;
  final List<DataPoint> dataPoints;

  Dataset(
      {required this.label,
      String? shortLabel,
      this.axisDependency = YAxisDependency.LEFT,
      required this.dataPoints})
      : this.shortLabel = shortLabel ?? label;

  double get maxY =>
      dataPoints.isEmpty ? 0 : dataPoints.map((e) => e.y).reduce(max);
  double get minY =>
      dataPoints.isEmpty ? 0 : dataPoints.map((e) => e.y).reduce(min);
  double get maxX =>
      dataPoints.isEmpty ? 0 : dataPoints.map((e) => e.x).reduce(max);
  double get minX =>
      dataPoints.isEmpty ? 0 : dataPoints.map((e) => e.x).reduce(min);

  @override
  int get hashCode => Object.hash(label, shortLabel, dataPoints);

  @override
  bool operator ==(Object other) =>
      other is Dataset &&
      other.label == label &&
      other.shortLabel == shortLabel &&
      other.dataPoints == dataPoints;

  @override
  String toString() =>
      'Dataset(label=$label,shortLabel=$shortLabel,dataPoints=[${dataPoints.length}])';
}

class DataPoint {
  final double x;
  final double y;
  final Object? model;

  DataPoint({required this.x, required this.y, this.model});

  Offset toOffset() => Offset(x, y);

  @override
  int get hashCode => Object.hash(x, y, model);

  @override
  bool operator ==(Object other) =>
      other is DataPoint &&
      other.x == x &&
      other.y == y &&
      other.model == model;

  @override
  String toString() => 'DataPoint(x=$x,y=$y,model=$model)';
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

  @override
  String toString() =>
      'QualifiedDataPoint(dataset=$dataset,dataPoint=$dataPoint)';
}
