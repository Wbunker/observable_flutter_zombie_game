import 'package:flame/components.dart';
import 'package:flutter/services.dart';

class Player extends SpriteComponent with KeyboardHandler {
  Player({super.position, super.sprite}) : super(anchor: Anchor.center);

  Vector2 movement = Vector2.zero();
  double speed = 10;

  @override
  void update(double dt) {
    super.update(dt);
    position += movement.normalized() * speed * dt;
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent) {
      if (keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
        movement = Vector2(movement.x, -1);
        return true;
      } else if (keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
        movement = Vector2(movement.x, 1);
        return true;
      } else if (keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
        movement = Vector2(-1, movement.y);
        return true;
      } else if (keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
        movement = Vector2(1, movement.y);
        return true;
      }
    } else if (event is KeyUpEvent) {
      movement = Vector2.zero();
      return true;
    }

    return false;
  }
}
