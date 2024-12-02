import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teddyRun/super_dash_game.dart';

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

  // Toggle Music state and save it to SharedPreferences
  Future<void> _toggleMusicState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isMusicOn = !isMusicOn;
    });
    isMusicOn == true;
    if (isMusicOn) {
      FlameAudio.bgm.play('game.mp3');
    }
    await prefs.setBool('musicOn', isMusicOn);
  }

  // Toggle Audio state and save it to SharedPreferences
  Future<void> _toggleAudioState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isAudioOn = !isAudioOn;
    });
    await prefs.setBool('audioOn', isAudioOn);
  }

  @override
  Widget build(BuildContext context) {
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
                  "Settings",
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
                ListTile(
                  leading: Icon(
                    isAudioOn ? Icons.volume_up : Icons.volume_off,
                    color: isAudioOn ? Colors.blue : Colors.red,
                  ),
                  title: Text(
                    isAudioOn ? "Audio On" : "Audio Off",
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: GoogleFonts.montserrat().fontFamily,
                    ),
                  ),
                  onTap: _toggleAudioState,
                ),
              ],
            ),
          ),

          // Close button
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: () {
                widget.game.overlays.remove('Settings');
                widget.game.resumeEngine();
              },
            ),
          ),
        ],
      ),
    );
  }
}
