import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/category_model.dart';
import '../../providers/brand_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/product_provider.dart';
import '../../utils/constants.dart';
import 'CategoryBrandScreen.dart';

class CategoriesBox extends StatelessWidget {
  const CategoriesBox({super.key});

  void _showCategoriesBottomSheet(BuildContext context) async {
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);

    await categoryProvider.loadCategories();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (context) {
        final height = MediaQuery.of(context).size.height * 0.8;

        return Consumer<CategoryProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return SizedBox(
                height: height,
                child: const Center(child: CircularProgressIndicator()),
              );
            }

            if (provider.errorMessage != null) {
              return SizedBox(
                height: height,
                child: Center(
                  child: Text(
                    provider.errorMessage!,
                    style: const TextStyle(
                      fontFamily: 'Gilroy',
                      color: Colors.red,
                    ),
                  ),
                ),
              );
            }

            if (provider.categories.isEmpty) {
              return SizedBox(
                height: height,
                child: const Center(
                  child: Text(
                    'No categories found',
                    style: TextStyle(fontFamily: 'Gilroy'),
                  ),
                ),
              );
            }

            return Container(
              height: height,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Available Categories',
                    style: TextStyle(
                      fontFamily: 'Gilroy',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: provider.categories.length,
                      itemBuilder: (context, index) {
                        final Category category = provider.categories[index];

                        return ListTile(
                          onTap: () async {
                            provider.selectCategory(category.id);

                            await Provider.of<BrandProvider>(context,
                                    listen: false)
                                .loadBrandsByCategory(category.id);

                            await Provider.of<ProductProvider>(context,
                                    listen: false)
                                .loadProductsByCategory(category.id);

                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    CategoryBrandScreen(category: category),
                              ),
                            );
                          },
                          title: Text(
                            category.name,
                            style: const TextStyle(
                              fontFamily: 'Gilroy',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                            size: 22,
                            color: Colors.black54,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showCategoriesBottomSheet(context),
      child: Container(
        height: 40,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.black, width: 0.4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icon/category.png', // 👈 Replace with your real asset
              width: 18,
              height: 18,
              // color: Colors.black,
            ),
            const SizedBox(width: 8),

            // 🖤 Same bold stroke effect as BrandsBox
            Stack(
              children: [
                Text(
                  'categories',
                  style: TextStyle(
                    fontFamily: 'Gilroy',
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 0.3
                      ..color = Colors.black,
                  ),
                ),
                const Text(
                  'categories',
                  style: TextStyle(
                    fontFamily: 'Gilroy',
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
