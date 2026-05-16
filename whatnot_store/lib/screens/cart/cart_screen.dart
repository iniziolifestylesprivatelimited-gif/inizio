import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../utils/constants.dart';
import '../payment/payment_screen.dart';
import 'CartPriceSection.dart';
import 'order_summary_section.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<CartProvider>(context, listen: false).getCart(context));
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    double totalBasePrice = cartProvider.items.fold(0, (sum, item) {
      return sum +
          ((item["product"]["basePrice"] ?? 0).toDouble() *
              (item["quantity"] ?? 1));
    });

   double totalOfferPrice = cartProvider.items.fold(0, (sum, item) {

  final product = item["product"];

  final offerPrice =
      (product["offerPrice"] ??
              product["basePrice"] ??
              0)
          .toDouble();

  return sum + (offerPrice * (item["quantity"] ?? 1));
});

    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   iconTheme: const IconThemeData(color: Colors.white),
      //   backgroundColor: Colors.black,
      // ),

      body: cartProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartProvider.items.isEmpty
              ? const Center(child: Text("Your cart is empty 🛒"))
              : ListView.builder(
                  itemCount: cartProvider.items.length + 1, // add summary slot
                  itemBuilder: (context, index) {
                    /// --- ORDER SUMMARY POSITION ---
                    if (index == cartProvider.items.length) {
                      return OrderSummarySection(
                        totalBasePrice: totalBasePrice,
                        totalOfferPrice: totalOfferPrice,
                      );
                    }

                  final item = cartProvider.items[index];
final product = item["product"];

String? imageUrl;

/// ✅ VARIANT IMAGE FIRST
if (item["variant"] != null &&
    item["variant"]["images"] != null &&
    item["variant"]["images"].isNotEmpty) {

  imageUrl =
      item["variant"]["images"][0].toString();

} else if (
    product["images"] != null &&
    product["images"].isNotEmpty) {

  imageUrl =
      product["images"][0].toString();
}

/// ✅ FULL URL
if (imageUrl != null &&
    imageUrl.isNotEmpty &&
    !imageUrl.startsWith("http")) {

  imageUrl =
      "${ApiConstants.imageBaseUrl}/$imageUrl";
}

final int quantity = item["quantity"] ?? 10;

/// ✅ DEFAULT PRICE
double offerPrice =
    (product["offerPrice"] ??
    product["basePrice"] ??
    0).toDouble();

/// ✅ ORIGINAL PRICE
double originalPrice =
    (product["basePrice"] ?? 0).toDouble();

/// ✅ GET SLAB PRICING
final List quantityPricing =
    product["quantityPricing"] ?? [];

/// ✅ APPLY SLAB PRICE
if (quantityPricing.isNotEmpty) {

  quantityPricing.sort(
    (a, b) =>
        (a["minQty"] as int)
            .compareTo(b["minQty"] as int),
  );

  for (final slab in quantityPricing) {

    if (quantity >= slab["minQty"]) {

      offerPrice =
          (slab["price"] as num).toDouble();
    }
  }
}

return Dismissible(

  key: ValueKey(
    "${product["_id"]}_${item["variantId"] ?? "default"}",
  ),

  direction: DismissDirection.endToStart,

  confirmDismiss: (direction) async {

    try {

      await cartProvider.removeFromCart(
        context,
        product["_id"],
        item["variantId"],
      );

      return true;

    } catch (e) {

      debugPrint("Remove error: $e");

      return false;
    }
  },

  background: Container(
    alignment: Alignment.centerRight,
    padding: const EdgeInsets.only(right: 20),
    color: Colors.red,

    child: const Icon(
      Icons.delete,
      color: Colors.white,
      size: 28,
    ),
  ),

  child: Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 10,
    ),

    child: Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        /// IMAGE
        ClipRRect(
          borderRadius:
              BorderRadius.circular(8),

          child: imageUrl != null

              ? Image.network(
                  imageUrl,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,

                  errorBuilder:
                      (_, __, ___) {

                    return const SizedBox(
                      width: 120,
                      height: 120,

                      child: Icon(
                        Icons.broken_image,
                        size: 40,
                      ),
                    );
                  },
                )

              : const SizedBox(
                  width: 120,
                  height: 120,

                  child: Icon(
                    Icons.image_not_supported,
                    size: 40,
                  ),
                ),
        ),

        const SizedBox(width: 12),

        /// DETAILS
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              /// NAME
             /// NAME
Text(
  product["name"],

  maxLines: 2,

  overflow: TextOverflow.ellipsis,

  style: const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  ),
),

/// ✅ VARIANT NAME
if (item["variant"] != null)
  Padding(
    padding: const EdgeInsets.only(top: 4),

    child: Text(
      item["variant"]["name"] ?? "",

      style: TextStyle(
        fontSize: 13,
        color: Colors.grey.shade700,
        fontWeight: FontWeight.w500,
      ),
    ),
  ),

const SizedBox(height: 6),

              /// PRICE
              CartPriceSection(
                offerPrice: offerPrice,
                originalPrice:
                    originalPrice,
              ),

              const SizedBox(height: 12),

              /// QTY CONTROLS
             /// QTY CONTROLS
Container(
  width: 120,
  height: 40,
  color: Colors.grey.shade200,

  child: Row(
    children: [

      /// MINUS
      GestureDetector(
        onTap: quantity > 10

            ? () {

                cartProvider
                    .updateQuantity(
                  context,
                  product["_id"],
                  quantity - 10,
                  item["variantId"],
                );
              }

            : null,

        child: const SizedBox(
          width: 34,

          child: Center(
            child: Icon(
              Icons.remove,
              size: 18,
            ),
          ),
        ),
      ),

      /// QTY
      Expanded(
        child: Center(
          child: Text(
            "$quantity",

            style: const TextStyle(
              fontSize: 15,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ),
      ),

      /// PLUS
      GestureDetector(
        onTap: () {

          cartProvider
              .updateQuantity(
            context,
            product["_id"],
            quantity + 10,
            item["variantId"],
          );
        },

        child: const SizedBox(
          width: 34,

          child: Center(
            child: Icon(
              Icons.add,
              size: 18,
            ),
          ),
        ),
      ),
    ],
  ),
),

              const SizedBox(height: 8),

              /// TOTAL
              Text(
                "Total: ₹${(offerPrice * quantity).toInt()}",

                style: const TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  ),
);
                  },
                ),

      bottomNavigationBar: cartProvider.items.isNotEmpty
          ? SafeArea(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Payable: ₹${totalOfferPrice.toInt()}",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const PaymentScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black),
                      child:
                          const Text("Checkout", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
