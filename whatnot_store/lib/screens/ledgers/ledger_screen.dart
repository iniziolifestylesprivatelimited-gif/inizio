import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ledger_provider.dart';
import '../homescreen/bottomnavigationbar/custom_bottom_navbar.dart';
import '../homescreen/home_screen.dart';
import 'ledger_viewer_screen.dart';

class LedgerScreen extends StatefulWidget {
  const LedgerScreen({super.key});

  @override
  State<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends State<LedgerScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
      Provider.of<LedgerProvider>(context, listen: false)
          .fetchLedgers(context));
  }

  @override
  Widget build(BuildContext context) {
    final ledgerProvider = Provider.of<LedgerProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("My Ledgers", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: ledgerProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ledgerProvider.ledgers.isEmpty
              ? const Center(
                  child: Text("No ledger statements found 📄",
                      style: TextStyle(fontSize: 16)),
                )
              : ListView.builder(
                  itemCount: ledgerProvider.ledgers.length,
                  itemBuilder: (context, index) {
                    final ledger = ledgerProvider.ledgers[index];

                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      elevation: 2,
                      child: ListTile(
                        title: Text(ledger.title),
                        subtitle: Text(
                          "Uploaded: ${ledger.createdAt.split('T')[0]}",
                        ),
                        trailing: const Icon(Icons.picture_as_pdf, color: Colors.red),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  LedgerViewerScreen(pdfUrl: ledger.fileUrl),
                            ),
                          );
                        },
                      ),
                    );
                  },
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
