// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:jumpapp/game_over_widget.dart';
import 'super_dash_game.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('gameBox');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final game = SuperDashGame();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          children: [
            GameWidget(
              game: game,
              overlayBuilderMap: {
                'GameOver': (BuildContext context, SuperDashGame game) {
                  return GameOverOverlay(game: game);
                },
              },
            ),
          ],
        ),
      ),
    );
  }
}
