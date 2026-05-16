import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../utils/cached_retry_image.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

class OrderDetailScreen extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderDetailScreen({super.key, required this.order});

  // ✅ Open PDF inside the app
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
    final items = order['items'] as List<dynamic>;
    final address = order['address'];
    final status = order['orderStatus'];
    final paymentMethod = order['paymentMethod'];
    final paymentStatus = order['paymentStatus'];
    final total = order['totalAmount'];
    final invoiceUrl = order['invoiceUrl'];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Details",style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView(
          children: [
            Text(
              "Order Status: $status",
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text("Payment Method: $paymentMethod"),
            Text("Payment Status: $paymentStatus"),
            const Divider(),

            // 🧾 Invoice button (if available)
            if (invoiceUrl != null && invoiceUrl.isNotEmpty) ...[
              ElevatedButton.icon(
                onPressed: () => _openInvoice(context, invoiceUrl),
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text("View Invoice"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
            ],

            const Text(
              "Shipping Address:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (address != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  "${address['name']}\n"
                  "${address['addressLine1']}${address['addressLine2'] != null ? ', ' + address['addressLine2'] : ''}\n"
                  "${address['city']}, ${address['state']}, ${address['country']} - ${address['pincode']}\n"
                  "Phone: ${address['phone']}",
                ),
              ),
            const Divider(),
            const Text(
              "Items:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ...items.map((item) {
              final product = item['product'];
              return ListTile(
               leading: SizedBox(
  width: 55,
  height: 55,
  child: ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: RetryImage(
      url: (() {
        // ✅ If variant images exist
        if (product['variants'] != null &&
            product['variants'] is List &&
            product['variants'].isNotEmpty &&
            product['variants'][0]['images'] != null &&
            product['variants'][0]['images'].isNotEmpty) {
          return buildImageUrl(product['variants'][0]['images'][0]);
        }

        // ✅ Else use product base images
        if (product['images'] != null && product['images'].isNotEmpty) {
          return buildImageUrl(product['images'][0]);
        }

        // ✅ Fallback image
        return ApiConstants.fallbackImage;
      })(),
      width: 55,
      height: 55,
      fit: BoxFit.cover,
    ),
  ),
),



                title: Text(product['name']),
                subtitle: Text("Qty: ${item['quantity']}"),
                trailing: Text("₹${product['basePrice'] * item['quantity']}"),
              );
            }),
            const Divider(),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "Total: ₹$total",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= PdfViewerScreen =================
class PdfViewerScreen extends StatelessWidget {
  final String pdfUrl;

  const PdfViewerScreen({super.key, required this.pdfUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Invoice PDF",style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),

      ),
      body: SfPdfViewer.network(
        pdfUrl,
        canShowScrollHead: true,
        canShowPaginationDialog: true,
      ),
    );
  }
}
