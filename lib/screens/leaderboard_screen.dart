import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:search_word/utils/design_system.dart';
import 'package:search_word/utils/firestore_service.dart';
import 'package:search_word/widgets/premium_button.dart';
import 'package:search_word/models/leaderboard_models.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<LeaderboardEntry> _eloRankings = [];
  List<LeaderboardEntry> _blitzRankings = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRankings();
  }

  Future<void> _loadRankings() async {
    setState(() => _isLoading = true);
    try {
      final eloData = await FirestoreService.getLeaderboard(field: 'elo');
      final blitzData = await FirestoreService.getLeaderboard(field: 'bestBlitzScore');

      setState(() {
        _eloRankings = eloData.asMap().entries.map((e) => LeaderboardEntry.fromMap(e.value, e.key + 1, 'elo')).toList();
        _blitzRankings = blitzData.asMap().entries.map((e) => LeaderboardEntry.fromMap(e.value, e.key + 1, 'bestBlitzScore')).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LexiColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildTabs(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildRankingList(_eloRankings, "ELO"),
                    _buildRankingList(_blitzRankings, "Score"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          PremiumIconButton(
            icon: Icons.arrow_back_rounded,
            onPressed: () => Navigator.pop(context),
            size: 40,
            backgroundColor: Colors.white10,
            isBackButton: true,
          ),
          const SizedBox(width: 20),
          Text(
            "CLASSEMENT",
            style: LexiTextStyles.display(color: Colors.white, fontSize: R.fs(context, 28)),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      height: 50,
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(25),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: LexiColors.tealGradient,
        ),
        labelStyle: LexiTextStyles.button(fontSize: R.fs(context, 14)),
        unselectedLabelColor: Colors.white60,
        tabs: const [
          Tab(text: "DUELS (ELO)"),
          Tab(text: "BLITZ"),
        ],
      ),
    );
  }

  Widget _buildRankingList(List<LeaderboardEntry> rankings, String unit) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: LexiColors.accentTeal));
    }

    if (rankings.isEmpty) {
      return Center(child: Text("Aucun classement disponible", style: LexiTextStyles.label()));
    }

    return RefreshIndicator(
      onRefresh: _loadRankings,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        itemCount: rankings.length,
        itemBuilder: (context, index) {
          final entry = rankings[index];
          if (index < 3) {
            return _buildPodiumItem(entry, unit);
          }
          return _buildRankingItem(entry, unit);
        },
      ),
    );
  }

  Widget _buildPodiumItem(LeaderboardEntry entry, String unit) {
    final colors = [
      const Color(0xFFFFD700), // Gold
      const Color(0xFFC0C0C0), // Silver
      const Color(0xFFCD7F32), // Bronze
    ];
    final color = colors[entry.rank - 1];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.2), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Row(
        children: [
          _buildRankBadge(entry.rank, color),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.name, style: LexiTextStyles.heading(color: Colors.white, fontSize: R.fs(context, 18))),
                Text(entry.model ?? "Joueur", style: LexiTextStyles.label(fontSize: R.fs(context, 12), color: Colors.white54)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("${entry.score}", style: LexiTextStyles.display(color: color, fontSize: R.fs(context, 24))),
              Text(unit, style: LexiTextStyles.label(fontSize: R.fs(context, 10), color: color)),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: -0.2, end: 0);
  }

  Widget _buildRankingItem(LeaderboardEntry entry, String unit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text("${entry.rank}", style: LexiTextStyles.label(color: Colors.white38)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(entry.name, style: LexiTextStyles.button(color: Colors.white, fontSize: R.fs(context, 15))),
          ),
          Text("${entry.score}", style: LexiTextStyles.heading(color: LexiColors.accentTeal, fontSize: R.fs(context, 16))),
          const SizedBox(width: 4),
          Text(unit, style: LexiTextStyles.label(fontSize: R.fs(context, 8), color: Colors.white38)),
        ],
      ),
    );
  }

  Widget _buildRankBadge(int rank, Color color) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 10)],
      ),
      alignment: Alignment.center,
      child: Text(
        "$rank",
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
      ),
    );
  }
}

