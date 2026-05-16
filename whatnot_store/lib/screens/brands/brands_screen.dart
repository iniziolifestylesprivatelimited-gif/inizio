import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/brand_provider.dart';
import '../../models/brand_model.dart';
import '../../utils/constants.dart';
import 'brand_products_screen.dart';

class BrandsScreen extends StatefulWidget {
  const BrandsScreen({super.key});

  @override
  State<BrandsScreen> createState() => _BrandsScreenState();
}

class _BrandsScreenState extends State<BrandsScreen> {

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      Provider.of<BrandProvider>(context, listen: false).loadBrands();
    });
  }

  @override
Widget build(BuildContext context) {
  final provider = Provider.of<BrandProvider>(context);

  return Container(
    color: Colors.white,
    child: provider.isLoading
        ? const Center(child: CircularProgressIndicator())
        : provider.brands.isEmpty
            ? const Center(
                child: Text(
                  "No brands found",
                  style: TextStyle(
                    fontFamily: "Gilroy",
                    fontSize: 14,
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: provider.brands.length,
                itemBuilder: (context, index) {
                  final Brand brand = provider.brands[index];

                  String? imageUrl;

                  if (brand.logo != null && brand.logo!.isNotEmpty) {
                    imageUrl = brand.logo!.startsWith("http")
                        ? brand.logo
                        : "${ApiConstants.imageBaseUrl}/${brand.logo}";
                  }

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
                          /// BRAND LOGO
                          imageUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.network(
                                    imageUrl,
                                    width: 30,
                                    height: 30,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(
                                  Icons.store_outlined,
                                  size: 28,
                                  color: Colors.black,
                                ),

                          const SizedBox(width: 12),

                          /// BRAND NAME
                          Expanded(
                            child: Text(
                              brand.name,
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
}}