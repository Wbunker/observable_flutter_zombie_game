import 'package:flame/components.dart';
import 'package:observable_zombies/components/unwalkable_terrain.dart';
import 'package:observable_zombies/zombie_game.dart';

mixin UnwalkableTerrainChecker
    on PositionComponent, HasGameReference<ZombieGame> {
  void checkMovement({
    required Vector2 movementThisFrame,
    required Vector2 originalPosition,
  }) {
    if (movementThisFrame.y < 0) {
      // Moving up
      final newTop = positionOfAnchor(Anchor.topCenter);
      for (final component in game.zombieWorld.componentsAtPoint(newTop)) {
        if (component is UnwalkableTerrain) {
          movementThisFrame.y = 0;
          break;
        }
      }
    }
    if (movementThisFrame.y > 0) {
      // Moving down
      final newBottom = positionOfAnchor(Anchor.bottomCenter);
      for (final component in game.zombieWorld.componentsAtPoint(newBottom)) {
        if (component is UnwalkableTerrain) {
          movementThisFrame.y = 0;
          break;
        }
      }
    }
    if (movementThisFrame.x < 0) {
      // Moving left
      final newLeft = positionOfAnchor(Anchor.centerLeft);
      for (final component in game.zombieWorld.componentsAtPoint(newLeft)) {
        if (component is UnwalkableTerrain) {
          movementThisFrame.x = 0;
          break;
        }
      }
    }
    if (movementThisFrame.x > 0) {
      // Moving right
      final newRight = positionOfAnchor(Anchor.centerRight);
      for (final component in game.zombieWorld.componentsAtPoint(newRight)) {
        if (component is UnwalkableTerrain) {
          movementThisFrame.x = 0;
          break;
        }
      }
    }

    position = originalPosition..add(movementThisFrame);
    final halfSize = size / 2;
    position.clamp(halfSize, game.worldSize - halfSize);
  }
}
