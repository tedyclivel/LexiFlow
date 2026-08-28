import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:search_word/utils/design_system.dart';
import 'package:search_word/utils/sound_service.dart';
import 'dart:math';

class CoinAnimationOverlay extends StatefulWidget {
  final Offset startOffset;
  final Offset endOffset;
  final int coinCount;
  final VoidCallback onComplete;

  const CoinAnimationOverlay({
    super.key,
    required this.startOffset,
    required this.endOffset,
    this.coinCount = 10,
    required this.onComplete,
  });

  @override
  State<CoinAnimationOverlay> createState() => _CoinAnimationOverlayState();
}

class _CoinAnimationOverlayState extends State<CoinAnimationOverlay> {
  int _completedCoins = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(widget.coinCount, (index) {
        final random = Random();
        final delay = (index * 100).ms;
        final spreadX = (random.nextDouble() - 0.5) * 100;
        final spreadY = (random.nextDouble() - 0.5) * 100;

        return Positioned(
          left: widget.startOffset.dx,
          top: widget.startOffset.dy,
          child: const Icon(
            Icons.monetization_on,
            color: Colors.amber,
            size: 24,
          )
          .animate(onPlay: (_) => SoundService.playCoinCollect(), onComplete: (_) {
            _completedCoins++;
            if (_completedCoins == widget.coinCount) {
              widget.onComplete();
            }
          })
          .move(
            begin: const Offset(0, 0),
            end: Offset(spreadX, spreadY),
            duration: 300.ms,
            curve: Curves.easeOut,
          )
          .then(delay: delay)
          .move(
            end: widget.endOffset - widget.startOffset - Offset(spreadX, spreadY),
            duration: 600.ms,
            curve: Curves.easeInOutBack,
          )
          .scale(end: const Offset(0.5, 0.5), duration: 600.ms)
          .fadeOut(duration: 600.ms),
        );
      }),
    );
  }
}

class CoinAnimationManager {
  static void show({
    required BuildContext context,
    required Offset startOffset,
    int coinCount = 10,
    VoidCallback? onComplete,
  }) {
    // End offset is roughly the top-left where CurrencyBar is
    const endOffset = Offset(80, 40); 
    
    OverlayEntry? entry;
    entry = OverlayEntry(
      builder: (context) => CoinAnimationOverlay(
        startOffset: startOffset,
        endOffset: endOffset,
        coinCount: coinCount,
        onComplete: () {
          entry?.remove();
          onComplete?.call();
        },
      ),
    );

    Overlay.of(context).insert(entry);
  }
}
