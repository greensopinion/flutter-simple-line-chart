extension DoubleExtension on double {
  double difference(double other) {
    if (other < 0 && this > 0 || other > 0 && this < 0) {
      return (other.abs() + this.abs()).abs();
    }
    return (other.abs() - this.abs()).abs();
  }
}
