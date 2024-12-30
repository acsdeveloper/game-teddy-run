import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:teddyrun/constent/Colors.dart';
import 'package:teddyrun/constent/button.dart';
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
            showExitConfirmationOverlay(
                _context, isBack: true, "Do you really want to exit the Game?");
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

  showExitConfirmationOverlay(
    BuildContext context,
    String text, {
    bool isBack = false,
  }) {
    final overlay = Overlay.of(context);

    // Declare the overlayEntry outside the builder function to avoid scoping issues
    OverlayEntry? overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Material(
          // Use Material to ensure proper theming and rendering
          color:
              overlayColor.withOpacity(0.9), // Apply the opacity here directly
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 16.0),
                ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.90),
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      color: textColor,
                      fontSize: 24.0,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
                const SizedBox(height: 40.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ButtonWidget(
                      onPressed: () {
                        // Remove overlay entry after pressing No
                        overlayEntry?.remove();
                      },
                      text: "No",
                    ),
                    const SizedBox(width: 25.0),
                    ButtonWidget(
                      onPressed: () {
                        // Remove overlay entry after pressing Yes
                        overlayEntry?.remove();
                        if (isBack) {
                          Navigator.of(context).pop();
                        }
                      },
                      text: "Yes",
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Insert the overlay entry after it's fully declared
    overlay.insert(overlayEntry);
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
