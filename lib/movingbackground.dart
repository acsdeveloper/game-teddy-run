import 'package:flame/components.dart';
import 'package:flame/game.dart';

class MovingBackground extends SpriteComponent with HasGameRef<FlameGame> {
  final String imagePath;
  final double speed;

  MovingBackground({required this.imagePath, required this.speed});

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load(imagePath);
    size = Vector2(gameRef.size.x / 2, gameRef.size.y / 2); // Double the width
    position = Vector2(300, 0); // Start at the initial position
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x -= speed * dt; // Move to the left by `speed`

    // Loop the background
    if (position.x <= -gameRef.size.x + 300) {
      position.x += gameRef.size.x;
    }
  }
}
