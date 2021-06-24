# simple_line_chart

Provides a simple line chart. An opinionated library that focuses on API simplicity.

* Charts multiple datasets
* Uses flutter components where text is presented so that system font sizes are adaptive
* Cubic bezier curves
* Multiple axes
* Legend

<img src="https://github.com/greensopinion/flutter-simple-line-chart/blob/main/chart-example.png" width="50%">

## Usage

Include a chart as follows:

```dart
class LineChartContent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LineChartContentState();
  }
}

class _LineChartContentState extends State<LineChartContent> {
  late final LineChartData data;

  @override
  void initState() {
    super.initState();

    // create a data model
    data = LineChartData(datasets: [
      Dataset(
          label: 'First', dataPoints: _createDataPoints(offsetInDegrees: 90)),
      Dataset(
          label: 'Second', dataPoints: _createDataPoints(offsetInDegrees: 0)),
      Dataset(
          label: 'Third', dataPoints: _createDataPoints(offsetInDegrees: 180))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
          padding: EdgeInsets.only(top: 20),
          child: SizedBox(
              height: 300,
              // add the chart
              child: LineChart(
                  // chart is styled
                  style: LineChartStyle.fromTheme(context),
                  // chart has data
                  data: data)))
    ]);
  }
}

// data points are created on a sine curve here,
// but you can plot any data you like
List<DataPoint> _createDataPoints({required int offsetInDegrees}) {
  List<DataPoint> dataPoints = [];
  final degreesToRadians = (pi / 180);
  for (int x = 0; x < 180; x += 20) {
    final di = (x * 2).toDouble() * degreesToRadians;
    dataPoints.add(DataPoint(
        x: x.toDouble(), y: 100.0 * ((sin(di + offsetInDegrees) + 1.0) / 2.0)));
  }
  return dataPoints;
}
```

See the [example](./example) for details.

## License

Copyright 2021 David Green

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice,
   this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, 
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors
   may be used to endorse or promote products derived from this software without
   specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR 
BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, 
STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
 OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.