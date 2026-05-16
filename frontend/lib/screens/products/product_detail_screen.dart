import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../services/product_service.dart';
import '../../utils/constants.dart';
import 'product_bottom_buttons.dart';
import 'product_description.dart';
import 'product_image_slider.dart';
import 'product_price_section.dart';
import 'product_quantity_selector.dart';
import 'product_variant_selector.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Product product;
  int quantity = 10;
  Variant? selectedVariant;

  @override
  void initState() {
    super.initState();
    product = widget.product;
  }

  Future<void> _reloadPage() async {
    try {
      final updatedProduct = await ProductService().fetchProductById(product.id);
      setState(() {
        selectedVariant = null;
        quantity = 10;

        product = product.copyWith(
          name: updatedProduct.name,
          images: updatedProduct.images,
          basePrice: updatedProduct.basePrice,
          offerPrice: updatedProduct.offerPrice,
          variants: updatedProduct.variants,
          totalQuantity: updatedProduct.totalQuantity,
          description: updatedProduct.description,
        );
      });
    } catch (e) {
      debugPrint("Product refresh failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> imageUrls = (() {
      if (selectedVariant != null && selectedVariant!.images.isNotEmpty) {
        return selectedVariant!.images;
      } else if (product.variants.isNotEmpty &&
          product.variants.first.images.isNotEmpty) {
        return product.variants.first.images;
      } else {
        return product.images;
      }
    })()
        .map((img) => img.startsWith('http')
            ? img
            : '${ApiConstants.imageBaseUrl}/$img')
        .toList();

    final double displayOfferPrice =
        selectedVariant?.offerPrice ??
        selectedVariant?.price ??
        product.offerPrice ??
        product.basePrice;
    final double originalPrice = selectedVariant?.price ?? product.basePrice;

    final int availableStock = (() {
      if (selectedVariant != null) return selectedVariant!.quantity;
      if (product.variants.isNotEmpty) return 0;
      return product.totalQuantity ?? 0;
    })();

    final bool isOutOfStock = availableStock <= 0;
    final bool isLowStock = availableStock > 0 && availableStock < 5;

    String stockText;
    if (product.variants.isNotEmpty && selectedVariant == null) {
      stockText = "Select a variant";
    } else if (isOutOfStock) {
      stockText = "Out of Stock";
    } else if (isLowStock) {
      stockText = "Only $availableStock left";
    } else {
      stockText = "In Stock";
    }

    return Scaffold(
      appBar: AppBar(title: Text(product.name)),

      body: RefreshIndicator(
        onRefresh: _reloadPage,
        child: LayoutBuilder(builder: (context, constraints) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 90), // leave space for bottom buttons
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProductImageSlider(imageUrls: imageUrls),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        product.name,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ProductPriceSection(
                        offerPrice: displayOfferPrice, originalPrice: originalPrice),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        stockText,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isOutOfStock
                                ? Colors.red
                                : isLowStock
                                    ? Colors.orange
                                    : Colors.green),
                      ),
                    ),
                    const Divider(),
                    ProductVariantSelector(
                      variants: product.variants,
                      selectedVariant: selectedVariant,
                      onSelect: (v) {
                        setState(() {
                          selectedVariant = v;
                          quantity = 10;
                        });
                      },
                    ),
                    const Divider(),
                   ProductQuantitySelector(
  quantity: quantity,
  onAdd: (quantity < availableStock)
      ? () => setState(() => quantity++)
      : null,
  onRemove: (quantity > 10)
      ? () => setState(() => quantity--)
      : null,
  availableStock: availableStock,
),


                    const Divider(),
                    ProductDescription(product: product),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              // ✅ Sticky Bottom Buttons
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                   margin: const EdgeInsets.only(bottom: 20), // ⬅️ move up by 20px
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: ProductBottomButtons(
                    product: product,
                    quantity: quantity,
                    selectedVariant: selectedVariant,
                    isOutOfStock: isOutOfStock,
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
