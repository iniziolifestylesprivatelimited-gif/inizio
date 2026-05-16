import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/product_model.dart';
import '../../../providers/cart_provider.dart';
import '../../../screens/payment/payment_screen.dart';
import '../homescreen/home_screen.dart';

class ProductBottomButtons extends StatelessWidget {
  final Product product;
  final int quantity;
  final Variant? selectedVariant;
  final bool isOutOfStock;

  const ProductBottomButtons({
    super.key,
    required this.product,
    required this.quantity,
    required this.selectedVariant,
    required this.isOutOfStock,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isOutOfStock
                ? null
                : () async {
                    if (product.variants.isNotEmpty && selectedVariant == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please select a variant"),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }
    
                    final cartProvider =
                        Provider.of<CartProvider>(context, listen: false);
    
                    await cartProvider.addToCart(
                      context,
                      product,
                      quantity,
                      selectedVariant,
                    );
    
                    if (cartProvider.error != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(cartProvider.error!),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '${product.name} added to cart (x$quantity) 🛒'),
                          backgroundColor: Colors.green,
                        ),
                      );
    
                     Future.delayed(
  const Duration(milliseconds: 500),
  () {

    Navigator.pushAndRemoveUntil(
      context,

      MaterialPageRoute(
        builder: (_) => const HomeScreen(
          initialIndex: 5,
        ),
      ),

      (route) => false,
    );
  },
);
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white, // ✅ Text color white
              padding: const EdgeInsets.symmetric(vertical: 14),
                shape:  RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),// 🔥 This makes it rectangular
  ),
            ),
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
            label: const Text("Add to Cart"),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isOutOfStock
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentScreen(
                          buyNowProduct: product,
                          selectedVariant: selectedVariant,
                          quantity: quantity,
                        ),
                      ),
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black, // ✅ Text color white
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape:  RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
  ),
            ),
            icon: const Icon(Icons.flash_on_outlined, color: Colors.black),
            label: const Text("Buy Now"),
          ),
        ),
      ],
    );
  }
}