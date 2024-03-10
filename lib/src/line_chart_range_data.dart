import 'dart:math';

import 'package:flutter/foundation.dart';

class Range {
  final double low;
  final double high;
  double get size => high - low;

  Range({required this.low, required this.high}) {
    assert(low <= high);
  }

  @override
  bool operator ==(other) =>
      other is Range && other.low == low && other.high == high;
  @override
  int get hashCode => Object.hash(low, high);

  Range expand(Range other) =>
      Range(low: min(low, other.low), high: max(high, other.high));

  bool intersects(Range other) =>
      _containsPoint(other.low) ||
      _containsPoint(other.high) ||
      other._containsPoint(low) ||
      other._containsPoint(high);

  bool _containsPoint(double offset) => offset >= low && offset <= high;
}

enum XAxisDependency { TOP, BOTTOM }

class RangeDataset {
  final String label;
  final XAxisDependency axisDependency;
  final List<Range> ranges;
  final Range bounds;
  final bool includeInLegend;
  double gradientDistance;

  RangeDataset(
      {required this.label,
      required this.axisDependency,
      required this.ranges,
      required this.bounds,
      this.gradientDistance = 0.0,
      this.includeInLegend = true});

  @override
  bool operator ==(other) =>
      other is RangeDataset &&
      listEquals(other.ranges, ranges) &&
      other.axisDependency == axisDependency;
  @override
  int get hashCode => Object.hashAll(ranges);
}
