import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../utils/cached_retry_image.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../homescreen/bottomnavigationbar/custom_bottom_navbar.dart';
import '../homescreen/home_screen.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<OrderProvider>(context, listen: false).fetchOrders(context));
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);

    return Scaffold(
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
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OrderDetailScreen(order: order),
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Order #${index + 1}",
                                      style: const TextStyle(
                                          fontSize: 16, fontWeight: FontWeight.bold)),
                                  Chip(
                                    label: Text(status),
                                    backgroundColor: status == "Delivered"
                                        ? Colors.green[200]
                                        : Colors.orange[200],
                                  ),
                                ],
                              ),
                              const Divider(),
                              
                              // ✅ Correct Image Building Here
                              ...items.map((item) {
  final product = item['product'];

  String imageUrl = ApiConstants.fallbackImage; // ✅ default

  
if (product['variants'] != null &&
    product['variants'] is List &&
    product['variants'].isNotEmpty &&
    product['variants'][0]['images'] != null &&
    product['variants'][0]['images'].isNotEmpty) {
  imageUrl = buildImageUrl(product['variants'][0]['images'][0]);
} else if (product['images'] != null && product['images'].isNotEmpty) {
  imageUrl = buildImageUrl(product['images'][0]);
}


 return ListTile(
  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  leading: SizedBox(
  width: 55,
  height: 55,
  child: ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: RetryImage(
  url: imageUrl,
  width: 55,
  height: 55,
  fit: BoxFit.cover,
),

  ),
),

  title: Text(product['name'], maxLines: 1, overflow: TextOverflow.ellipsis),
  subtitle: Text("Qty: ${item['quantity']}"),
  trailing: Text(
    "₹${product['basePrice'] * item['quantity']}",
    style: const TextStyle(fontWeight: FontWeight.bold),
  ),
);


}),


                              const Divider(),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  "Total: ₹$total",
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
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
