import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/brand_model.dart';
import '../../../providers/brand_provider.dart';
import '../../../utils/constants.dart';
import '../../../widgets/global/global_error_retry.dart';
import '../../../widgets/global/global_shimmer_list.dart';
import '../../brands/brand_products_screen.dart';



class HomeBrandsCarousel extends StatefulWidget {
  const HomeBrandsCarousel({super.key});

  @override
  State<HomeBrandsCarousel> createState() => _HomeBrandsCarouselState();
}

class _HomeBrandsCarouselState extends State<HomeBrandsCarousel>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<BrandProvider>(context, listen: false).loadBrands());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BrandProvider>(
      builder: (context, provider, _) {
        /// SHOW SHIMMER WHEN LOADING
        if (provider.isLoading) {
          return const GlobalShimmerList(itemCount: 6, height: 180, width: 120);
        }

        /// SHOW ERROR WITH RETRY
        if (provider.error != null) {
          return GlobalErrorRetry(
            message: provider.error!,
            onRetry: () => provider.loadBrands(),
          );
        }

        /// EMPTY DATA SAFETY CHECK
        if (provider.brands.isEmpty) return const SizedBox();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔥 TITLE
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 10),
              child: Text(
                "Brands in focus",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: 'Gilroy',
                ),
              ),
            ),

            // 🌪 CAROUSEL LISTVIEW
            SizedBox(
              height: 180,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: provider.brands.length > 5 ? 5 : provider.brands.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  final Brand brand = provider.brands[i];

                  final String? imageUrl = (brand.logo != null &&
                          brand.logo!.isNotEmpty)
                      ? (brand.logo!.startsWith("http")
                          ? brand.logo
                          : "${ApiConstants.imageBaseUrl}/${brand.logo}")
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

                    // TAP SCALE ANIMATION
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      curve: Curves.easeOut,
                      width: 120,
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: Colors.black, width: 0.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      padding: const EdgeInsets.all(5),
                      child: Column(
                        children: [
                          // 🟡 PERFECT CIRCLE IMAGE FIT
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Container(
                              width: 95,
                              height: 95,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.black.withOpacity(0.1),
                                    width: 1),
                              ),
                              child: ClipOval(
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: imageUrl != null
                                      ? Image.network(
                                          imageUrl,
                                          fit: BoxFit.cover,
                                        )
                                      : const Icon(Icons.store,
                                          size: 40, color: Colors.black),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // BRAND NAME
                          Expanded(
                            child: Text(
                              brand.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Gilroy',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
