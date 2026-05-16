import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:whatnot_store/screens/payment/ICICIPaymentWebView.dart';
import '../../models/product_model.dart';
import '../../providers/order_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/address_model.dart';
import '../../services/address_service.dart';
import 'package:http/http.dart' as http;
import '../../utils/constants.dart';
import '../address/address_screen.dart';
import '../orders/orders_screen.dart';
import 'address_form.dart';
import 'address_selector.dart';
import 'order_summary.dart';
import 'payment_action_button.dart';
import 'payment_processing_screen.dart';

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
  String selectedMethod = "ONLINE";
  late AddressService _addressService;
  // late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    _addressService = AddressService(token: token);
    _fetchAddresses();

    // _razorpay = Razorpay();
    // _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    // _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    // _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
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


//   void _handlePaymentSuccess(PaymentSuccessResponse response) async {
//   final orderProvider = Provider.of<OrderProvider>(context, listen: false);
//   final token = Provider.of<AuthProvider>(context, listen: false).token;

//   final url = Uri.parse('${ApiConstants.baseUrl}/orders/verify');

//   final res = await http.post(
//     url,
//     headers: {
//       'Content-Type': 'application/json',
//       'Authorization': 'Bearer $token',
//     },
//     body: jsonEncode({
//       "razorpay_order_id": orderProvider.razorpayOrder!['id'],
//       "razorpay_payment_id": response.paymentId,
//       "razorpay_signature": response.signature,
//       "orderId": orderProvider.razorpayOrder!['receipt'],
//     }),
//   );

//   if (!mounted) return;

//   if (res.statusCode == 200) {
//  Navigator.pushReplacement(
//   context,
//   MaterialPageRoute(
//     builder: (_) => const PaymentProcessingScreen(isSuccess: true),
//   ),
// );

// } else {
//   Navigator.pushReplacement(
//   context,
//   MaterialPageRoute(
//     builder: (_) => const PaymentProcessingScreen(isSuccess: false),
//   ),
// );
// } 
// }


//   void _handlePaymentError(PaymentFailureResponse response) {
//   if (!mounted) return;

//   Navigator.pushReplacement(
//     context,
//     MaterialPageRoute(
//       builder: (_) => const PaymentProcessingScreen(isSuccess: false),
//     ),
//   );
// }



//   void _handleExternalWallet(ExternalWalletResponse response) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("External Wallet: ${response.walletName}")),
//     );
//   }

//   void _startRazorpayPayment() {
//     final orderProvider = Provider.of<OrderProvider>(context, listen: false);
//     if (orderProvider.razorpayOrder == null) return;

//     final options = {
//       'key': 'rzp_test_al5RfK3OZWPzeA',
//       'amount': orderProvider.razorpayOrder!['amount'],
//       'order_id': orderProvider.razorpayOrder!['id'],
//       'name': 'My Shop',
//       'description': 'Order Payment',
//       'prefill': {
//         'contact': '9999999999',
//         'email': 'customer@example.com',
//       },
//       'theme': {'color': '#F37254'}
//     };

//     _razorpay.open(options);
//   }

  Future<void> _onSubmit() async {
  if (_selectedAddress == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please select address')),
    );
    return;
  }

  setState(() => _isPlacingOrder = true);

  final cartProvider = Provider.of<CartProvider>(context, listen: false);

  List<Map<String, dynamic>> orderItems;

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

  // 🔥 choose payment method
  // String paymentMethod = selectedMethod;
  String paymentMethod = "COD";

  final response = await orderProvider.placeOrder(
    context,
    orderItems,
    totalAmount,
    _selectedAddress!.id,
    paymentMethod,
  );

  setState(() => _isPlacingOrder = false);

  if (!mounted) return;

  if (response != null) {
    // ✅ COD → directly success
    if (paymentMethod == "COD") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const PaymentProcessingScreen(isSuccess: true),
        ),
      );
    }

    // ✅ ONLINE / PARTIAL → open ICICI URL
    else if (response['paymentUrl'] != null) {
      final url = response['paymentUrl'];

      // 🔥 open in browser or webview
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ICICIPaymentWebView(url: url),
        ),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(orderProvider.error ?? "Order failed")),
    );
  }
}



Future<void> _addNewAddress(Address newAddress) async {
  try {
    final added = await _addressService.addAddress(newAddress);
    setState(() {
      _addresses.add(added);
      _selectedAddress = added;
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Address added successfully")));
  } catch (e) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Failed to add address: $e")));
  }
}


void _openAddAddressForm() {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const AddressScreen()),
  ).then((_) => _fetchAddresses());
}




  @override
  void dispose() {
    // _razorpay.clear();
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Payment"))
        ,
     body: Padding(
  padding: const EdgeInsets.all(16.0),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      AddressSelector(
        addresses: _addresses,
        selectedAddress: _selectedAddress,
        isLoading: _isLoadingAddresses,
        onAddPressed: _openAddAddressForm,
        onChanged: (val) => setState(() => _selectedAddress = val),
      ),

      const SizedBox(height: 20),
      const Text("Order Summary",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),

      OrderSummary(
        items: items,
        isBuyNow: widget.buyNowProduct != null,
        selectedVariant: widget.selectedVariant,
        buyNowProduct: widget.buyNowProduct,
      ),

      const SizedBox(height: 10),
      const Text("Payment Method",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      // ListTile(
      //   leading: const Icon(Icons.payment, color: Colors.blue),
      //   title: const Text("Razorpay"),
      //   subtitle: const Text("Pay securely with Razorpay"),
      //   trailing: const Icon(Icons.check, color: Colors.green),
      // ),
   Column(
  children: [
    // ✅ COD ONLY (ACTIVE)
    ListTile(
      title: const Text("Cash on Delivery"),
      leading: const Icon(Icons.money),
      trailing: const Icon(Icons.check, color: Colors.green),
      onTap: () => setState(() => selectedMethod = "COD"),
    ),

    // ❌ ONLINE PAYMENT (TEMP DISABLED)
    // ListTile(
    //   title: const Text("Online Payment (ICICI)"),
    //   leading: const Icon(Icons.payment),
    //   trailing: selectedMethod == "ONLINE"
    //       ? const Icon(Icons.check, color: Colors.green)
    //       : null,
    //   onTap: () => setState(() => selectedMethod = "ONLINE"),
    // ),

    // ❌ PARTIAL PAYMENT (TEMP DISABLED)
    // ListTile(
    //   title: const Text("Partial Payment (20%)"),
    //   leading: const Icon(Icons.account_balance_wallet),
    //   trailing: selectedMethod == "PARTIAL"
    //       ? const Icon(Icons.check, color: Colors.green)
    //       : null,
    //   onTap: () => setState(() => selectedMethod = "PARTIAL"),
    // ),
  ],
),

      const SizedBox(height: 10),
      Center(
        child: Text(
          "Total: ₹${getTotalAmount(cartProvider).toStringAsFixed(2)}",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),

      const SizedBox(height: 20),
      PaymentActionButton(
        isLoading: _isPlacingOrder,
        onSubmit: _onSubmit,
      ),
      const SizedBox(height: 30),
    ],
  ),
),
    );
  }
}