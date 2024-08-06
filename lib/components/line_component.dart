import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:observable_zombies/components/components.dart';
import 'package:observable_zombies/utilities/utilities.dart';
import 'package:observable_zombies/zombie_game.dart';

class LineComponent extends CustomPainterComponent
    with HasGameReference<ZombieGame> {
  LineComponent({
    required this.line,
    this.debug = false,
    this.thickness = 1.0,
    this.color = const Color(0xFF000000),
  }) : super(
          anchor: Anchor.center,
          position: line.start,
          priority: 3,
          size: Vector2(line.length, 1),
        );

  factory LineComponent.red({
    required Line line,
    bool debug = false,
    double thickness = 3,
  }) =>
      LineComponent(
        line: line,
        color: const Color(0xFFFF0000),
        debug: debug,
        thickness: thickness,
      );

  factory LineComponent.green({
    required Line line,
    bool debug = false,
    double thickness = 3,
  }) =>
      LineComponent(
        line: line,
        color: const Color(0xFF00FF00),
        debug: debug,
        thickness: thickness,
      );

  factory LineComponent.blue({
    required Line line,
    bool debug = false,
    double thickness = 3,
  }) =>
      LineComponent(
        line: line,
        color: const Color(0xFF0000FF),
        debug: debug,
        thickness: thickness,
      );

  Line line;
  final Color color;
  late RectangleComponent child;
  bool debug;
  double thickness;

  ColoredSquare? start;
  ColoredSquare? end;
  ColoredSquare? middle;

  @override
  Future<void> onLoad() async {
    size = Vector2(line.dx.abs(), line.dy.abs());
    child = _LineRectComponent(
      size: Vector2(line.length, thickness),
      angle: line.angle,
      paint: Paint()..color = color,
      position: positionOfAnchor(anchor),
      priority: 3,
    );
    game.zombieWorld.add(child);

    if (debug) {
      start = ColoredSquare.red(line.start);
      game.zombieWorld.add(start!);
      end = ColoredSquare.blue(line.end);
      game.zombieWorld.add(end!);
      middle = ColoredSquare(line.center);
      game.zombieWorld.add(middle!);
    }
  }

  void clean() {
    if (start != null) {
      game.zombieWorld.remove(start!);
    }
    if (end != null) {
      game.zombieWorld.remove(end!);
    }
    if (middle != null) {
      game.zombieWorld.remove(middle!);
    }
    game.zombieWorld.remove(child);
    game.zombieWorld.remove(this);
  }

  @override
  void update(double dt) {
    position = line.start;
    child.size = Vector2(line.length, thickness);
    child.angle = line.angle;
    child.position = positionOfAnchor(anchor);
    super.update(dt);
  }

  Vector2 get lineCenter => line.center;

  @override
  void renderDebugMode(Canvas canvas) {
    return;
  }
}

class _LineRectComponent extends RectangleComponent {
  _LineRectComponent({
    required super.size,
    required super.angle,
    required super.paint,
    required super.position,
    required super.priority,
  });

  @override
  void renderDebugMode(Canvas canvas) {
    return;
  }
}
