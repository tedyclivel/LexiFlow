import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:search_word/utils/design_system.dart';
import 'package:search_word/providers/tournament_provider.dart';
import 'package:search_word/models/tournament_models.dart';
import 'package:search_word/widgets/premium_button.dart';

class TournamentScreen extends ConsumerWidget {
  const TournamentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tState = ref.watch(tournamentProvider);
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LexiColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, tState.timeRemaining),
              _buildMyLeagueCard(tState.rankings),
              Expanded(
                child: _buildRankingsList(tState),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Duration remaining) {
    final days = remaining.inDays;
    final hours = remaining.inHours % 24;
    final minutes = remaining.inMinutes % 60;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              PremiumIconButton(
                icon: Icons.arrow_back_rounded,
                onPressed: () => Navigator.pop(context),
                backgroundColor: Colors.white10,
              ),
              const SizedBox(width: 16),
              Text("TOURNOI", style: LexiTextStyles.display(fontSize: 28)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black38,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                const Icon(Icons.timer_outlined, color: Colors.orangeAccent, size: 16),
                const SizedBox(width: 8),
                Text(
                  "${days}j ${hours}h ${minutes}m",
                  style: LexiTextStyles.label(color: Colors.orangeAccent, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyLeagueCard(List<TournamentEntry> rankings) {
    // For demo, assume first entry is the user if we don't have deviceId check here
    final myEntry = rankings.isNotEmpty ? rankings.first : null;
    final league = myEntry?.league ?? LeagueTier.bronze;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: _getLeagueGradient(league),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: _getLeagueColor(league).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        children: [
          _buildLeagueIcon(league),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("VOTRE LIGUE", style: LexiTextStyles.label(color: Colors.white70, fontSize: 12)),
                Text(
                  _getLeagueName(league).toUpperCase(),
                  style: LexiTextStyles.display(fontSize: 24),
                ),
                const SizedBox(height: 4),
                Text(
                  myEntry != null ? "Rang: #${myEntry.rank}" : "Non classé",
                  style: LexiTextStyles.button(fontSize: 14, color: Colors.white),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("${myEntry?.tp ?? 0}", style: LexiTextStyles.display(fontSize: 28)),
              Text("TP", style: LexiTextStyles.label(fontSize: 10)),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildRankingsList(TournamentState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator(color: LexiColors.accentTeal));
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      itemCount: state.rankings.length,
      itemBuilder: (context, index) {
        final entry = state.rankings[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: Text("#${entry.rank}", 
                  style: LexiTextStyles.heading(
                    fontSize: 16, 
                    color: index < 3 ? LexiColors.accentTeal : Colors.white38
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildLeagueMiniIcon(entry.league),
              const SizedBox(width: 12),
              Expanded(
                child: Text(entry.playerName, style: LexiTextStyles.button(fontSize: 16)),
              ),
              Text("${entry.tp}", style: LexiTextStyles.heading(fontSize: 18, color: LexiColors.accentTeal)),
              const SizedBox(width: 4),
              Text("TP", style: LexiTextStyles.label(fontSize: 8, color: Colors.white38)),
            ],
          ),
        ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1, end: 0);
      },
    );
  }

  Color _getLeagueColor(LeagueTier tier) {
    switch (tier) {
      case LeagueTier.bronze: return const Color(0xFFCD7F32);
      case LeagueTier.silver: return const Color(0xFFC0C0C0);
      case LeagueTier.gold: return const Color(0xFFFFD700);
      case LeagueTier.platinum: return const Color(0xFFE5E4E2);
      case LeagueTier.diamond: return const Color(0xFFB9F2FF);
    }
  }

  LinearGradient _getLeagueGradient(LeagueTier tier) {
    final color = _getLeagueColor(tier);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [color, color.withOpacity(0.7)],
    );
  }

  String _getLeagueName(LeagueTier tier) {
    return tier.toString().split('.').last;
  }

  Widget _buildLeagueIcon(LeagueTier tier) {
    IconData icon;
    switch (tier) {
      case LeagueTier.diamond: icon = Icons.diamond_rounded; break;
      case LeagueTier.platinum: icon = Icons.shield_rounded; break;
      case LeagueTier.gold: icon = Icons.military_tech_rounded; break;
      default: icon = Icons.workspace_premium_rounded;
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
      child: Icon(icon, color: Colors.white, size: 32),
    );
  }

  Widget _buildLeagueMiniIcon(LeagueTier tier) {
    return Icon(Icons.shield, color: _getLeagueColor(tier), size: 16);
  }
}
