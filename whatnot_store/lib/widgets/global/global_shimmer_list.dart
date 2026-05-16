import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class GlobalShimmerList extends StatelessWidget {
  final int itemCount;
  final double width;
  final double height;

  const GlobalShimmerList({
    super.key,
    this.itemCount = 6,
    this.width = 150,
    this.height = 250,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        itemBuilder: (_, index) {
          return Container(
            width: width,
            margin: const EdgeInsets.only(right: 12),
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image skeleton
                  Expanded(
                    child: Container(
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // brand skeleton
                  Container(height: 10, width: 60, color: Colors.grey.shade300),
                  const SizedBox(height: 6),

                  // name skeleton
                  Container(height: 10, width: 120, color: Colors.grey.shade300),
                  const SizedBox(height: 4),
                  Container(height: 10, width: 100, color: Colors.grey.shade300),
                  const SizedBox(height: 6),

                  // price skeleton
                  Container(height: 12, width: 80, color: Colors.grey.shade300),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
