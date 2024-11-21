// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:teddyRun/game_over_widget.dart';

import 'constent/buttoncontionser.dart';
import 'super_dash_game.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('gameBox');
  // Set the app to full-screen mode
  // Lock the orientation to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StartScreen(),
    );
  }
}

class StartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        // decoration: BoxDecoration(
        //   gradient: LinearGradient(
        //     colors:Colors.white,
        //     begin: Alignment.topCenter,
        //     end: Alignment.bottomCenter,
        //   ),
        // ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/teddyicon.jpg',
                width: 200, // Adjust dimensions as needed
              ),
              const SizedBox(height: 50),
              AppConstants.gradientContainer(
                  text: "Start",
                  icon: Icons.play_arrow,
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => GameScreen()));
                  }),
              Container(
                height: 30,
              ),
              AppConstants.gradientContainer(
                  text: "Exit",
                  icon: Icons.exit_to_app,
                  onTap: () {
                    SystemNavigator.pop();
                  })
              // ButtonWidget(
              //   text: "Start",
              //   icon: Icons.play_arrow,
              //   onPressed: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(builder: (context) => GameScreen()),
              //     );
              //   },
              // ),
              // SizedBox(height: 20),
              // ButtonWidget(
              //   text: "Exit Game",
              //   onPressed: () {
              //     SystemNavigator.pop();
              //   },
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

class GameScreen extends StatelessWidget {
  final game = SuperDashGame();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}
