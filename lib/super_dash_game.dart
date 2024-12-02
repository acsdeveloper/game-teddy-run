import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';

import 'package:teddyRun/main.dart';
import 'package:teddyRun/movingbackground.dart';
import 'package:teddyRun/teady.dart';

import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences

import 'obstacle.dart';

class SuperDashGame extends FlameGame with HasCollisionDetection, TapCallbacks {
  late TeddyBear teddyBear;
  late Timer obstacleTimer;
  int score = 0;
  bool isGameOver = false;
  late TextComponent scoreText;
  late TextComponent highScoreText;
  int highScore = 0;
  late MovingBackground movingBackground;
  bool isMusicOn = true; // Track if music should play

  double groundY = 0; // Will be set dynamically in onLoad
  bool ispaused = false;
  late SpriteButtonComponent avatarButton;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Load the music preference from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    isMusicOn = prefs.getBool('musicOn') ?? true; // Default to true if not set

    // Play background music if enabled
    if (isMusicOn) {
      FlameAudio.bgm.play('game.mp3');
    }

    // Set `groundY` based on screen size to keep elements at the bottom
    groundY =
        size.y - 100; // Adjust offset (e.g., 100) to match your asset size

    // Load the high score from Hive
    highScore = await _loadHighScore();
    highScoreText = TextComponent(
      anchor: Anchor.topLeft,
      text: 'Best Score :${formatScore(highScore)}',
      position: Vector2(size.x - 180, 15),
      textRenderer: TextPaint(
          style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontFamily: GoogleFonts.montserrat().fontFamily)),
    );

    add(MovingBackground(
        imagePath: "screen/background.png",
        invertimagePath: "screen/invertedbackground.png",
        speed: 400)
      ..size = Vector2(size.x * 5, size.y));
    add(MovingBackground(
        imagePath: "screen/cloud2.png",
        invertimagePath: "screen/cloud.png",
        speed: 20)
      ..size = Vector2(size.x, size.y / 3));

    obstacleTimer = Timer(2, onTick: spawnObstacle, repeat: true);
    teddyBear = TeddyBear()..position = Vector2(500, groundY);
    add(teddyBear);

    scoreText = TextComponent(
      text: 'Score: 0',
      position: Vector2(size.x - 180, 35),
      textRenderer: TextPaint(
          style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontFamily: GoogleFonts.montserrat().fontFamily)),
    );
    add(scoreText);
    add(highScoreText);

    avatarButton = SpriteButtonComponent(
      position: Vector2(60, 10),
      size: Vector2(40, 40),
      button:
          await Sprite.load(ispaused ? "screen/pause.png" : "screen/play.png"),
      onPressed: () async {
        if (!isGameOver) {
          if (!ispaused) {
            FlameAudio.bgm.stop();
            pauseEngine();
            ispaused = true;
            avatarButton.button = await Sprite.load("screen/play.png");
          } else {
            if (isMusicOn) {
              FlameAudio.bgm.play('game.mp3');
            }
            resumeEngine();
            ispaused = false;
            avatarButton.button = await Sprite.load("screen/pause.png");
          }
        }
      },
    );

    add(avatarButton);
    add(SpriteButtonComponent(
        button: await Sprite.load("screen/back.png"),
        position: Vector2(20, 15),
        size: Vector2(30, 30),
        onPressed: () {
          if (isMusicOn) {
            FlameAudio.bgm.stop();
          }
          pauseEngine(); // Pause the game when navigating back to the home screen
          Navigator.pushAndRemoveUntil(
            buildContext!, // Pass the buildContext of the FlameGame
            MaterialPageRoute(builder: (context) => StartScreen()),
            (route) => false, // Remove all previous routes
          );
        }));
    add(SpriteButtonComponent(
        button: await Sprite.load("screen/settings.png"),
        position: Vector2(120, 15),
        size: Vector2(30, 30),
        onPressed: () {
          overlays.add('Settings');
          if (isMusicOn) {
            FlameAudio.bgm.stop();
          }
          pauseEngine(); // Pause the game when navigating back to the home screen
        }));

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
    isGameOver = true;

    obstacleTimer.stop();
    pauseEngine();

    // Check if current score is higher than saved high score
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
              fontFamily: GoogleFonts.montserrat().fontFamily)),
    );
    add(gameOverText);
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (!isGameOver) {
      teddyBear.jump();
    }
  }

  void resetGame() async {
    children
        .whereType<Obstacle>()
        .forEach((obstacle) => obstacle.removeFromParent());

    teddyBear.position = Vector2(500, groundY);
    teddyBear.reset();
    isGameOver = false;

    await _loadHighScore().then((xscore) async {
      if (xscore > highScore) {
        highScoreText.text = "Best Score: ${formatScore(xscore)}";
        await _saveHighScore(xscore);
      }
    });
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
    int highScore = box.get('highScore', defaultValue: 0);
    return highScore;
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
