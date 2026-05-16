import 'package:flutter/material.dart';
import '../../models/product_model.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Product Image
          AspectRatio(
            aspectRatio: 1,
            child: Image.network(
              product.images.isNotEmpty ? product.images[0] : "",
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Icon(Icons.image_not_supported, size: 40),
            ),
          ),

          const SizedBox(height: 5),

          // ✅ Name
          Text(
            product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: FontWeight.w600),
          ),

          // ✅ Price & offer price
          Row(
            children: [
              Text(
                "₹${product.offerPrice ?? product.basePrice}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              if (product.offerPrice != null)
                SizedBox(width: 5),
              if (product.offerPrice != null)
                Text(
                  "₹${product.basePrice}",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
