import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../providers/product_provider.dart';
import '../../../providers/brand_provider.dart';
import '../../../utils/constants.dart';
import '../../products/product_detail_screen.dart';

class TravelSmartPicksSection extends StatelessWidget {
  const TravelSmartPicksSection({super.key});

  String cleanPrice(double value) {
    if (value == value.toInt()) {
      return value.toInt().toString();
    }
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final brandProvider = Provider.of<BrandProvider>(context);

    final List<String> allowedCategories = [
  "Kindle Paper",
  "Portable Speaker",
  "Fire TV Stick",
];

final products = productProvider.products
    .where((p) => allowedCategories.contains(p.categoryName?.trim()))
    .toList();


    final bool isLoading = productProvider.isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Amazon Products",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 10),

        SizedBox(
          height: 250,

          // ⭐ CASE 1 — LOADING → Show shimmer UI
          child: isLoading
              ? _buildShimmerLoading()

              // ⭐ CASE 2 — NO PRODUCTS → Show empty placeholder
              : products.isEmpty
                  ? _buildEmptyUI()

                  // ⭐ CASE 3 — SHOW PRODUCTS
                  : _buildProductList(products, brandProvider, context),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // ⭐ SHIMMER LOADING SKELETON
  // ---------------------------------------------------------------------------
  Widget _buildShimmerLoading() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 6,
      itemBuilder: (_, index) {
        return Container(
          width: 150,
          margin: const EdgeInsets.only(right: 12),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image skeleton
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 8),

                // Brand text skeleton
                Container(height: 10, width: 60, color: Colors.grey.shade300),
                const SizedBox(height: 6),

                // Name skeleton
                Container(height: 10, width: 120, color: Colors.grey.shade300),
                const SizedBox(height: 4),

                Container(height: 10, width: 100, color: Colors.grey.shade300),
                const SizedBox(height: 6),

                // Price skeleton
                Container(height: 12, width: 80, color: Colors.grey.shade300),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // ⭐ EMPTY UI WHEN NO PRODUCTS
  // ---------------------------------------------------------------------------
  Widget _buildEmptyUI() {
    return Center(
      child: Container(
        height: 180,
        width: 180,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.headset_off, size: 50, color: Colors.grey),
            SizedBox(height: 10),
            Text(
              "No Amazon Products",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 5),
            Text(
              "Products not available",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ⭐ PRODUCT LIST UI
  // ---------------------------------------------------------------------------
  Widget _buildProductList(
      List products, BrandProvider brandProvider, BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: products.length,
      itemBuilder: (_, index) {
        final product = products[index];

        final brand = brandProvider.brands.firstWhere(
          (b) => b.id == product.brandId,
          orElse: () => brandProvider.brands.first,
        );

        String? imageUrl;
        if (product.variants.isNotEmpty &&
            product.variants.first.images.isNotEmpty) {
          imageUrl = product.variants.first.images.first.startsWith('http')
              ? product.variants.first.images.first
              : '${ApiConstants.imageBaseUrl}/${product.variants.first.images.first}';
        } else if (product.images.isNotEmpty) {
          imageUrl = product.images.first.startsWith('http')
              ? product.images.first
              : '${ApiConstants.imageBaseUrl}/${product.images.first}';
        }

        final bool hasOffer = product.offerPrice != null;

        int offerPercent = 0;
        if (hasOffer) {
          offerPercent =
              ((1 - (product.offerPrice! / product.basePrice)) * 100).round();
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
            width: 150,
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image box
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(244,248,250, 1), // background color
                    borderRadius: BorderRadius.circular(1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: imageUrl != null
                        ? Image.network(imageUrl, fit: BoxFit.cover)
                        : Container(
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.image, size: 40),
                          ),
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  brand.name,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),

               SizedBox(
  height: 34,
  child: Text(
    product.name,
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
    style: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
  ),
),


                const SizedBox(height: 3),

                hasOffer
                    ? Row(
                        children: [
                          Text(
                            "₹${cleanPrice(product.offerPrice!)}",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(width: 5),

                          Text(
                            "₹${cleanPrice(product.basePrice)}",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),

                          const SizedBox(width: 5),

                          Text(
                            "$offerPercent% OFF",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        "₹${cleanPrice(product.basePrice)}",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      )
              ],
            ),
          ),
        );
      },
    );
  }
}
