import 'package:flutter/material.dart';
import '../../../models/product_model.dart';
import '../../../services/product_service.dart';
import '../../../utils/constants.dart';
import '../../products/product_detail_screen.dart';

class MoreFromBrandSection extends StatelessWidget {
  final String brandId;
  final String currentProductId;

  const MoreFromBrandSection({
    super.key,
    required this.brandId,
    required this.currentProductId,
  });

  Future<List<Product>> _fetchBrandProducts() async {
    return await ProductService().fetchProductsByBrand(brandId);
  }

  String? _resolveImage(String? img) {
    if (img == null || img.trim().isEmpty) return null;
    if (img.startsWith("http")) return img;
    return "${ApiConstants.imageBaseUrl}/$img";
  }

  String clean(double value) {
    if (value == value.toInt()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: _fetchBrandProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final products = snapshot.data!
            .where((p) => p.id != currentProductId)
            .toList();

        if (products.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(
                "More from this Brand",
                style: TextStyle(
                  fontFamily: "Gilroy",
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),

            SizedBox(
              height: 250,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 16),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final p = products[index];

                  String? image = p.variants.isNotEmpty &&
                          p.variants.first.images.isNotEmpty
                      ? p.variants.first.images.first
                      : p.images.isNotEmpty
                          ? p.images.first
                          : null;

                  final finalImage = _resolveImage(image);

                  // PRICE LOGIC (same as SoundBars)
                  final bool hasOffer = p.offerPrice != null;
                  int offerPercent = 0;

                  if (hasOffer) {
                    offerPercent =
                        ((1 - (p.offerPrice! / p.basePrice)) * 100).round();
                  }

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailScreen(product: p),
                        ),
                      );
                    },
                    child: Container(
                      width: 150,
                      margin: const EdgeInsets.only(right: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // IMAGE BOX
                          Container(
                            height: 150,
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(244, 248, 250, 1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: finalImage != null
                                  ? Image.network(
                                      finalImage,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      color: Colors.grey.shade300,
                                      child: const Icon(Icons.image, size: 40),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // BRAND NAME
                          Text(
                            p.brandName ?? "",
                            style: const TextStyle(
                              fontFamily: "Gilroy",
                              fontSize: 10,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          // PRODUCT NAME
                          SizedBox(
                            height: 32,
                            child: Text(
                              p.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: "Gilroy",
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),

                          const SizedBox(height: 3),

                          // ⭐ PRICE SECTION (exactly like SoundBars)
                          hasOffer
                              ? Row(
                                  children: [
                                    Text(
                                      "₹${clean(p.offerPrice!)}",
                                      style: const TextStyle(
                                        fontFamily: "Gilroy",
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      "₹${clean(p.basePrice)}",
                                      style: const TextStyle(
                                        fontFamily: "Gilroy",
                                        fontSize: 12,
                                        color: Colors.grey,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      "$offerPercent% OFF",
                                      style: const TextStyle(
                                        fontFamily: "Gilroy",
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  "₹${clean(p.basePrice)}",
                                  style: const TextStyle(
                                    fontFamily: "Gilroy",
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
