import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:teddyrun/constent/Colors.dart';
import 'package:teddyrun/constent/button.dart';
import 'package:teddyrun/constent/translation.dart';
import 'package:teddyrun/movingbackground.dart';
import 'package:teddyrun/teady.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'constent/contaxt.dart';
import 'obstacle.dart';
import 'main.dart';

class SuperDashGame extends FlameGame with HasCollisionDetection, TapCallbacks {
  late TeddyBear teddyBear;
  late Timer obstacleTimer;
  int score = 0;
  bool isGameOver = false;
  late TextComponent scoreText;
  late TextComponent highScoreText;
  int highScore = 0;
  late MovingBackground movingBackground;
  bool isMusicOn = false; // Track if music should play
  double groundY = 0; // Will be set dynamically in onLoad
  bool ispaused = true;
  late SpriteButtonComponent playpauseButton;
  double baseObstacleSpeed = 200; // Default speed of obstacles

  double speedMultiplier = 1.0; // Default multiplier

  Future<void> preloadAudio() async {
    // Preload jump sound to prevent glitches
    await FlameAudio.audioCache.load("jump.mp3");
    await FlameAudio.audioCache.load("game.mp3");
  }

  @override
  Future<void> onLoad() async {
    BuildContext? optionalcontext = ContextService().optionalContext;

    await super.onLoad();

    // **Load Preferences and Set Initial Values**
    final prefs = await SharedPreferences.getInstance();
    isMusicOn = prefs.getBool('musicOn') ?? true; // Default to true if not set

    // Calculate ground level
    groundY = size.y - 100; // Adjust offset based on asset size

    // **Background Components**
    final background = MovingBackground(
      imagePath: "screen/background.png",
      invertimagePath: "screen/invertedbackground.png",
      speed: 200,
    )..size = Vector2(size.x * 5, size.y);

    final clouds = MovingBackground(
      imagePath: "screen/cloud2.png",
      invertimagePath: "screen/cloud.png",
      speed: 20,
    )..size = Vector2(size.x, size.y / 3.5);

    // **Gameplay Elements**
    highScore = await _loadHighScore();
    final highScoreStyle = TextPaint(
      style: TextStyle(
        color: Colors.black,
        fontSize: 18,
        fontFamily: GoogleFonts.montserrat().fontFamily,
      ),
    );
    highScoreText = TextComponent(
      anchor: Anchor.topLeft,
      text:
      '${LocaleStrings.getString('bestScore', Localizations.localeOf(optionalcontext!))}:${formatScore(highScore)}',
      position: Vector2(size.x - 200, 15),
      textRenderer: highScoreStyle,
    );

    teddyBear = TeddyBear()..position = Vector2(500, groundY);

    final scoreStyle = TextPaint(
      style: TextStyle(
        color: Colors.black,
        fontSize: 18,
        fontFamily: GoogleFonts.montserrat().fontFamily,
      ),
    );
    scoreText = TextComponent(
      text:
      '${LocaleStrings.getString('score', Localizations.localeOf(optionalcontext!))}: 0',
      position: Vector2(size.x - 200, 35),
      textRenderer: scoreStyle,
    );

    obstacleTimer = Timer(2, onTick: spawnObstacle, repeat: true);

    final backButton = SpriteButtonComponent(
        button: await Sprite.load("screen/back.png"),
        position: Vector2(15, 13),
        size: Vector2(34, 34),
        onPressed: () {
          if (isMusicOn) {
            FlameAudio.bgm.stop();
          }
          pauseEngine();
          if (!isGameOver) {
            // Show confirmation dialog only if the game is NOT over
            showConfirmationDialog(
              buildContext!,
              LocaleStrings.getString(
              'exitmessage', Localizations.localeOf(optionalcontext)),
              true, // Set isBack to true
            );
          } else {
            // If the game is over, directly go to the start screen
            Navigator.pushAndRemoveUntil(
              buildContext!,
              MaterialPageRoute(builder: (context) => StartScreen()),
              (route) => false,
            );
          }
        });
    // **Initialize Settings Button with Correct Initial Sprite**
    Sprite settingsButtonSprite;
    Sprite settingsButtonDownSprite;
    late SpriteButtonComponent settingsButton;

    if (isMusicOn) {
      settingsButtonSprite = await Sprite.load("screen/speaker.png");
      settingsButtonDownSprite = await Sprite.load("screen/speaker.png");
    } else {
      settingsButtonSprite = await Sprite.load("screen/speakeroff.png");
      settingsButtonDownSprite = await Sprite.load("screen/speakeroff.png");
    }

    settingsButton = SpriteButtonComponent(
      button: settingsButtonSprite,
      buttonDown: settingsButtonDownSprite,
      //position: Vector2(57.5, 15),
      size: Vector2(30, 30),
      onPressed: () async {
        if (!isGameOver && ispaused) {
          if (isMusicOn) {
            // Turn music off
            FlameAudio.bgm.stop();
            settingsButton.button = await Sprite.load("screen/speakeroff.png");
            settingsButton.buttonDown = await Sprite.load("screen/speaker.png");
          } else {
            // Turn music on
            // FlameAudio.bgm.play("game.mp3");
            settingsButton.button = await Sprite.load("screen/speaker.png");
            settingsButton.buttonDown =
                await Sprite.load("screen/speakeroff.png");
          }
          isMusicOn = !isMusicOn;

          // Save the updated music state to SharedPreferences
          await prefs.setBool('musicOn', isMusicOn);
        }
      },
    ); // Show pause button initially

    final pauseButtonSprite = await Sprite.load("screen/pause.png");
    final playButtonSprite = await Sprite.load("screen/play.png");

    playpauseButton = SpriteButtonComponent(
      position: Vector2(57.5, 15),

      // position: Vector2(100, 15),
      size: Vector2(30, 30),
      button: pauseButtonSprite,
      buttonDown: playButtonSprite,
      onPressed: () async {
        if (!isGameOver) {
          ispaused ? pauseEngine() : resumeEngine();
          if (!ispaused && isMusicOn) {
            // FlameAudio.bgm.play("game.mp3");
          } else {
            FlameAudio.bgm.stop();
          }
          ispaused = !ispaused;
        }
      },
    );

    // Add the pause button initially
    add(background);
    add(highScoreText);
    add(clouds);
    add(teddyBear);
    add(scoreText);
    add(playpauseButton);
    add(backButton);
    // add(settingsButton);

    // **Music**
    if (!isGameOver && isMusicOn) {
      // FlameAudio.bgm.play('game.mp3');
    }

    // Initial state for TeddyBear
    teddyBear.isRunning = false;
  }

  void showConfirmationDialog(BuildContext context, String text, bool isBack) {
    showDialog(
      context: context,
      barrierColor:
          Colors.transparent, // Make the barrier (background) transparent
      builder: (BuildContext context) {
        return Scaffold(
          backgroundColor:
              Colors.transparent, // Make the Scaffold background transparent
          body: Stack(
            children: [
              // Transparent background covering the entire screen
              Positioned.fill(
                child: Container(
                  color:
                      overlayColor.withOpacity(0.1), // Adjust opacity as needed
                ),
              ),
              // Centered dialog content
              Center(
                child: Material(
                  color: Colors
                      .transparent, // Make the Material widget transparent
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.60,
                        ),
                        child: Text(
                          text,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                            color: Colors.black, // Use your textColor here
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
                              Navigator.of(context).pop(); // Close the dialog
                              resumeEngine();
                            },
                            text:  // Use your localization here
                             LocaleStrings.getString(
                                'no', Localizations.localeOf(context)),
                          ),
                          const SizedBox(width: 25.0),
                          ButtonWidget(
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the dialog
                              if (isBack) {
                                Navigator.of(context)
                                    .pop(); // Navigate back if isBack is true
                              }
                            },
                            text:
                             LocaleStrings.getString(
                                'yes', Localizations.localeOf(context)),
                            // Use your localization here
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void update(double dt) async {
    super.update(dt);
    BuildContext? optionalcontext = ContextService().optionalContext;

    if (!isGameOver) {
      obstacleTimer.update(dt);

      // Update score over time
      score += (dt * 90).toInt();
      scoreText.text = '${LocaleStrings.getString('score', Localizations.localeOf(optionalcontext!))}: ${formatScore(score)}';
      if (score > highScore) {
        highScore = score;
        highScoreText.text =
        "${LocaleStrings.getString('bestScore', Localizations.localeOf(optionalcontext!))}: ${formatScore(score)}";
        await _saveHighScore(score);
      }
      // Dynamically adjust speedMultiplier based on score
      speedMultiplier = 1.0 +
          (score ~/ 2000) * 0.1; // Increase speed by 10% for every 2000 points
    }
  }

  void spawnObstacle() {
    if (!isGameOver) {
      final obstacle = Obstacle()
        ..position =
            Vector2(size.x + 25, groundY) // Position obstacle at `groundY`
        ..anchor = Anchor.bottomCenter;
      add(obstacle);
    }
  }

  void gameOver() async {
    BuildContext? optionalcontext = ContextService().optionalContext;

    if (isGameOver) return; // Ensure gameOver logic is triggered only once

    isGameOver = true;

    obstacleTimer.stop();
    pauseEngine();

    if (isMusicOn) {
      FlameAudio.bgm.stop();
    }

    if (score > highScore) {
      highScore = score;
      await _saveHighScore(highScore);
      highScoreText.text = 
      ' ${LocaleStrings.getString('bestScore', Localizations.localeOf(optionalcontext!))} : ${formatScore(highScore)}';
    }

    final gameOverText = TextComponent(
      text:
      ' ${LocaleStrings.getString('gameOver', Localizations.localeOf(optionalcontext!))}',
      position: Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.red,
          fontSize: 30,
          fontFamily: GoogleFonts.montserrat().fontFamily,
        ),
      ),
    );
    add(gameOverText);
  }

  @override
  void onTapDown(TapDownEvent event) {
    BuildContext? optionalcontext = ContextService().optionalContext;

    if (isGameOver) return; // Ignore taps if the game is over

    teddyBear.jump();
  }

  void resetGame() async {
    BuildContext? optionalcontext = ContextService().optionalContext;

    children
        .whereType<Obstacle>()
        .forEach((obstacle) => obstacle.removeFromParent());

    teddyBear.position = Vector2(500, groundY);
    teddyBear.reset();
    isGameOver = false;

    score = 0;
    scoreText.text = 
    '${LocaleStrings.getString('score', Localizations.localeOf(optionalcontext!))}: ${formatScore(score)}';

    obstacleTimer.start();
    resumeEngine();
  }

  // Save high score to Hive
  Future<void> _saveHighScore(int score) async {
    final box = Hive.box('gameBox');
    await box.put('highScore', score);
  }

  // Load high score from Hive
  Future<int> _loadHighScore() async {
    final box = Hive.box('gameBox');
    return box.get('highScore', defaultValue: 0);
  }

  String formatScore(int score) {
    if (score >= 1000000000) {
      return '${(score / 1000000000).toStringAsFixed(1)}B';
    } else if (score >= 1000000) {
      return '${(score / 1000000).toStringAsFixed(1)}M';
    } else if (score >= 1000) {
      return '${(score / 1000).toStringAsFixed(1)}K';
    } else {
      return score.toString();
    }
  }
}
