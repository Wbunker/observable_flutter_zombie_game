import 'dart:ui';

import 'package:flame/components.dart';

class UnwalkableTerrain extends PolygonComponent {
  UnwalkableTerrain(super.vertices) {
    // Define a Paint object with a semi-transparent color
    paint = Paint()
      ..color =
          const Color(0x00000000); // 0x88 is the alpha value for 50% opacity
  }
}
