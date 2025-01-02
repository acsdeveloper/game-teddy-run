import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teddyrun/super_dash_game.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Settings extends StatefulWidget {
  final SuperDashGame game;

  const Settings({required this.game, super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool isMusicOn = true; // Default value for Music
  bool isAudioOn = true; // Default value for Audio

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  // Load Music and Audio states from SharedPreferences
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isMusicOn = prefs.getBool('musicOn') ?? true;
      isAudioOn = prefs.getBool('audioOn') ?? true;
    });
  }

  // Save preferences to SharedPreferences when popup is closed
  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('musicOn', isMusicOn);
    await prefs.setBool('audioOn', isAudioOn);
  }

  // Toggle Music state without saving immediately
  void _toggleMusicState() {
    setState(() {
      isMusicOn = !isMusicOn;
    });
  }

  // Toggle Audio state without saving immediately
  void _toggleAudioState() {
    setState(() {
      isAudioOn = !isAudioOn;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context!)!; // Now defined

    return AlertDialog(
      contentPadding: const EdgeInsets.all(0), // Remove default padding
      content: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  localizations.settings,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    fontFamily: GoogleFonts.montserrat().fontFamily,
                  ),
                ),
                const SizedBox(height: 10),

                // Music Toggle Option
                ListTile(
                  leading: Icon(
                    isMusicOn ? Icons.music_note : Icons.music_off,
                    color: isMusicOn ? Colors.blue : Colors.red,
                  ),
                  title: Text(
                    isMusicOn ? "Music On" : "Music Off",
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: GoogleFonts.montserrat().fontFamily,
                    ),
                  ),
                  onTap: _toggleMusicState,
                ),

                // Audio Toggle Option
                // ListTile(
                //   leading: Icon(
                //     isAudioOn ? Icons.volume_up : Icons.volume_off,
                //     color: isAudioOn ? Colors.blue : Colors.red,
                //   ),
                //   title: Text(
                //     isAudioOn ? "SFX On" : "SFX Off",
                //     style: TextStyle(
                //       fontSize: 18,
                //       fontFamily: GoogleFonts.montserrat().fontFamily,
                //     ),
                //   ),
                //   onTap: _toggleAudioState,
                // ),
              ],
            ),
          ),

          // Close button
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: () async {
                await _savePreferences(); // Save preferences on close
                widget.game.overlays.remove('Settings');
                widget.game.resumeEngine();
                if (!isMusicOn) {
                  // FlameAudio.bgm.play('game.mp3');
                  FlameAudio.bgm.stop();
                }
                if (isMusicOn == true) {
                  FlameAudio.bgm.play("game.mp3");
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
