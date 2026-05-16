import 'package:flutter/material.dart';

class RetryImage extends StatefulWidget {
  final String url;
  final int retries;
  final BoxFit fit;
  final double? width;
  final double? height;

  const RetryImage({
    super.key,
    required this.url,
    this.retries = 5,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  @override
  State<RetryImage> createState() => _RetryImageState();
}

class _RetryImageState extends State<RetryImage> {
  int attempt = 0;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      "${widget.url}?retry=$attempt", // 👈 add param to force fresh request
      key: ValueKey(attempt), // 👈 force Image widget to rebuild
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: Colors.grey.shade200,
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        if (attempt < widget.retries) {
          attempt++;

          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) setState(() {});
          });

          return Container(
            color: Colors.grey.shade200,
            child: const Center(
              child: Text("Retrying...", style: TextStyle(fontSize: 10)),
            ),
          );
        }

        return Container(
          color: Colors.grey.shade300,
          child: const Icon(Icons.image_not_supported, size: 30),
        );
      },
    );
  }
}
