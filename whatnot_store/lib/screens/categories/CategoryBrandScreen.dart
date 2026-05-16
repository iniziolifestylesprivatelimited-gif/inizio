import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/category_model.dart';
import '../../providers/brand_provider.dart';
import '../../providers/product_provider.dart';
import '../../utils/constants.dart';
import '../../utils/product_helper.dart';
import '../../widgets/global/global_empty_products.dart';
import '../../widgets/global/global_error_retry.dart';
import '../../widgets/global/global_shimmer_list.dart';
import '../homescreen/bottomnavigationbar/custom_bottom_navbar.dart';
import '../homescreen/home_screen.dart';
import '../products/product_detail_screen.dart';

class CategoryBrandScreen extends StatefulWidget {
  final Category category;

  const CategoryBrandScreen({super.key, required this.category});

  @override
  State<CategoryBrandScreen> createState() => _CategoryBrandScreenState();
}

class _CategoryBrandScreenState extends State<CategoryBrandScreen> {
  String? selectedBrandId;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final brandProvider = Provider.of<BrandProvider>(context, listen: false);
      final productProvider = Provider.of<ProductProvider>(context, listen: false);

      await brandProvider.loadBrandsByCategory(widget.category.id);

      if (brandProvider.brands.isNotEmpty) {
        setState(() => selectedBrandId = brandProvider.brands.first.id);
        await productProvider.loadProductsByBrandAndCategory(
          categoryId: widget.category.id,
          brandId: selectedBrandId!,
        );
      } else {
        // Load category only products
        await productProvider.loadProductsByCategory(widget.category.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final brandProvider = Provider.of<BrandProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(widget.category.name),
      ),
      body: Column(
        children: [
          // BRAND CHIP LIST
          SizedBox(
            height: 60,
            child: brandProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: brandProvider.brands.length,
                    itemBuilder: (_, i) {
                      final brand = brandProvider.brands[i];
                      final isSelected = selectedBrandId == brand.id;

                      return GestureDetector(
                        onTap: () async {
                          setState(() => selectedBrandId = brand.id);
                          await productProvider.loadProductsByBrandAndCategory(
                            categoryId: widget.category.id,
                            brandId: brand.id,
                          );
                        },
                        child: Container(
                          height: 16,
                          constraints: const BoxConstraints(minWidth: 90),
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.black : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.black, width: 1.2),
                          ),
                          child: Center(
                            child: Text(
                              brand.name,
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

          Expanded(
            child: Builder(builder: (context) {

              if (productProvider.isLoading) {
                return const GlobalShimmerList(itemCount: 6, width: 150, height: 250);
              }

              if (productProvider.errorMessage != null) {
                return GlobalErrorRetry(
                  message: productProvider.errorMessage!,
                  onRetry: () {
                    if (selectedBrandId != null) {
                      productProvider.loadProductsByBrandAndCategory(
                        categoryId: widget.category.id,
                        brandId: selectedBrandId!,
                      );
                    } else {
                      productProvider.loadProductsByCategory(widget.category.id);
                    }
                  },
                );
              }

              // FINAL EMPTY CHECK
              if (productProvider.products.isEmpty) {
                return const GlobalEmptyProductsCard(
                  title: "No Products",
                  subtitle: "Products not available for this category",
                  icon: Icons.inventory_outlined,
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemCount: productProvider.products.length,
                itemBuilder: (_, index) {
                  final product = productProvider.products[index];

                String? imageUrl = ProductHelper.getProductImage(product);
                  final hasOffer = product.offerPrice != null;
                  final discountPercent = ProductHelper.getDiscountPercent(product);

                return GestureDetector(
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ProductDetailScreen(product: product),
    ),
  ),
  child: Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(2),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color.fromRGBO(244, 248, 250, 1),
            borderRadius: BorderRadius.circular(2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: imageUrl != null
                ? Image.network(imageUrl, fit: BoxFit.contain)
                : Container(
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.image, size: 40),
                  ),
          ),
        ),

        const SizedBox(height: 6),

        Text(
          product.brandName ?? "",
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
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),

        const SizedBox(height: 4),

        Row(
          children: [
            Text(
              "₹${product.displayPrice ?? product.basePrice}",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 5),
            if (product.offerPrice != null)
              Text(
                "₹${product.basePrice}",
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            const SizedBox(width: 5),
            if (product.offerPrice != null)
              Text(
                "${ProductHelper.getDiscountPercent(product)}% OFF",
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ],
    ),
  ),
);
                },
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: CustomBottomNavBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    HomeScreen(initialIndex: index),
              ),
              (route) => false,
            );
          },
        ),
      ),
    );
  }
}
