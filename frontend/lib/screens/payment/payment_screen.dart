import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../models/product_model.dart';
import '../../providers/order_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/address_model.dart';
import '../../services/address_service.dart';
import 'package:http/http.dart' as http;
import '../../utils/constants.dart';
import '../orders/orders_screen.dart';

class PaymentScreen extends StatefulWidget {
  final Product? buyNowProduct;
  final Variant? selectedVariant;
  final int? quantity;

  const PaymentScreen({
    super.key,
    this.buyNowProduct,
    this.selectedVariant,
    this.quantity,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  List<Address> _addresses = [];
  Address? _selectedAddress;
  bool _isLoadingAddresses = true;
  bool _isPlacingOrder = false;

  late AddressService _addressService;
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    _addressService = AddressService(token: token);
    _fetchAddresses();

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  Future<void> _fetchAddresses() async {
    try {
      final addresses = await _addressService.getAddresses();
      setState(() {
        _addresses = addresses;
        if (addresses.isNotEmpty) _selectedAddress = addresses[0];
        _isLoadingAddresses = false;
      });
    } catch (e) {
      setState(() => _isLoadingAddresses = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load addresses')),
      );
    }
  }

  double getTotalAmount(CartProvider cartProvider) {
  if (widget.buyNowProduct != null) {
    double price = (widget.selectedVariant?.offerPrice ??
            widget.selectedVariant?.price ??
            widget.buyNowProduct!.offerPrice ??
            widget.buyNowProduct!.basePrice)
        .toDouble();

    return price * (widget.quantity ?? 1);
  } else {
    return cartProvider.items.fold(0.0, (sum, item) {
      double price = ((item['product']['offerPrice'] ??
              item['product']['basePrice'] ??
              0))
          .toDouble();

      int qty = item['quantity'] ?? 1;

      return sum + (price * qty);
    });
  }
}


  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
  final orderProvider = Provider.of<OrderProvider>(context, listen: false);
  final token = Provider.of<AuthProvider>(context, listen: false).token;

  final url = Uri.parse('${ApiConstants.baseUrl}/orders/verify');

  final res = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      "razorpay_order_id": orderProvider.razorpayOrder!['id'],
      "razorpay_payment_id": response.paymentId,
      "razorpay_signature": response.signature,
      "orderId": orderProvider.razorpayOrder!['receipt'],
    }),
  );

  if (!mounted) return;

  if (res.statusCode == 200) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Payment Successful ✅")),
    );

    // ✅ Navigate to Orders Screen
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const OrdersScreen()),
      (route) => false,
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Payment verification failed ❌")),
    );

    // ❗ Also navigate to orders screen
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const OrdersScreen()),
      (route) => false,
    );
  }
}


  void _handlePaymentError(PaymentFailureResponse response) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Payment Failed ❌")),
  );

  if (!mounted) return;

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => const OrdersScreen()),
    (route) => false,
  );
}


  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("External Wallet: ${response.walletName}")),
    );
  }

  void _startRazorpayPayment() {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    if (orderProvider.razorpayOrder == null) return;

    final options = {
      'key': 'rzp_test_al5RfK3OZWPzeA',
      'amount': orderProvider.razorpayOrder!['amount'],
      'order_id': orderProvider.razorpayOrder!['id'],
      'name': 'My Shop',
      'description': 'Order Payment',
      'prefill': {
        'contact': '9999999999',
        'email': 'customer@example.com',
      },
      'theme': {'color': '#F37254'}
    };

    _razorpay.open(options);
  }

  Future<void> _onSubmit() async {
  if (_selectedAddress == null) {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select address')));
    return;
  }

  setState(() => _isPlacingOrder = true);

  final cartProvider = Provider.of<CartProvider>(context, listen: false);
  late List<Map<String, dynamic>> orderItems;

  if (widget.buyNowProduct != null) {
    orderItems = [
      {
        "product": widget.buyNowProduct!.id,
        "quantity": widget.quantity,
        "variantName": widget.selectedVariant?.name
      }
    ];
  } else {
    orderItems = cartProvider.items
        .map<Map<String, dynamic>>((i) => {
              "product": i['product']['_id'],
              "quantity": i['quantity'],
              "variantName": i['variantName'],
            })
        .toList();
  }

  final totalAmount = getTotalAmount(cartProvider);
  final orderProvider = Provider.of<OrderProvider>(context, listen: false);

  try {
    final success = await orderProvider.placeOrderRazorpay(
        context, orderItems, totalAmount, _selectedAddress!.id);

    if (!mounted) return;

    setState(() => _isPlacingOrder = false);

    if (success) {
      _startRazorpayPayment();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(orderProvider.error ?? "Order failed")));
    }
  } catch (e) {
    setState(() => _isPlacingOrder = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")));
    }
  }
}


  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    // Build list of order items
    final List<Map<String, dynamic>> items = widget.buyNowProduct != null
        ? [
            {
              "product": widget.buyNowProduct!,
              "quantity": widget.quantity,
              "variantName": widget.selectedVariant?.name
            }
          ]
        : cartProvider.items;

    return Scaffold(
      appBar: AppBar(title: const Text("Payment")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select Address",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _isLoadingAddresses
                ? const Center(child: CircularProgressIndicator())
                : _addresses.isEmpty
                    ? const Text("No address found. Add in profile.")
                    : DropdownButton<Address>(
                        value: _selectedAddress,
                        isExpanded: true,
                        items: _addresses.map((address) {
                          return DropdownMenuItem<Address>(
                            value: address,
                            child: Text(
                              "${address.name} - ${address.addressLine1}, ${address.city}, ${address.state}, ${address.pincode}",
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() => _selectedAddress = val);
                        },
                      ),
            const SizedBox(height: 20),
            const Text("Order Summary",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];

final isBuyNow = widget.buyNowProduct != null;

final product = isBuyNow
    ? item['product'] as Product
    : Product.fromJson(item['product']); // ✅ Convert Map → Product model

final qty = item['quantity'];
final variant = item['variantName'];

final price = isBuyNow
    ? (widget.selectedVariant?.offerPrice ??
        widget.selectedVariant?.price ??
        widget.buyNowProduct!.offerPrice ??
        widget.buyNowProduct!.basePrice)
        .toDouble()
    : ((item['product']['offerPrice'] ??
        item['product']['basePrice'] ??
        0))
        .toDouble();



                  return ListTile(
  title: Text(product.name),
  subtitle: variant != null ? Text("Variant: $variant") : null,
  trailing: Text("₹${(price * qty).toStringAsFixed(2)} x $qty"),
);
                },
              ),
            ),
            const SizedBox(height: 10),
            const Text("Payment Method",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ListTile(
              leading: const Icon(Icons.payment, color: Colors.blue),
              title: const Text("Razorpay"),
              subtitle: const Text("Pay securely with Razorpay"),
              trailing: const Icon(Icons.check, color: Colors.green),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                "Total: ₹${getTotalAmount(cartProvider).toStringAsFixed(2)}",
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            Builder(builder: (context) {
              final GlobalKey<SlideActionState> key = GlobalKey();
              return _isPlacingOrder
                  ? const Center(child: CircularProgressIndicator())
                  : SlideAction(
  key: key,
  text: "Swipe to Pay Now",
  textStyle: const TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.w600),
  outerColor: Colors.black,
  innerColor: Colors.green,
  sliderButtonIcon:
      const Icon(Icons.arrow_forward_ios, color: Colors.white),
  submittedIcon: const Icon(Icons.check, color: Colors.white),
  height: 60,
  onSubmit: () async {
    await _onSubmit();

    // Reset slide after completion safely
    if (mounted && ModalRoute.of(context)?.isCurrent == true) {
    key.currentState?.reset();
  }
  },
);

            }),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
