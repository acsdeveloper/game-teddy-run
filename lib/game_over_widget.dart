// lib/game_over_overlay.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jumpapp/constent/stringconst.dart';
import 'super_dash_game.dart';

class GameOverOverlay extends StatelessWidget {
  final SuperDashGame game;

  const GameOverOverlay({required this.game, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            StringConstants.gameOverOverlayKey,
            style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w500,
                color: Colors.red,
                fontFamily: GoogleFonts.montserrat().fontFamily),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blue)),
            onPressed: () {
              game.resetGame(); // Call resetGame on restart
              game.overlays.remove('GameOver'); // Hide overlay
              // Resume the game engine
            },
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: Text(
              StringConstants.tryAgain,
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: GoogleFonts.montserrat().fontFamily),
            ),
          ),
        ],
      ),
    );
  }
}
