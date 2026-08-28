import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:search_word/providers/economy_provider.dart';
import 'package:search_word/utils/sound_service.dart';
import 'package:search_word/utils/design_system.dart';
import 'package:search_word/widgets/premium_button.dart';

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eco = ref.watch(economyProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LexiColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, eco),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(context, "INDICES"),
                      const SizedBox(height: 16),
                      _buildShopItem(
                        context,
                        "Pack de 5 Indices",
                        "Ne restez plus bloqué",
                        "50",
                        Icons.lightbulb_outline,
                        Colors.amber,
                        () async {
                          final success = await ref.read(economyProvider.notifier).spendCoins(50);
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Achat réussi : +5 Indices", style: GoogleFonts.outfit())),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Pièces insuffisantes !", style: GoogleFonts.outfit()), backgroundColor: Colors.redAccent),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildShopItem(
                        context,
                        "Pack de 20 Indices",
                        "Maîtrisez tous les niveaux",
                        "150",
                        Icons.tips_and_updates,
                        Colors.orange,
                        () async {
                          final success = await ref.read(economyProvider.notifier).spendCoins(150);
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Achat réussi : +20 Indices", style: GoogleFonts.outfit())),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Pièces insuffisantes !", style: GoogleFonts.outfit()), backgroundColor: Colors.redAccent),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 32),
                      _buildSectionTitle(context, "MONNAIE"),
                      const SizedBox(height: 16),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: R.gridCols(context, mobile: 2, tablet: 3),
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.8,
                        children: [
                          _buildPackCard("Petit Sac", "500 Pièces", "0.99 €", Icons.savings, Colors.teal),
                          _buildPackCard("Coffre Fort", "2000 Pièces", "2.99 €", Icons.inventory_2, Colors.indigo),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, dynamic eco) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              PremiumIconButton(
                icon: Icons.arrow_back_rounded,
                onPressed: () => Navigator.pop(context),
                backgroundColor: Colors.white10,
                isBackButton: true,
              ),
              const SizedBox(width: 16),
              Text("BOUTIQUE", style: LexiTextStyles.display(fontSize: R.fs(context, 28))),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildCurrencyBadge(context, eco.coins, Icons.monetization_on, Colors.amber),
              const SizedBox(width: 12),
              _buildCurrencyBadge(context, eco.gems, Icons.diamond, Colors.cyan),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyBadge(BuildContext context, int count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: R.sp(context, 18)),
          const SizedBox(width: 8),
          Text(
            "$count",
            style: LexiTextStyles.button(fontSize: R.fs(context, 16), color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        title,
        style: LexiTextStyles.label(
          fontSize: R.fs(context, 14),
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildShopItem(
    BuildContext context,
    String title,
    String desc,
    String price,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: InkWell(
        onTap: () {
          SoundService.playClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: LexiTextStyles.button(fontSize: R.fs(context, 18)),
                    ),
                    Text(
                      desc,
                      style: LexiTextStyles.label(fontSize: R.fs(context, 12), color: Colors.white38),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: LexiColors.accentTeal,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.monetization_on, color: Colors.amber, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      price,
                      style: LexiTextStyles.button(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPackCard(String name, String qty, String price, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 48),
          const SizedBox(height: 16),
          Text(name, style: LexiTextStyles.label(fontSize: 12, color: Colors.white38)),
          Text(qty, style: LexiTextStyles.heading(fontSize: 20)),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: PremiumButton(
              label: price,
              backgroundColor: color,
              height: 48,
              onPressed: () {
                // TODO: IAP integration
              },
            ),
          ),
        ],
      ),
    );
  }
}
