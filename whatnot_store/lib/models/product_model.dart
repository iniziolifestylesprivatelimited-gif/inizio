  class Product {
    final String id;
    final String name;
    final String? description;

    final double basePrice;
    final double? offerPrice;
    final List<QuantityPrice> quantityPricing;
    // 🔥 NEW — multi-pricing
    final double? l1Price;
    final double? l2Price;
    final double? l3Price;
    
    // 🔥 NEW — resolved price for logged-in user (L1/L2/L3)
    final double? displayPrice;

    final List<String> images;
    final List<String> banners;

    final String? details;
    final String? expertNotes;
    final String? cancellationPolicy;
    final String? warranty;
    final String? sevenDaysReturn;

    final String? categoryName;
    final String? brandName;
    final String? categoryId;
    final String? brandId;

    final int? totalQuantity;
    final bool isActive;

    final List<Variant> variants;

    Product({
      required this.id,
      required this.name,
      this.description,
      required this.basePrice,
      this.offerPrice,
      this.l1Price,
      this.l2Price,
      this.l3Price,
      this.displayPrice,
      this.quantityPricing = const [],
      this.images = const [],
      this.banners = const [],
      this.details,
      this.expertNotes,
      this.cancellationPolicy,
      this.warranty,
      this.sevenDaysReturn,
      this.categoryName,
      this.brandName,
      this.categoryId,
      this.brandId,
      this.totalQuantity,
      required this.isActive,
      this.variants = const [],
    });

    factory Product.fromJson(Map<String, dynamic> json) {
      return Product(
        id: json['_id'] ?? '',
        name: json['name'] ?? '',
        description: json['description'],

        basePrice: (json['basePrice'] ?? 0).toDouble(),
        offerPrice: json['offerPrice']?.toDouble(),
        quantityPricing: json['quantityPricing'] != null
    ? (json['quantityPricing'] as List)
        .map((e) => QuantityPrice.fromJson(e))
        .toList()
    : [],
        // ⭐ multi-level pricing
        l1Price: json['l1Price']?.toDouble(),
        l2Price: json['l2Price']?.toDouble(),
        l3Price: json['l3Price']?.toDouble(),
        displayPrice: json['displayPrice']?.toDouble(),

        images: json['images'] != null
            ? List<String>.from(json['images'])
            : [],

        banners: json['banners'] != null
            ? List<String>.from(json['banners'])
            : [],

        details: json['details'],
        expertNotes: json['expertNotes'],
        cancellationPolicy: json['cancellationPolicy'],
        warranty: json['warranty'],
        sevenDaysReturn: json['sevenDaysReturn'],

        categoryName:
            json['category'] is Map ? json['category']['name'] : null,
        brandName:
            json['brand'] is Map ? json['brand']['name'] : null,

        categoryId:
            json['category'] is Map ? json['category']['_id'] : json['category'],
        brandId:
            json['brand'] is Map ? json['brand']['_id'] : json['brand'],

        totalQuantity: json['totalQuantity'],
        isActive: json['isActive'] ?? true,

        variants: json['variants'] != null
            ? (json['variants'] as List)
                .map((v) => Variant.fromJson(v))
                .toList()
            : [],
      );
    }
    // ---------------------- COPYWITH (INSIDE PRODUCT CLASS) ----------------------
  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? basePrice,
    double? offerPrice,
    double? l1Price,
    double? l2Price,
    double? l3Price,
    double? displayPrice,
    List<QuantityPrice>? quantityPricing,
    List<String>? images,
    List<String>? banners,
    String? details,
    String? expertNotes,
    String? cancellationPolicy,
    String? warranty,
    String? sevenDaysReturn,
    String? categoryName,
    String? brandName,
    String? categoryId,
    String? brandId,
    int? totalQuantity,
    bool? isActive,
    List<Variant>? variants,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      basePrice: basePrice ?? this.basePrice,
      offerPrice: offerPrice ?? this.offerPrice,

      l1Price: l1Price ?? this.l1Price,
      l2Price: l2Price ?? this.l2Price,
      l3Price: l3Price ?? this.l3Price,
      displayPrice: displayPrice ?? this.displayPrice,
      quantityPricing:
    quantityPricing ?? this.quantityPricing,
      images: images ?? this.images,
      banners: banners ?? this.banners,

      details: details ?? this.details,
      expertNotes: expertNotes ?? this.expertNotes,
      cancellationPolicy: cancellationPolicy ?? this.cancellationPolicy,
      warranty: warranty ?? this.warranty,
      sevenDaysReturn: sevenDaysReturn ?? this.sevenDaysReturn,

      categoryName: categoryName ?? this.categoryName,
      brandName: brandName ?? this.brandName,
      categoryId: categoryId ?? this.categoryId,
      brandId: brandId ?? this.brandId,

      totalQuantity: totalQuantity ?? this.totalQuantity,
      isActive: isActive ?? this.isActive,

      variants: variants ?? this.variants,
    );
  }

  }

  class Variant {
    final String id; // ✅ ADD THIS
    final String name;
    final List<String> images;
    final int quantity;
    final double? price;
    final double? offerPrice;

    // 🔥 NEW — multi pricing
    final double? l1Price;
    final double? l2Price;
    final double? l3Price;

    // 🔥 NEW — resolved display price
    final double? displayPrice;
    final List<QuantityPrice> quantityPricing;

    Variant({
      required this.id, 
      required this.name,
      this.images = const [],
      required this.quantity,
      this.price,
      this.offerPrice,
      this.l1Price, 
      this.l2Price,
      this.l3Price,
      this.displayPrice,
      this.quantityPricing = const [],
    });

    factory Variant.fromJson(Map<String, dynamic> json) {
      return Variant(
        id: json['_id'] ?? '', 
        name: json['name'] ?? '',
        images: json['images'] != null
            ? List<String>.from(json['images'])
            : [],
        quantity: json['quantity'] ?? 0,

        price: json['price']?.toDouble(),
        offerPrice: json['offerPrice']?.toDouble(),

        // ⭐ multi pricing
        l1Price: json['l1Price']?.toDouble(),
        l2Price: json['l2Price']?.toDouble(),
        l3Price: json['l3Price']?.toDouble(),

        displayPrice: json['displayPrice']?.toDouble(),
        quantityPricing: json['quantityPricing'] != null
    ? (json['quantityPricing'] as List)
        .map((e) => QuantityPrice.fromJson(e))
        .toList()
    : [],
      );
    }
  }

  class QuantityPrice {

  final int minQty;
  final double price;

  QuantityPrice({
    required this.minQty,
    required this.price,
  });

  factory QuantityPrice.fromJson(Map<String, dynamic> json) {
    return QuantityPrice(
      minQty: json['minQty'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
    );
  }
}