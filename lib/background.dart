import 'dart:ui';

import 'package:flame/components.dart';
import 'package:teddyRun/super_dash_game.dart';

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
