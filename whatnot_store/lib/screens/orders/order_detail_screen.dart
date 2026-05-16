import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../models/product_model.dart';
import '../../providers/return_provider.dart';
import '../../services/product_service.dart';
import '../../utils/cached_retry_image.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../homescreen/bottomnavigationbar/custom_bottom_navbar.dart';
import '../homescreen/home_screen.dart';
import '../products/product_detail_screen.dart';
import 'return_request_form.dart';

class OrderDetailScreen extends StatefulWidget {
  final Map<String, dynamic> order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  int _currentIndex = 0;

  void _openInvoice(BuildContext context, String url) {
    final fullUrl = url.startsWith('http')
        ? url
        : "${ApiConstants.imageBaseUrl}$url";

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PdfViewerScreen(pdfUrl: fullUrl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final returnProvider = Provider.of<ReturnProvider>(context);
    final existingReturn =
        returnProvider.getReturnForOrder(widget.order["_id"]);
    final bool alreadyRequested = existingReturn != null;

    final items = widget.order['items'] as List<dynamic>;
    final address = widget.order['address'];
    final status = widget.order['orderStatus'];
    final paymentMethod = widget.order['paymentMethod'];
    final paymentStatus = widget.order['paymentStatus'];
    final total = widget.order['totalAmount'];
    final invoiceUrl = widget.order['invoiceUrl'];

    /// RETURN LOGIC
    DateTime? deliveredAt;

    if (widget.order["deliveredAt"] != null) {
      deliveredAt = DateTime.parse(widget.order["deliveredAt"]);
    } else if (status == "Delivered") {
      deliveredAt = DateTime.now();
    }

    bool isReturnEligible = false;

    if (!alreadyRequested &&
        status == "Delivered" &&
        deliveredAt != null) {
      final diff = DateTime.now().difference(deliveredAt).inDays;
      if (diff <= 7) {
        isReturnEligible = true;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title:
            const Text("Order Details", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [

          /// 🔥 SHIPPING + ORDER CARD
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Shipping Address",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    // TextButton(
                    //   onPressed: () {},
                    //   child: const Text("Change"),
                    // )
                  ],
                ),

                const SizedBox(height: 28),

                /// DELIVERY STATUS
                Row(
                  children: [
                    const Icon(Icons.local_shipping, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        status == "Delivered"
                            ? "Your order is delivered."
                            : "Your order is $status",
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: status == "Delivered"
                            ? Color(0xFF00BE23)
                            : Colors.orange,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 11),
                      ),
                    )
                  ],
                ),

                const Divider(height: 40),

                /// PAYMENT
                RichText(
  text: TextSpan(
    style: TextStyle(color: Colors.black), // default style
    children: [
      TextSpan(
        text: "Payment Method: ",
        style: TextStyle(fontWeight: FontWeight.normal),
      ),
      TextSpan(
        text: paymentMethod,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    ],
  ),
),
RichText(
  text: TextSpan(
    style: TextStyle(color: Colors.black), // default style
    children: [
      TextSpan(
        text: "Payment Method: ",
        style: TextStyle(fontWeight: FontWeight.normal),
      ),
      TextSpan(
        text: paymentStatus,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    ],
  ),
),
                

                const SizedBox(height: 30),

                /// BUTTONS
              Row(
  children: [

    /// 🔥 VIEW INVOICE
    if (invoiceUrl != null && invoiceUrl.isNotEmpty)
      SizedBox(
        width: 140, // 👈 control width
        child: ElevatedButton(
          onPressed: () => _openInvoice(context, invoiceUrl),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            elevation: 0,
          ),
          child: const Text("View Invoice"),
        ),
      ),

    if (isReturnEligible &&
        invoiceUrl != null &&
        invoiceUrl.isNotEmpty)
      const SizedBox(width: 10),

    /// 🔥 RETURN ITEM (SAME STYLE)
    if (isReturnEligible)
      SizedBox(
        width: 140, // 👈 SAME WIDTH
        child: OutlinedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ReturnRequestForm(order: widget.order),
              ),
            );
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6), // 👈 same radius
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text("Return Item"),
        ),
      ),
  ],
),

                const SizedBox(height: 34),

                /// ADDRESS
                Text(
                  address != null ? address['name'] : "",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    const Icon(Icons.home, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "${address['addressLine1']}, ${address['city']}",
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    const Icon(Icons.phone, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      address != null ? address['phone'] : "",
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          /// 🔥 ITEMS LIST
        Container(
  padding: const EdgeInsets.all(14),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 10,
      )
    ],
  ),
  child: Column(
  children: [

    /// 🔥 ITEMS
    ...List.generate(items.length, (index) {
  final item = items[index];
  final product = item['product'];

  final isLast = index == items.length - 1;

  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// 🔥 IMAGE + QTY BADGE
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: RetryImage(
                url: buildImageUrl(product['images'][0]),
                width: 110,
                height: 110,
                fit: BoxFit.cover,
              ),
            ),

            Positioned(
              bottom: 6,
              right: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "Qty: ${item['quantity']}",
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

        const SizedBox(width: 12),

        /// 🔥 RIGHT SIDE
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// PRODUCT NAME
              Text(
                product['name'],
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 10),

              /// 🔥 ONLY FOR LAST ITEM → SHOW TOTAL + BUTTON
              if (isLast)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    /// TOTAL
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Total",
                          style: TextStyle(
                              fontSize: 12, color: Colors.black54),
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

                    /// BUTTON
                    SizedBox(
                      height: 34,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () async {
  final productData = item['product'];
  final productId = productData['_id'];

  // 🔥 Fetch full product from API
  final fullProduct =
      await ProductService().fetchProductById(productId);

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ProductDetailScreen(
        product: fullProduct,
      ),
    ),
  );
},
                        child: const Text(
                          "View Product",
                          style: TextStyle(fontSize: 12),
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
  );
}),

   
  ],
),
),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: CustomBottomNavBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => HomeScreen(initialIndex: index),
              ),
              (route) => false,
            );
          },
        ),
      ),
    );
  }
}

class PdfViewerScreen extends StatelessWidget {
  final String pdfUrl;
  const PdfViewerScreen({super.key, required this.pdfUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Invoice PDF", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SfPdfViewer.network(pdfUrl),
    );
  }
}