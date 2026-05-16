import 'package:flutter/material.dart';
import '../../models/privacy_model.dart';
import '../../services/privacy_service.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  PrivacyModel? privacy;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadPrivacy();
  }

  Future<void> loadPrivacy() async {
    final data = await PrivacyService.fetchPrivacy();
    setState(() {
      privacy = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Privacy Policy",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : privacy == null
              ? const Center(child: Text("Failed to load Privacy Policy"))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    privacy!.content,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                ),
    );
  }
}
