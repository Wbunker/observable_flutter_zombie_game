import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/animation.dart';
import 'package:observable_zombies/components/components.dart';
import 'package:observable_zombies/components/line_component.dart';
import 'package:observable_zombies/constants.dart';
import 'package:observable_zombies/gen/assets.gen.dart';
import 'package:observable_zombies/utilities/utilities.dart';
import 'package:observable_zombies/zombie_game.dart';

enum ZombieState { wander, chase }

class Zombie extends SpriteComponent
    with HasGameReference<ZombieGame>, UnwalkableTerrainChecker {
  Zombie({super.position}) : super(anchor: Anchor.center, priority: 1) {
    halfSize = size / 2;
  }

  Vector2 movement = Vector2.zero();
  double speed = zombieTilesPerSecond * worldTileSize;
  final double maximumFollowDistance = worldTileSize * 10;
  late Vector2 halfSize;
  late Vector2 maxPosition;

  late ZombieState state;

  Random rnd = Random();

  Vector2? wanderPath;

  /// The maximum angle to the left (and/or right) the zombie will veer between.
  static const maxVeerDeg = 45;
  static const minimumVeerDurationMs = 3000;
  static const maximumVeerDurationMs = 6000;
  late Duration veerDuration;
  late DateTime veerStartedAt;
  late bool clockWiseVeerFirst;

  static const minimumLurchDurationMs = 300;
  static const maximumLurchDurationMs = 1500;
  late Duration lurchDuration;
  late DateTime lurchStartedAt;
  late Curve lurchCurve;

  static const minimumWanderDelta = -3;
  static const maximumWanderDelta = 3;
  int? wanderDeltaDeg;
  DateTime? wanderStartedAt;

  /// Amount of time to follow a given wander path before resetting
  Duration? wanderLength;

  final curves = <Curve>[
    Curves.easeIn,
    Curves.easeInBack,
    Curves.easeInOut,
    Curves.easeInOutBack,
  ];

  @override
  void onLoad() {
    maxPosition = game.worldSize - halfSize;
    sprite = Sprite(game.images
        .fromCache(Assets.characters.zombie.poses.zombieCheer1.path));

    setVeer();
    setLurch();
    setStateToWander();
  }

  void setVeer() {
    veerStartedAt = DateTime.now();
    veerDuration = Duration(
      milliseconds: rnd.nextInt(maximumVeerDurationMs - minimumVeerDurationMs) +
          minimumVeerDurationMs,
    );
    clockWiseVeerFirst = rnd.nextBool();
  }

  void setLurch() {
    lurchStartedAt = DateTime.now();
    lurchDuration = Duration(
      milliseconds:
          rnd.nextInt(maximumLurchDurationMs - minimumLurchDurationMs) +
              minimumLurchDurationMs,
    );
    curves.shuffle();
    lurchCurve = curves.first;
  }

  LineComponent? visualizedPathToPlayer;

  @override
  void update(double dt) {
    updateState();
    final pathToPlayer = Line(position, game.zombieWorld.player.position);
    switch (state) {
      case (ZombieState.wander):
        wander(dt);
      case (ZombieState.chase):
        chase(pathToPlayer, dt);
    }
  }

  void updateState() {
    final pathToPlayer = Line(position, game.zombieWorld.player.position);
    if (pathToPlayer.length > maximumFollowDistance) {
      if (state != ZombieState.wander) {
        setStateToWander();
      }
    } else {
      state = ZombieState.chase;
    }
  }

  void setStateToWander() {
    state = ZombieState.wander;
    wanderPath = getRandomWanderPath();
    wanderStartedAt = DateTime.now();
    wanderDeltaDeg ??= rnd.nextInt(maximumWanderDelta - minimumWanderDelta) +
        minimumWanderDelta;
    wanderLength = const Duration(milliseconds: 1500);
  }

  void wander(double dt) {
    if (DateTime.now().difference(wanderStartedAt!) > wanderLength!) {
      setStateToWander();
    }
    wanderPath = wanderPath!..rotate(wanderDeltaDeg! * degrees2Radians);
    applyMovement(wanderPath!, applyLurch(dt / 2));
  }

  Vector2 getRandomWanderPath() {
    int deg = rnd.nextInt(360);
    return Vector2(1, 0)..rotate(deg * degrees2Radians);
  }

  void chase(Line pathToPlayer, double dt) {
    wanderPath = null;
    wanderDeltaDeg = null;
    final pathToTake = applyVeerToPath(pathToPlayer);
    _debugPathFinding(pathToTake);
    moveAlongPath(pathToTake, dt);
  }

  Line applyVeerToPath(Line path) {
    // Percentage into the total veer we currently are
    double percentVeered =
        DateTime.now().difference(veerStartedAt).inMilliseconds /
            veerDuration.inMilliseconds;

    if (percentVeered > 1.0) {
      setVeer();
      percentVeered = 0;
    }

    late double veerAngleDeg;
    if (percentVeered < 0.25) {
      veerAngleDeg = maxVeerDeg * percentVeered * 4;
    } else if (percentVeered < 0.5) {
      veerAngleDeg = (0.5 - percentVeered) * 4 * maxVeerDeg;
    } else if (percentVeered < 0.75) {
      veerAngleDeg = -(maxVeerDeg * (percentVeered - 0.5) * 4);
    } else {
      veerAngleDeg = -(1 - percentVeered) * 4 * maxVeerDeg;
    }
    if (!clockWiseVeerFirst) {
      veerAngleDeg = veerAngleDeg * -1;
    }

    final rotated = path.vector2..rotate(veerAngleDeg * degrees2Radians);
    return Line(
      path.start,
      path.start + rotated,
    );
  }

  void moveAlongPath(Line pathToPlayer, double dt) {
    Line? collision = _getUnwalkableCollision(pathToPlayer);

    if (collision != null) {
      final distanceToStart =
          Line(game.zombieWorld.player.position, collision.start).length2;
      final distanceToEnd =
          Line(game.zombieWorld.player.position, collision.end).length2;
      if (distanceToStart < distanceToEnd) {
        pathToPlayer = Line(position, collision.start).extend(1.5);
      } else {
        pathToPlayer = Line(position, collision.end).extend(1.5);
      }
    }

    final movement = pathToPlayer.vector2.normalized();
    applyMovement(movement, applyLurch(dt));
  }

  void applyMovement(Vector2 movement, double dt) {
    final originalPosition = position.clone();
    final movementThisFrame = movement * speed * dt;
    position.add(movementThisFrame);
    checkMovement(
      movementThisFrame: movementThisFrame,
      originalPosition: originalPosition,
    );
  }

  double applyLurch(double speed) {
    double percentLurched =
        DateTime.now().difference(lurchStartedAt).inMilliseconds /
            lurchDuration.inMilliseconds;
    if (percentLurched > 1.0) {
      setLurch();
      percentLurched = 0;
    }
    percentLurched = Curves.easeIn.transform(percentLurched);
    return percentLurched * speed;
  }

  Line? _getUnwalkableCollision(pathToPlayer) {
    Vector2? nearestIntersection;
    double? shortestLength;
    Line? unwalkableBoundary;
    for (final line in game.zombieWorld.unwalkableTerrainEdges) {
      Vector2? intersection = pathToPlayer.intersectsAt(line);
      if (intersection != null) {
        if (nearestIntersection == null) {
          nearestIntersection = intersection;
          shortestLength = Line(position, intersection).length2;
          unwalkableBoundary = line;
        } else {
          final lengthToThisPoint = Line(position, intersection).length2;
          if (lengthToThisPoint < shortestLength!) {
            shortestLength = lengthToThisPoint;
            nearestIntersection = intersection;
            unwalkableBoundary = line;
          }
        }
      }
    }
    return unwalkableBoundary;
  }

  void _debugPathFinding(Line pathToPlayer) {
    if (visualizedPathToPlayer == null) {
      visualizedPathToPlayer = LineComponent.blue(line: pathToPlayer);
      if (visualizedPathToPlayer != null) game.add(visualizedPathToPlayer!);
    } else {
      visualizedPathToPlayer?.line = pathToPlayer;
    }
  }
}
