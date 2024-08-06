import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:observable_zombies/components/components.dart';
import 'package:observable_zombies/utilities/utilities.dart';
import 'package:observable_zombies/constants.dart';
import 'package:observable_zombies/zombie_game.dart';

class ZombieWorld extends World with HasGameRef<ZombieGame> {
  ZombieWorld({super.children});

  final List<Land> land = [];
  late final Player player;
  final unwalkableTerrainEdges = <Line>[];
  late final TiledComponent<FlameGame<World>> map;
  late final Vector2 scaledSize;

  @override
  Future<void> onLoad() async {
    map = await TiledComponent.load('world.tmx', Vector2.all(worldTileSize));
    add(map);

    scaledSize = Vector2(map.tileMap.map.width.toDouble() * worldTileSize,
        map.tileMap.map.height.toDouble() * worldTileSize);

    final objectLayer = map.tileMap.getLayer<ObjectGroup>('Objects');

    if (objectLayer != null) {
      for (final TiledObject object in objectLayer.objects) {
        if (!object.isPolygon) continue;

        if (!object.properties.byName.containsKey('blocksMovement')) continue;

        final vertices = <Vector2>[];
        Vector2? lastPoint;
        Vector2? nextPoint;
        Vector2? firstPoint;
        for (final point in object.polygon) {
          nextPoint = Vector2((point.x + object.x) * worldScale,
              (point.y + object.y) * worldScale);
          firstPoint ??= nextPoint;
          vertices.add(nextPoint);

          // If there is a last point, or this is the end of the list, we have a
          // line to add to our cached list of lines
          if (lastPoint != null) {
            final line = Line(lastPoint.clone(), nextPoint.clone());
            unwalkableTerrainEdges.add(line);
          }
          lastPoint = nextPoint;
        }
        if (lastPoint != null && firstPoint != null) {
          unwalkableTerrainEdges
              .add(Line(lastPoint.clone(), firstPoint.clone()));
        }
        add(UnwalkableTerrain(vertices));
      }
    }

    for (final line in unwalkableTerrainEdges) {
      add(LineComponent.red(line: line, thickness: 3, debug: false));
    }

    final zombie =
        Zombie(position: Vector2(worldTileSize * 16.6, worldTileSize * 7.5));

    player = Player();
    addAll([player, zombie]);

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
