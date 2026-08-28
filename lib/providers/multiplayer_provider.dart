import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:search_word/models/multiplayer_models.dart';
import 'package:search_word/providers/profile_provider.dart';
import 'package:search_word/providers/daily_challenge_provider.dart';
import 'package:search_word/providers/tournament_provider.dart';
import 'package:search_word/utils/firestore_service.dart';
import 'package:search_word/models/daily_task_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MultiplayerState {
  final List<MultiplayerPlayer> queue;
  final DuelMatch? activeMatch;
  final bool isSearching;
  final String? error;

  MultiplayerState({
    this.queue = const [],
    this.activeMatch,
    this.isSearching = false,
    this.error,
  });

  MultiplayerState copyWith({
    List<MultiplayerPlayer>? queue,
    DuelMatch? activeMatch,
    bool? isSearching,
    String? error,
  }) {
    return MultiplayerState(
      queue: queue ?? this.queue,
      activeMatch: activeMatch ?? this.activeMatch,
      isSearching: isSearching ?? this.isSearching,
      error: error ?? this.error,
    );
  }
}

class MultiplayerNotifier extends StateNotifier<MultiplayerState> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Ref _ref;
  StreamSubscription? _matchSubscription;
  StreamSubscription? _queueSubscription;
  StreamSubscription? _inviteSubscription;

  MultiplayerNotifier(this._ref) : super(MultiplayerState()) {
    _initQueueSubscription();
    final myUid = FirebaseAuth.instance.currentUser?.uid;
    if (myUid != null) _listenForIncomingInvites(myUid);
  }

  void _initQueueSubscription() {
    _queueSubscription = _db.collection('multiplayer_queue')
        .orderBy('timestamp', descending: true)
        .limit(10)
        .snapshots()
        .listen((snapshot) {
      final players = snapshot.docs.map((doc) => MultiplayerPlayer.fromJson({
        'userId': doc.id,
        ...doc.data(),
      })).toList();
      state = state.copyWith(queue: players);
    });
  }

  Future<void> findMatch() async {
    final profile = _ref.read(profileProvider);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (profile == null || uid == null) return;

    state = state.copyWith(isSearching: true, error: null);

    try {
      // 1. Join queue
      await _db.collection('multiplayer_queue').doc(uid).set({
        'pseudo': profile.pseudo,
        'avatarUrl': profile.avatarUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 2. Listen for a match where I am player2
      _matchSubscription?.cancel();
      _matchSubscription = _db.collection('matches')
          .where('player2Id', isEqualTo: uid)
          .where('status', isEqualTo: 'invited')
          .snapshots()
          .listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final matchDoc = snapshot.docs.first;
          _listenToMatch(matchDoc.id);
        }
      });

      // 3. Try to find someone else in queue to be player1
      final otherPlayers = await _db.collection('multiplayer_queue')
          .where(FieldPath.documentId, isNotEqualTo: uid)
          .limit(1)
          .get();

      if (otherPlayers.docs.isNotEmpty) {
        final opponentId = otherPlayers.docs.first.id;
        final opponentData = otherPlayers.docs.first.data();
        
        await _createMatch(uid, profile.pseudo, opponentId, opponentData['pseudo'] ?? 'Joueur');
      }
    } catch (e) {
      state = state.copyWith(isSearching: false, error: e.toString());
    }
  }

  Future<void> _createMatch(String myUid, String myName, String opponentId, String opponentName) async {
    final matchId = _db.collection('matches').doc().id;
    
    final newMatch = DuelMatch(
      id: matchId,
      player1Id: myUid,
      player2Id: opponentId,
      player1Name: myName,
      player2Name: opponentName,
      status: 'invited',
      levelId: 1, 
      p1Progress: [],
      p2Progress: [],
      startTime: DateTime.now(),
    );

    await _db.collection('matches').doc(matchId).set(newMatch.toFirestore());
    await _db.collection('multiplayer_queue').doc(myUid).delete();
    await _db.collection('multiplayer_queue').doc(opponentId).delete();
    
    _listenToMatch(matchId);
  }

  void _listenToMatch(String matchId) {
    _matchSubscription?.cancel();
    _matchSubscription = _db.collection('matches').doc(matchId).snapshots().listen((doc) {
      if (doc.exists) {
        final match = DuelMatch.fromFirestore(doc);
        state = state.copyWith(activeMatch: match, isSearching: false);
      }
    });
  }

  Future<void> acceptInvite() async {
    if (state.activeMatch == null) return;
    await _db.collection('matches').doc(state.activeMatch!.id).update({
      'status': 'active',
      'startTime': FieldValue.serverTimestamp(),
    });
  }

  /// Sends a direct invite to a specific player (creates a real match doc).
  Future<void> invitePlayer(Map<String, dynamic> targetPlayer) async {
    final profile = _ref.read(profileProvider);
    final myUid = FirebaseAuth.instance.currentUser?.uid;
    if (profile == null || myUid == null) return;

    final targetUid = targetPlayer['userId'] ?? targetPlayer['id'] as String?;
    if (targetUid == null) return;

    state = state.copyWith(isSearching: true, error: null);

    try {
      final matchRef = _db.collection('matches').doc();
      final newMatch = DuelMatch(
        id: matchRef.id,
        player1Id: myUid,
        player2Id: targetUid,
        player1Name: profile.pseudo,
        player2Name: targetPlayer['playerName'] ?? targetPlayer['pseudo'] ?? 'Joueur',
        status: 'invited',
        levelId: 1,
        p1Progress: [],
        p2Progress: [],
        startTime: DateTime.now(),
      );
      await matchRef.set(newMatch.toFirestore());
      _listenToMatch(matchRef.id);
    } catch (e) {
      state = state.copyWith(isSearching: false, error: e.toString());
    }
  }

  /// Listens for invitations where this player is the target (player2).
  void _listenForIncomingInvites(String myUid) {
    _inviteSubscription?.cancel();
    _inviteSubscription = _db
        .collection('matches')
        .where('player2Id', isEqualTo: myUid)
        .where('status', isEqualTo: 'invited')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final matchDoc = snapshot.docs.first;
        _listenToMatch(matchDoc.id);
      }
    });
  }

  Future<void> updateProgress(String word) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (state.activeMatch == null || uid == null) return;

    final isP1 = state.activeMatch!.player1Id == uid;
    final progressField = isP1 ? 'p1_progress' : 'p2_progress';
    final attackField = isP1 ? 'p2Attack' : 'p1Attack';

    Map<String, dynamic> updates = {
      progressField: FieldValue.arrayUnion([word]),
    };

    // Trigger attacks based on word length
    if (word.length >= 5) {
      String attack = 'ink';
      if (word.length == 6) attack = 'gel';
      if (word.length >= 7) attack = 'earthquake';
      
      updates[attackField] = attack;
    }

    await _db.collection('matches').doc(state.activeMatch!.id).update(updates);
    
    // Clear attack after sending (logic should be on receiver, but let's be safe)
    // Actually, receiver will clear it after reacting.
  }

  Future<void> clearAttack() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (state.activeMatch == null || uid == null) return;
    final isP1 = state.activeMatch!.player1Id == uid;
    final attackField = isP1 ? 'p1Attack' : 'p2Attack';
    
    await _db.collection('matches').doc(state.activeMatch!.id).update({
      attackField: null,
    });
  }

  Future<void> quitMatch() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await _db.collection('multiplayer_queue').doc(uid).delete();
    }
    
    if (state.activeMatch != null) {
      await _db.collection('matches').doc(state.activeMatch!.id).delete();
    }
    
    _matchSubscription?.cancel();
    state = state.copyWith(activeMatch: null, isSearching: false);
  }

  @override
  void dispose() {
    _matchSubscription?.cancel();
    _queueSubscription?.cancel();
    _inviteSubscription?.cancel();
    super.dispose();
  }
}

final multiplayerProvider = StateNotifierProvider<MultiplayerNotifier, MultiplayerState>((ref) {
  return MultiplayerNotifier(ref);
});
