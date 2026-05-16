import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../utils/constants.dart';
import '../payment/payment_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<CartProvider>(context, listen: false).getCart(context));
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        actions: [
          if (cartProvider.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_forever),
              onPressed: () async {
                await cartProvider.clearCart(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cart cleared 🧹')),
                );
              },
            ),
        ],
      ),
      body: cartProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartProvider.items.isEmpty
              ? const Center(
                  child: Text('Your cart is empty 🛒'),
                )
              : ListView.builder(
                  itemCount: cartProvider.items.length,
                  itemBuilder: (context, index) {
                    final item = cartProvider.items[index];
                    final product = item['product'];
                    final image = (product['images'] != null &&
                            product['images'].isNotEmpty)
                        ? (product['images'][0].startsWith('http')
                            ? product['images'][0]
                            : '${ApiConstants.imageBaseUrl}/${product['images'][0]}')
                        : null;
                    final price = product['basePrice'] ?? 0;
                    final quantity = item['quantity'] ?? 1;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      child: ListTile(
                        leading: image != null
                            ? Image.network(image, width: 50, height: 50)
                            : const Icon(Icons.image, size: 50),
                        title: Text(
                          product['name'] ?? 'Unnamed Product',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('₹$price x $quantity'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await cartProvider.removeFromCart(
                                context, product['_id']);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    '${product['name']} removed from cart'),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
      bottomNavigationBar: cartProvider.items.isNotEmpty
    ? SafeArea(
        minimum: const EdgeInsets.only(bottom: 12), // ⬅️ moves it up
        child: Container(
          margin: const EdgeInsets.only(bottom: 8), // ⬅️ lift more if needed
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 5),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total: ₹${_calculateTotal(cartProvider)}",
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PaymentScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                ),
                child: const Text("Checkout",
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      )
    : null,

    );
  }

  double _calculateTotal(CartProvider cartProvider) {
    double total = 0;
    for (var item in cartProvider.items) {
      final price = (item['product']['basePrice'] ?? 0).toDouble();
      final quantity = item['quantity'] ?? 1;
      total += price * quantity;
    }
    return total;
  }
}
