import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../services/product_service.dart';
import '../../utils/constants.dart';
import '../homescreen/bottomnavigationbar/custom_bottom_navbar.dart';
import '../homescreen/home_screen.dart';
import 'product_bottom_buttons.dart';
import 'product_description.dart';
import 'product_image_slider.dart';
import 'product_price_section.dart';
import 'product_quantity_selector.dart';
import 'product_variant_selector.dart';
import 'widgets/product_extra_details.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});
  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Product product;
  int quantity = 10;
  Variant? selectedVariant;
  int _currentIndex = 0;
  int? selectedSlabQty;

  @override
  void initState() {
    super.initState();
    product = widget.product;
  }

  Future<void> _reloadPage() async {
    try {
      final updatedProduct =
          await ProductService().fetchProductById(product.id);

      setState(() {
        selectedVariant = null;
        quantity = 10;

        product = product.copyWith(
  name: updatedProduct.name,
  images: updatedProduct.images,
  basePrice: updatedProduct.basePrice,
  offerPrice: updatedProduct.offerPrice,
  variants: updatedProduct.variants,
  totalQuantity: updatedProduct.totalQuantity,
  description: updatedProduct.description,
  brandName: updatedProduct.brandName,
  brandId: updatedProduct.brandId,
  banners: updatedProduct.banners,
  details: updatedProduct.details,
  expertNotes: updatedProduct.expertNotes,
  cancellationPolicy: updatedProduct.cancellationPolicy,
  warranty: updatedProduct.warranty,
  sevenDaysReturn: updatedProduct.sevenDaysReturn,
  quantityPricing:
    updatedProduct.quantityPricing,
);

      });
    } catch (e) {
      debugPrint("Product refresh failed: $e");
    }
  }


void _openBetterPriceForm(BuildContext context, int quantity) {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _qtyController = TextEditingController(text: quantity.toString());
  final _priceController = TextEditingController();
  final _descController = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "Request Better Price",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Your Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Phone Number",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _qtyController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Required Quantity",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Expected Price",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Additional Message",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
  width: double.infinity,
  height: 48,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.black, // Button color
      foregroundColor: Colors.white, // Text color
      textStyle: const TextStyle(
        fontFamily: 'Gilroy',
        fontWeight: FontWeight.w600, // SemiBold
        fontSize: 16,
      ),
    ),
    onPressed: () {
      // TODO: Call API here
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Request submitted successfully!"),
        ),
      );
    },
    child: const Text("Submit Request"),
  ),
),

            ],
          ),
        ),
      );
    },
  );
}
  @override
  Widget build(BuildContext context) {
    final List<String> imageUrls = (() {
      if (selectedVariant != null &&
          selectedVariant!.images.isNotEmpty) {
        return selectedVariant!.images;
      } else if (product.variants.isNotEmpty &&
          product.variants.first.images.isNotEmpty) {
        return product.variants.first.images;
      } else {
        return product.images;
      }
    })()
        .map((img) =>
            img.startsWith('http') ? img : '${ApiConstants.imageBaseUrl}/$img')
        .toList();
/// ✅ DEFAULT PRICE
double currentPrice =
    selectedVariant?.offerPrice ??
    selectedVariant?.price ??
    product.offerPrice ??
    product.basePrice;

/// ✅ ORIGINAL PRICE
double originalPrice =
    selectedVariant?.price ??
    product.basePrice;

/// ✅ GET SLAB LIST
final List<QuantityPrice> slabList =
    selectedVariant != null
        ? selectedVariant!.quantityPricing
        : product.quantityPricing;

/// ✅ APPLY SLAB PRICING
if (slabList.isNotEmpty) {

  // SORT BY MIN QUANTITY
  slabList.sort(
    (a, b) => a.minQty.compareTo(b.minQty),
  );

  for (final slab in slabList) {

   if (quantity >= slab.minQty) {

  currentPrice = slab.price;

  selectedSlabQty = slab.minQty;
}
  }
}

/// ✅ FINAL DISPLAY PRICE
final double displayOfferPrice =
    currentPrice;

/// ✅ TOTAL PRICE
final double totalPrice =
    displayOfferPrice * quantity;

    final int availableStock = (() {
      if (selectedVariant != null) return selectedVariant!.quantity;
      if (product.variants.isNotEmpty) return 0;
      return product.totalQuantity ?? 0;
    })();

    final bool isOutOfStock = availableStock <= 0;
    final bool isLowStock = availableStock > 0 && availableStock < 5;

    String stockText;
    if (product.variants.isNotEmpty && selectedVariant == null) {
      stockText = "Select a variant";
    } else if (isOutOfStock) {
      stockText = "Out of Stock";
    } else if (isLowStock) {
      stockText = "Only $availableStock left";
    } else {
      stockText = "In Stock";
    }

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.2),
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: RefreshIndicator(
        onRefresh: _reloadPage,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 90),
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProductImageSlider(imageUrls: imageUrls),
                        const SizedBox(height: 16),

                        // ⭐ BRAND NAME (small grey text)
                        if (product.brandName != null &&
                            product.brandName!.isNotEmpty)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              product.brandName!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                        const SizedBox(height: 4),

                        // ⭐ PRODUCT NAME
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                       /// ✅ PRICE SECTION
ProductPriceSection(
  offerPrice: displayOfferPrice,
  originalPrice: originalPrice,
  quantity: quantity,
  totalPrice: totalPrice,
),

/// ✅ BULK PRICING UI
if (slabList.isNotEmpty)
  Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 10,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const Text(
          "Bulk Pricing",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

       if (slabList.isNotEmpty)
  Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 10,
    ),

    child: SizedBox(
      height: 105,

      child: ListView.separated(
        scrollDirection: Axis.horizontal,

        itemCount: slabList.length,

        separatorBuilder: (_, __) =>
            const SizedBox(width: 12),

        itemBuilder: (context, index) {

          final slab = slabList[index];

          final bool isSelected =
              quantity >= slab.minQty;

          return GestureDetector(

            onTap: () {

              setState(() {

                quantity = slab.minQty;

                selectedSlabQty =
                    slab.minQty;
              });
            },

            child: AnimatedContainer(
              duration:
                  const Duration(milliseconds: 250),

              width: 110,

              padding: const EdgeInsets.all(8),

              decoration: BoxDecoration(

                color: isSelected
                    ? Colors.green.shade50
                    : Colors.white,
                gradient: LinearGradient(
  colors: isSelected
      ? [
          Colors.green.shade50,
          Colors.green.shade100,
        ]
      : [
          Colors.white,
          Colors.white,
        ],
),
                borderRadius:
                    BorderRadius.circular(14),

                border: Border.all(
                  color: isSelected
                      ? Colors.green
                      : Colors.grey.shade300,

                  width: 1.5,
                ),

                boxShadow: [

                  if (isSelected)
                    BoxShadow(
                      color: Colors.green
                          .withOpacity(0.15),

                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                ],
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  /// TOP BADGE
                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.green,
                      
                      borderRadius:
                          BorderRadius.circular(20),
                    ),

                    child: Text(

                      "${slab.minQty}+ Qty",

                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  /// PRICE
                 /// PRICE
Text(
  "₹${slab.price % 1 == 0 
      ? slab.price.toInt() 
      : slab.price.toStringAsFixed(2)}",

  style: const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 4),

/// SAVINGS
Text(
  "Save ₹${(originalPrice - slab.price).toStringAsFixed(0)}",

  style: const TextStyle(
    color: Colors.green,
    fontSize: 10,
    fontWeight: FontWeight.w600,
  ),
),

const SizedBox(height: 2),

/// LABEL
Text(
  "per unit",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  ),
      ],
    ),
  ),

                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            stockText,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isOutOfStock
                                  ? Colors.red
                                  : isLowStock
                                      ? Colors.orange
                                      : Colors.green,
                            ),
                          ),
                        ),

                        const Divider(),

                        ProductVariantSelector(
                          variants: product.variants,
                          selectedVariant: selectedVariant,
                          onSelect: (v) {
                            setState(() {
                              selectedVariant = v;
                              quantity = 10;
                            });
                          },
                        ),

                        // const Divider(),

                       Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      ProductQuantitySelector(
        quantity: quantity,
        availableStock: availableStock,
        onChanged: (val) {
          setState(() {
            quantity = val;
          });
        },
      ),

      // 🔥 Show only when quantity >= 1000
      if (quantity >= 1000) ...[
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              _openBetterPriceForm(context, quantity);
            },
            child: const Text(
              "Request for a Better Price",
              style: TextStyle(color: Colors.black),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: Colors.black),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    ],
  ),
),


                        // const Divider(),
                        const SizedBox(height: 16),
                        ProductDescription(product: product),
                        const Divider(),
ProductExtraDetails(product: product,selectedVariant: selectedVariant,),


                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // ⭐ Sticky bottom buttons
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 5),
                    // color: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: ProductBottomButtons(
                      product: product,
                      quantity: quantity,
                      selectedVariant: selectedVariant,
                      isOutOfStock: isOutOfStock,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: CustomBottomNavBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    HomeScreen(initialIndex: index),
              ),
              (route) => false,
            );
          },
        ),
      ),
    );
  }
}
