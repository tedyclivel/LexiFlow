import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:search_word/providers/profile_provider.dart';
import 'package:search_word/utils/design_system.dart';
import 'package:search_word/widgets/premium_button.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

    if (profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LexiColors.backgroundGradient),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                child: PremiumIconButton(
                  icon: Icons.arrow_back_rounded,
                  onPressed: () => Navigator.pop(context),
                  backgroundColor: Colors.white10,
                  isBackButton: true,
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black26, Colors.transparent],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.tealAccent.withOpacity(0.1),
                        backgroundImage: NetworkImage(profile.avatarUrl),
                      ).animate().scale(delay: 200.ms, duration: 600.ms, curve: Curves.easeOutBack),
                      const SizedBox(height: 16),
                      Text(
                        profile.pseudo,
                        style: LexiTextStyles.display(
                          fontSize: 28,
                          color: Colors.white,
                        ),
                      ).animate().fadeIn(delay: 400.ms),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.tealAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.tealAccent.withOpacity(0.3)),
                        ),
                        child: Text(
                          "EXPLORATEUR NIV. 1",
                          style: LexiTextStyles.label(
                            fontSize: 12,
                            color: LexiColors.accentTeal,
                          ),
                        ),
                      ).animate().fadeIn(delay: 600.ms),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Global Stats Row
                    Row(
                      children: [
                        _buildStatCard("SCORE TOTAL", profile.totalScore.toString(), Icons.stars_rounded, Colors.orange),
                        const SizedBox(width: 16),
                        _buildStatCard("MOTS TROUVÉS", profile.totalWordsFound.toString(), Icons.text_snippet_rounded, Colors.teal),
                      ],
                    ).animate().fadeIn(delay: 800.ms).moveY(begin: 20, end: 0),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildStatCard("SERIE ACTUELLE", "${profile.currentStreak} Jours", Icons.local_fire_department_rounded, Colors.redAccent),
                        const SizedBox(width: 16),
                        _buildStatCard("VICTOIRES", profile.gamesWon.toString(), Icons.emoji_events_rounded, Colors.amber),
                      ],
                    ).animate().fadeIn(delay: 1000.ms).moveY(begin: 20, end: 0),
                    const SizedBox(height: 40),
                    Text(
                      "TROPHÉES",
                      style: LexiTextStyles.label(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ).animate().fadeIn(delay: 1200.ms),
                    const SizedBox(height: 20),
                    // Trophies Grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      children: [
                        _buildTrophyItem("word_novice", "Apprenti", Icons.menu_book_rounded, profile.unlockedTrophies.contains('word_novice')),
                        _buildTrophyItem("word_master", "Maître", Icons.auto_stories_rounded, profile.unlockedTrophies.contains('word_master')),
                        _buildTrophyItem("high_scorer", "Champion", Icons.military_tech_rounded, profile.unlockedTrophies.contains('high_scorer')),
                        _buildTrophyItem("diligent", "Assidu", Icons.calendar_month_rounded, profile.unlockedTrophies.contains('diligent')),
                        _buildTrophyItem("winner", "Vainqueur", Icons.workspace_premium_rounded, profile.unlockedTrophies.contains('winner')),
                        _buildTrophyItem("sharer", "Social", Icons.share_rounded, profile.unlockedTrophies.contains('sharer')),
                      ],
                    ).animate().fadeIn(delay: 1400.ms),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 16),
            Text(
              value,
              style: LexiTextStyles.heading(
                fontSize: 22,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: LexiTextStyles.label(
                fontSize: 10,
                color: Colors.white38,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrophyItem(String id, String name, IconData icon, bool isUnlocked) {
    return Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: isUnlocked ? Colors.tealAccent.withOpacity(0.1) : Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
              border: Border.all(
                color: isUnlocked ? Colors.tealAccent.withOpacity(0.5) : Colors.white.withOpacity(0.1),
              ),
            ),
            child: Icon(
              icon,
              color: isUnlocked ? Colors.tealAccent : Colors.white.withOpacity(0.2),
              size: 28,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: LexiTextStyles.label(
            fontSize: 10,
            color: isUnlocked ? Colors.white : Colors.white24,
          ),
        ),
      ],
    );
  }
}
