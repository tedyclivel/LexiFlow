import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:search_word/screens/world_selection_screen.dart';
import 'package:search_word/screens/profile_screen.dart';
import 'package:search_word/screens/leaderboard_screen.dart';
import 'package:search_word/screens/tournament_screen.dart';
import 'package:search_word/screens/shop_screen.dart';
import 'package:search_word/screens/settings_screen.dart';
import 'package:search_word/providers/economy_provider.dart';
import 'package:search_word/providers/multiplayer_provider.dart';
import 'package:search_word/providers/reward_provider.dart';
import 'package:search_word/utils/sound_service.dart';
import 'package:search_word/widgets/lexiflow_text_logo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:search_word/utils/design_system.dart';
import 'package:search_word/widgets/premium_button.dart';
import 'package:search_word/screens/play_hub_screen.dart';
import 'package:search_word/screens/explorer_hub_screen.dart';
import 'package:search_word/screens/profile_hub_screen.dart';
import 'package:search_word/widgets/daily_challenge_panel.dart';
import 'package:search_word/screens/blitz_mode_screen.dart';
import 'package:search_word/screens/multiplayer_lobby_screen.dart';
import 'package:search_word/screens/game_screen.dart';
import 'package:search_word/screens/duel_game_screen.dart';
import 'package:search_word/models/level_model.dart';
import 'package:search_word/models/multiplayer_models.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:search_word/widgets/game_background.dart';
import 'package:search_word/widgets/currency_bar.dart';
import 'package:search_word/utils/firebase_state.dart';

class MainMenuScreen extends ConsumerStatefulWidget {
  const MainMenuScreen({super.key});

  @override
  ConsumerState<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends ConsumerState<MainMenuScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameBackground(
        child: SafeArea(
          child: Consumer(
            builder: (context, ref, child) {
              _listenForInvites(context, ref);
              final eco = ref.watch(economyProvider);
              return Column(
                children: [
                  // Top Bar (Currency & Settings)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: R.sp(context, 20),
                      vertical: R.sp(context, 14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const CurrencyBar(),
                        PremiumIconButton(
                          icon: Icons.settings_rounded,
                          backgroundColor: Colors.white10,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SettingsScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),
                  LexiFlowTextLogo(
                    fontSize: R.fs(context, 48),
                  ), // Reduced from 60
                  const SizedBox(height: 8),
                  Text(
                    "DÉFIE TES LIMITES",
                    style: LexiTextStyles.label(
                      color: Colors.white70,
                      fontSize: R.fs(context, 13),
                    ),
                  ).animate().fadeIn(delay: 400.ms),
                  const Spacer(),

                  // 3 SECTIONS LAYOUT
                  Expanded(
                    flex: 6, // Increased flex to give buttons more priority
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: R.sp(context, 20),
                        vertical: R.sp(context, 4),
                      ),
                      child: Column(
                        children: [
                          _MainHubButton(
                            label: "JOUER",
                            subtitle: "Solo, Multi & Défis",
                            icon: Icons.sports_esports_outlined,
                            color: LexiColors.accentTeal,
                            onPressed: () {
                              SoundService.playNavigation();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const PlayHubScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          _MainHubButton(
                            label: "EXPLORER",
                            subtitle: "Modes & Boutique",
                            icon: Icons.explore_outlined,
                            color: LexiColors.accentOrange,
                            onPressed: () {
                              SoundService.playNavigation();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ExplorerHubScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          _MainHubButton(
                            label: "PROFIL",
                            subtitle: "Stats & Paramètres",
                            icon: Icons.account_circle_outlined,
                            color: LexiColors.primaryBlue,
                            onPressed: () {
                              SoundService.playNavigation();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ProfileHubScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),

                  // FOOTER
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      "v1.2.0 - LexiFlow Studio",
                      style: GoogleFonts.outfit(
                        color: Colors.white24,
                        fontSize: 10,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _listenForInvites(BuildContext context, WidgetRef ref) {
    if (!firebaseReady) return;
    ref.listen(multiplayerProvider, (previous, next) {
      // Only show if transitioning to 'invited' and we are not in an active match
      if (next.activeMatch?.status == 'invited' &&
          next.activeMatch?.player2Id ==
              FirebaseAuth.instance.currentUser?.uid &&
          previous?.activeMatch?.id != next.activeMatch?.id) {
        // Don't show if we are already in a duel or if the status changed for the same match
        _showInvitePanel(context, ref, next.activeMatch!);
      }

      if (next.activeMatch?.status == 'active' &&
          previous?.activeMatch?.status != 'active') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DuelGameScreen(match: next.activeMatch!),
          ),
        );
      }
    });
  }

  void _showInvitePanel(BuildContext context, WidgetRef ref, DuelMatch match) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: LexiColors.primaryBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          "DÉFI REÇU !",
          style: GoogleFonts.bungee(color: Colors.white),
        ),
        content: Text(
          "${match.player1Name} vous défie en duel !",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(multiplayerProvider.notifier).quitMatch();
              Navigator.pop(context);
            },
            child: const Text(
              "DÉCLINER",
              style: TextStyle(color: Colors.white38),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: LexiColors.accentTeal,
            ),
            onPressed: () {
              ref.read(multiplayerProvider.notifier).acceptInvite();
              Navigator.pop(context);
            },
            child: const Text(
              "ACCEPTER",
              style: TextStyle(
                color: LexiColors.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white38, size: R.sp(context, 18)),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.bungee(
            color: Colors.white38,
            fontSize: R.fs(context, 14),
            letterSpacing: 2,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Divider(color: Colors.white10)),
      ],
    ).animate().fadeIn(duration: 400.ms).moveX(begin: -20, end: 0);
  }

  Widget _buildMenuRow(List<Widget> children) {
    return Row(
      children: children
          .expand(
            (widget) => [
              Expanded(child: widget),
              if (widget != children.last) const SizedBox(width: 12),
            ],
          )
          .toList(),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildCurrencyChip(
    BuildContext context,
    int amount,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: R.sp(context, 12),
        vertical: R.sp(context, 6),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: R.sp(context, 18)),
          SizedBox(width: R.sp(context, 6)),
          Text(
            amount.toString(),
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: R.fs(context, 16),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            "PARAMÈTRES",
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSettingRow(
                "Musique",
                SoundService.musicEnabled,
                (val) async {
                  await SoundService.toggleMusic();
                  setDialogState(() {});
                },
                SoundService.musicVolume,
                (val) async {
                  await SoundService.setMusicVolume(val);
                  setDialogState(() {});
                },
                Icons.music_note,
              ),
              const SizedBox(height: 20),
              _buildSettingRow(
                "Effets Sonores",
                SoundService.sfxEnabled,
                (val) async {
                  await SoundService.toggleSfx();
                  setDialogState(() {});
                },
                SoundService.sfxVolume,
                (val) async {
                  await SoundService.setSfxVolume(val);
                  setDialogState(() {});
                },
                Icons.volume_up,
              ),
            ],
          ),
          actions: [
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text(
                "FERMER",
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingRow(
    String title,
    bool enabled,
    Function(bool) onToggle,
    double volume,
    Function(double) onVolumeChange,
    IconData icon,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: const Color(0xFF1E3A8A),
                  size: R.sp(context, 20),
                ),
                SizedBox(width: R.sp(context, 12)),
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: R.fs(context, 16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Switch(
              value: enabled,
              onChanged: onToggle,
              activeColor: Colors.tealAccent,
            ),
          ],
        ),
        if (enabled)
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF1E3A8A),
              thumbColor: const Color(0xFF1E3A8A),
              overlayColor: const Color(0xFF1E3A8A).withOpacity(0.1),
            ),
            child: Slider(value: volume, onChanged: onVolumeChange),
          ),
      ],
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;

  const _MenuButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Colors.white.withOpacity(0.08);
    final isCustomColor = color != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          SoundService.playClick();
          onPressed();
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          decoration: BoxDecoration(
            color: isCustomColor
                ? effectiveColor.withOpacity(0.2)
                : effectiveColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isCustomColor
                  ? effectiveColor.withOpacity(0.5)
                  : Colors.white.withOpacity(0.1),
              width: 2,
            ),
            boxShadow: [
              if (isCustomColor)
                BoxShadow(
                  color: effectiveColor.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isCustomColor ? effectiveColor : Colors.white,
                size: 28,
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.bungee(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}

class _MainHubButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _MainHubButton({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child:
          Container(
                height: R.sp(context, 100), // Reduced from 120
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.35), color.withOpacity(0.1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: color.withOpacity(0.3), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: -5,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Decorative Icon in background
                    Positioned(
                      right: -20,
                      bottom: -20,
                      child: Icon(
                        icon,
                        size: R.sp(context, 120),
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Icon(
                              icon,
                              color: color,
                              size: R.sp(context, 32),
                            ),
                          ),
                          SizedBox(width: R.sp(context, 20)),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  label,
                                  style: GoogleFonts.bungee(
                                    fontSize: R.fs(
                                      context,
                                      22,
                                    ), // Reduced from 26
                                    color: Colors.white,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                Text(
                                  subtitle,
                                  style: TextStyle(
                                    color: Colors.white60,
                                    fontSize: R.fs(
                                      context,
                                      12,
                                    ), // Reduced from 14
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.white24,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(duration: 500.ms)
              .slideX(begin: 0.1, curve: Curves.easeOutBack),
    );
  }
}
