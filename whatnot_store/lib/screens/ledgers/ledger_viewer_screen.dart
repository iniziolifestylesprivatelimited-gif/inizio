import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../utils/constants.dart';

class LedgerViewerScreen extends StatelessWidget {
  final String pdfUrl;

  const LedgerViewerScreen({super.key, required this.pdfUrl});

  @override
  Widget build(BuildContext context) {
    final fullUrl = pdfUrl.startsWith("http")
        ? pdfUrl
        : "${ApiConstants.imageBaseUrl}$pdfUrl";

    return Scaffold(
      backgroundColor: Colors.white, // ← Entire screen background
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Ledger PDF",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // Force PDF viewer to have white background too
      body: Container(
        color: Colors.white, // ← FORCE PDF background white
        child: SfPdfViewer.network(
          fullUrl,
          canShowScrollHead: true,
          canShowPaginationDialog: true,
        ),
      ),
    );
  }
}
