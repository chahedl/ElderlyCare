import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '/pages/dashboard/chart_data_provider.dart'; // Import ChartDataProvider and ChartData

class BarChartWidget extends StatelessWidget {
  const BarChartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Debug: Check if provider is available
    try {
      final provider = Provider.of<ChartDataProvider>(context, listen: false);
      print('ChartDataProvider found: ${provider.chartData}');
    } catch (e) {
      print('Error: ChartDataProvider not found: $e');
      return const Center(child: Text('Error: Chart Data Provider not found'));
    }

    return _barChart(context);
  }

  Widget _barChart(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Users BMI Stats',
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(child: _buildDefaultBarChart(context)),
        ],
      ),
    );
  }

  Widget _buildDefaultBarChart(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      enableSideBySideSeriesPlacement: true,
      title: const ChartTitle(text: ''),
      legend: const Legend(isVisible: true, position: LegendPosition.top),
      primaryXAxis: const CategoryAxis(
        majorGridLines: MajorGridLines(width: 0),
      ),
      primaryYAxis: const NumericAxis(
        axisLine: AxisLine(width: 0),
        labelFormat: '{value}',
        majorTickLines: MajorTickLines(size: 0),
        majorGridLines: MajorGridLines(width: 1),
        rangePadding: ChartRangePadding.additional,
      ),
      series: _getDefaultColumnSeries(context),
      tooltipBehavior: TooltipBehavior(
        enable: true,
        header: '',
        canShowMarker: false,
        textStyle: TextStyle(
          color: isDark ? Colors.black : Colors.grey,
        ),
      ),
    );
  }

  List<ColumnSeries<ChartData, String>> _getDefaultColumnSeries(
      BuildContext context) {
    final chartData = context.watch<ChartDataProvider>().chartData ?? [];
    if (chartData.isEmpty) {
      print('Warning: chartData is empty');
    }

    return <ColumnSeries<ChartData, String>>[
      ColumnSeries<ChartData, String>(
        dataSource: chartData,
        xValueMapper: (ChartData data, _) => data.x,
        yValueMapper: (ChartData data, _) => data.y,
        pointColorMapper: (ChartData data, _) =>
            {
              'Underweight': Colors.red,
              'Normal': Colors.blue,
              'Overweight': Colors.orange,
              'Obese': Colors.green,
              'Cardiologist': Colors.purple,
              'Dentist': Colors.teal,
              'Neurologist': Colors.indigo,
              'Orthopedist': Colors.amber,
              'Pediatrician': Colors.pink,
            }[data.x] ??
            Colors.blue,
        name: 'Distribution',
        dataLabelSettings: const DataLabelSettings(
          isVisible: true,
          textStyle: TextStyle(fontSize: 10),
        ),
      ),
    ];
  }
}
