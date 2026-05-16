import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProductQuantitySelector extends StatefulWidget {
  final int quantity;
  final Function(int) onChanged;
  final int availableStock;

  const ProductQuantitySelector({
    super.key,
    required this.quantity,
    required this.onChanged,
    required this.availableStock,
  });

  @override
  State<ProductQuantitySelector> createState() =>
      _ProductQuantitySelectorState();
}

class _ProductQuantitySelectorState extends State<ProductQuantitySelector>
    with SingleTickerProviderStateMixin {
  static const int minQty = 10;
  

  late TextEditingController _controller;
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(text: widget.quantity.toString());

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    );

    _scaleAnim = Tween<double>(begin: 0.95, end: 1.0)
        .chain(CurveTween(curve: Curves.easeOut))
        .animate(_animController);
  }

  @override
  void didUpdateWidget(covariant ProductQuantitySelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.quantity != widget.quantity) {
      _controller.text = widget.quantity.toString();
      _animController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _animController.dispose();
    super.dispose();
  }

int _validateQuantity(int value) {
  return value.clamp(minQty, widget.availableStock);
}
  void _updateQuantity(int value, {bool haptic = true}) {
    final snapped = _validateQuantity(value);

    if (snapped == widget.quantity) return;

    if (haptic) {
      HapticFeedback.lightImpact();
    }

    widget.onChanged(snapped);
    _controller.text = snapped.toString();
  }

  void _openQuantityPicker() {
    final List<int> values = [];
    for (int i = minQty; i <= widget.availableStock; i++) {
  values.add(i);
}

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            ...values.map(
              (q) => ListTile(
                title: Text(q.toString()),
                onTap: () {
                  HapticFeedback.mediumImpact();
                  Navigator.pop(context);
                  _updateQuantity(q, haptic: false);
                },
              ),
            ),
            const Divider(),
            const ListTile(
              title: Text(
                "Custom quantity",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "QUANTITY",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),

          /// 🔒 SAME CLEAN UI
          Container(
            width: 140,
            height: 40,
            color: Colors.grey.shade200,
            child: Row(
              children: [
                // ➖
                GestureDetector(
                 onTap: widget.quantity > minQty
    ? () => _updateQuantity(widget.quantity - 1)
    : null,
                  child: const SizedBox(
                    width: 34,
                    child: Center(child: Icon(Icons.remove, size: 18)),
                  ),
                ),

                // 🔢 Quantity (tap = dropdown, type = custom)
                Expanded(
                  child: GestureDetector(
                    onTap: _openQuantityPicker,
                    child: ScaleTransition(
                      scale: _scaleAnim,
                      child: TextField(
                        controller: _controller,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        onSubmitted: (value) {
                          final parsed =
                              int.tryParse(value) ?? minQty;
                          _updateQuantity(parsed);
                        },
                      ),
                    ),
                  ),
                ),

                // ➕
                GestureDetector(
                 onTap:
  widget.quantity < widget.availableStock
      ? () => _updateQuantity(widget.quantity + 1)
      : null,
                  child: const SizedBox(
                    width: 34,
                    child: Center(child: Icon(Icons.add, size: 18)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),
          Text(
            "(Stock: ${widget.availableStock}, Min: $minQty)",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
