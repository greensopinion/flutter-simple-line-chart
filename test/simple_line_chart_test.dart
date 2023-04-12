import 'package:simple_line_chart/simple_line_chart.dart';
import 'package:test/test.dart';

void main() {
  test('exports API', () {
    expect(LineChartStyle, LineChartStyle);
    expect(AxisStyle, AxisStyle);
    expect(LineChart, LineChart);
    expect(LineChartController, LineChartController);
    expect(LineChartData, LineChartData);
  });
}
