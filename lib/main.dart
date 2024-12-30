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
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    oninit();
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
      home: StartScreen(),
    );
  }
}

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  late BuildContext _context;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _context = context;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.exit_to_app_rounded,
            color: textColor,
          ),
          onPressed: () {
            showExitConfirmationOverlay(_context);
          },
        ),
        iconTheme: IconThemeData(
          color: textColorWhite,
        ),
        backgroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/screen/teddyicon.jpg',
                width: 200,
              ),
              const SizedBox(height: 50),
              AppConstants.gradientContainer(
                text: "Start",
                icon: Icons.play_arrow,
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => GameScreen()));
                },
              ),
              Container(
                height: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showExitConfirmationOverlay(BuildContext context) {
    OverlayEntry? _overlayEntry;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        left: 50,
        child: Material(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.5,
            width: MediaQuery.of(context).size.width * 0.8,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Do you want to Exit?',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _overlayEntry?.remove();
                          _overlayEntry = null;
                        },
                        child: Text('No'),
                        style: ElevatedButton.styleFrom(),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Yes'),
                        style: ElevatedButton.styleFrom(),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }
}

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => StartScreen()),
          (route) => false,
        );
        return false;
      },
      child: Scaffold(
        body: GameWidget(
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
      ),
    );
  }
}
