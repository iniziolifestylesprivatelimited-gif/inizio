import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/cart_provider.dart';


class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(20),
      topRight: Radius.circular(20),
    ),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [

  /// HOME
  _buildNavItem(
    icon: Icons.home_outlined,
    label: "Home",
    index: 0,
    isSelected: currentIndex == 0,
    onTap: onTap,
  ),

/// CATEGORIES
_buildNavItem(
  icon: Icons.category_outlined,
  label: "Categories",
  index: 1,
  isSelected: currentIndex == 1,
  onTap: onTap,
),

/// BRANDS
_buildNavItem(
  icon: Icons.diamond,
  label: "Brands",
  index: 2,
  isSelected: currentIndex == 2,
  onTap: onTap,
),
  /// CART
  _buildCartButton(
    context,
    index: 3,
    isSelected: currentIndex == 3,
    onTap: onTap,
  ),
],
      ),
    );
  }
  

  Widget _buildCartButton(
  BuildContext context, {
  required int index,
  required bool isSelected,
  required ValueChanged<int> onTap,
}) {
  return Consumer<CartProvider>(
    builder: (context, cartProvider, _) {
      int cartCount = cartProvider.items.length;

      return GestureDetector(
        onTap: () => onTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Stack(
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 26,
                  color: isSelected ? Colors.white : Colors.white54,
                ),

                if (cartCount > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
  constraints: const BoxConstraints(
    minWidth: 16,
    minHeight: 16,
  ),
  padding: const EdgeInsets.symmetric(
    horizontal: 4,
    vertical: 2,
  ),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        cartCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 4),

            Text(
              "Cart",
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white : Colors.white54,
              ),
            ),
          ],
        ),
      );
    },
  );
}

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
    required ValueChanged<int> onTap,
  }) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 26,
            color: isSelected ? Colors.white : Colors.white54,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.white : Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterButton({
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Icon(
          Icons.search,
          size: 30,
          color: isSelected ? Colors.black : Colors.white,
        ),
      ),
    );
  }
}