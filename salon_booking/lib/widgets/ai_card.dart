import 'package:flutter/material.dart';

class AICard extends StatelessWidget {
  final Widget child;
  const AICard({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF121A22),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }
}
