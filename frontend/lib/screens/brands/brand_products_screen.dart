import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/brand_model.dart';
import '../../providers/category_provider.dart';
import '../../providers/product_provider.dart';
import '../../utils/constants.dart';
import '../products/product_detail_screen.dart'; // 👈 import this

class BrandProductsScreen extends StatefulWidget {
  final Brand brand;

  const BrandProductsScreen({super.key, required this.brand});

  @override
  State<BrandProductsScreen> createState() => _BrandProductsScreenState();
}

class _BrandProductsScreenState extends State<BrandProductsScreen> {
  String? selectedCategoryId;

  @override
  void initState() {
    super.initState();

    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);

    _loadInitialData(categoryProvider, productProvider);
  }

  Future<void> _loadInitialData(
      CategoryProvider categoryProvider, ProductProvider productProvider) async {
    await categoryProvider.loadCategories();

    // ✅ After categories are loaded, select first category automatically
    if (categoryProvider.categories.isNotEmpty) {
      setState(() {
        selectedCategoryId = categoryProvider.categories.first.id;
      });

      await productProvider.loadProductsByBrandAndCategory(
  categoryId: selectedCategoryId!,
  brandId: widget.brand.id,
);

    } else {
      // If no categories found, clear products
      productProvider.loadProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.brand.name),
      ),
      body: Column(
        children: [
          // 🧱 Categories Filter (horizontal)
          SizedBox(
            height: 60,
            child: categoryProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: categoryProvider.categories.length,
                    itemBuilder: (context, index) {
                      final cat = categoryProvider.categories[index];
                      final isSelected = cat.id == selectedCategoryId;

                      return GestureDetector(
                        onTap: () async {
                          setState(() {
                            selectedCategoryId = cat.id;
                          });
                          await productProvider.loadProductsByBrandAndCategory(
  categoryId: cat.id,
  brandId: widget.brand.id,
);

                        },
                       child: Container(
  height: 16,
  constraints: BoxConstraints(minWidth: 90),
  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
  padding: const EdgeInsets.symmetric(horizontal: 12),
  decoration: BoxDecoration(
    color: isSelected ? Colors.black : Colors.white,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: Colors.black, width: 1.2),
  ),
  child: Center(
    child: Text(
      cat.name,
      style: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    ),
  ),
),

                      );
                    },
                  ),
          ),

          const Divider(),

          // 🛍️ Products Grid
          Expanded(
            child: Builder(
              builder: (context) {
                if (productProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (productProvider.errorMessage != null) {
                  return Center(
                    child: Text(
                      productProvider.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

               if (productProvider.products.isEmpty) {
  return const Center(
    child: Text('No products available for this category'),
  );
}

                return GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: productProvider.products.length,
                  itemBuilder: (context, index) {
                    final product = productProvider.products[index];
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
} else {
  imageUrl = null;
}


                    // 👇 Added tap to open product detail screen
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ProductDetailScreen(product: product),
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
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(8)),
                                child: imageUrl != null
                                    ? Image.network(
                                        imageUrl,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      )
                                    : Container(
                                        color: Colors.grey.shade300,
                                        child: const Icon(
                                          Icons.image,
                                          size: 40,
                                          color: Colors.black,
                                        ),
                                      ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                product.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0),
                              child: Text(
                                '₹${product.basePrice}',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}