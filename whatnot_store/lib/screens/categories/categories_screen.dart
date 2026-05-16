import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/brand_provider.dart';
import '../../models/category_model.dart';
import 'CategoryBrandScreen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      Provider.of<CategoryProvider>(context, listen: false).loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CategoryProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,

      // appBar: AppBar(
      //   backgroundColor: Colors.white,
      //   elevation: 1,
      //   iconTheme: const IconThemeData(color: Colors.black),
      //   title: const Text(
      //     "Categories",
      //     style: TextStyle(
      //       fontFamily: "Gilroy",
      //       color: Colors.black,
      //       fontWeight: FontWeight.w800,
      //     ),
      //   ),
      // ),

      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.categories.isEmpty
              ? const Center(
                  child: Text(
                    "No categories found",
                    style: TextStyle(
                      fontFamily: "Gilroy",
                      fontSize: 14,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.categories.length,
                  itemBuilder: (context, index) {

                    final Category category = provider.categories[index];

                    return GestureDetector(
                      onTap: () async {

                        provider.selectCategory(category.id);

                        await Provider.of<BrandProvider>(context, listen: false)
                            .loadBrandsByCategory(category.id);

                        await Provider.of<ProductProvider>(context, listen: false)
                            .loadProductsByCategory(category.id);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CategoryBrandScreen(category: category),
                          ),
                        );
                      },

                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.black.withOpacity(0.2),
                          ),
                        ),

                        child: Row(
                          children: [

                            /// CATEGORY ICON
                            // Image.asset(
                            //   'assets/icon/category.png',
                            //   width: 22,
                            //   height: 22,
                            // ),

                            const SizedBox(width: 12),

                            /// CATEGORY NAME
                            Expanded(
                              child: Text(
                                category.name,
                                style: const TextStyle(
                                  fontFamily: "Gilroy",
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                            ),

                            /// ARROW
                            const Icon(
                              Icons.chevron_right,
                              size: 22,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}