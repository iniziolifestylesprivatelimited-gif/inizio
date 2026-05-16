import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ProductImageSlider extends StatelessWidget {
  final List<String> imageUrls;

  const ProductImageSlider({super.key, required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    return imageUrls.isNotEmpty
        ? CarouselSlider(
            options: CarouselOptions(height: 300, viewportFraction: 1),
            items: imageUrls.map((url) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  url,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.broken_image, size: 100),
                ),
              );
            }).toList(),
          )
        : Container(
            height: 300,
            color: Colors.grey.shade300,
            child: const Center(child: Icon(Icons.image, size: 80)),
          );
  }
}
