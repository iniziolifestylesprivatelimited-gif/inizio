import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/brand_model.dart';
import '../../providers/category_provider.dart';
import '../../providers/product_provider.dart';
import '../../utils/constants.dart';
import '../../utils/product_helper.dart';
import '../filters/sort_filter_screen.dart';
import '../homescreen/bottomnavigationbar/custom_bottom_navbar.dart';
import '../homescreen/home_screen.dart';
import '../products/product_detail_screen.dart'; // 👈 import this

class BrandProductsScreen extends StatefulWidget {
  final Brand brand;

  const BrandProductsScreen({super.key, required this.brand});

  @override
  State<BrandProductsScreen> createState() => _BrandProductsScreenState();
}

class _BrandProductsScreenState extends State<BrandProductsScreen> {
  String? selectedCategoryId;
    int _currentIndex = 0;


  @override
void initState() {
  super.initState();

  final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
  final productProvider = Provider.of<ProductProvider>(context, listen: false);

  _loadInitialData(categoryProvider, productProvider);
}

Future<void> _loadInitialData(
  CategoryProvider categoryProvider,
  ProductProvider productProvider,
) async {

  await categoryProvider.loadCategoriesByBrand(widget.brand.id);

  if (categoryProvider.categories.isNotEmpty) {
    setState(() {
      selectedCategoryId = categoryProvider.categories.first.id;
    });

    await productProvider.loadProductsByBrandAndCategory(
      categoryId: selectedCategoryId!,
      brandId: widget.brand.id,
    );
  } else {
    return;
  }
}   //  ✅ THIS WAS MISSING




  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);

double maxPrice = 0;

for (var product in productProvider.products) {
  double price = 0;

  if (product.displayPrice != null && product.displayPrice! > 0) {
    price = product.displayPrice!;
  } else if (product.basePrice > 0) {
    price = product.basePrice;
  }

  if (price > maxPrice) {
    maxPrice = price;
  }
}

// ✅ IMPORTANT: fallback if no valid price
if (maxPrice <= 0) {
  maxPrice = 10000; // default safe value
}

// ✅ round safely
maxPrice = (maxPrice / 1000).ceil() * 1000;

    return Scaffold(
      backgroundColor: Colors.white, 
      appBar: AppBar(
        backgroundColor: Colors.white, 
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
if (selectedCategoryId == null) {
  return const Center(child: Text("No products for this brand"));
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
                    String? imageUrl = ProductHelper.getProductImage(product);

                    // 👇 Added tap to open product detail screen
                    return GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(product: product),
      ),
    );
  },
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

        // BRAND NAME
        Text(
          product.brandName ?? "",
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),

        // PRODUCT NAME
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

        // PRICE / OFFER SECTION
        Builder(builder: (_) {
          final hasOffer = product.offerPrice != null;
          int discountPercent = ProductHelper.getDiscountPercent(product);

          return hasOffer
              ? Row(
                  children: [
                    Text(
                      "₹${product.displayPrice!.toStringAsFixed(0)}",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "₹${product.basePrice.toStringAsFixed(0)}",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "$discountPercent% OFF",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
              : Text(
                  "₹${product.basePrice.toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                );
        }),
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

      
     floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
     
floatingActionButton: FloatingActionButton(
  backgroundColor: Colors.black,
  child: const Icon(Icons.sort, color: Colors.white),
  
  onPressed: () {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
      ),
      builder: (_) => SortFilterBottomSheet(
  maxPrice: maxPrice, // 👈 ADD THIS
  onApply: (filters) {
    Provider.of<ProductProvider>(context, listen: false)
        .applySortAndFilter(
      sort: filters["sort"],
      minPrice: filters["minPrice"],
      maxPrice: filters["maxPrice"],
    );
  },
),
    );
  },
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