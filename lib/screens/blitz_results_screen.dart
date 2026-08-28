import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:search_word/models/blitz_session.dart';
import 'package:search_word/providers/blitz_provider.dart';
import 'package:search_word/utils/design_system.dart';
import 'package:search_word/widgets/premium_button.dart';

class BlitzResultsScreen extends ConsumerWidget {
  final BlitzSession session;

  const BlitzResultsScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LexiColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              
              // Title
              Text(
                "BLITZ TERMINÉ !",
                textAlign: TextAlign.center,
                style: GoogleFonts.bungee(
                  fontSize: R.fs(context, 32),
                  color: LexiColors.accentOrange,
                  letterSpacing: 2,
                ),
              ).animate().fadeIn().scale(duration: 400.ms, curve: Curves.easeOutBack),
              
              const SizedBox(height: 40),
              
              // Score Card
              _buildScoreCard(context),
              
              const SizedBox(height: 32),
              
              // Stats Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    _buildStatItem(context, "GRILLES", "${session.gridsCompleted}", Icons.grid_view_rounded, LexiColors.accentTeal),
                    const SizedBox(width: 16),
                    _buildStatItem(context, "CHRONO MOY.", "${session.averageTimePerGrid.toStringAsFixed(1)}s", Icons.timer_outlined, Colors.orange),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // History Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "HISTORIQUE DES GRILLES",
                    style: GoogleFonts.bungee(color: Colors.white38, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Results List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: session.gridResults.length,
                  itemBuilder: (context, index) {
                    final result = session.gridResults[index];
                    return _buildResultListItem(context, result).animate(delay: (index * 100).ms).fadeIn().slideX(begin: 0.1);
                  },
                ),
              ),
              
              // Actions
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 60,
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white24, width: 2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: Text("MENU", style: GoogleFonts.bungee(color: Colors.white70)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SizedBox(
                        height: 60,
                        child: ElevatedButton(
                          onPressed: () {
                            ref.read(blitzProvider.notifier).startNewSession();
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: LexiColors.accentTeal,
                            foregroundColor: LexiColors.primaryBlue,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            elevation: 8,
                          ),
                          child: Text("REJOUER", style: GoogleFonts.bungee(fontSize: 16)),
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate(delay: 500.ms).fadeIn(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: LexiColors.accentOrange.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(color: LexiColors.accentOrange.withOpacity(0.1), blurRadius: 30, spreadRadius: -5),
        ],
      ),
      child: Column(
        children: [
          Text(
            "SCORE TOTAL",
            style: GoogleFonts.bungee(color: Colors.white54, fontSize: R.fs(context, 14)),
          ),
          const SizedBox(height: 8),
          Text(
            "${session.totalScore}",
            style: GoogleFonts.bungee(fontSize: R.fs(context, 72), color: Colors.white, height: 1),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).scale(duration: 600.ms, curve: Curves.elasticOut);
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: R.sp(context, 28)),
            const SizedBox(height: 12),
            Text(value, style: GoogleFonts.bungee(color: Colors.white, fontSize: R.fs(context, 24))),
            Text(label, style: GoogleFonts.outfit(color: Colors.white38, fontSize: R.fs(context, 10), fontWeight: FontWeight.w900, letterSpacing: 1)),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2);
  }

  Widget _buildResultListItem(BuildContext context, BlitzGridResult result) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: result.completed ? LexiColors.accentTeal.withOpacity(0.2) : Colors.redAccent.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text("${result.gridIndex + 1}", style: GoogleFonts.bungee(color: result.completed ? LexiColors.accentTeal : Colors.redAccent)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.completed ? "GRID OK" : "TEMPS ÉCOULÉ",
                  style: GoogleFonts.bungee(color: Colors.white, fontSize: R.fs(context, 14)),
                ),
                Text(
                  "${result.wordsFound}/${result.totalWords} MOTS • ${result.timeUsed}S",
                  style: GoogleFonts.outfit(color: Colors.white38, fontSize: R.fs(context, 10), fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Text(
            "+${result.score}",
            style: GoogleFonts.bungee(color: LexiColors.accentTeal, fontSize: R.fs(context, 18)),
          ),
        ],
      ),
    );
  }
}
