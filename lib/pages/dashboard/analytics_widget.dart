import 'package:flareline/core/theme/global_colors.dart';
import 'package:flutter/material.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:flareline_uikit/components/charts/circular_chart.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '/services/api_service.dart';
import '../analytics_viewmodel.dart';

class AnalyticsWidget extends StatefulWidget {
  const AnalyticsWidget({super.key});

  @override
  State<AnalyticsWidget> createState() => _AnalyticsWidgetState();
}

class _AnalyticsWidgetState extends State<AnalyticsWidget> {
  late final AnalyticsViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = AnalyticsViewModel(
      ApiService(baseUrl: 'http://localhost:2000/api'),
    );
    viewModel.addListener(() => setState(() {}));
    viewModel.fetchAnalytics();
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      desktop: _analyticsWeb,
      mobile: _analyticsMobile,
      tablet: _analyticsMobile,
    );
  }

  Widget _analyticsWeb(BuildContext context) => SizedBox(
        height: 350,
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: CommonCard(
                child: viewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : viewModel.errorMessage != null
                        ? Center(child: Text(viewModel.errorMessage!))
                        : CircularhartWidget(
                            title: 'Doctors by Specialization',
                            palette: const [
                              GlobalColors.warn,
                              GlobalColors.secondary,
                              GlobalColors.primary,
                              Colors.green,
                              Colors.red,
                              Colors.purple,
                              Colors.orange,
                              Colors.teal,
                              Colors.blue,
                              Colors.yellow,
                              Colors.cyan,
                              Colors.pink,
                              Colors.lime,
                              Colors.indigo,
                              Colors.brown,
                            ],
                            chartData: viewModel.stats.isNotEmpty
                                ? viewModel.stats
                                : [
                                    {'x': 'No Data', 'y': 1}
                                  ],
                          ),
              ),
            ),
            // const SizedBox(width: 16),
            // Expanded(
            //   flex: 4,
            //   child: CommonCard(child: const MapChartWidget()),
            // ),
          ],
        ),
      );

  Widget _analyticsMobile(BuildContext context) => Column(
        children: [
          SizedBox(
            height: 350,
            child: CommonCard(
              child: viewModel.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : viewModel.errorMessage != null
                      ? Center(child: Text(viewModel.errorMessage!))
                      : CircularhartWidget(
                          title: 'Doctors by Specialization',
                          palette: const [
                            GlobalColors.warn,
                            GlobalColors.secondary,
                            GlobalColors.primary,
                            Colors.green,
                            Colors.red,
                            Colors.purple,
                            Colors.orange,
                            Colors.teal,
                            Colors.blue,
                            Colors.yellow,
                            Colors.cyan,
                            Colors.pink,
                            Colors.lime,
                            Colors.indigo,
                            Colors.brown,
                          ],
                          chartData: viewModel.stats.isNotEmpty
                              ? viewModel.stats
                              : [
                                  {'x': 'No Data', 'y': 1}
                                ],
                        ),
            ),
          ),
          // const SizedBox(height: 16),
          // SizedBox(
          //   height: 350,
          //   child: CommonCard(child: const MapChartWidget()),
          // ),
        ],
      );
}
