import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:teddyrun/constent/assets.dart';
import 'dart:math';

import 'package:teddyrun/super_dash_game.dart';

class Obstacle extends SpriteComponent
    with HasGameRef<SuperDashGame>, CollisionCallbacks {
  double baseSpeed = 200; // Base speed of the obstacle
  double speedMultiplier = 1.0; // Multiplier for increasing speed

  Obstacle() : super(size: Vector2(100, 100), anchor: Anchor.bottomRight);

  @override
  Future<void> onLoad() async {
    // Load the sprite image for the obstacle
    sprite = await gameRef.loadSprite(Assets.treeImage);

    // Set initial position off-screen to the right, so it moves into view
    position = Vector2(
        gameRef.size.x + size.x + Random().nextDouble() * gameRef.size.x,
        gameRef.groundY);

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

    // Remove obstacle when off-screen
    if (position.x < -size.x) {
      removeFromParent();
    }
  }
}
