import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SportBadge extends StatelessWidget {
  final String sport;

  const SportBadge({super.key, required this.sport});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        sport,
        style: GoogleFonts.inter(
          color: Colors.blue,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
