import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:observable_zombies/components/world.dart';

import 'gen/assets.gen.dart';

class ZombieGame extends FlameGame with HasKeyboardHandlerComponents {
  late final CameraComponent cameraComponent;
  final ZombieWorld _world;

  ZombieGame() : _world = ZombieWorld() {
    cameraComponent = CameraComponent(world: _world);
    images.prefix = '';
  }

  Vector2 get worldSize => _world.size;

  @override
  Future<void> onLoad() async {
    await images.loadAll([
      Assets.characters.adventurer.adventurerTilesheet.path,
      Assets.town.tile0000.path,
    ]);

    add(cameraComponent);
    add(_world);
  }
}
