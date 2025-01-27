import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:teddyrun/constent/assets.dart';
import 'dart:math';

import 'package:teddyrun/super_dash_game.dart';

class Obstacle extends SpriteComponent
    with HasGameRef<SuperDashGame>, CollisionCallbacks {
  double baseSpeed = 300; // Base speed of the obstacle
  double speedMultiplier = 1.0; // Multiplier for increasing speed

  Obstacle() : super(size: Vector2(100, 100), anchor: Anchor.bottomRight);

  @override
  Future<void> onLoad() async {
    // Load the sprite image for the obstacle
    sprite = await gameRef.loadSprite(Assets.treeImage);

if(gameRef.score>2000)
{
    // Set initial position off-screen to the right, so it moves into view
    position = Vector2(
        gameRef.size.x + size.x + Random().nextDouble() * gameRef.size.x,
        gameRef.groundY);
}          
else
{
   position = Vector2(
        gameRef.size.x + size.x  * gameRef.size.x,
        gameRef.groundY);
}
    // Add a hitbox that matches the obstacle's image size
    add(RectangleHitbox.relative(Vector2(0.6, 0.6), parentSize: size));

    await super.onLoad();
  }

  @override
void update(double dt) {
  super.update(dt);

  // Dynamically calculate the current speed
  double speed = baseSpeed * speedMultiplier;

  // Update position with the calculated speed
  position.x -= speed * dt;

  // Check if obstacle is off-screen and remove it
  if (position.x < -size.x) {
    removeFromParent();
  }
}

}
