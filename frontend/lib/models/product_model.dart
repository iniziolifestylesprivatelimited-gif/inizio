class Product {
  final String id;
  final String name;
  final String? description;
  final double basePrice;
  final double? offerPrice; 
  final List<String> images;
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
    this.images = const [],
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
       offerPrice: json['offerPrice'] != null 
          ? (json['offerPrice']).toDouble() 
          : null, // ✅ parse offer price
      images: (json['images'] != null)
          ? List<String>.from(json['images'])
          : [],
      categoryName: json['category'] is Map
          ? json['category']['name']
          : null,
      brandName: json['brand'] is Map
          ? json['brand']['name']
          : null,
      categoryId: json['category'] is Map
          ? json['category']['_id']
          : json['category'],
      brandId: json['brand'] is Map
          ? json['brand']['_id']
          : json['brand'],
      totalQuantity: json['totalQuantity'],
      isActive: json['isActive'] ?? true,
      variants: json['variants'] != null
          ? (json['variants'] as List)
              .map((v) => Variant.fromJson(v))
              .toList()
          : [],
    );
  }
}

class Variant {
  final String name;
  final List<String> images;
  final int quantity;
  final double? price;
  final double? offerPrice; 

  Variant({
    required this.name,
    this.images = const [],
    required this.quantity,
    this.price,
    this.offerPrice,
  });

  factory Variant.fromJson(Map<String, dynamic> json) {
    return Variant(
      name: json['name'] ?? '',
      images: json['images'] != null
          ? List<String>.from(json['images'])
          : [],
      quantity: json['quantity'] ?? 0,
      price: json['price'] != null ? (json['price']).toDouble() : null,
        offerPrice: json['offerPrice'] != null 
          ? (json['offerPrice']).toDouble() 
          : null, // ✅ parse variant offer price
    );
  }
  
}

extension ProductCopy on Product {
  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? basePrice,
    double? offerPrice,
    List<String>? images,
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
      images: images ?? this.images,
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
