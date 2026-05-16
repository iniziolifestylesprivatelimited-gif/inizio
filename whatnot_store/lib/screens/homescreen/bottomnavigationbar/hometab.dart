import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../main.dart'; // 👈 import routeObserver
import '../../../providers/banner_provider.dart';
import '../../../providers/brand_provider.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/category_provider.dart';
import '../../../providers/product_provider.dart';
import '../../brands/brands_box.dart';
import '../../categories/categories_box.dart';
import '../../banners/banners_box.dart';
import '../widgets/HomeBrandsGrid.dart';
import '../widgets/accessories.dart';
import '../widgets/audio_wearables_section.dart';
import '../widgets/fujifilm_accessories.dart';
import '../widgets/home_brands_carousel.dart';
import '../widgets/soundbars.dart';
import '../widgets/travel_smart_picks.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with RouteAware {

  Future<void> _refreshData() async {
  if (!mounted) return;
  await Provider.of<ProductProvider>(context, listen: false).loadProducts();

  if (!mounted) return;
  await Provider.of<CategoryProvider>(context, listen: false).loadCategories();

  if (!mounted) return;
  await Provider.of<BrandProvider>(context, listen: false).loadBrands();

  if (!mounted) return;
  await Provider.of<BannerProvider>(context, listen: false).loadBanners();

  if (!mounted) return;
  await Provider.of<CartProvider>(context, listen: false).getCart(context);

  if (!mounted) return;
  setState(() {});
}

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshData());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  // 👇 triggers when coming back from another screen
  @override
  void didPopNext() {
    _refreshData();
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    body: RefreshIndicator(
      onRefresh: _refreshData,
      color: Colors.black,
      child: CustomScrollView(
        slivers: [
          // STICKY HEADER
          // SliverPersistentHeader(
          //   pinned: true,
          //   delegate: _StickyHeaderDelegate(
          //     child: Container(
          //       color: Colors.white,
          //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          //       child: const Row(
          //         children: [
          //           Expanded(child: CategoriesBox()),
          //           SizedBox(width: 10),
          //           Expanded(child: BrandsBox()),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),

         SliverToBoxAdapter(
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        BannersBox(),
        SizedBox(height: 20),
        Divider(thickness: 0.5),
        SizedBox(height: 20),
        AudioWearablesSection(),
        SizedBox(height: 20),
        Divider(thickness: 0.5),
        SizedBox(height: 20),
        SoundBars(),
        SizedBox(height: 20),
        Divider(thickness: 0.5),
        SizedBox(height: 20),
        TravelSmartPicksSection(),
        SizedBox(height: 20),
        Divider(thickness: 0.5),
        SizedBox(height: 20),
        Accessories(),
        SizedBox(height: 20),
        Divider(thickness: 0.5),
        SizedBox(height: 20),
        HomeBrandsCarousel(),
        SizedBox(height: 20),
        Divider(thickness: 0.5),
        Fujifilm(),
        SizedBox(height: 20),
        Divider(thickness: 0.5),
        HomeBrandsGrid(),
                SizedBox(height: 40),

        // ------------------ FOOTER ------------------
        Center(
          child: Text(
            "Powered by Inizio Lifestyle © 2026\nAll Rights Reserved",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: "Gilroy",
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
        ),

        SizedBox(height: 30),
      ],
    ),
  ),
),

        ],
      ),
    ),
  );
}

}


class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyHeaderDelegate({required this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 60; // height of the header
  @override
  double get minExtent => 60;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
