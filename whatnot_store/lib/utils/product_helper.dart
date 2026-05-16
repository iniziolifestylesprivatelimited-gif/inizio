import 'constants.dart';

class ProductHelper {
  static String? getProductImage(product) {
    // ✅ Check all variants
    for (var v in product.variants) {
      if (v.images.isNotEmpty) {
        final img = v.images.first;
        return img.startsWith('http')
            ? img
            : '${ApiConstants.imageBaseUrl}/$img';
      }
    }

    // ✅ fallback to product image
    if (product.images.isNotEmpty) {
      final img = product.images.first;
      return img.startsWith('http')
          ? img
          : '${ApiConstants.imageBaseUrl}/$img';
    }

    return null;
  }

  static int getDiscountPercent(product) {
    if (product.offerPrice == null ||
        product.basePrice <= 0 ||
        product.offerPrice! <= 0 ||
        product.offerPrice! > product.basePrice) {
      return 0;
    }

    return ((1 - (product.offerPrice! / product.basePrice)) * 100).round();
  }
}