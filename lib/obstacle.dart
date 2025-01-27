import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:teddyrun/constent/assets.dart';
import 'dart:math';

import 'package:teddyrun/super_dash_game.dart';

class Obstacle extends SpriteComponent
    with HasGameRef<SuperDashGame>, CollisionCallbacks {
  double baseSpeed = 400; // Base speed of the obstacle
  double speedMultiplier = 1.0; // Multiplier for increasing speed
  static const double minGap = 500; // Minimum gap between obstacles (distance)
  double lastSpawnPosition = 0; // To track the last spawn position of the obstacle

  Obstacle() : super(size: Vector2(100, 100), anchor: Anchor.bottomRight);

  @override
  Future<void> onLoad() async {
    // Load the sprite image for the obstacle
    sprite = await gameRef.loadSprite(Assets.treeImage);

    // Set the initial position off-screen to the right, with a random gap
    _resetPosition();

    // Add a hitbox that matches the obstacle's image size
    add(RectangleHitbox.relative(Vector2(0.6, 0.6), parentSize: size));

    await super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Increase speed multiplier every 1500 points
    if (gameRef.score % 1500 == 0 && gameRef.score != 0) {
      speedMultiplier = 1.0 + (gameRef.score ~/ 1500) * 0.1; // Increase by 10% for every 1500 points
    }

    // Calculate the current speed
    double speed = baseSpeed * speedMultiplier;

    // Update obstacle position with the new speed
    position.x -= speed * dt;

    // Check if the obstacle has moved off-screen
    if (position.x < -size.x) {
      // Reset the position with a gap logic for scores < 10,000
      _resetPosition();
    }
  }

  void _resetPosition() {
    double randomGap = _calculateGap(); // Calculate the gap dynamically

    // Set the new position off-screen to the right, considering the random gap
    position = Vector2(
      gameRef.size.x + size.x + randomGap,
      gameRef.groundY,
    );

    lastSpawnPosition = position.x; // Update the last spawn position
  }

  double _calculateGap() {
    // Increase gap if the score is less than 10,000
    if (gameRef.score < 10000) {
      return minGap + Random().nextDouble() * 1000; // Add a random gap between 500 and 1500
    } else {
      // For higher scores, keep the gap smaller
      return minGap + Random().nextDouble() * 500; // Add a random gap between 500 and 1000
    }
  }
}
