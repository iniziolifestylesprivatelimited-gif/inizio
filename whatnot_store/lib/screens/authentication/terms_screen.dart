import 'package:flutter/material.dart';

import '../../models/terms_model.dart';
import '../../services/terms_service.dart';



class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  TermsModel? terms;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadTerms();
  }

  Future<void> loadTerms() async {
    final data = await TermsService.fetchTerms();
    setState(() {
      terms = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
  title: const Text(
    "Terms & Conditions",
    style: TextStyle(color: Colors.white), // ✅ Make title white
  ),
  backgroundColor: Colors.black,
  iconTheme: const IconThemeData(color: Colors.white), // ✅ Make back arrow white
),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : terms == null
              ? const Center(child: Text("Failed to load Terms & Conditions"))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    terms!.content,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                ),
    );
  }
}
