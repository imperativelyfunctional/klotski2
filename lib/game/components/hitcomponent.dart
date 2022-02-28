import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class HintComponent extends PositionComponent {
  Color color1;
  Color color2;
  double side;
  late Paint fill;
  int counter = 0;
  bool taken = false;

  HintComponent(
      {required this.color1, required this.color2, required this.side}) {
    fill = Paint()
      ..color = color1
      ..style = PaintingStyle.fill;
  }

  @override
  Future<void>? onLoad() {
    add(
      RectangleComponent(size: Vector2(side, side), paint: fill),
    );
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (counter % 22 == 21) {
      if (fill.color == color1) {
        fill.color = color2;
      } else {
        fill.color = color1;
      }
    }
    counter = (counter + 1) % 22;
  }
}
