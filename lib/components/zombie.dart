import 'package:flame/components.dart';
import 'package:observable_zombies/components/components.dart';
import 'package:observable_zombies/constants.dart';
import 'package:observable_zombies/gen/assets.gen.dart';
import 'package:observable_zombies/zombie_game.dart';

class Zombie extends SpriteComponent with HasGameReference<ZombieGame> {
  Zombie({super.position}) : super(anchor: Anchor.center, priority: 1) {
    halfSize = size / 2;
  }

  Vector2 movement = Vector2.zero();
  double speed = tilesPerSecond * worldTileSize;
  late Vector2 halfSize;
  late Vector2 maxPosition;

  @override
  void onLoad() {
    maxPosition = game.worldSize - halfSize;
    sprite = Sprite(game.images
        .fromCache(Assets.characters.zombie.poses.zombieCheer1.path));
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
}
