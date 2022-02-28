import 'package:flame/components.dart';
import 'package:flutter/cupertino.dart';

class MenuButton extends SpriteComponent {
  Sprite normal;
  Sprite pressed;
  bool isPressed = false;
  VoidCallback onClick;

  MenuButton({
    required this.normal,
    required this.pressed,
    required this.onClick,
  });

  @override
  Future<void>? onLoad() {
    sprite = normal;
    return super.onLoad();
  }

  @override
  void update(double dt) {
    sprite = isPressed ? pressed : normal;
    super.update(dt);
  }

  void setOnState(bool on) {
    isPressed = on;
  }
}
