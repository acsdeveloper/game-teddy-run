// lib/teddy_bear.dart

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:vibration/vibration.dart';
import 'super_dash_game.dart';
import 'obstacle.dart';
import 'dart:math';

class TeddyBear extends SpriteAnimationComponent
    with HasGameRef<SuperDashGame>, CollisionCallbacks {
  late SpriteAnimation walkAnimation;
  late SpriteAnimation jumpAnimation;
  late SpriteAnimation collisionAnimation;
  late SpriteAnimation runningAnimation; // Add running animation
  late SpriteAnimationTicker collisionTicker;
  bool isJumping = false;
  bool isColliding = false;
  bool isRunning = false; // Track running state

  final double initialVelocityY = 1200; // Vertical speed for higher jump
  final double gravity = 400; // Gravity to control the descent
  double time = 0; // Track jump time
  late double velocityY; // Vertical velocity

  TeddyBear()
      : super(
          size: Vector2(70, 100), // Adjust the size if necessary
          anchor: Anchor.bottomCenter,
        );

  @override
  Future<void> onLoad() async {
    // Set initial position on the left side of the screen
    position = Vector2(100, gameRef.groundY); // Starting on the ground

    // Load walk animation frames
    final walkImages = await gameRef.images.loadAll([
      'NUDE/03-Walk/01-Walk/FA_TEDDY_Walk_000.png',
      'NUDE/03-Walk/01-Walk/FA_TEDDY_Walk_001.png',
      'NUDE/03-Walk/01-Walk/FA_TEDDY_Walk_002.png',
      'NUDE/03-Walk/01-Walk/FA_TEDDY_Walk_003.png',
      'NUDE/03-Walk/01-Walk/FA_TEDDY_Walk_004.png',
      'NUDE/03-Walk/01-Walk/FA_TEDDY_Walk_005.png',
      'NUDE/03-Walk/01-Walk/FA_TEDDY_Walk_006.png',
      'NUDE/03-Walk/01-Walk/FA_TEDDY_Walk_007.png',
      'NUDE/03-Walk/01-Walk/FA_TEDDY_Walk_008.png',
      'NUDE/03-Walk/01-Walk/FA_TEDDY_Walk_009.png',
    ]);
    walkAnimation = SpriteAnimation.spriteList(
      walkImages.map((image) => Sprite(image)).toList(),
      stepTime: 0.1,
    );

    // Load jump animation frames
    final jumpImages = await gameRef.images.loadAll([
      'NUDE/06-Jump/03-Jump_Throw/FA_TEDDY_Jump_Throw_000.png',
      'NUDE/06-Jump/03-Jump_Throw/FA_TEDDY_Jump_Throw_001.png',
      'NUDE/06-Jump/03-Jump_Throw/FA_TEDDY_Jump_Throw_002.png',
      'NUDE/06-Jump/03-Jump_Throw/FA_TEDDY_Jump_Throw_003.png',
      'NUDE/06-Jump/03-Jump_Throw/FA_TEDDY_Jump_Throw_004.png',
      'NUDE/06-Jump/03-Jump_Throw/FA_TEDDY_Jump_Throw_005.png',
      'NUDE/06-Jump/03-Jump_Throw/FA_TEDDY_Jump_Throw_006.png',
      'NUDE/06-Jump/03-Jump_Throw/FA_TEDDY_Jump_Throw_007.png',
    ]);
    jumpAnimation = SpriteAnimation.spriteList(
      jumpImages.map((image) => Sprite(image)).toList(),
      stepTime: 0.3,
    );

    // Load collision animation frames
    final collisionImages = await gameRef.images.loadAll([
      'NUDE/08-Dead/FA_TEDDY_Dead_008.png',
      'NUDE/08-Dead/FA_TEDDY_Dead_009.png',
    ]);
    collisionAnimation = SpriteAnimation.spriteList(
      collisionImages.map((image) => Sprite(image)).toList(),
      stepTime: 0.1,
      loop: false, // Play once upon collision
    );

    // Load running animation frames
    final runningImages = await gameRef.images.loadAll([
      'NUDE/04-Run/FA_TEDDY_Run_000.png',
      'NUDE/04-Run/FA_TEDDY_Run_001.png',
      'NUDE/04-Run/FA_TEDDY_Run_002.png',
      'NUDE/04-Run/FA_TEDDY_Run_003.png',
      'NUDE/04-Run/FA_TEDDY_Run_004.png',
      'NUDE/04-Run/FA_TEDDY_Run_005.png',
      'NUDE/04-Run/FA_TEDDY_Run_006.png',
      'NUDE/04-Run/FA_TEDDY_Run_007.png',
    ]);
    runningAnimation = SpriteAnimation.spriteList(
      runningImages.map((image) => Sprite(image)).toList(),
      stepTime: 0.07, // Faster animation for running
    );

    // Initialize collision ticker to detect when collision animation finishes
    collisionTicker = collisionAnimation.createTicker();

    // Start with the walk animation
    animation = walkAnimation;

    // Flip the teddy bear to face right-to-left
    scale = Vector2(-1, 1);

    // Add a hitbox
    add(RectangleHitbox.relative(Vector2(0.2, 0.2),
        parentSize: size, isSolid: true));
  }

  // Method to trigger the jump with vertical motion only
void jump() {
  if (!isJumping && !isColliding) {
    isJumping = true;
    animation = jumpAnimation;
    time = 0;

    // Set initial vertical velocity dynamically based on obstacle speed
    double obstacleSpeed = gameRef.baseObstacleSpeed * gameRef.speedMultiplier;
    velocityY = obstacleSpeed * 4; // Adjust multiplier as needed for jump height
  }
}


  // Override update to simulate vertical jump motion and handle collision animation
  @override
  void update(double dt) {
    super.update(dt);

    // Switch to running animation if score is above 1000
    if (gameRef.score > 800 && !isJumping && !isColliding && !isRunning) {
      animation = runningAnimation;
      isRunning = true;
    } else if (gameRef.score <= 800 &&
        !isJumping &&
        !isColliding &&
        isRunning) {
      animation = walkAnimation;
      isRunning = false;
    }

    if (isJumping) {
      // Update time
      time += dt;

      // Update position for vertical motion
      position.y -= (velocityY * dt - 0.5 * gravity * pow(time, 2));

      // Check if teddy has landed back on the ground
      if (position.y >= gameRef.groundY) {
        position.y = gameRef.groundY; // Reset to ground level
        animation = isRunning
            ? runningAnimation
            : walkAnimation; // Switch back to appropriate animation
        isJumping = false; // Reset jumping state
      }
    }

    // Check if collision animation has completed
    if (isColliding) {
      collisionTicker.update(dt);
      gameRef.obstacleTimer.stop();
      gameRef.overlays.add('GameOver');

      if (collisionTicker.done()) {
        // Show Game Over overlay
        gameRef.isGameOver = true;

        gameRef.pauseEngine(); // Pause the game
      }
    }
  }

  // Handle collision with obstacles
  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (other is Obstacle && !isColliding) {
      FlameAudio.bgm.stop();
      Vibration.hasVibrator().then((hasVibrator) {
        if (hasVibrator ?? false) {
          Vibration.vibrate(duration: 80); // Vibrate for 100ms
        }
      });
      // Trigger collision animation only if not already colliding
      isColliding = true;
      animation = collisionAnimation; // Set collision animation
      //collisionTicker.reset(); // Start the collision ticker
    }
  }

  void reset() {
    position = Vector2(75, gameRef.groundY); // Reset to starting position
    isJumping = false;
    isColliding = false;
    isRunning = false; // Reset running state
    animation = walkAnimation; // Reset to walk animation
  }
}
