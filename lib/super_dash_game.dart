import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:jumpapp/teady.dart';
import 'obstacle.dart';

class SuperDashGame extends FlameGame with TapDetector, HasCollisionDetection {
  late TeddyBear teddyBear;
  late Timer obstacleTimer;
  int score = 0;
  bool isGameOver = false;
  late TextComponent scoreText;
  late TextComponent highScoreText;
  int highScore = 0;

  double groundY = 0; // Will be set dynamically in onLoad

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
      text: 'High Score: $highScore',
      position: Vector2(size.x - 140, 31),
      textRenderer:
          TextPaint(style: TextStyle(color: Colors.green, fontSize: 18)),
    );

    // Initialize background, teddy bear, and score display
    add(Background(imagePath: 'background.jpg'));

    // Position the teddy bear at `groundY`
    teddyBear = TeddyBear()..position = Vector2(50, groundY);
    add(teddyBear);

    scoreText = TextComponent(
      text: 'Score: 0',
      position: Vector2(10, 30),
      textRenderer:
          TextPaint(style: TextStyle(color: Colors.black, fontSize: 18)),
    );
    add(scoreText);
    add(highScoreText);

    // Set up obstacle spawning every 2 seconds
    obstacleTimer = Timer(2, onTick: spawnObstacle, repeat: true);
    obstacleTimer.start();
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
        highScoreText.text = "High Score :$score";
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
      highScoreText.text = 'High Score: $highScore';
    }

    // Display a game-over message
    final gameOverText = TextComponent(
      text: 'Game Over!',
      position: Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
      textRenderer:
          TextPaint(style: TextStyle(color: Colors.red, fontSize: 30)),
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
    teddyBear.position = Vector2(50, groundY);
    teddyBear.reset();
    isGameOver = false;

    await _loadHighScore().then((xscore) async {
      if (xscore > highScore) {
        highScoreText.text = "High Score :$xscore";
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
}
