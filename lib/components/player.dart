import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:observable_zombies/constants.dart';
import 'package:observable_zombies/gen/assets.gen.dart';
import 'package:observable_zombies/utilities/utilities.dart';
import 'package:observable_zombies/zombie_game.dart';

class Player extends SpriteComponent
    with
        KeyboardHandler,
        HasGameReference<ZombieGame>,
        UnwalkableTerrainChecker {
  Player({super.position}) : super(anchor: Anchor.center, priority: 1) {
    halfSize = size / 2;
  }

  Vector2 movement = Vector2.zero();
  double speed = adventurerTilesPerSecond * worldTileSize;
  late Vector2 halfSize;
  late Vector2 maxPosition;

  @override
  void onLoad() {
    position = Vector2(worldTileSize * 9.6, worldTileSize * 2.5);
    maxPosition = game.worldSize - halfSize;
    sprite = Sprite(game.images
        .fromCache(Assets.characters.adventurer.poses.adventurerAction1.path));
  }

  @override
  void update(double dt) {
    final originalPosition = position.clone();

    final movementThisFrame = movement.normalized() * speed * dt;
    position.add(movement);

    checkMovement(
        movementThisFrame: movementThisFrame,
        originalPosition: originalPosition);
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
