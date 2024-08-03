import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:observable_zombies/components/components.dart';
import 'package:observable_zombies/constants.dart';
import 'package:observable_zombies/zombie_game.dart';

class ZombieWorld extends World with HasGameRef<ZombieGame> {
  ZombieWorld({super.children});

  final List<Land> land = [];
  late final Player player;
  late final TiledComponent<FlameGame<World>> map;
  late final Vector2 scaledSize;

  @override
  Future<void> onLoad() async {
    map = await TiledComponent.load('world.tmx', Vector2.all(worldTileSize));
    add(map);

    scaledSize = Vector2(map.tileMap.map.width.toDouble() * worldTileSize,
        map.tileMap.map.height.toDouble() * worldTileSize);

    player = Player();
    add(player);

    gameRef.cameraComponent.follow(player);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    setCameraBounds(size);
  }

  void setCameraBounds(Vector2 gameSize) {
    final rect = Rectangle.fromLTWH(gameSize.x / 2, gameSize.y / 2,
        scaledSize.x - gameSize.x, scaledSize.y - gameSize.y);

    gameRef.cameraComponent.setBounds(rect);
  }

  Vector2 get size => scaledSize;
}
