import 'package:flutter/material.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import '/components/charts/bar_chart.dart';
import 'package:provider/provider.dart';
import '/services/api_service.dart';
import 'chart_data_provider.dart';
import 'bmi_view_model.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:flareline_uikit/components/charts/line_chart.dart';

class RevenueWidget extends StatefulWidget {
  const RevenueWidget({super.key});

  @override
  State<RevenueWidget> createState() => _RevenueWidgetState();
}

class _RevenueWidgetState extends State<RevenueWidget> {
  late final BMIViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = BMIViewModel(ApiService(baseUrl: 'http://localhost:2000/api'));
    viewModel.addListener(() => setState(() {}));
    viewModel.fetchBMIAnalytics();
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _revenueWidget(context);
  }

  Widget _revenueWidget(BuildContext context) {
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
            child: _lineChart(),
            flex: 2,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _barChart(context),
            flex: 1,
          ),
        ],
      ),
    );
  }

  Widget _revenueWidgetMobile(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 360,
          child: _lineChart(),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 360,
          child: _barChart(context),
        ),
      ],
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

  Widget _barChart(BuildContext context) {
    return CommonCard(
      child: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : viewModel.errorMessage != null
              ? Center(child: Text(viewModel.errorMessage!))
              : ChangeNotifierProvider(
                  create: (context) => ChartDataProvider(viewModel.bmiStats),
                  child: const BarChartWidget(),
                ),
    );
  }
}
