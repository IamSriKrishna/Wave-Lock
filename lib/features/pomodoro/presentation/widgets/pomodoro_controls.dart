import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class PomodoroControls extends StatelessWidget {
  final bool isRunning;
  final bool isPaused;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onReset;

  const PomodoroControls({
    super.key,
    required this.isRunning,
    required this.isPaused,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton.filledTonal(
          onPressed: onReset,
          icon: const Icon(Icons.refresh),
          iconSize: 24,
        ),
        const SizedBox(width: 24),
        SizedBox(
          width: 76,
          height: 76,
          child: FilledButton(
            onPressed: isRunning
                ? onPause
                : isPaused
                ? onResume
                : onStart,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
              shape: const CircleBorder(),
            ),
            child: Icon(isRunning ? Icons.pause : Icons.play_arrow, size: 38),
          ),
        ),
      ],
    );
  }
}
