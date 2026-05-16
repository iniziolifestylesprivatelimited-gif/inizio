import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class WatermarkWrapper extends StatelessWidget {
  final Widget child;

  const WatermarkWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Stack(
      children: [
        child,

        if (user != null && user.userId.isNotEmpty)
          IgnorePointer(
            child: Opacity(
              opacity: 0.10, // lighter for better UX
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return GridView.builder(
                    itemCount: 100, // controls density
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // number of columns
                      childAspectRatio: 2.5,
                    ),
                    itemBuilder: (context, index) {
                      return Center(
                        child: Transform.rotate(
                          angle: -0.5,
                          child: Text(
                            user.userId,
                            style: const TextStyle(
                              fontSize: 14, // 👈 SMALL SIZE
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}