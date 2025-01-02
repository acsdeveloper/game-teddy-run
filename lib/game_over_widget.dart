import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teddyrun/constent/buttoncontionser.dart';
import 'package:teddyrun/constent/stringconst.dart';
import 'super_dash_game.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GameOverOverlay extends StatefulWidget {
  final SuperDashGame game;

  const GameOverOverlay({required this.game, super.key});

  @override
  State<GameOverOverlay> createState() => _GameOverOverlayState();
}

class _GameOverOverlayState extends State<GameOverOverlay> {
  bool isMusicOn = true; // Default value for music state

  @override
  void initState() {
    super.initState();
    _loadMusicState();
  }

  // Load music state from SharedPreferences
  Future<void> _loadMusicState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isMusicOn =
          prefs.getBool('musicOn') ?? true; // Default to true if not set
    });
  }

  // Play the background music if enabled
  void _playBackgroundMusic() {
    if (isMusicOn) {
      FlameAudio.bgm.play('game.mp3');
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context!)!; // Now defined

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            localizations.gameOver,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w500,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 20),
          AppConstants.gradientContainer(
            icon: Icons.refresh,
            text: localizations.tryAgain,
            onTap: () {
              // _playBackgroundMusic(); // Play music based on the preference
              widget.game.ispaused = true;
              widget.game.resetGame(); // Call resetGame on restart
              widget.game.overlays.remove('GameOver'); // Hide overlay
            },
          ),
        ],
      ),
    );
  }
}
