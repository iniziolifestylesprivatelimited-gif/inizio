import 'package:flutter/material.dart';

import '../../../models/product_model.dart';
import '../../../utils/cached_retry_image.dart';
import '../../../utils/constants.dart';
import '../../products/product_detail_screen.dart';




class HomeProductsGrid extends StatelessWidget {
  final List<Product> products;

  const HomeProductsGrid({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.7,
      ),
      itemCount: products.length,
      itemBuilder: (_, index) {
        final product = products[index];

        String? imageUrl;

        if (product.variants.isNotEmpty &&
            product.variants.first.images.isNotEmpty) {
          imageUrl = product.variants.first.images.first.startsWith("http")
              ? product.variants.first.images.first
              : "${ApiConstants.imageBaseUrl}/${product.variants.first.images.first}";
        } else if (product.images.isNotEmpty) {
          imageUrl = product.images.first.startsWith("http")
              ? product.images.first
              : "${ApiConstants.imageBaseUrl}/${product.images.first}";
        }

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailScreen(product: product),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(8)),
                    child: imageUrl != null
                        ? RetryImage(url: imageUrl)
                        : Container(
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.image, size: 40),
                          ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style:
                        const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    "₹${product.offerPrice ?? product.basePrice}",
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
              ],
            ),
          ),
        );
      },
    );
  }
}
