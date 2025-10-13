import 'package:flutter/material.dart';
import 'package:stampede/core/design_constants.dart';

class SportBadge extends StatelessWidget {
  final String? sport;

  const SportBadge({Key? key, this.sport}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (sport == null || sport == 'General') {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: DesignConstants.getSportColor(sport!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        sport!,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
