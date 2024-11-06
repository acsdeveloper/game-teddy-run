import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'package:flutter/material.dart';
import 'package:jumpapp/super_dash_game.dart';
import 'dart:math'; // Import the math library for random number generation

class Obstacle extends SpriteComponent
    with HasGameRef<SuperDashGame>, CollisionCallbacks {
  final double speed = 200; // Pixels per second
  final String imagePath = 'tree/t1.png'; // Path to your obstacle image
  static final Random _random = Random(); // Static Random instance

  Obstacle() : super(size: Vector2(100, 100), anchor: Anchor.bottomRight);

  @override
  Future<void> onLoad() async {
    // Load the sprite image for the obstacle
    sprite = await gameRef.loadSprite(imagePath);

    // Set initial position off-screen to the right, so it moves into view
    position = Vector2(gameRef.size.x + size.x, gameRef.groundY);

    // Add a hitbox that matches the obstacle's image size
    add(RectangleHitbox.relative(Vector2(0.6, 0.6), parentSize: size));

    await super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x -= speed * dt;

    // Remove obstacle when off-screen
    if (position.x < -size.x) {
      removeFromParent();
    }
  }

  // Method to generate a random height between 100 and 150
  static int _randomHeight() {
    return 100 +
        _random.nextInt(
            51); // Generates a random integer between 0 and 50, adds 100
  }
}

class Background extends SpriteComponent with HasGameRef<SuperDashGame> {
  final String imagePath;

  Background({required this.imagePath})
      : super(
          position: Vector2.zero(),
          size:
              Vector2.zero(), // Will be set in onLoad based on the image's size
          anchor: Anchor.topLeft,
        );

  @override
  Future<void>? onLoad() async {
    // Load the background image sprite
    sprite = await gameRef.loadSprite(imagePath);

    // Set the size to match the game's viewport
    size = gameRef.size;

    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Optionally, add additional rendering logic here
  }
}
