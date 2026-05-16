import 'package:flutter/material.dart';
import '../../../models/product_model.dart';
import '../../../utils/constants.dart';
import 'more_from_brand_section.dart';
import 'more_from_category_section.dart';

class ProductExtraDetails extends StatelessWidget {
  final Product product;
  final Variant? selectedVariant; // ⭐ NEW

  const ProductExtraDetails({
    super.key,
    required this.product,
    this.selectedVariant,
  });

  Widget _buildExpandableSection(
      BuildContext context, String title, String? text) {
    if (text == null || text.isEmpty) return SizedBox.shrink();

    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 12),
        childrenPadding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
        iconColor: Colors.black,
        collapsedIconColor: Colors.black,
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: "Gilroy",
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: Colors.black,
          ),
        ),
        children: [
          Text(
            text,
            style: const TextStyle(
              fontFamily: "Gilroy",
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // ⭐ Decide image list (variant or product)
  List<String> _getImageList() {
    if (selectedVariant != null && selectedVariant!.images.isNotEmpty) {
      return selectedVariant!.images;
    }
    return product.images;
  }

  // ⭐ Show full-width banner image
  Widget _fullWidthImage(String img) {
    final imgUrl = img.startsWith("http")
        ? img
        : "${ApiConstants.imageBaseUrl}/$img";

    return Image.network(
      imgUrl,
      width: double.infinity,
      height: 220,
      fit: BoxFit.cover,
    );
  }

  // ⭐ First banner (second last image)
  Widget _topExtraImage(List<String> images) {
    if (images.length < 2) return SizedBox.shrink();
    return _fullWidthImage(images[images.length - 2]);
  }

  // ⭐ Second banner (last image)
  Widget _bottomExtraImage(List<String> images) {
    if (images.isEmpty) return SizedBox.shrink();
    return _fullWidthImage(images.last);
  }

  @override
  Widget build(BuildContext context) {
    final images = _getImageList(); // ⭐ use correct image source

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _topExtraImage(images),

        // _buildExpandableSection(context, "Product Details", product.details),
        // _buildExpandableSection(context, "Notes From Our Experts", product.expertNotes),
        _buildExpandableSection(context, "Cancellation Policy", product.cancellationPolicy),
        _buildExpandableSection(context, "Warranty", product.warranty),

        if (product.sevenDaysReturn != null &&
            product.sevenDaysReturn!.trim().isNotEmpty)
          _buildExpandableSection(context, "Return Policy", product.sevenDaysReturn),

        _bottomExtraImage(images),
        SizedBox(height: 20),
        if (product.brandId != null)
  MoreFromBrandSection(
    brandId: product.brandId!,
    currentProductId: product.id,
  ),
  if (product.categoryId != null)
  MoreFromCategorySection(
    categoryId: product.categoryId!,
    currentProductId: product.id,
  ),

      ],
    );
  }
}
