import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/product_provider.dart';
import '../../../utils/constants.dart';
import '../../products/product_detail_screen.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<ProductProvider>(context, listen: false).loadProducts();
    });
  }

  // ✅ Debounce Search Logic
  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      Provider.of<ProductProvider>(context, listen: false).searchProducts(query);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ✅ Search Box
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _controller,
                onChanged: (value) {
                  setState(() {});
                  onSearchChanged(value);
                },
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _controller.clear();
                            provider.searchProducts("");
                            setState(() {});
                          },
                        )
                      : null,
                  hintText: "Search products...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
        
            // ✅ SHIMMER LOADING UI
            if (provider.isLoading) Expanded(child: _buildShimmerList()),
        
            // ✅ PRODUCT LIST WITH ANIMATION
            if (!provider.isLoading)
              Expanded(
                child: provider.products.isEmpty
                    ? const Center(child: Text("No products found"))
                    : ListView.builder(
                        itemCount: provider.products.length,
                        itemBuilder: (context, index) {
                          final product = provider.products[index];
        
                         String imageUrl = "";
        
        if (product.variants.isNotEmpty && product.variants.first.images.isNotEmpty) {
          imageUrl = product.variants.first.images.first.startsWith("http")
          ? product.variants.first.images.first
          : "${ApiConstants.imageBaseUrl}/${product.variants.first.images.first}";
        } else if (product.images.isNotEmpty) {
          imageUrl = product.images.first.startsWith("http")
          ? product.images.first
          : "${ApiConstants.imageBaseUrl}/${product.images.first}";
        }
        
        
                          return TweenAnimationBuilder(
                            tween: Tween<double>(begin: 0.90, end: 1),
                            duration: Duration(milliseconds: 300 + (index * 80)),
                            curve: Curves.easeOut,
                            builder: (context, value, child) {
                              return Transform.scale(scale: value, child: child);
                            },
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 350),
                              opacity: 1,
                              child: Card(
                                 color: Colors.white, // <-- WHITE CARD
                                  // elevation: 4, 
                                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        transitionDuration: const Duration(milliseconds: 450),
                                        pageBuilder: (_, __, ___) => ProductDetailScreen(product: product),
                                        transitionsBuilder: (context, animation, sec, child) {
                                          return FadeTransition(
                                            opacity: animation,
                                            child: child,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  child: ListTile(
                                    leading: Hero(
                                      tag: "product_${product.id}",
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: imageUrl.isNotEmpty
                                            ? Image.network(
                                                imageUrl,
                                                width: 60,
                                                height: 60,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                                              )
                                            : const Icon(Icons.image_not_supported),
                                      ),
                                    ),
                                    title: Text(product.name),
                                    subtitle: _buildPrice(product),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
          ],
        ),
      ),
    );
  }

  // ✅ Price UI Widget
  Widget _buildPrice(product) {
    if (product.offerPrice != null) {
      return Row(
        children: [
          Text("₹${product.offerPrice}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
          const SizedBox(width: 6),
          Text(
            "₹${product.basePrice}",
            style: const TextStyle(
              fontSize: 14,
              color: Colors.red,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
      );
    } else {
      return Text(
        "₹${product.basePrice}",
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      );
    }
  }

  // ✅ Shimmer List Builder
  Widget _buildShimmerList() {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            shimmerBox(width: 60, height: 60, radius: 8),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  shimmerBox(width: 120, height: 14),
                  const SizedBox(height: 8),
                  shimmerBox(width: 80, height: 12),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // ✅ Shimmer Box Widget
  Widget shimmerBox({double width = 100, double height = 14, double radius = 6}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
