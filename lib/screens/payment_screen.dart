import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe hide Card;
import 'package:pim/screens/OrderConfirmationScreen.dart';
import '../models/cart_model.dart';
import 'package:dio/dio.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PaymentScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final String token;

  const PaymentScreen({required this.cartItems, required this.token, Key? key})
      : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final Dio _dio = Dio();
  String? clientSecret;
  String? orderId;
  String? errorMessage;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (stripe.Stripe.publishableKey.isEmpty) {
      print('Stripe publishable key not set. Please initialize in main.dart.');
      setState(() {
        errorMessage = 'Payment configuration error. Please try again later.';
        isLoading = false;
      });
      return;
    }
    _createPaymentIntent();
  }

  Future<void> _createPaymentIntent() async {
    try {
      final cartData = widget.cartItems
          .map((item) => {
                'productId': item.product.id,
                'quantity': item.quantity,
              })
          .toList();

      final response = await _dio.post(
        'http://10.0.2.2:2000/api/orders/create-payment-intent',
        data: {'items': cartData},
        options: Options(headers: {'Authorization': 'Bearer ${widget.token}'}),
      );

      setState(() {
        clientSecret = response.data['clientSecret'];
        orderId = response.data['orderId'];
        isLoading = false;
      });
    } catch (e) {
      print('Failed to create payment intent: $e');
      setState(() {
        errorMessage = 'Failed to initialize payment. Please try again.';
        isLoading = false;
      });
    }
  }

  Future<void> _makePayment() async {
    if (clientSecret == null || orderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Payment not ready. Please try again.'),
          backgroundColor: Colors.red[700],
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }
    try {
      await stripe.Stripe.instance.initPaymentSheet(
        paymentSheetParameters: stripe.SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'ElderlyCare',
          appearance: stripe.PaymentSheetAppearance(
            colors: stripe.PaymentSheetAppearanceColors(
              primary: const Color(0xFF199A8E),
              background: Colors.white,
              componentBorder: Colors.grey[300]!,
              componentBackground: Colors.white,
              placeholderText: Colors.grey[600]!,
              componentText: Colors.black87,
              error: Colors.red[700]!,
            ),
            shapes: const stripe.PaymentSheetShape(
              borderRadius: 12.0,
              borderWidth: 1.0,
            ),
            primaryButton: stripe.PaymentSheetPrimaryButtonAppearance(
              colors: stripe.PaymentSheetPrimaryButtonTheme(
                light: stripe.PaymentSheetPrimaryButtonThemeColors(
                  background: const Color(0xFF199A8E),
                  text: Colors.white,
                  border: const Color(0xFF199A8E),
                ),
                dark: stripe.PaymentSheetPrimaryButtonThemeColors(
                  background: const Color(0xFF199A8E),
                  text: Colors.white,
                  border: const Color(0xFF199A8E),
                ),
              ),
            ),
          ),
          googlePay: const stripe.PaymentSheetGooglePay(
            merchantCountryCode: 'US',
            testEnv: true,
          ),
        ),
      );

      await stripe.Stripe.instance.presentPaymentSheet();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Payment successful!'),
          backgroundColor: const Color(0xFF199A8E),
          duration: const Duration(seconds: 3),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OrderConfirmationScreen(
            orderId: orderId!,
            cartItems: widget.cartItems,
          ),
        ),
      );
    } catch (e) {
      print('Payment failed: $e');
      String userFriendlyMessage = 'Payment failed. Please try again.';
      if (e is stripe.StripeException) {
        if (e.error.code == 'cancelled') {
          userFriendlyMessage = 'Payment cancelled.';
        } else if (e.error.code == 'card_declined') {
          userFriendlyMessage =
              'Card declined. Please use a different payment method.';
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(userFriendlyMessage),
          backgroundColor: Colors.red[700],
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  double getTotalPrice() {
    return widget.cartItems
        .fold(0, (sum, item) => sum + (item.product.price * item.quantity));
  }

  double getShippingPrice() {
    return 21.00;
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF199A8E);
    final totalPrice = getTotalPrice();
    const shippingPrice = 21.00;
    final finalPrice = totalPrice + shippingPrice;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Checkout', style: TextStyle(color: Colors.white)),
        elevation: 0,
        centerTitle: true,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(color: primaryColor),
            )
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red[700],
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        errorMessage!,
                        style: TextStyle(
                          color: Colors.red[700],
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _createPaymentIntent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Progress Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildProgressStep('Shipping', false, primaryColor),
                            _buildProgressStep('Payment', true, primaryColor),
                            _buildProgressStep('Checkout', false, primaryColor),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Order Summary Section
                              Text(
                                'Order Summary',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                              const SizedBox(height: 16),
                              // List of cart items
                              ...widget.cartItems.map(
                                (item) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Card(
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Row(
                                        children: [
                                          // Product Image
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: item.product.image.isNotEmpty
                                                ? CachedNetworkImage(
                                                    imageUrl:
                                                        item.product.image,
                                                    width: 60,
                                                    height: 60,
                                                    fit: BoxFit.cover,
                                                    placeholder: (context,
                                                            url) =>
                                                        Center(
                                                            child: CircularProgressIndicator(
                                                                color:
                                                                    primaryColor)),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Container(
                                                      width: 60,
                                                      height: 60,
                                                      color: Colors.grey[200],
                                                      child: const Icon(
                                                        Icons.broken_image,
                                                        size: 30,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  )
                                                : Container(
                                                    width: 60,
                                                    height: 60,
                                                    color: Colors.grey[200],
                                                    child: const Icon(
                                                      Icons.image,
                                                      size: 30,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                          ),
                                          const SizedBox(width: 12),
                                          // Product Details
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item.product.name,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'Quantity: ${item.quantity}',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  '\$${item.product.price.toStringAsFixed(2)}',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: primaryColor,
                                                    fontWeight: FontWeight.w600,
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
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      _buildPriceRow('Item total:', totalPrice,
                                          false, primaryColor),
                                      const SizedBox(height: 12),
                                      _buildPriceRow('Shipping:', shippingPrice,
                                          false, primaryColor),
                                      const Divider(height: 24),
                                      _buildPriceRow('Total price:', finalPrice,
                                          true, primaryColor),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
      bottomNavigationBar: !isLoading && errorMessage == null
          ? Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _makePayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Pay Now (\$${finalPrice.toStringAsFixed(2)})',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildProgressStep(String label, bool isActive, Color primaryColor) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? primaryColor : Colors.grey[300],
          ),
          child: isActive
              ? Icon(
                  Icons.check_circle,
                  size: 24,
                  color: Colors.white,
                )
              : const SizedBox(),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isActive ? primaryColor : Colors.grey[600],
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
