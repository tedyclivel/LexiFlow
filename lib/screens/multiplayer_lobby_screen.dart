import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:search_word/providers/multiplayer_provider.dart';
import 'package:search_word/screens/duel_game_screen.dart';
import 'package:search_word/utils/design_system.dart';
import 'package:search_word/widgets/premium_button.dart';
import 'package:search_word/widgets/lexiflow_logo.dart';
import 'package:search_word/utils/haptic_service.dart';
import 'package:search_word/utils/sound_service.dart';
import 'package:search_word/utils/firestore_service.dart';
import 'package:search_word/models/multiplayer_models.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MultiplayerLobbyScreen extends ConsumerStatefulWidget {
  const MultiplayerLobbyScreen({super.key});

  @override
  ConsumerState<MultiplayerLobbyScreen> createState() => _MultiplayerLobbyScreenState();
}

class _MultiplayerLobbyScreenState extends ConsumerState<MultiplayerLobbyScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _displayPlayers = [];
  bool _isLoadingPlayers = false;
  bool _isShowingLeaderboard = false;

  @override
  void initState() {
    super.initState();
    _fetchOnlinePlayers();
  }

  Future<void> _fetchOnlinePlayers() async {
    setState(() => _isLoadingPlayers = true);
    var players = await FirestoreService.getOnlinePlayers();
    
    bool showingLeaderboard = false;
    if (players.isEmpty) {
      // Fallback to top players if no one is online
      players = await FirestoreService.getLeaderboard(limit: 10);
      showingLeaderboard = true;
    }

    setState(() {
      _displayPlayers = players;
      _isLoadingPlayers = false;
      _isShowingLeaderboard = showingLeaderboard;
    });
  }

  void _handleFindMatch() {
    SoundService.playClick();
    ref.read(multiplayerProvider.notifier).findMatch();
  }

  void _handleSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    final player = await FirestoreService.findPlayerByPseudo(query);
    if (player != null) {
      _showInviteDialog(player);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Joueur non trouvé")),
      );
    }
  }

  void _showInviteDialog(Map<String, dynamic> player) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text("DÉFIER", style: GoogleFonts.bungee(color: Colors.white)),
        content: Text("Voulez-vous défier ${player['playerName']} ?", style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("NON")),
          ElevatedButton(
            onPressed: () {
              ref.read(multiplayerProvider.notifier).invitePlayer(player);
              Navigator.pop(context);
            },
            child: const Text("DÉFIER"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final multiState = ref.watch(multiplayerProvider);

    // Listen for match becoming active
    ref.listen(multiplayerProvider, (previous, next) {
      if (next.activeMatch?.status == 'active' && previous?.activeMatch?.status != 'active') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DuelGameScreen(match: next.activeMatch!),
          ),
        );
      }
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LexiColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "MULTIJOUEUR",
                      style: GoogleFonts.bungee(color: Colors.white, fontSize: R.fs(context, 20)),
                    ),
                  ],
                ),
              ),

              // Search Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: (_) => _handleSearch(),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Rechercher par pseudo...",
                      hintStyle: const TextStyle(color: Colors.white38),
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search, color: LexiColors.accentTeal),
                        onPressed: _handleSearch,
                      ),
                    ),
                  ),
                ),
              ).animate().fadeIn().slideY(begin: 0.2, end: 0),

              const SizedBox(height: 32),

              // Online Players Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _isShowingLeaderboard ? "JOUEURS À DÉFIER" : "JOUEURS EN LIGNE", 
                      style: GoogleFonts.bungee(color: Colors.white38, fontSize: 10),
                    ),
                    if (_isLoadingPlayers)
                      const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white24))
                    else
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white38, size: 16),
                        onPressed: _fetchOnlinePlayers,
                      ),
                  ],
                ),
              ),

              Expanded(
                child: _displayPlayers.isEmpty 
                  ? Center(child: Text("Aucun joueur trouvé", style: TextStyle(color: Colors.white24)))
                  : GridView.builder(
                    padding: const EdgeInsets.all(24),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: _displayPlayers.length,
                    itemBuilder: (context, index) {
                      final player = _displayPlayers[index];
                      // Don't show myself
                      if (player['userId'] == FirestoreService.currentUserId) return const SizedBox.shrink();
                      return _buildPlayerCard(player);
                    },
                  ),
              ),

              const Spacer(),

              // Invitation Received UI
              if (multiState.activeMatch?.status == 'invited' && 
                  multiState.activeMatch?.player2Id != multiState.activeMatch?.player1Id) ...[
                _buildInvitationPanel(multiState.activeMatch!),
              ],

              if (multiState.isSearching) ...[
                Center(
                  child: Column(
                    children: [
                      const CircularProgressIndicator(color: LexiColors.accentTeal),
                      const SizedBox(height: 16),
                      Text("Invitation envoyée... en attente", style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerCard(Map<String, dynamic> player) {
    return GestureDetector(
      onTap: () => _showInviteDialog(player),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: LexiColors.primaryBlue,
              backgroundImage: player['avatarUrl'] != null ? NetworkImage(player['avatarUrl']) : null,
              child: player['avatarUrl'] == null ? const Icon(Icons.person, color: Colors.white) : null,
            ),
            const SizedBox(height: 8),
            Text(
              player['playerName'] ?? player['pseudo'] ?? "Inconnu",
              style: TextStyle(color: Colors.white, fontSize: R.fs(context, 10), fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ).animate().scale();
  }

  Widget _buildInvitationPanel(DuelMatch match) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: LexiColors.primaryBlue.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 20)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "INVITATION REÇUE",
            style: GoogleFonts.bungee(color: Colors.white, fontSize: R.fs(context, 16)),
          ),
          const SizedBox(height: 12),
          Text(
            "${match.player1Name} vous défie !",
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: PremiumButton(
                  label: "DÉCLINER",
                  backgroundColor: Colors.white24,
                  onPressed: () => ref.read(multiplayerProvider.notifier).quitMatch(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PremiumButton(
                  label: "ACCEPTER",
                  isPrimary: true,
                  backgroundColor: LexiColors.accentTeal,
                  onPressed: () => ref.read(multiplayerProvider.notifier).acceptInvite(),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().slideY(begin: 1, end: 0);
  }
}
