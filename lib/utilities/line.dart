import 'dart:math';
import 'package:equatable/equatable.dart';
import 'package:vector_math/vector_math_64.dart';

class Line extends Equatable {
  final Vector2 start;
  final Vector2 end;
  final Vector2 vector2;
  final double dx;
  final double dy;

  late final double length = sqrt(pow(dx, 2) + pow(dy, 2));
  late final double length2 = pow(dx, 2).toDouble() + pow(dy, 2).toDouble();

  Line(this.start, this.end)
      : vector2 = Vector2(end.x - start.x, end.y - start.y),
        dx = end.x - start.x,
        dy = end.y - start.y;

  factory Line.doubles(
    double startX,
    double startY,
    double endX,
    double endY,
  ) =>
      Line(Vector2(startX, startY), Vector2(endX, endY));

  List<double> asList() => [start.x, start.y, end.x, end.y];

  double? get slope {
    if (start.x == end.x) return null;
    return dy / dx;
  }

  Vector2 get center => (start + end) / 2;

  Line extend(double multiplier) {
    final longerVector = vector2 * multiplier;
    return Line(start, longerVector + start);
  }

  @override
  String toString() {
    return 'Line(start: $start, end: $end)';
  }

  double get angle => atan2(dy, dx);
  double get angleDeg => angle * radians2Degrees;

  Line copy() => Line.doubles(start.x, start.y, end.x, end.y);

  @override
  List<Object> get props => asList();

  Vector2? intersectsAt(Line other) {
    double s =
        (-dy * (start.x - other.start.x) + dx * (start.y - other.start.y)) /
            (-other.dx * dy + dx * other.dy);
    double t = (other.dx * (start.y - other.start.y) -
            other.dy * (start.x - other.start.x)) /
        (-other.dx * dy + dx * other.dy);

    if (s >= 0 && s <= 1 && t >= 0 && t <= 1) {
      // Collision!
      return Vector2(start.x + (t * dx), start.y + (t * dy));
    }
    return null;
  }

  bool intersects(Line other) {
    final a = end.y - start.y;
    final b = start.x - end.x;
    final c = a * start.x + b * start.y;

    final u = other.end.y - other.start.y;
    final v = other.start.x - other.end.x;
    final w = u * other.start.x + v * other.start.y;

    final det = a * v - u * b;

    if (det == 0) {
      return false;
    }

    final x = (v * c - b * w) / det;
    final y = (a * w - u * c) / det;

    return x >= start.x &&
        x <= end.x &&
        y >= start.y &&
        y <= end.y &&
        x >= other.start.x &&
        x <= other.end.x &&
        y >= other.start.y &&
        y <= other.end.y;
  }
}
