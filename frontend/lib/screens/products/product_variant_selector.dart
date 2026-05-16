import 'package:flutter/material.dart';
import '../../models/product_model.dart';

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
          const Text("Select Variant",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),

          Wrap(
            spacing: 8,
            children: variants.map((v) {
              final isSelected = selectedVariant == v;
              return ChoiceChip(
                label: Text(v.name),
                selected: isSelected,
                onSelected: (_) => onSelect(v),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
