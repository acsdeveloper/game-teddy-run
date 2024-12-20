import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'package:teddyRun/settings/settings.dart';
import 'obstacle.dart';
import 'movingbackground.dart';
import 'teady.dart';
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
  Future<void> preloadAudio() async {
    // Preload jump sound to prevent glitches
    await FlameAudio.audioCache.load("jump.mp3");
    await FlameAudio.audioCache.load("game.mp3");
  }

  @override
  Future<void> onLoad() async {
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
      speed: 400,
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
      text: 'Best Score :${formatScore(highScore)}',
      position: Vector2(size.x - 180, 15),
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
      text: 'Score: 0',
      position: Vector2(size.x - 180, 35),
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
        Navigator.pushAndRemoveUntil(
          buildContext!, // Pass the buildContext of the FlameGame
          MaterialPageRoute(builder: (context) => StartScreen(true)),
          (route) => false,
        );
      },
    );
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
            FlameAudio.bgm.play("game.mp3");
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
            FlameAudio.bgm.play("game.mp3");
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
      FlameAudio.bgm.play('game.mp3');
    }

    // Initial state for TeddyBear
    teddyBear.isRunning = false;
  }

  @override
  void update(double dt) async {
    super.update(dt);

    if (!isGameOver) {
      obstacleTimer.update(dt);

      // Update score over time
      score += (dt * 90).toInt();
      scoreText.text = 'Score: ${formatScore(score)}';
      if (score > highScore) {
        highScore = score;
        highScoreText.text = "Best Score: ${formatScore(score)}";
        await _saveHighScore(score);
      }
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
      highScoreText.text = 'Best Score: ${formatScore(highScore)}';
    }

    final gameOverText = TextComponent(
      text: 'Game Over!',
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
    if (isGameOver) return; // Ignore taps if the game is over

    teddyBear.jump();
  }

  void resetGame() async {
    children
        .whereType<Obstacle>()
        .forEach((obstacle) => obstacle.removeFromParent());

    teddyBear.position = Vector2(500, groundY);
    teddyBear.reset();
    isGameOver = false;

    score = 0;
    scoreText.text = 'Score: ${formatScore(score)}';

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
