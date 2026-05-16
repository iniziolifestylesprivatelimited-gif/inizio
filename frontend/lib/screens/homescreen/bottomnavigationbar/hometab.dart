import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/banner_provider.dart';
import '../../../providers/brand_provider.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/category_provider.dart';
import '../../../providers/product_provider.dart';
import '../../brands/brands_box.dart';
import '../../categories/categories_box.dart';
import '../../banners/banners_box.dart';
import 'home_products_grid.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {

  Future<void> _refreshData() async {
    // ✅ Refresh all providers
    await Provider.of<ProductProvider>(context, listen: false).loadProducts();
    await Provider.of<CategoryProvider>(context, listen: false).loadCategories();
    await Provider.of<BrandProvider>(context, listen: false).loadBrands();
    await Provider.of<BannerProvider>(context, listen: false).loadBanners();
    await Provider.of<CartProvider>(context, listen: false).getCart(context);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData(); // ✅ Load on start
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,

      // ✅ Pull to refresh
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: Colors.black,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                Expanded(child: CategoriesBox()),
                Expanded(child: BrandsBox()),
              ],
            ),

            const SizedBox(height: 15),

            const BannersBox(),

            const SizedBox(height: 20),

            const Text(
              "All Products",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // ✅ Show products
            Builder(
              builder: (_) {
                if (productProvider.isLoading) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (productProvider.products.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: Center(child: Text("No products found")),
                  );
                }

                return HomeProductsGrid(products: productProvider.products);
              },
            ),
          ],
        ),
      ),
    );
  }
}
