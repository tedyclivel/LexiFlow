import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:search_word/providers/daily_challenge_provider.dart';
import 'package:search_word/models/daily_task_model.dart';
import 'package:search_word/utils/design_system.dart';
import 'package:search_word/utils/sound_service.dart';
import 'package:search_word/utils/haptic_service.dart';

class DailyChallengePanel extends ConsumerWidget {
  const DailyChallengePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyState = ref.watch(dailyChallengeProvider);

    if (dailyState.tasks.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "DÉFIS QUOTIDIENS",
                style: GoogleFonts.bungee(color: Colors.white, fontSize: 14, letterSpacing: 1),
              ),
              const Icon(Icons.timer_outlined, color: Colors.white70, size: 16),
            ],
          ),
        ),
        SizedBox(
          height: 120, // Reduced height
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: dailyState.tasks.length,
            itemBuilder: (context, index) {
              return ChallengeCard(task: dailyState.tasks[index])
                .animate()
                .fadeIn(delay: (index * 100).ms)
                .slideX(begin: 0.2, end: 0);
            },
          ),
        ),
      ],
    );
  }
}

class ChallengeCard extends ConsumerWidget {
  final DailyTask task;
  const ChallengeCard({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isCompleted = task.isCompleted;
    final bool isClaimed = task.isClaimed;

    return Container(
      width: 170, // Slightly narrower
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isClaimed ? Colors.black45 : Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted && !isClaimed ? LexiColors.accentTeal : Colors.white10,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            task.title.toUpperCase(),
            style: GoogleFonts.outfit(
              color: isClaimed ? Colors.white24 : Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (!isClaimed) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${task.progress}/${task.target}",
                      style: GoogleFonts.outfit(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.monetization_on, color: Colors.amber, size: 12),
                        const SizedBox(width: 2),
                        Text("${task.rewardCoins}", style: GoogleFonts.outfit(fontSize: 10, color: Colors.amber, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: (task.progress / task.target).clamp(0, 1),
                    backgroundColor: Colors.white12,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isCompleted ? LexiColors.accentTeal : LexiColors.primaryBlue,
                    ),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ] else
            const Center(
              child: Icon(Icons.check_circle_rounded, color: LexiColors.accentTeal, size: 24),
            ),
          
          if (isCompleted && !isClaimed)
            GestureDetector(
              onTap: () {
                SoundService.playReward();
                HapticService.success();
                ref.read(dailyChallengeProvider.notifier).claimReward(task.id);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  gradient: LexiColors.tealGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Text(
                  "RÉCUPÉRER",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 9),
                ),
              ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds),
            ),
        ],
      ),
    );
  }
}
