import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/banner_provider.dart';
import '../../utils/constants.dart';
import 'package:carousel_slider/carousel_slider.dart';

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

  @override
  Widget build(BuildContext context) {
    final bannerProvider = Provider.of<BannerProvider>(context);

    if (bannerProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (bannerProvider.errorMessage != null) {
      return Center(child: Text(bannerProvider.errorMessage!));
    }

    if (bannerProvider.banners.isEmpty) {
      return const Center(child: Text("No banners available"));
    }

    return CarouselSlider(
      items: bannerProvider.banners.map((banner) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            '${ApiConstants.imageBaseUrl}/${banner.image}',
            fit: BoxFit.cover,
            width: double.infinity,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image, size: 50),
          ),
        );
      }).toList(),
      options: CarouselOptions(
        height: 180,
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 0.9,
      ),
    );
  }
}
