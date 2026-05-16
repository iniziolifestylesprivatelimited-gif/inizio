import 'package:flutter/material.dart';
import '../../models/product_model.dart';

class OrderSummary extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final bool isBuyNow;
  final Variant? selectedVariant;
  final Product? buyNowProduct;

  const OrderSummary({
    super.key,
    required this.items,
    required this.isBuyNow,
    required this.selectedVariant,
    required this.buyNowProduct,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final product = isBuyNow
              ? item['product'] as Product
              : Product.fromJson(item['product']);

          final qty = item['quantity'];
          final variant = item['variantName'];

          final price = isBuyNow
              ? (selectedVariant?.offerPrice ??
                  selectedVariant?.price ??
                  buyNowProduct!.offerPrice ??
                  buyNowProduct!.basePrice)
                  .toDouble()
              : ((item['product']['offerPrice'] ??
                  item['product']['basePrice'] ??
                  0))
                  .toDouble();

          return ListTile(
            title: Text(product.name),
            subtitle: variant != null ? Text("Variant: $variant") : null,
            trailing: Text("₹${(price * qty).toStringAsFixed(2)} x $qty"),
          );
        },
      ),
    );
  }
}
