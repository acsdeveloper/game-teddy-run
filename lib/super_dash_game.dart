import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:teddyRun/background.dart';
import 'package:teddyRun/movingbackground.dart';
import 'package:teddyRun/teady.dart';

import 'obstacle.dart';

class SuperDashGame extends FlameGame with TapDetector, HasCollisionDetection {
  late TeddyBear teddyBear;
  late Timer obstacleTimer;
  int score = 0;
  bool isGameOver = false;
  late TextComponent scoreText;
  late TextComponent highScoreText;
  int highScore = 0;
  late MovingBackground movingBackground;

  double groundY = 0; // Will be set dynamically in onLoad
  bool ispaused = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Set `groundY` based on screen size to keep elements at the bottom
    groundY =
        size.y - 100; // Adjust offset (e.g., 100) to match your asset size

    // Load the high score from Hive
    highScore = await _loadHighScore();
    highScoreText = TextComponent(
      anchor: Anchor.topLeft,
      text: 'Best Score : $highScore',
      position: Vector2(size.x - 150, 31),
      textRenderer: TextPaint(
          style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontFamily: GoogleFonts.montserrat().fontFamily)),
    );

    // Initialize background, teddy bear, and score display
    // add(Background(
    //   imagePath: 'screen/background.jpg',
    // ));
    add(MovingBackground(
        imagePath: "screen/backgroundfn.png",
        invertimagePath: "screen/invertedbackground.png",
        speed: 400)
      ..size = Vector2(size.x * 5, size.y));
    add(MovingBackground(
        imagePath: "screen/cloud2.png",
        invertimagePath: "screen/cloud.png",
        speed: 20)
      ..size = Vector2(size.x, size.y / 3));
    // final button = ButtonComponent(
    //   button: TextComponent(
    //     size: Vector2(30, 30),
    //     text: ispaused ? "||" : "|>",
    //     textRenderer: TextPaint(
    //         style: const TextStyle(color: Colors.white, fontSize: 18)),
    //   ),
    //   onPressed: () {
    //     if (ispaused == false) {
    //       pauseEngine();
    //       ispaused = true;
    //     } else {
    //       resumeEngine();
    //       ispaused = false;
    //     }
    //   },
    //   position: Vector2(300, 10),
    // );

    // final button = HudButtonComponent(
    //   button: TextComponent(

    //     text: 'Back',
    //     textRenderer: TextPaint(
    //         style: const TextStyle(color: Colors.white, fontSize: 18)),
    //   ),
    //   onPressed: () {
    //     print('Back button pressed!');
    //   },
    //   position: Vector2(10, 10),
    // );

    // add(button);

    // Add moving background layer
    // movingBackground =
    //     MovingBackground(imagePath: 'mountain/cloud.png', speed: 200);
    // add(movingBackground);

    // Position the teddy bear at `groundY`
    obstacleTimer = Timer(2, onTick: spawnObstacle, repeat: true);
    teddyBear = TeddyBear()..position = Vector2(500, groundY);
    add(teddyBear);

    scoreText = TextComponent(
      text: 'Score: 0',
      position: Vector2(10, 30),
      textRenderer: TextPaint(
          style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontFamily: GoogleFonts.montserrat().fontFamily)),
    );
    add(scoreText);
    add(highScoreText);
    // Pause button

    // Set up obstacle spawning every 2 seconds

    obstacleTimer.start();
    teddyBear.isRunning = false;
  }

  @override
  void update(double dt) async {
    super.update(dt);

    if (!isGameOver) {
      obstacleTimer.update(dt);

      // Update score over time
      score += (dt * 90).toInt();
      scoreText.text = 'Score: $score';
      if (score > highScore) {
        highScore = score;
        highScoreText.text = "Best Score: $score";
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
      highScoreText.text = 'Best Score: $highScore';
    }

    // Display a game-over message
    final gameOverText = TextComponent(
      text: 'Game Over!',
      position: Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
      textRenderer: TextPaint(
          style: TextStyle(
              color: Colors.red,
              fontSize: 30,
              fontWeight: FontWeight.w900,
              fontFamily: GoogleFonts.montserrat().fontFamily)),
    );
    add(gameOverText);
  }

  @override
  void onTap() {
    if (!isGameOver) {
      teddyBear.jump();
    }
  }

  void resetGame() async {
    // Remove all obstacles and reset game state
    children
        .whereType<Obstacle>()
        .forEach((obstacle) => obstacle.removeFromParent());

    // Reset teddy bear position and game state
    teddyBear.position = Vector2(500, groundY);
    teddyBear.reset();
    isGameOver = false;

    await _loadHighScore().then((xscore) async {
      if (xscore > highScore) {
        highScoreText.text = "Best Score: $xscore";
        await _saveHighScore(xscore);
      }
    });
    score = 0;
    scoreText.text = 'Score: $score';

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

  void startGame() {
    // Set the game to started state and start the timer
    // isGameStarted = true;
    score = 0;
    scoreText.text = 'Score: $score';
    obstacleTimer.start();
    isGameOver = false;
    removeAll([
      children
          .whereType<TextComponent>()
          .firstWhere((child) => child.text == 'Start')
    ]);
  }
}
