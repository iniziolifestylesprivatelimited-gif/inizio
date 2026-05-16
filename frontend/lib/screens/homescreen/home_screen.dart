import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/brand_provider.dart';
import '../../providers/banner_provider.dart';
import '../../providers/order_provider.dart';

import '../notifications/notification_bell.dart';
import 'bottomnavigationbar/custom_bottom_navbar.dart';
import 'bottomnavigationbar/hometab.dart';
import 'bottomnavigationbar/searchtab.dart';
import 'bottomnavigationbar/profiletab.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;
  const HomeScreen({super.key, this.initialIndex = 0});
  

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _currentIndex;
  // int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeTab(),
    SearchTab(),
    ProfileTab(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    // ✅ Load cart initially
    Future.microtask(() {
      Provider.of<CartProvider>(context, listen: false).getCart(context);
    });
  }

  // ✅ Auto refresh based on tab index
  // ✅ Auto refresh based on tab index
Future<void> _handleTabRefresh(int index) async {
  if (index == 0) {
    // Home refresh
    await Provider.of<ProductProvider>(context, listen: false).loadProducts();
    await Provider.of<CategoryProvider>(context, listen: false).loadCategories();
    await Provider.of<BrandProvider>(context, listen: false).loadBrands();
    await Provider.of<BannerProvider>(context, listen: false).loadBanners();
    await Provider.of<CartProvider>(context, listen: false).getCart(context);
  } 
  else if (index == 1) {
    // Search refresh
    await Provider.of<ProductProvider>(context, listen: false).loadProducts();
  } 
  else if (index == 2) {
    // Profile refresh → orders list
    await Provider.of<OrderProvider>(context, listen: false).fetchOrders(context);
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 1,
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Whatnot',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          // NotificationBell(), // 🔔 here
        SizedBox(width: 6),
          Consumer<CartProvider>(
            builder: (context, cartProvider, _) {
              int cartCount = cartProvider.items.length;

              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                    onPressed: () {
                      Navigator.pushNamed(context, '/cart');
                    },
                  ),
                  if (cartCount > 0)
                    Positioned(
                      right: 6,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          cartCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),

      // ✅ Keep page state
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) async {
          if (index == _currentIndex) {
            await _handleTabRefresh(index); // ✅ Refresh same tab tap
          }

          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
