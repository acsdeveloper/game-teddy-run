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
import 'constent/contaxt.dart';
import 'constent/translation.dart';
import 'super_dash_game.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('gameBox');
  runApp(Test());
}

class Test extends StatefulWidget {
  @override
  _TestState createState() => _TestState();
}

class _TestState extends State<Test> {
  @override
  Widget build(BuildContext context) {
    return MyApp(
      optionalContext: context,
    );
  }
}

class MyApp extends StatelessWidget {
  final BuildContext? optionalContext;

  MyApp({this.optionalContext, super.key}) {
    oninit();
  }

  Future<void> oninit() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    ContextService().setContext(optionalContext);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      supportedLocales: const [
        Locale('en'), // English
        Locale('fr'), // fr
        // ... other locales your app supports
      ],
      locale: Locale('fr', ''),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      home: StartScreen(optionalContext: optionalContext),
    );
  }
}

class StartScreen extends StatefulWidget {
  final BuildContext? optionalContext;

  const StartScreen({this.optionalContext, super.key});

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
    return WillPopScope(
      onWillPop: () async {
        showExitConfirmationOverlay(
          context,
          LocaleStrings.getString(
              'exitmessage', Localizations.localeOf(context)),
          // "Do you really want to exit the game?",
          isBack: true,
        );
        return false; // Add this line to return a value
      },
      child: Scaffold(
        appBar: AppBar(
          leading: widget.optionalContext != null
              ? IconButton(
                  icon: Icon(
                    Icons.exit_to_app_rounded,
                    color: textColor,
                  ),
                  onPressed: () {
                    showExitConfirmationOverlay(
                      widget.optionalContext,
                      LocaleStrings.getString(
                          'exitmessage', Localizations.localeOf(context)),
                      // "Do you really want to exit the game?",
                      isBack: true,
                    );
                  },
                )
              : null,
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
                  'assets/images/screen/teddyiconfr.jpg',
                  width: 200,
                ),
                const SizedBox(height: 50),
                AppConstants.gradientContainer(
                  text: LocaleStrings.getString(
                      'start', Localizations.localeOf(context)),
                  icon: Icons.play_arrow,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => GameScreen(
                              optionalContext: widget.optionalContext)),
                    );
                  },
                ),
                Container(
                  height: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showExitConfirmationOverlay(
    BuildContext? context, // Make context optional
    String text, {
    bool isBack = false,
  }) {
    if (context == null) {
      // If context is null, return early to avoid issues
      // debugPrint(
      //     "Context is null. Unable to show the exit confirmation overlay.");
      return;
    }

    final overlay = Overlay.of(context);

    if (overlay == null) {
      // If the overlay is null, log a message and return
      // debugPrint("Overlay is null. Unable to show the exit confirmation overlay.");
      return;
    }

    OverlayEntry? overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Material(
          color: overlayColor.withOpacity(0.9),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 16.0),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.90,
                  ),
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
                        overlayEntry?.remove();
                      },
                      text: LocaleStrings.getString(
                          'no', Localizations.localeOf(context)),
                    ),
                    const SizedBox(width: 25.0),
                    ButtonWidget(
                      onPressed: () {
                        overlayEntry?.remove();
                        if (isBack) {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        }
                      },
                      text: LocaleStrings.getString(
                          'yes', Localizations.localeOf(context)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
  }
}

class GameScreen extends StatelessWidget {
  final BuildContext? optionalContext; // Optional parameter

  const GameScreen({super.key, this.optionalContext});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Use optionalContext if provided; otherwise, use the current context
        BuildContext targetContext = optionalContext ?? context;
        this.showExitConfirmationOverlay(
          context,
          LocaleStrings.getString(
              'exitmessage', Localizations.localeOf(context)),
          // "Do you really want to exit the game?",
          isBack: true,
        );

        // Navigator.pushAndRemoveUntil(
        //   targetContext,
        //   MaterialPageRoute(
        //       builder: (context) =>
        //           StartScreen(optionalContext: targetContext)),
        //   (route) => false,
        // );
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

  void showExitConfirmationOverlay(
    BuildContext? context, // Make context optional
    String text, {
    bool isBack = false,
  }) {
    if (context == null) {
      // If context is null, return early to avoid issues
      // debugPrint(
      //     "Context is null. Unable to show the exit confirmation overlay.");
      return;
    }

    final overlay = Overlay.of(context);

    if (overlay == null) {
      // If the overlay is null, log a message and return
      // debugPrint("Overlay is null. Unable to show the exit confirmation overlay.");
      return;
    }

    OverlayEntry? overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Material(
          color: overlayColor.withOpacity(0.9),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 16.0),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.90,
                  ),
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
                        overlayEntry?.remove();
                      },
                      text: LocaleStrings.getString(
                          'no', Localizations.localeOf(context)),
                    ),
                    const SizedBox(width: 25.0),
                    ButtonWidget(
                      onPressed: () {
                        overlayEntry?.remove();
                        if (isBack) {
                          Navigator.of(context).pop();
                        }
                      },
                      text: LocaleStrings.getString(
                          'yes', Localizations.localeOf(context)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
  }
}
