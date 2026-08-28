import 'package:flutter/material.dart';

/// Animated countdown timer widget for Blitz mode
class CountdownTimer extends StatelessWidget {
  final int secondsRemaining;
  final int totalSeconds;
  final bool isRunning;
  final VoidCallback? onTimeout;

  const CountdownTimer({
    super.key,
    required this.secondsRemaining,
    this.totalSeconds = 60,
    this.isRunning = false,
    this.onTimeout,
  });

  @override
  Widget build(BuildContext context) {
    final progress = secondsRemaining / totalSeconds;
    final isUrgent = secondsRemaining <= 10;
    final isCritical = secondsRemaining <= 5;

    // Color based on time remaining
    Color timerColor;
    if (isCritical) {
      timerColor = Colors.red;
    } else if (isUrgent) {
      timerColor = Colors.orange;
    } else {
      timerColor = Colors.teal;
    }

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 0, end: isUrgent ? 1.1 : 1.0),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: timerColor.withOpacity(0.3),
                  blurRadius: isUrgent ? 20 : 10,
                  spreadRadius: isUrgent ? 5 : 2,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Circular progress indicator
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(timerColor),
                  ),
                ),
                // Time display
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      size: 24,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(secondsRemaining),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: timerColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(1, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}

/// Compact timer display for game header
class CompactTimer extends StatelessWidget {
  final int secondsRemaining;
  final bool isRunning;

  const CompactTimer({
    super.key,
    required this.secondsRemaining,
    this.isRunning = false,
  });

  @override
  Widget build(BuildContext context) {
    final isUrgent = secondsRemaining <= 10;
    final isCritical = secondsRemaining <= 5;

    Color timerColor;
    if (isCritical) {
      timerColor = Colors.red;
    } else if (isUrgent) {
      timerColor = Colors.orange;
    } else {
      timerColor = const Color(0xFF2DD4BF);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: timerColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: timerColor, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            color: timerColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            _formatTime(secondsRemaining),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: timerColor,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins}:${secs.toString().padLeft(2, '0')}';
  }
}
