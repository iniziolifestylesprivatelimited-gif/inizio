import 'package:flutter/material.dart';
import '../../models/faq_model.dart';
import '../../services/faq_service.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  List<FaqModel> faqs = [];
  bool loading = true;

  // Track expanded tile index
  int expandedIndex = -1;

  @override
  void initState() {
    super.initState();
    loadFaqs();
  }

  Future<void> loadFaqs() async {
    final data = await FaqService.fetchFaqs();
    setState(() {
      faqs = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "FAQs",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : faqs.isEmpty
              ? const Center(child: Text("No FAQs available"))
              : ListView.builder(
                  itemCount: faqs.length,
                  itemBuilder: (context, index) {
                    final faq = faqs[index];

                    final isExpanded = expandedIndex == index;

                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Colors.black12), // thin border
                      ),
                      elevation: 0,
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          dividerColor: Colors.transparent, // REMOVE BLACK LINE
                        ),
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),

                          // 🔥 Custom + and – icon
                          trailing: Icon(
                            isExpanded ? Icons.remove : Icons.add,
                            color: Colors.black,
                            size: 28,
                          ),

                          title: Text(
                            faq.question,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),

                          onExpansionChanged: (expanded) {
                            setState(() {
                              expandedIndex = expanded ? index : -1;
                            });
                          },

                          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          children: [
                            Text(
                              faq.answer,
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.4,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
