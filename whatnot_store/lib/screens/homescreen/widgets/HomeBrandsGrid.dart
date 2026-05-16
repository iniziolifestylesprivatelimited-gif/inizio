import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/brand_model.dart';
import '../../../providers/brand_provider.dart';
import '../../../utils/constants.dart';
import '../../brands/brand_products_screen.dart';

class HomeBrandsGrid extends StatefulWidget {
  const HomeBrandsGrid({super.key});

  @override
  State<HomeBrandsGrid> createState() => _HomeBrandsGridState();
}

class _HomeBrandsGridState extends State<HomeBrandsGrid> {
  @override
void initState() {
  super.initState();
  Future.microtask(() {
    Provider.of<BrandProvider>(context, listen: false).loadBrands();
  });
}


  @override
  Widget build(BuildContext context) {
    return Consumer<BrandProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (provider.brands.isEmpty) return const SizedBox();

        int count = provider.brands.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 10),
              child: Text(
                "Our Brands",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Gilroy',
                ),
              ),
            ),

            Table(
  border: TableBorder(
    verticalInside: BorderSide(color: Colors.grey.shade300, width: 1),
    horizontalInside: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
              children: [
                for (int row = 0; row < (count / 3).ceil(); row++)
                  TableRow(
                    children: [
                      for (int col = 0; col < 3; col++)
                        _buildGridItem(
                          provider,
                          row * 3 + col,
                        ),
                    ],
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildGridItem(BrandProvider provider, int index) {
    if (index >= provider.brands.length) {
      return Container(); // empty tile
    }

    Brand brand = provider.brands[index];

    final String? imageUrl =
        (brand.logo != null && brand.logo!.isNotEmpty)
            ? (brand.logo!.startsWith('http')
                ? brand.logo
                : '${ApiConstants.imageBaseUrl}/${brand.logo}')
            : null;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BrandProductsScreen(brand: brand),
          ),
        );
      },
      child: Container(
        height: 110,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: imageUrl != null
            ? Image.network(
                imageUrl,
                fit: BoxFit.contain,
              )
            : const Icon(
                Icons.store,
                size: 40,
              ),
      ),
    );
  }
}
