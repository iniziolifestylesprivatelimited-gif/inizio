import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ICICIPaymentWebView extends StatefulWidget {
  final String url;

  const ICICIPaymentWebView({super.key, required this.url});

  @override
  State<ICICIPaymentWebView> createState() => _ICICIPaymentWebViewState();
}

class _ICICIPaymentWebViewState extends State<ICICIPaymentWebView> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Payment')),
      body: WebViewWidget(controller: controller),
    );
  }
}