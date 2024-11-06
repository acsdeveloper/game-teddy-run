// lib/game_over_overlay.dart

import 'package:flutter/material.dart';
import 'super_dash_game.dart';

class GameOverOverlay extends StatelessWidget {
  final SuperDashGame game;

  const GameOverOverlay({required this.game, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Game Over!',
            style: TextStyle(fontSize: 30, color: Colors.red),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              game.resetGame(); // Call resetGame on restart
              game.overlays.remove('GameOver'); // Hide overlay
              game.resumeEngine(); // Resume the game engine
            },
            icon: const Icon(Icons.refresh,
                color: Colors.black), // Use an appropriate icon
            label: const Text(
              'Try Again',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
