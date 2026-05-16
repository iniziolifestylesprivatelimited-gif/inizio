import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../utils/constants.dart';

class ProductVariantSelector extends StatelessWidget {
  final List<Variant> variants;
  final Variant? selectedVariant;
  final Function(Variant) onSelect;

  const ProductVariantSelector({
    super.key,
    required this.variants,
    required this.selectedVariant,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (variants.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Colour",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

        SizedBox(
  height: 65,
  child: Stack(
    children: [
      // HORIZONTAL SCROLLABLE VARIANTS
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: variants.map((v) {
            final isSelected = selectedVariant == v;

            String? variantImage =
                v.images.isNotEmpty ? v.images.first : null;

            String? imageUrl = variantImage != null
                ? (variantImage.startsWith('http')
                    ? variantImage
                    : '${ApiConstants.imageBaseUrl}/$variantImage')
                : null;

            return GestureDetector(
              onTap: () => onSelect(v),
              child: Container(
                width: 55,
                height: 55,
                margin: const EdgeInsets.only(right: 12),
                padding: EdgeInsets.all(isSelected ? 2 : 1),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        isSelected ? Colors.black : Colors.grey.shade400,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: Colors.grey.shade300,
                          alignment: Alignment.center,
                          child: Text(
                            v.name,
                            style: const TextStyle(
                                fontSize: 10, color: Colors.black),
                          ),
                        ),
                ),
              ),
            );
          }).toList(),
        ),
      ),

      // ➡️ Right fading effect to indicate scroll
      Positioned(
        right: 0,
        top: 0,
        bottom: 0,
        child: IgnorePointer(
          ignoring: true,
          child: Container(
            width: 45,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.0),
                  Colors.white.withOpacity(0.9),
                  Colors.white,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
        ),
      ),

      // ➡️ Scroll arrow icon hint
      Positioned(
        right: 10,
        top: 0,
        bottom: 0,
        child: Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: Colors.grey.shade600,
        ),
      ),
    ],
  ),
),

        ],
      ),
    );
  }
}
