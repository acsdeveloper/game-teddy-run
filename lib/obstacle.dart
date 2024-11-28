import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:teddyRun/constent/assets.dart';
import 'dart:math';

import 'package:teddyRun/super_dash_game.dart';

class Obstacle extends SpriteComponent
    with HasGameRef<SuperDashGame>, CollisionCallbacks {
  double baseSpeed = 400; // Base speed of the obstacle
  // Path to your obstacle image

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

    // Increase speed based on score
    double speed = baseSpeed + (gameRef.score / 10).clamp(0, 80000);
// Limit speed increase

    // Update obstacle position with the new speed
    position.x -= speed * dt;

    // Remove obstacle when off-screen
    if (position.x < -size.x) {
      removeFromParent();
    }
  }

  // Method to generate a random height between 100 and 150
}
