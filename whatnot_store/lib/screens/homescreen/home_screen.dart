import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/brand_provider.dart';
import '../../providers/banner_provider.dart';
import '../../providers/order_provider.dart';

import '../brands/brands_screen.dart';
import '../cart/cart_screen.dart';
import '../categories/categories_screen.dart';
import 'bottomnavigationbar/custom_bottom_navbar.dart';
import 'bottomnavigationbar/hometab.dart';
import 'bottomnavigationbar/profiletab.dart';
import 'bottomnavigationbar/searchtab.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;
  const HomeScreen({super.key, this.initialIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _currentIndex;

  final List<Widget> _pages = const [
    HomeTab(),          // 0
    CategoriesScreen(), // 1
    BrandsScreen(),     // 2
    ProfileTab(),       //3
    SearchTab(),        // 4 ✅
    CartScreen(),       // 5 ✅
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;

    Future.microtask(() {
      Provider.of<CartProvider>(context, listen: false).getCart(context);
    });
  }

  Future<void> _handleTabRefresh(int index) async {
    if (index == 0) {
      await Provider.of<ProductProvider>(context, listen: false).loadProducts();
      await Provider.of<CategoryProvider>(context, listen: false).loadCategories();
      await Provider.of<BrandProvider>(context, listen: false).loadBrands();
      await Provider.of<BannerProvider>(context, listen: false).loadBanners();
      await Provider.of<CartProvider>(context, listen: false).getCart(context);
    } 
   else if (index == 4) {
  // Search
  await Provider.of<ProductProvider>(context, listen: false).loadProducts();
} 
else if (index == 5) {
  // Cart
  await Provider.of<CartProvider>(context, listen: false).getCart(context);
}
else if (index == 3) {
  // Profile
  await Provider.of<OrderProvider>(context, listen: false).fetchOrders(context);
}
    else if (index == 2) {
      // Orders (if needed)
      await Provider.of<OrderProvider>(context, listen: false).fetchOrders(context);
    }
  }

String _getTitle() {
  switch (_currentIndex) {
    case 1:
      return "Categories";
    case 2:
      return "Brands";
    case 3:
      return "Profile";
    case 4:
      return "Search";
    case 5:
      return "Cart";
    default:
      return "";
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,

        // ✅ Back button for Search & Cart
       leading: (_currentIndex == 3 || _currentIndex == 4 || _currentIndex == 5)
    ? IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () {
          setState(() {
            _currentIndex = 0;
          });
        },
      )
    : null,

       title: _currentIndex == 0
    ? Image.asset(
        "assets/logos/inizio_logo.png",
        height: 70,
      )
    : Text(
        _getTitle(),
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),

        actions: (_currentIndex == 3)
            ? [] // hide icons in search
            : [
                /// SEARCH
                IconButton(
                  onPressed: () {
                    setState(() {
                      _currentIndex = 4; // ✅ opens Search
                    });
                  },
                  icon: const CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.black,
                    child: Icon(Icons.search, color: Colors.white, size: 20),
                  ),
                ),

                /// PROFILE / BRANDS
                IconButton(
                  onPressed: () {
                    setState(() {
                      _currentIndex = 3;
                    });
                  },
                  icon: const CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.black,
                    child: Icon(Icons.person_outline, color: Colors.white, size: 20),
                  ),
                ),

                const SizedBox(width: 10),
              ],
      ),

      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      bottomNavigationBar: SafeArea(
        child: CustomBottomNavBar(
          currentIndex: _currentIndex == 5 ? 3 : _currentIndex,
          onTap: (index) async {
  int pageIndex;

  if (index == 3) {
    pageIndex = 5; // Cart
  } else {
    pageIndex = index;
  }

  setState(() {
    _currentIndex = pageIndex;
  });

  await _handleTabRefresh(pageIndex);
},
        ),
      ),
    );
  }
}