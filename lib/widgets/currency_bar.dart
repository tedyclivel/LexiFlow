import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:search_word/providers/economy_provider.dart';

class CurrencyBar extends ConsumerWidget {
  const CurrencyBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eco = ref.watch(economyProvider);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCurrencyChip(context, eco.coins, Icons.monetization_on, Colors.amber),
        const SizedBox(width: 8),
        _buildCurrencyChip(context, eco.gems, Icons.diamond, Colors.cyan),
      ],
    );
  }

  Widget _buildCurrencyChip(BuildContext context, int amount, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Text(
            amount.toString(),
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
