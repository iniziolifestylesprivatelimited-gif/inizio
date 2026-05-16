import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AutoReloadImage extends StatefulWidget {
  final String url;
  const AutoReloadImage({super.key, required this.url});

  @override
  State<AutoReloadImage> createState() => _AutoReloadImageState();
}

class _AutoReloadImageState extends State<AutoReloadImage> {
  int retry = 0;

  @override
  Widget build(BuildContext context) {
    // Add cache-buster to force reload: ?retry=1
    final finalUrl = "${widget.url}?retry=$retry";

    return Image.network(
      finalUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      loadingBuilder: (context, child, event) {
        if (event == null) return child;
        return const Center(child: CircularProgressIndicator());
      },
      errorBuilder: (context, error, stackTrace) {
        // Retry after 500ms
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() => retry++);
          }
        });

        return const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      },
    );
  }
}
