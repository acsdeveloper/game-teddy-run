import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:flutter/material.dart';
import 'package:jumpapp/obstacle.dart';
import 'super_dash_game.dart'; // Ensure correct import if needed

class Player extends RectangleComponent
    with HasGameRef<SuperDashGame>, CollisionCallbacks {
  double velocityY = 0;
  bool isJumping = false;
  final double gravity = 800; // Pixels per second squared
  final double jumpSpeed = -400;

  Player()
      : super(
          size: Vector2(50, 50),
          paint: Paint()..color = Colors.blue,
        );

  @override
  void update(double dt) {
    super.update(dt);
    velocityY += gravity * dt;
    position.y += velocityY * dt;

    // Ground collision
    if (position.y >= gameRef.size.y - 100 - size.y / 2) {
      position.y = gameRef.size.y - 100 - size.y / 2;
      velocityY = 0;
      isJumping = false;
    }
  }

  void jump() {
    if (!isJumping) {
      velocityY = jumpSpeed;
      isJumping = true;
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    // Handle collision with obstacles
    if (other is Obstacle) {
      gameRef.overlays.add('GameOver');
      gameRef.pauseEngine();
    }
  }

  @override
  FutureOr<void> onLoad() {
    add(RectangleHitbox());
    return super.onLoad();
  }
}
