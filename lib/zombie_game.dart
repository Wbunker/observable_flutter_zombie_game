import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:observable_zombies/components/world.dart';

import 'gen/assets.gen.dart';

class ZombieGame extends FlameGame with HasKeyboardHandlerComponents {
  late final CameraComponent cameraComponent;
  final ZombieWorld zombieWorld;

  ZombieGame() : zombieWorld = ZombieWorld() {
    cameraComponent = CameraComponent(world: zombieWorld);
    images.prefix = '';
  }

  Vector2 get worldSize => zombieWorld.size;

  @override
  Future<void> onLoad() async {
    await images.loadAll([
      Assets.characters.adventurer.poses.adventurerAction1.path,
      Assets.characters.zombie.poses.zombieCheer1.path,
      Assets.town.tile0000.path,
    ]);

    // debugMode = true;
    addAll([
      zombieWorld,
      cameraComponent,
    ]);
  }
}
