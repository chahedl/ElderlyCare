import 'package:flareline/core/theme/global_colors.dart';
import 'package:flutter/material.dart';
import 'package:flareline_uikit/components/buttons/button_widget.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:flareline/pages/layout.dart';
import 'package:flareline/flutter_gen/app_localizations.dart';
import 'add_product_form.dart'; // Adjust path based on your structure
import 'add_doctor_form.dart'; // Adjust path based on your structure

class InvoicePage extends LayoutWidget {
  const InvoicePage({super.key});

  @override
  String breakTabTitle(BuildContext context) {
    return 'Add Product & Doctor';
  }

  @override
  Widget contentDesktopWidget(BuildContext context) {
    return CommonCard(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Product',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const AddProductForm(),
            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 40),
            const Text(
              'Add Doctor',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const AddDoctorForm(),
          ],
        ),
      ),
    );
  }
}
