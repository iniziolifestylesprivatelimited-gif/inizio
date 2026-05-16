import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/banner_provider.dart';
import '../../utils/constants.dart';
import 'package:carousel_slider/carousel_slider.dart';

// GLOBAL WIDGETS
import '../../widgets/global/global_banner_shimmer.dart';
import '../../widgets/global/global_shimmer_list.dart';
import '../../widgets/global/global_error_retry.dart';
import '../../widgets/global/global_no_internet.dart';

class BannersBox extends StatefulWidget {
  const BannersBox({super.key});

  @override
  State<BannersBox> createState() => _BannersBoxState();
}

class _BannersBoxState extends State<BannersBox> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<BannerProvider>(context, listen: false).loadBanners());
  }

  bool _isNoInternetError(String? error) {
    if (error == null) return false;

    final text = error.toLowerCase();
    return text.contains("socket") ||
        text.contains("network") ||
        text.contains("connection") ||
        text.contains("internet");
  }

  @override
  Widget build(BuildContext context) {
    final bannerProvider = Provider.of<BannerProvider>(context);

    // -------------------------------
    // ⭐ 1) LOADING → SHOW SHIMMER
    // -------------------------------
    if (bannerProvider.isLoading) {
      return SizedBox(
  height: 180,
  child: ListView.builder(
    scrollDirection: Axis.horizontal,
    itemCount: 3,
    itemBuilder: (_, __) => const GlobalBannerShimmer(),
  ),
);

    }

    // -------------------------------
    // ⭐ 2) CHECK NO INTERNET
    // -------------------------------
    if (_isNoInternetError(bannerProvider.errorMessage)) {
      return const SizedBox(
        height: 180,
        child: GlobalNoInternet(),
      );
    }

    // -------------------------------
    // ⭐ 3) OTHER ERROR → RETRY BUTTON
    // -------------------------------
    if (bannerProvider.errorMessage != null) {
      return SizedBox(
        height: 180,
        child: GlobalErrorRetry(
          title: "Couldn’t load banners",
          message: "Something went wrong.\nPlease try again.",
          onRetry: () => bannerProvider.loadBanners(),
        ),
      );
    }

    // -------------------------------
    // ⭐ 4) EMPTY STATE
    // -------------------------------
    if (bannerProvider.banners.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(
          child: Text(
            "No banners available",
            style: TextStyle(fontSize: 14, fontFamily: 'Gilroy'),
          ),
        ),
      );
    }

    // -------------------------------
    // ⭐ 5) SUCCESS → SHOW CAROUSEL
    // -------------------------------
   return CarouselSlider(
  items: bannerProvider.banners.map((banner) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 637 / 416,
        child: Image.network(
          '${ApiConstants.imageBaseUrl}/${banner.image}',
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.broken_image, size: 50),
        ),
      ),
    );
  }).toList(),
  options: CarouselOptions(
    height: MediaQuery.of(context).size.width * (416 / 637),
    autoPlay: true,
    enlargeCenterPage: true,
    viewportFraction: 1.0,
  ),
);
  }
}
