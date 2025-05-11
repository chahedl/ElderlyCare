import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'dart:io';
import '../models/cart_model.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final String orderId;
  final List<CartItem> cartItems;

  const OrderConfirmationScreen({
    required this.orderId,
    required this.cartItems,
    Key? key,
  }) : super(key: key);

  double getTotalPrice() {
    return cartItems.fold(
        0, (sum, item) => sum + (item.product.price * item.quantity));
  }

  double getShippingPrice() {
    return 20.00;
  }

  Future<void> _generateAndSavePdf(BuildContext context) async {
    final pdf = pw.Document();
    final totalPrice = getTotalPrice();
    const shippingPrice = 21.00;
    final finalPrice = totalPrice + shippingPrice;
    const primaryColor = PdfColor.fromInt(0xFF199A8E);

    // Create PDF content
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Order Receipt',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: primaryColor,
              ),
            ),
            pw.SizedBox(height: 16),
            pw.Text(
              'Order #$orderId',
              style: const pw.TextStyle(fontSize: 18),
            ),
            pw.SizedBox(height: 16),
            pw.Text(
              'Order Details',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: primaryColor,
              ),
            ),
            pw.Divider(color: primaryColor),
            // Item List
            ...cartItems.map(
              (item) => pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 4),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Item: ${item.product.name}',
                            style:
                                pw.TextStyle(fontSize: 14, color: primaryColor),
                          ),
                          pw.Text(
                            'Quantity: ${item.quantity}',
                            style: const pw.TextStyle(fontSize: 12),
                          ),
                          pw.Text(
                            'Price: \$${item.product.price.toStringAsFixed(2)}',
                            style: const pw.TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    pw.Text(
                      '\$${(item.product.price * item.quantity).toStringAsFixed(2)}',
                      style: const pw.TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            pw.SizedBox(height: 16),
            pw.Divider(color: primaryColor),
            // Price Breakdown
            pw.Text(
              'Price Breakdown',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: primaryColor,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Item total:', style: const pw.TextStyle(fontSize: 14)),
                pw.Text(
                  '\$${totalPrice.toStringAsFixed(2)}',
                  style: const pw.TextStyle(fontSize: 14),
                ),
              ],
            ),
            pw.SizedBox(height: 8),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Shipping:', style: const pw.TextStyle(fontSize: 14)),
                pw.Text(
                  '\$${shippingPrice.toStringAsFixed(2)}',
                  style: const pw.TextStyle(fontSize: 14),
                ),
              ],
            ),
            pw.SizedBox(height: 8),
            pw.Divider(color: primaryColor),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Total price:',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  '\$${finalPrice.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    // Save PDF to temporary directory
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/order_$orderId.pdf');
      await file.writeAsBytes(await pdf.save());

      // Open the PDF
      final result = await OpenFile.open(file.path);
      if (result.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open PDF: ${result.message}'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate PDF: $e'),
          backgroundColor: Colors.red[700],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = getTotalPrice();
    const shippingPrice = 21.00;
    final finalPrice = totalPrice + shippingPrice;
    const primaryColor = Color(0xFF199A8E);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text(
          'Order Confirmation',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                // Progress Bar
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildProgressStep('Shipping', false, primaryColor),
                      _buildProgressStep('Payment', false, primaryColor),
                      _buildProgressStep('Checkout', true, primaryColor),
                    ],
                  ),
                ),
                // Success Message
                AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 500),
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [primaryColor, primaryColor.withOpacity(0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Your order #$orderId successfully placed',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Track order feature coming soon!')),
                    );
                  },
                  child: Text(
                    'Track your order here',
                    style: TextStyle(
                      fontSize: 16,
                      color: primaryColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // List of items
                        ...cartItems.map(
                          (item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                    color: primaryColor.withOpacity(0.2)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    // Product Image
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        gradient: LinearGradient(
                                          colors: [
                                            primaryColor.withOpacity(0.1),
                                            primaryColor.withOpacity(0.05),
                                          ],
                                        ),
                                      ),
                                      child: item.product.image.isNotEmpty
                                          ? Image.network(
                                              item.product.image,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Image.asset(
                                                  'assets/placeholder_image.png',
                                                  fit: BoxFit.cover,
                                                );
                                              },
                                            )
                                          : Image.asset(
                                              'assets/placeholder_image.png',
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                    const SizedBox(width: 16),
                                    // Product Details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Item: ${item.product.name}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: primaryColor,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Quantity: ${item.quantity}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black54,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Price: \$${item.product.price.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Price Breakdown
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                                color: primaryColor.withOpacity(0.2)),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white,
                                  primaryColor.withOpacity(0.05),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                _buildPriceRow('Item total:', totalPrice, false,
                                    primaryColor),
                                const SizedBox(height: 8),
                                _buildPriceRow('Shipping:', shippingPrice,
                                    false, primaryColor),
                                const Divider(height: 24),
                                _buildPriceRow('Total price:', finalPrice, true,
                                    primaryColor),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                // Download Receipt Button
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _generateAndSavePdf(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Download Receipt',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                // Continue Shopping Button
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Continue Shopping',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressStep(String label, bool isActive, Color primaryColor) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? primaryColor : Colors.grey[300],
          ),
          child: isActive
              ? Icon(
                  Icons.check,
                  size: 20,
                  color: Colors.white,
                )
              : const SizedBox(),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isActive ? primaryColor : Colors.grey,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(
      String label, double price, bool isTotal, Color primaryColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: Colors.black87,
          ),
        ),
        Text(
          '\$${price.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? primaryColor : Colors.black54,
          ),
        ),
      ],
    );
  }
}
