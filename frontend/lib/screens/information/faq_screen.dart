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
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      child: ExpansionTile(
                        title: Text(
                          faq.question,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        childrenPadding: const EdgeInsets.all(16),
                        children: [
                          Text(
                            faq.answer,
                            style: const TextStyle(fontSize: 15, height: 1.4),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
