// lib/man.dart

import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:jumpapp/obstacle.dart';
import 'super_dash_game.dart';

class Man extends PositionComponent
    with CollisionCallbacks, HasGameRef<SuperDashGame> {
  double velocityY = 0;
  bool isJumping = false;
  final double gravity = 800; // Pixels per second squared
  final double jumpSpeed = -400;

  double armAngle = 0; // For simple arm animation

  Man()
      : super(
          size: Vector2(50, 100), // Adjusted size for a taller figure
          anchor: Anchor.center,
        );

  @override
  FutureOr<void> onLoad() {
    // Add a hitbox for collision detection
    add(RectangleHitbox());
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    velocityY += gravity * dt;
    position.y += velocityY * dt;

    // Animate arm during jump
    if (isJumping) {
      armAngle += dt * 2; // Adjust the speed as needed
      if (armAngle > 0.5) {
        armAngle = 0.5;
      }
    } else {
      if (armAngle > 0) {
        armAngle -= dt * 2;
        if (armAngle < 0) armAngle = 0;
      }
    }

    // Ground collision
    double groundLevel =
        gameRef.size.y - 100; // Adjust based on your game's ground position
    if (position.y >= groundLevel - size.y / 2) {
      position.y = groundLevel - size.y / 2;
      velocityY = 0;
      isJumping = false;
      armAngle = 0;
    }
  }

  void jump() {
    if (!isJumping) {
      velocityY = jumpSpeed;
      isJumping = true;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Define paints
    final headPaint = Paint()..color = Colors.blue;
    final bodyPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 4;

    final limbPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 4;

    // Draw head
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 8),
      size.x / 8,
      headPaint,
    );

    // Draw body
    canvas.drawLine(
      Offset(size.x / 2, size.y / 4),
      Offset(size.x / 2, size.y * 0.6),
      bodyPaint,
    );

    // Draw arms with rotation
    canvas.save();
    // Left arm
    canvas.translate(size.x / 2, size.y / 3);
    canvas.rotate(armAngle);
    canvas.drawLine(
      Offset(0, 0),
      Offset(-size.x / 2, size.y / 6),
      limbPaint,
    );
    canvas.restore();

    canvas.save();
    // Right arm
    canvas.translate(size.x / 2, size.y / 3);
    canvas.rotate(-armAngle);
    canvas.drawLine(
      Offset(0, 0),
      Offset(size.x / 2, size.y / 6),
      limbPaint,
    );
    canvas.restore();

    // Draw legs
    canvas.drawLine(
      Offset(size.x / 2, size.y * 0.6),
      Offset(0, size.y),
      limbPaint,
    );
    canvas.drawLine(
      Offset(size.x / 2, size.y * 0.6),
      Offset(size.x, size.y),
      limbPaint,
    );
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

  // Corrected reset method without super.reset()
  void resetMan() {
    position = Vector2(50, gameRef.size.y - 100 - size.y / 2);
    velocityY = 0;
    isJumping = false;
    armAngle = 0;
  }

  void reset() {
    position = Vector2(50, gameRef.size.y - 100 - size.y / 2);
    velocityY = 0;
    isJumping = false;
    armAngle = 0;
  }
}
