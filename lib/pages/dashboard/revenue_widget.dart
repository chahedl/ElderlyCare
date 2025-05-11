// lib/widgets/revenue_widget.dart
import 'package:flutter/material.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:fl_chart/fl_chart.dart';
import '/services/api_service.dart';
import '/pages/top_analytics_view_model.dart';
import 'bmi_view_model.dart';
import 'chart_data_provider.dart';
import '/components/charts/bar_chart.dart';
import 'package:flareline_uikit/components/charts/line_chart.dart';

class RevenueWidget extends StatefulWidget {
  const RevenueWidget({super.key});

  @override
  State<RevenueWidget> createState() => _RevenueWidgetState();
}

class _RevenueWidgetState extends State<RevenueWidget> {
  late final TopAnalyticsViewModel topAnalyticsViewModel;
  late final BMIViewModel bmiViewModel;

  @override
  void initState() {
    super.initState();
    topAnalyticsViewModel =
        TopAnalyticsViewModel(ApiService(baseUrl: 'http://localhost:2000/api'));
    bmiViewModel =
        BMIViewModel(ApiService(baseUrl: 'http://localhost:2000/api'));
    topAnalyticsViewModel.addListener(() => setState(() {}));
    bmiViewModel.addListener(() => setState(() {}));
    topAnalyticsViewModel.fetchTopAnalytics();
    bmiViewModel.fetchBMIAnalytics();
  }

  @override
  void dispose() {
    topAnalyticsViewModel.dispose();
    bmiViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      desktop: _revenueWidgetDesktop,
      mobile: _revenueWidgetMobile,
      tablet: _revenueWidgetMobile,
    );
  }

  Widget _revenueWidgetDesktop(BuildContext context) {
    return SizedBox(
      height: 350,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: _topAnalyticsChart(
                context), // Top Analytics (Most Bought, Most Booked)
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: _bmiChart(context), // BMI Chart
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: _lineChart(), // Existing Line Chart
          ),
        ],
      ),
    );
  }

  Widget _revenueWidgetMobile(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 360,
            child: _topAnalyticsChart(context), // Top Analytics
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 360,
            child: _bmiChart(context), // BMI Chart
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 360,
            child: _lineChart(), // Existing Line Chart
          ),
        ],
      ),
    );
  }

  Widget _topAnalyticsChart(BuildContext context) {
    return CommonCard(
      child: topAnalyticsViewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : topAnalyticsViewModel.errorMessage != null
              ? Center(child: Text(topAnalyticsViewModel.errorMessage!))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Top Analytics',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF199A8E),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: _getMaxY(),
                            barGroups: [
                              BarChartGroupData(
                                x: 0,
                                barRods: [
                                  BarChartRodData(
                                    toY: topAnalyticsViewModel
                                        .mostBoughtProduct!['y']
                                        .toDouble(),
                                    color: const Color(0xFF199A8E),
                                    width: 40,
                                  ),
                                ],
                              ),
                              BarChartGroupData(
                                x: 1,
                                barRods: [
                                  BarChartRodData(
                                    toY: topAnalyticsViewModel
                                        .mostBookedDoctor!['y']
                                        .toDouble(),
                                    color: const Color(0xFF01B7F9),
                                    width: 40,
                                  ),
                                ],
                              ),
                            ],
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) => Text(
                                    value.toInt().toString(),
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  reservedSize: 40,
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) => Text(
                                    value == 0
                                        ? topAnalyticsViewModel
                                            .mostBoughtProduct!['x']
                                        : topAnalyticsViewModel
                                            .mostBookedDoctor!['x'],
                                    style: const TextStyle(fontSize: 14),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  reservedSize: 60,
                                ),
                              ),
                              topTitles: const AxisTitles(),
                              rightTitles: const AxisTitles(),
                            ),
                            borderData: FlBorderData(show: false),
                            gridData: const FlGridData(show: false),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _bmiChart(BuildContext context) {
    return CommonCard(
      child: bmiViewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : bmiViewModel.errorMessage != null
              ? Center(child: Text(bmiViewModel.errorMessage!))
              : ChangeNotifierProvider(
                  create: (context) => ChartDataProvider(bmiViewModel.bmiStats),
                  child: const BarChartWidget(),
                ),
    );
  }

  Widget _lineChart() {
    return CommonCard(
      child: LineChartWidget(
        title: 'Revenue',
        dropdownItems: ['Daily', 'Monthly', 'Yearly'],
        datas: const [
          {
            'name': 'Marketing Sales',
            'color': Color(0xFFFE8111),
            'data': [
              {'x': 'Jan', 'y': 25},
              {'x': 'Feb', 'y': 75},
              {'x': 'Mar', 'y': 28},
              {'x': 'Apr', 'y': 32},
              {'x': 'May', 'y': 40},
              {'x': 'Jun', 'y': 48},
              {'x': 'Jul', 'y': 44},
              {'x': 'Aug', 'y': 42},
              {'x': 'Sep', 'y': 70},
              {'x': 'Oct', 'y': 65},
              {'x': 'Nov', 'y': 55},
              {'x': 'Dec', 'y': 78}
            ]
          },
          {
            'name': 'Cases Sales',
            'color': Color(0xFF01B7F9),
            'data': [
              {'x': 'Jan', 'y': 70},
              {'x': 'Feb', 'y': 30},
              {'x': 'Mar', 'y': 66},
              {'x': 'Apr', 'y': 44},
              {'x': 'May', 'y': 55},
              {'x': 'Jun', 'y': 51},
              {'x': 'Jul', 'y': 44},
              {'x': 'Aug', 'y': 30},
              {'x': 'Sep', 'y': 100},
              {'x': 'Oct', 'y': 87},
              {'x': 'Nov', 'y': 77},
              {'x': 'Dec', 'y': 20}
            ]
          },
        ],
      ),
    );
  }

  double _getMaxY() {
    final productY =
        topAnalyticsViewModel.mostBoughtProduct?['y']?.toDouble() ?? 0;
    final doctorY =
        topAnalyticsViewModel.mostBookedDoctor?['y']?.toDouble() ?? 0;
    return (productY > doctorY ? productY : doctorY) * 1.2; // Add 20% padding
  }
}
