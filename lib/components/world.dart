import 'package:flame/components.dart';
import 'package:observable_zombies/components/components.dart';
import 'package:observable_zombies/gen/assets.gen.dart';
import 'package:observable_zombies/zombie_game.dart';

class ZombieWorld extends World with HasGameRef<ZombieGame> {
  ZombieWorld({super.children});

  final List<Land> land = [];
  late final Player player;

  @override
  Future<void> onLoad() async {
    final greenlandImage = game.images.fromCache(Assets.town.tile0000.path);
    land.add(Land(position: Vector2(50, 50), sprite: Sprite(greenlandImage)));
    add(land.first);

    final playerImage = game.images
        .fromCache(Assets.characters.adventurer.adventurerTilesheet.path);
    player = Player(position: Vector2(100, 100), sprite: Sprite(playerImage));
    add(player);
    await super.onLoad();
  }
}
