import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/category_model.dart';
import '../../providers/brand_provider.dart';
import '../../providers/product_provider.dart';
import '../../utils/constants.dart';
import '../products/product_detail_screen.dart';

class CategoryBrandScreen extends StatefulWidget {
  final Category category;

  const CategoryBrandScreen({super.key, required this.category});

  @override
  State<CategoryBrandScreen> createState() => _CategoryBrandScreenState();
}

class _CategoryBrandScreenState extends State<CategoryBrandScreen> {
  String? selectedBrandId;

  @override
void initState() {
  super.initState();

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final brandProvider = Provider.of<BrandProvider>(context, listen: false);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);

    await brandProvider.loadBrandsByCategory(widget.category.id);

    // ✅ Auto select first brand if exists
    if (brandProvider.brands.isNotEmpty) {
      setState(() {
        selectedBrandId = brandProvider.brands.first.id;
      });

      await productProvider.loadProductsByBrandAndCategory(
        categoryId: widget.category.id,
        brandId: selectedBrandId!,
      );
    } else {
      // fallback: load all products in that category
      productProvider.loadProductsByCategory(widget.category.id);
    }
  });
}


  @override
  Widget build(BuildContext context) {
    final brandProvider = Provider.of<BrandProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white, 
      appBar: AppBar(title: Text(widget.category.name)),
      body: Column(
        children: [
          SizedBox(
  height: 70,
  child: brandProvider.isLoading
      ? const Center(child: CircularProgressIndicator())
      : brandProvider.errorMessage != null
          ? Center(child: Text("Failed: ${brandProvider.errorMessage}"))
          : brandProvider.brands.isEmpty
              ? const Center(child: Text("No brands found"))
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: brandProvider.brands.length,
                  itemBuilder: (_, i) {
                    final brand = brandProvider.brands[i];

                    return GestureDetector(
                      onTap: () {
                        setState(() => selectedBrandId = brand.id);

                        Provider.of<ProductProvider>(context, listen: false)
                            .loadProductsByBrandAndCategory(
                          categoryId: widget.category.id,
                          brandId: brand.id,
                        );
                      },
                     child: Container(
  height: 16, // realistic compact height
  constraints: BoxConstraints(minWidth: 90),
  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
  padding: const EdgeInsets.symmetric(horizontal: 12), // ❌ removed vertical padding
  decoration: BoxDecoration(
    color: selectedBrandId == brand.id ? Colors.black : Colors.white,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: Colors.black, width: 1.2),
  ),
  child: Center(
    child: Text(
      brand.name,
      style: TextStyle(
        color: selectedBrandId == brand.id ? Colors.white : Colors.black,
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
            child: productProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : productProvider.products.isEmpty
                    ? const Center(child: Text('No products'))
                    : Expanded(
  child: Builder(
    builder: (context) {
      if (productProvider.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      if (productProvider.products.isEmpty) {
        return const Center(child: Text('No products'));
      }

      return GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.7,
        ),
        itemCount: productProvider.products.length,
        itemBuilder: (context, index) {
          final product = productProvider.products[index];

          // ✅ image logic same as Brand screen
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
          }

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
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(8)),
                      child: imageUrl != null
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            )
                          : Container(
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.image, size: 40),
                            ),
                    ),
                  ),

                  // ✅ Product Name
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.visible,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),

                  // ✅ Price
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      "₹${product.basePrice}",
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 5),
                ],
              ),
            ),
          );
        },
      );
    },
  ),
),

          ),
        ],
      ),
    );
  }
}
