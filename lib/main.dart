import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:teddyrun/constent/Colors.dart';
import 'package:teddyrun/game_over_widget.dart';
import 'package:teddyrun/settings/settings.dart';
import 'constent/buttoncontionser.dart';
import 'super_dash_game.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('gameBox');

  // Set the app to full-screen mode and lock the orientation to landscape
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Example: Pass optional external data to the app
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final BuildContext? someData;

  const MyApp({this.someData, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StartScreen(data: someData),
    );
  }
}

class StartScreen extends StatelessWidget {
  final BuildContext? data;

  const StartScreen({this.data, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset(
                'assets/images/screen/teddyicon.jpg',
                width: 200,
              ),
              if (data != null)
                Text(
                  'Data passed: $data',
                  style: const TextStyle(fontSize: 20),
                ),
              AppConstants.gradientContainer(
                text: "Start",
                icon: Icons.play_arrow,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GameScreen()),
                  );
                },
              ),
              if (data != null) // Show "Exit" button only if context is passed
                AppConstants.gradientContainer(
                  text: "Exit",
                  icon: Icons.exit_to_app,
                  onTap: () {
                    Navigator.pop(data!);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const StartScreen()),
          (route) => false,
        );
      },
      child: Scaffold(
        body: Stack(
          children: [
            GameWidget(
              game: SuperDashGame(),
              overlayBuilderMap: {
                'GameOver': (BuildContext context, SuperDashGame game) {
                  return GameOverOverlay(game: game);
                },
                'Settings': (BuildContext context, SuperDashGame game) {
                  return Settings(game: game);
                },
              },
            ),
          ],
        ),
      ),
    );
  }
}
