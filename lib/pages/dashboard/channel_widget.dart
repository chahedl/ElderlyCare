import 'package:flutter/material.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import '/components/charts/bar_chart.dart';
import 'package:provider/provider.dart';
import 'bmi_view_model.dart';
import '/services/api_service.dart';
import 'chart_data_provider.dart';

class BMIWidget extends StatefulWidget {
  const BMIWidget({super.key});

  @override
  State<BMIWidget> createState() => _BMIWidgetState();
}

class _BMIWidgetState extends State<BMIWidget> {
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
    return SizedBox(
      height: 350,
      child: CommonCard(
        child: viewModel.isLoading
            ? const Center(child: CircularProgressIndicator())
            : viewModel.errorMessage != null
                ? Center(child: Text(viewModel.errorMessage!))
                : ChangeNotifierProvider(
                    create: (context) => ChartDataProvider(viewModel.bmiStats),
                    child: const BarChartWidget(),
                  ),
      ),
    );
  }
}
