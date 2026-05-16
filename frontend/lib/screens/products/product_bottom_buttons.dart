import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/product_model.dart';
import '../../../providers/cart_provider.dart';
import '../../../screens/payment/payment_screen.dart';

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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
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

                        Future.delayed(const Duration(milliseconds: 500), () {
                          Navigator.pushNamed(context, '/cart');
                        });
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white, // ✅ Text color white
                padding: const EdgeInsets.symmetric(vertical: 14),
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
                backgroundColor: Colors.green,
                foregroundColor: Colors.white, // ✅ Text color white
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(Icons.flash_on_outlined, color: Colors.white),
              label: const Text("Buy Now"),
            ),
          ),
        ],
      ),
    );
  }
}