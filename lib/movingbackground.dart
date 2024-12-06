import 'dart:developer';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/extensions.dart';

// class MovingBackground extends SpriteComponent with HasGameRef<FlameGame> {
//   final String imagePath;
//   final double speed;

//   MovingBackground({required this.imagePath, required this.speed});

//   @override
//   Future<void> onLoad() async {
//     sprite = await Sprite.load(imagePath);
//     size = Vector2(gameRef.size.x / 2, gameRef.size.y / 2); // Double the width
//     position = Vector2(300, 0); // Start at the initial position
//   }

//   @override
//   void update(double dt) {
//     super.update(dt);
//     position.x -= speed * dt; // Move to the left by `speed`

//     // Loop the background
//     if (position.x <= -gameRef.size.x + 300) {
//       position.x += gameRef.size.x;
//     }
//   }
// }
class MovingBackground extends PositionComponent {
  String? imagePath;
  String? invertimagePath;
  double speed;
  late Sprite sprite, sprite2;
  double offsetX = 0;
  bool shouldMove = true; // Flag to control movement

  MovingBackground({
    this.imagePath,
    this.invertimagePath,
    this.speed = 300,
  });

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load(imagePath!);
    sprite2 = await Sprite.load(invertimagePath!);
    size = Vector2(size.x, size.y); // Ensure the size matches the game canvas
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (shouldMove) {
      // Move background
      offsetX -= speed * dt;

      // Reset offset to create a seamless loop
      if (offsetX <= -size.x) {
        offsetX += size.x;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw the sprite twice to create a looping effect
    sprite.render(canvas, position: Vector2(offsetX, 0), size: size);

    sprite2.render(canvas,
        position: Vector2(offsetX + size.x - 20, 0), size: size);
    // sprite2.render(canvas, position: Vector2(offsetX + size.x, 0), size: size);
  }

  stop() {
    shouldMove = false;
    update(offsetX);
  }
}
