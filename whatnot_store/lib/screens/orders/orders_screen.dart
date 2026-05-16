import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/return_provider.dart';
import '../../utils/cached_retry_image.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../homescreen/bottomnavigationbar/custom_bottom_navbar.dart';
import '../homescreen/home_screen.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatefulWidget {
    final bool showSuccessMessage;
  const OrdersScreen({super.key, this.showSuccessMessage = false});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<OrderProvider>(context, listen: false).fetchOrders(context));
  if (widget.showSuccessMessage) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("🎉 Order placed successfully"),
          backgroundColor: Colors.green,
        ),
      );
    });
  }
  }

  

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);

    return Scaffold(
        backgroundColor: Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text("My Orders", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: orderProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : orderProvider.orders.isEmpty
              ? const Center(
                  child: Text("No orders found 🛍️", style: TextStyle(fontSize: 16)),
                )
              : ListView.builder(
                  itemCount: orderProvider.orders.length,
                  itemBuilder: (context, index) {
                    final order = orderProvider.orders[index];
                    final items = order['items'] as List<dynamic>;
                    final status = order['orderStatus'];
                    final total = order['totalAmount'];

                    return GestureDetector(
                      onTap: () async {
  final rProvider = Provider.of<ReturnProvider>(context, listen: false);
  await rProvider.fetchMyReturns(context); // FETCH RETURNS BEFORE OPENING

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => OrderDetailScreen(order: order),
    ),
  );
},
                      child: Card(
                         color: Color(0xFFFFFFFF),
                         shadowColor: Colors.black.withOpacity(0.2), 
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        elevation: 4,
                      child: Padding(
  padding: const EdgeInsets.all(14),
  child: IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [

        /// 🔥 FULL HEIGHT IMAGE
       Stack(
  children: [

    /// 🔥 IMAGE
    ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: RetryImage(
        url: (() {
          final firstItem = items[0];
          final product = firstItem['product'];

          if (product['variants'] != null &&
              product['variants'].isNotEmpty &&
              product['variants'][0]['images'] != null &&
              product['variants'][0]['images'].isNotEmpty) {
            return buildImageUrl(product['variants'][0]['images'][0]);
          } else if (product['images'] != null &&
              product['images'].isNotEmpty) {
            return buildImageUrl(product['images'][0]);
          }
          return ApiConstants.fallbackImage;
        })(),
        width: 110,
        fit: BoxFit.cover,
      ),
    ),

    /// 🔥 QUANTITY BADGE (bottom-right)
    Positioned(
      bottom: 6,
      right: 6,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          "Qty: ${items.length}",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  ],
),

        const SizedBox(width: 10),

        /// 🔥 RIGHT SIDE CONTENT
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// Order number + status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Order #${index + 1}",
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                 Chip(
  label: Text(
    status,
    style: const TextStyle(fontSize: 10),
  ),
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0), // 🔥 wider, less height
  labelPadding: const EdgeInsets.symmetric(horizontal: 2), // 🔥 more width
  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
  visualDensity: const VisualDensity(horizontal: 0, vertical: -4), // 🔥 reduce height
  backgroundColor: status == "Delivered"
      ? Colors.green[200]
      : Colors.orange[200],
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(6),
  ),
)
                ],
              ),

              const SizedBox(height: 6),

              /// Items
             ...items.map((item) {
  final product = item['product'];

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// 🔥 PRODUCT NAME (bigger)
        Text(
          "${product['name']} (x${item['quantity']})",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14, // 🔥 increased
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 2),

        /// 🔥 PRICE BELOW NAME
        Text(
          "₹${product['basePrice'] * item['quantity']}",
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    ),
  );
}),

              const Spacer(),

              /// 🔥 TOTAL + VIEW MORE
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const Text(
      "Total :",
      style: TextStyle(
        fontSize: 12,
        color: Colors.black,
        // fontWeight: FontWeight.w500,
      ),
    ),
    Text(
      "₹$total",
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ),
  ],
),

                 SizedBox(
  height: 30,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8), // small radius
      ),
      elevation: 0,
    ),
    onPressed: () async {
      final rProvider = Provider.of<ReturnProvider>(context, listen: false);
      await rProvider.fetchMyReturns(context);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OrderDetailScreen(order: order),
        ),
      );
    },
    child: const Text(
      "View More",
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 10,
      ),
    ),
  ),
),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  ),
),
                      ),
                    );
                  },
                ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 2) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => HomeScreen(initialIndex: index)),
            (route) => false,
          );
        },
      ),
    );
  }
}
