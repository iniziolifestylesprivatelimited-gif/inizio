  import 'package:flutter/material.dart';
  import 'package:provider/provider.dart';
  import '../../models/brand_model.dart';
  import '../../providers/banner_provider.dart';
import '../../providers/brand_provider.dart';
  import '../../providers/cart_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/product_provider.dart';
import '../../utils/constants.dart';
  import 'brand_products_screen.dart';

  class BrandsBox extends StatelessWidget {
    const BrandsBox({super.key});

    void _showBrandsBottomSheet(BuildContext context) async {
      final brandProvider = Provider.of<BrandProvider>(context, listen: false);

      await brandProvider.loadBrands();

      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        isScrollControlled: true,
        builder: (context) {
          final height = MediaQuery.of(context).size.height * 0.8;
          return Consumer<BrandProvider>(
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
                        color: Colors.red,
                        fontFamily: 'Gilroy',
                      ),
                    ),
                  ),
                );
              }

              if (provider.brands.isEmpty) {
                return SizedBox(
                  height: height,
                  child: const Center(
                    child: Text(
                      'No brands found',
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
                      'Available Brands',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Gilroy',
                      ),
                    ),
                    const Divider(),
                    Expanded(
                      child: ListView.builder(
                        itemCount: provider.brands.length,
                        itemBuilder: (context, index) {
                          final Brand brand = provider.brands[index];

                          final String? imageUrl =
                              (brand.logo != null && brand.logo!.isNotEmpty)
                                  ? (brand.logo!.startsWith('http')
                                      ? brand.logo
                                      : '${ApiConstants.imageBaseUrl}/${brand.logo}')
                                  : null;

                          return ListTile(
                            leading: imageUrl != null
                                ? CircleAvatar(
                                    backgroundImage: NetworkImage(imageUrl),
                                    backgroundColor: Colors.transparent,
                                  )
                                : const CircleAvatar(
                                    backgroundColor: Colors.grey,
                                    child: Icon(Icons.store_outlined),
                                  ),
                            title: Text(
                              brand.name,
                              style: const TextStyle(
                              fontFamily: 'Gilroy',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            ),
                            onTap: () {
  Navigator.pop(context);
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => BrandProductsScreen(brand: brand)),
  ).then((_) async {
    if (!context.mounted) return; // Prevents crash
  });
},


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
        onTap: () => _showBrandsBottomSheet(context),
        child: Container(
          height: 40,
          margin: const EdgeInsets.only(left: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Colors.black, width: 0.4),
          ),
        child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Image.asset(
        'assets/icon/store.png',
        width: 18,
        height: 18,
        color: Colors.black,
      ),
      const SizedBox(width: 8),
Stack(
  children: [
    Text(
      'brands',
      style: TextStyle(
        fontFamily: 'Gilroy',
        fontSize: 12,
        fontWeight: FontWeight.w900,
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.3 // outline
          ..color = Colors.black,
      ),
    ),
    const Text(
      'brands',
      style: TextStyle(
        fontFamily: 'Gilroy',
        fontSize: 12,
        fontWeight: FontWeight.w900,
        color: Colors.black,
      ),
    ),
  ],
)


    ],
  ),


        ),
      );
    }
  }
