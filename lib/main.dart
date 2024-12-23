import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:teddyrun/game_over_widget.dart';
import 'package:teddyrun/settings/settings.dart';
import 'constent/buttoncontionser.dart';
import 'super_dash_game.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('gameBox');
  var isfromapp = true;
  // Set the app to full-screen mode
  // Lock the orientation to portrait mode
  // await SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.landscapeRight,
  //   DeviceOrientation.landscapeLeft,
  // ]);
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(MyApp(isfromapp));
}

class MyApp extends StatefulWidget {
  var fromapp;
  MyApp(bool isfromapp, {super.key}) {
    fromapp = isfromapp;
  }

  @override
  State<MyApp> createState() => _MyAppState(fromapp);
}

class _MyAppState extends State<MyApp> {
  var isfromapp;
  _MyAppState(fromapp) {
    fromapp = isfromapp;
  }

  @override
  void initState() {
    super.initState();
    oninit(); // Call oninit here
  }

  Future<void> oninit() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StartScreen(isfromapp),
    );
  }
}

// ... (rest of your code, StartScreen and GameScreen remain the same)

class StartScreen extends StatelessWidget {
  var isapp;
  StartScreen(isfromapp, {super.key}) {
    isapp = isfromapp;
  }

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
                'assets/images/screen/teddyicon.jpg',
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
              // AppConstants.gradientContainer(
              //     text: "Exit",
              //     icon: Icons.exit_to_app,
              //     onTap: () {
              //       Navigator.pop(context);
              //     })
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
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        Navigator.pushAndRemoveUntil(
          context, // Pass the buildContext of the FlameGame
          MaterialPageRoute(builder: (context) => StartScreen(true)),
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
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
