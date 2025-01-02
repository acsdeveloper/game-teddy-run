// lib/game_over_overlay.dart

import 'package:flame/timer.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'super_dash_game.dart';

class StartGameOverlay extends StatelessWidget {
  final SuperDashGame game;
  late Timer obstacleTimer;

  StartGameOverlay({required this.game, super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context!)!; // Now defined

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            localizations.start,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w500,
              color: Colors.red,
              // fontFamily: GoogleFonts.montserrat().fontFamily,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.blue),
            ),
            onPressed: () {
              game.overlays.remove('StartGame'); // Hide the start overlay
              obstacleTimer = Timer(1.5,
                  onTick: SuperDashGame().spawnObstacle, repeat: true);
              obstacleTimer.start();
              // game.startGame();
              SuperDashGame().teddyBear.isRunning = true;

              // Call startGame to initialize the game start
            },
            icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
            label: Text(
              localizations.start,
              style: TextStyle(
                color: Colors.white,
                // fontFamily: GoogleFonts.montserrat().fontFamily,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
