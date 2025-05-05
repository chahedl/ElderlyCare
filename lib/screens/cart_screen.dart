import 'package:flutter/material.dart';
import '../models/cart_model.dart';
import '../viewmodels/cart_viewmodel.dart';
import 'payment_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CartScreen extends StatefulWidget {
  final String token;
  CartScreen({required this.token});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late final CartViewModel _cartViewModel;
  List<CartItem> _cartItems = [];

  @override
  void initState() {
    super.initState();
    _cartViewModel = CartViewModel(widget.token);
    _loadCart();
  }

  Future<void> _loadCart() async {
    print("Fetching cart items...");
    try {
      Cart cart = await _cartViewModel.getCart();
      print("Cart items loaded: ${cart.items}");
      setState(() {
        _cartItems = cart.items;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load cart: $e'),
          backgroundColor: Colors.red[700],
        ),
      );
    }
  }

  void _showItemOptionsDialog(CartItem item) {
    int selectedQuantity = item.quantity;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Manage Item',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF199A8E),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Product: ${item.product.name}',
                style: TextStyle(color: Colors.grey[800]),
              ),
              const SizedBox(height: 12),
              Text(
                'Current Quantity: ${item.quantity}',
                style: TextStyle(color: Colors.grey[800]),
              ),
              const SizedBox(height: 12),
              DropdownButton<int>(
                value: selectedQuantity,
                items: List.generate(10, (index) => index + 1)
                    .map((value) => DropdownMenuItem<int>(
                          value: value,
                          child: Text(value.toString()),
                        ))
                    .toList(),
                onChanged: (newValue) async {
                  if (newValue != null) {
                    try {
                      await _cartViewModel.updateQuantity(
                          item.product.id, newValue);
                      await _loadCart();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Quantity updated!'),
                          backgroundColor: const Color(0xFF199A8E),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to update quantity: $e'),
                          backgroundColor: Colors.red[700],
                        ),
                      );
                    }
                  }
                },
                dropdownColor: Colors.white,
                style: const TextStyle(color: Colors.black, fontSize: 16),
                underline: Container(height: 2, color: const Color(0xFF199A8E)),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () async {
                      try {
                        await _cartViewModel.removeFromCart(item.product.id);
                        await _loadCart();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Item removed from cart!'),
                            backgroundColor: const Color(0xFF199A8E),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to remove item: $e'),
                            backgroundColor: Colors.red[700],
                          ),
                        );
                      }
                    },
                    child: const Text('Remove',
                        style: TextStyle(color: Colors.red)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF199A8E);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('My Cart', style: TextStyle(color: Colors.white)),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white, size: 28),
            onPressed: () {
              // Implement search functionality later
            },
            tooltip: 'Search Cart',
          ),
        ],
      ),
      body: _cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        Navigator.pop(context), // Return to Marketplace
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Shop Now'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Cart',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _cartItems.length,
                    itemBuilder: (context, index) {
                      final item = _cartItems[index];
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: item.product.image.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: item.product.image,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Center(
                                            child: CircularProgressIndicator(
                                                color: primaryColor)),
                                        errorWidget: (context, url, error) =>
                                            Container(
                                          color: Colors.grey[200],
                                          child: const Icon(
                                            Icons.broken_image,
                                            size: 40,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      )
                                    : Container(
                                        width: 80,
                                        height: 80,
                                        color: Colors.grey[200],
                                        child: const Icon(
                                          Icons.image,
                                          size: 40,
                                          color: Colors.grey,
                                        ),
                                      ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '\$${item.product.price.toStringAsFixed(2)}',
                                      style: TextStyle(
                                          color: primaryColor,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 8),
                                    GestureDetector(
                                      onTap: () => _showItemOptionsDialog(item),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Qty: ${item.quantity}',
                                            style: TextStyle(
                                                color: Colors.grey[600]),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.edit,
                                                color: primaryColor, size: 20),
                                            onPressed: () =>
                                                _showItemOptionsDialog(item),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
      bottomNavigationBar: _cartItems.isNotEmpty
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentScreen(
                          cartItems: _cartItems, token: widget.token),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Checkout (\$${(_cartItems.fold(0.0, (sum, item) => sum + item.product.price * item.quantity)).toStringAsFixed(2)})',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            )
          : null,
    );
  }
}
