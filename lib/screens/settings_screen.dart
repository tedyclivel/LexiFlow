import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:search_word/utils/sound_service.dart';
import 'package:search_word/utils/design_system.dart';
import 'package:search_word/widgets/premium_button.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LexiColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  children: [
                    _buildSectionHeader("AUDIO"),
                    _buildSliderSetting(
                      context,
                      "Musique", 
                      SoundService.musicVolume, 
                      (val) => SoundService.setMusicVolume(val),
                      Icons.music_note_rounded,
                    ),
                    _buildSliderSetting(
                      context,
                      "Effets Sonores", 
                      SoundService.sfxVolume, 
                      (val) => SoundService.setSfxVolume(val),
                      Icons.volume_up_rounded,
                    ),
                    
                    const SizedBox(height: 32),
                    _buildSectionHeader("AFFICHAGE"),
                    _buildListTileSetting(
                      context,
                      "Taille des lettres",
                      "Moyenne (Par défaut)",
                      Icons.format_size_rounded,
                      () {
                        // TODO: Implement letter size picker
                      },
                    ),
                    _buildSwitchSetting(
                      context,
                      "Mode Sombre",
                      false,
                      (val) {
                        // TODO: Implement theme switching
                      },
                      Icons.dark_mode_rounded,
                    ),
                    _buildListTileSetting(
                      context,
                      "Couleur de sélection",
                      "Sarcelle (Teal)",
                      Icons.palette_rounded,
                      () {
                        // TODO: Implement color picker
                      },
                    ),

                    const SizedBox(height: 32),
                    _buildSectionHeader("LANGUE"),
                    _buildListTileSetting(
                      context,
                      "Langue du jeu",
                      "Français",
                      Icons.language_rounded,
                      () {
                        // TODO: Implement language selector
                      },
                    ),

                    const SizedBox(height: 32),
                    _buildSectionHeader("GÉNÉRAL"),
                    _buildListTileSetting(
                      context,
                      "Réinitialiser progression",
                      "Action irréversible",
                      Icons.refresh_rounded,
                      () {
                        _showResetConfirmation(context);
                      },
                      isDestructive: true,
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          PremiumIconButton(
            icon: Icons.arrow_back_rounded,
            onPressed: () => Navigator.pop(context),
            backgroundColor: Colors.white10,
            isBackButton: true,
          ),
          const SizedBox(width: 16),
          Text("PARAMÈTRES", style: LexiTextStyles.display(fontSize: R.fs(context, 28))),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 16),
      child: Text(
        title,
        style: LexiTextStyles.label(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildSliderSetting(BuildContext context, String title, double value, Function(double) onChanged, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white70, size: R.sp(context, 20)),
              const SizedBox(width: 12),
              Text(title, style: LexiTextStyles.button(fontSize: R.fs(context, 16))),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: LexiColors.accentTeal,
              inactiveTrackColor: Colors.white10,
              thumbColor: Colors.white,
              overlayColor: LexiColors.accentTeal.withOpacity(0.2),
            ),
            child: Slider(
              value: value,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchSetting(BuildContext context, String title, bool value, Function(bool) onChanged, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        leading: Icon(icon, color: Colors.white70, size: R.sp(context, 24)),
        title: Text(title, style: LexiTextStyles.button(fontSize: R.fs(context, 16))),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: LexiColors.accentTeal,
          activeTrackColor: LexiColors.accentTeal.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildListTileSetting(BuildContext context, String title, String subtitle, IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        leading: Icon(icon, color: isDestructive ? Colors.redAccent : Colors.white70),
        title: Text(
          title, 
          style: LexiTextStyles.button(
            fontSize: R.fs(context, 16), 
            color: isDestructive ? Colors.redAccent : Colors.white,
          )
        ),
        subtitle: Text(subtitle, style: LexiTextStyles.label(fontSize: R.fs(context, 10), color: Colors.white38)),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white24),
        onTap: () {
          SoundService.playClick();
          onTap();
        },
      ),
    );
  }

  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("CRITICAL", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.redAccent)),
        content: Text("Voulez-vous vraiment réinitialiser toute votre progression ? Cette action est définitive."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("ANNULER", style: GoogleFonts.outfit(color: const Color(0xFF64748B))),
          ),
          FilledButton(
            onPressed: () {
              // TODO: Reset logic
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: Text("RÉINITIALISER", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
