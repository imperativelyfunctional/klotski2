import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';

enum Direction { up, down, left, right, center }

class Movement {
  Direction direction;
  Vector2 destination;

  Movement({required this.direction, required this.destination});
}

class Piece extends SpriteComponent {
  final speed = 500;
  final List<Movement> movements = [];
  int currentIndex = 0;
  late Effect effect;
  late VoidCallback? callback;

  Piece({required Sprite sprite, this.callback}) : super(sprite: sprite);

  void recordPosition() {
    movements
        .add(Movement(direction: Direction.center, destination: Vector2(x, y)));
  }

  void addEffect(Effect effect) {
    add(effect);
    this.effect = effect;
    effect.resume();
  }

  void playEffect() {
    effect.reset();
    effect.resume();
  }

  void stopEffect() {
    effect.reset();
    effect.pause();
  }

  @override
  void update(double dt) {
    if (currentIndex < movements.length) {
      final movement = movements[currentIndex];
      final destination = movement.destination;
      var destinationX = destination.x;
      var destinationY = destination.y;
      switch (movement.direction) {
        case Direction.right:
          {
            if (x + dt * speed > destinationX) {
              x = destinationX;
              if (callback != null) {
                callback!();
              }
            } else {
              x += dt * speed;
            }
            if (x == destinationX) {
              currentIndex++;
            }
            break;
          }
        case Direction.left:
          {
            if (x - dt * speed < destinationX) {
              x = destinationX;
              if (callback != null) {
                callback!();
              }
            } else {
              x -= dt * speed;
            }
            if (x == destinationX) {
              currentIndex++;
            }
            break;
          }
        case Direction.up:
          {
            if (y - dt * speed < destinationY) {
              y = destinationY;
              if (callback != null) {
                callback!();
              }
            } else {
              y -= dt * speed;
            }
            if (y == destinationY) {
              currentIndex++;
            }
            break;
          }
        case Direction.down:
          {
            if (y + dt * speed > destinationY) {
              y = destinationY;
              if (callback != null) {
                callback!();
              }
            } else {
              y += dt * speed;
            }
            if (y == destinationY) {
              currentIndex++;
            }
            break;
          }
        case Direction.center:
          {
            currentIndex++;
            break;
          }
      }
    }
  }

  void addAnimation(Movement movement) {
    movements.add(movement);
  }
}
