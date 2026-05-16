import 'package:flutter/material.dart';

class SortFilterBottomSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onApply;
  final double maxPrice;

  const SortFilterBottomSheet({
    super.key,
    required this.onApply,
    required this.maxPrice,
  });

  @override
  State<SortFilterBottomSheet> createState() =>
      _SortFilterBottomSheetState();
}

class _SortFilterBottomSheetState extends State<SortFilterBottomSheet> {
  String selectedSort = "none";
  late RangeValues priceRange;

  int selectedTab = 0;


@override
void initState() {
  super.initState();
  priceRange = RangeValues(0, widget.maxPrice);
}
  /// 🔹 LEFT TAB
Widget _buildTab(String title, int index) {
  final isSelected = selectedTab == index;

  return GestureDetector(
    onTap: () => setState(() => selectedTab = index),
    child: Container(
      width: double.infinity,
      height: 80, // 🔥 INCREASE HEIGHT (was padding before)
      alignment: Alignment.center,
      color: isSelected ? Colors.white : Colors.grey.shade200,
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14, // 🔥 slightly bigger text
          color: isSelected ? Colors.black : Colors.grey,
        ),
      ),
    ),
  );
}

  /// 🔹 SORT GRID
Widget _buildSortOptions() {
  return GridView.count(
    crossAxisCount: 2,
    crossAxisSpacing: 12,
    mainAxisSpacing: 12,
    childAspectRatio: 1.4, // 🔥 LOWER = MORE HEIGHT (was 2.5)
    children: [
      _sortBox("Price - high to low", "high-low"),
      _sortBox("Price - low to high", "low-high"),
      _sortBox("Newest first", "newest"),
      _sortBox("Discount", "discount"),
    ],
  );
}

  /// 🔹 SORT BOX
Widget _sortBox(String title, String value) {
  final isSelected = selectedSort == value;

  return GestureDetector(
    onTap: () => setState(() => selectedSort = value),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 2), // 🔥 MORE HEIGHT
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? Colors.black : Colors.grey.shade300,
          width: 1.2,
        ),
        color: isSelected ? Colors.black : Colors.white, // 🔥 better UI
      ),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: isSelected ? Colors.white : Colors.black, // 🔥 contrast
        ),
      ),
    ),
  );
}
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: Column(
        children: [
          /// 🔹 HANDLE
          Container(
            width: 40,
            height: 5,
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
            ),
          ),

          const Text(
            "Filter",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          /// 🔹 MAIN CONTENT
          Expanded(
            child: Row(
              children: [
                /// LEFT MENU
                Container(
                  width: 130,
                  color: Colors.grey.shade100,
                  child: Column(
                    children: [
                      _buildTab("Sort by", 0),
                      _buildTab("Category", 1),
                      _buildTab("Brands", 2),
                    ],
                  ),
                ),

                /// RIGHT CONTENT
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: selectedTab == 0
                        ? _buildSortOptions()
                        : const Center(child: Text("Coming Soon")),
                  ),
                ),
              ],
            ),
          ),

          /// 🔹 PRICE SECTION
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const Text(
                  "Price",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                /// 🔥 BLACK RANGE SLIDER
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.black,
                    inactiveTrackColor: Colors.grey.shade300,
                    thumbColor: Colors.black,
                    overlayColor: Colors.black.withOpacity(0.1),
                    trackHeight: 3,
                  ),
                  child: RangeSlider(
                    values: priceRange,
                    min: 0,
                    max: widget.maxPrice,
                    divisions: 40,
                    labels: RangeLabels(
                      "₹${priceRange.start.round()}",
                      "₹${priceRange.end.round()}",
                    ),
                    onChanged: (values) {
                      setState(() => priceRange = values);
                    },
                  ),
                ),
              ],
            ),
          ),

          /// 🔹 BUTTONS
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// RESET (BLACK)
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.35,
                  height: 55,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.black,
                      side: const BorderSide(color: Colors.black),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        selectedSort = "none";
                        priceRange = const RangeValues(0, 20000);
                      });
                    },
                    child: const Text(
                      "Reset",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                /// APPLY (WHITE)
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.35,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      side: const BorderSide(color: Colors.black),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onPressed: () {
                      widget.onApply({
                        "sort": selectedSort,
                        "minPrice": priceRange.start,
                        "maxPrice": priceRange.end,
                      });
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Apply",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}