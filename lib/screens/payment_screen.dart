import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe
    hide Card;
import 'package:pim/screens/OrderConfirmationScreen.dart';
import '../models/cart_model.dart';
import 'package:dio/dio.dart';

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
        const SnackBar(
          content: Text('Payment not ready. Please try again.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
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
              primary: Colors.blue,
              background: Colors.white,
              componentBorder: Colors.grey,
              componentBackground: Colors.white,
              placeholderText: Colors.grey,
              componentText: Colors.black,
              error: Colors.red,
            ),
            shapes: const stripe.PaymentSheetShape(
              borderRadius: 8.0,
              borderWidth: 1.0,
            ),
            primaryButton: stripe.PaymentSheetPrimaryButtonAppearance(
              colors: stripe.PaymentSheetPrimaryButtonTheme(
                light: stripe.PaymentSheetPrimaryButtonThemeColors(
                  background: Colors.blue,
                  text: Colors.white,
                  border: Colors.blue,
                ),
                dark: stripe.PaymentSheetPrimaryButtonThemeColors(
                  background: Colors.blue,
                  text: Colors.white,
                  border: Colors.blue,
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

      // Navigate to OrderConfirmationScreen on success
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
      print('Payment failed: $e'); // Log the detailed error for debugging
      String userFriendlyMessage = 'Payment failed. Please try again.';

      // Provide specific messages based on the error type
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
          backgroundColor: Colors.red,
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
    return 21.00; // Fixed as per the screenshot
  }

  @override
  Widget build(BuildContext context) {
    // Debug print to check images
    for (var item in widget.cartItems) {
      print('Product: ${item.product.name}, Image URL: ${item.product.image}');
    }

    final totalPrice = getTotalPrice();
    const shippingPrice = 21.00;
    final finalPrice = totalPrice + shippingPrice;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.black87,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            )
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      // Progress Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildProgressStep('Shipping', false),
                            _buildProgressStep('Payment', true),
                            _buildProgressStep('Checkout', false),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Order Summary Section
                              const Text(
                                'Order Summary',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 16),
                              // List of cart items with images
                              ...widget.cartItems.map(
                                (item) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Card(
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Row(
                                        children: [
                                          // Product Image
                                          Container(
                                            width: 60,
                                            height: 60,
                                            child: item.product.image.isNotEmpty
                                                ? Image.network(
                                                    item.product.image,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
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
                                          const SizedBox(width: 12),
                                          // Product Details
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Item: ${item.product.name}',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black87,
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
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      _buildPriceRow(
                                          'Item total:', totalPrice, false),
                                      const SizedBox(height: 8),
                                      _buildPriceRow(
                                          'Shipping:', shippingPrice, false),
                                      const Divider(height: 24),
                                      _buildPriceRow(
                                          'Total price:', finalPrice, true),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                      // Pay Now Button
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _makePayment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.greenAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: const Text(
                              'Pay Now',
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
                ),
    );
  }

  Widget _buildProgressStep(String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Colors.blue : Colors.grey[300],
          ),
          child: isActive
              ? const Icon(
                  Icons.circle,
                  size: 24,
                  color: Colors.greenAccent,
                )
              : const SizedBox(),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isActive
                ? const Color.fromARGB(255, 17, 225, 173)
                : Colors.grey,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, double price, bool isTotal) {
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
            color: isTotal
                ? const Color.fromARGB(255, 17, 225, 173)
                : Colors.black54,
          ),
        ),
      ],
    );
  }
}
