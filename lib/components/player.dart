import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:observable_zombies/components/components.dart';
import 'package:observable_zombies/constants.dart';
import 'package:observable_zombies/gen/assets.gen.dart';
import 'package:observable_zombies/zombie_game.dart';

class Player extends SpriteComponent
    with KeyboardHandler, HasGameReference<ZombieGame> {
  Player({super.position}) : super(anchor: Anchor.center) {
    halfSize = size / 2;
  }

  Vector2 movement = Vector2.zero();
  double speed = tilesPerSecond * worldTileSize;
  late Vector2 halfSize;
  late Vector2 maxPosition;

  @override
  void onLoad() {
    position = Vector2(worldTileSize * 12.6, worldTileSize * 5.5);
    maxPosition = game.worldSize - halfSize;
    sprite = Sprite(game.images
        .fromCache(Assets.characters.adventurer.poses.adventurerAction1.path));
  }

  @override
  void update(double dt) {
    final originalPosition = position.clone();

    final movementThisFrame = movement.normalized() * speed * dt;
    position.add(movement);

    // moving up
    if (movement.y < 0) {
      // Moving up
      final newTop = positionOfAnchor(Anchor.topCenter);
      for (final component in game.zombieWorld.componentsAtPoint(newTop)) {
        if (component is UnwalkableTerrain) {
          movementThisFrame.y = 0;
          break;
        }
      }
    }
    // moving down
    if (movement.y > 0) {
      final newBottom = positionOfAnchor(Anchor.bottomCenter);
      for (Component component
          in game.zombieWorld.componentsAtPoint(newBottom)) {
        if (component is UnwalkableTerrain) {
          movementThisFrame.y = 0;
          break;
        }
      }
    }

    // moving left
    if (movement.x < 0) {
      final newLeft = positionOfAnchor(Anchor.centerLeft);
      for (Component component in game.zombieWorld.componentsAtPoint(newLeft)) {
        if (component is UnwalkableTerrain) {
          movementThisFrame.x = 0;
          break;
        }
      }
    }

    // moving right
    if (movement.x > 0) {
      final newRight = positionOfAnchor(Anchor.centerRight);
      for (Component component
          in game.zombieWorld.componentsAtPoint(newRight)) {
        if (component is UnwalkableTerrain) {
          movementThisFrame.x = 0;
          break;
        }
      }
    }

    position = originalPosition + movementThisFrame;
    position.clamp(halfSize, maxPosition);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    int yMovement = 0;
    int xMovement = 0;
    bool handled = false;
    if (keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
      yMovement += -1;
      handled = true;
    } else if (keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
      yMovement += 1;
      handled = true;
    } else if (keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      xMovement += -1;
      handled = true;
    } else if (keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      xMovement += 1;
      handled = true;
    }

    movement = Vector2(xMovement.toDouble(), yMovement.toDouble());
    return handled;
  }
}
