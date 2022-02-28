import 'dart:async' as async;

import 'package:audioplayers/audioplayers.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';

import 'components/hitcomponent.dart';
import 'components/menubutton.dart';
import 'components/piece.dart';

class Game extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GameWidget(game: Klotski()),
      ),
    );
  }
}

class Klotski extends FlameGame with PanDetector {
  bool running = true;
  late double tileWidth;
  Piece? current;
  late SpriteAnimationComponent victory;
  late AudioPlayer playingBGM;
  List<HintComponent> hints = [];

  @override
  void onPanDown(DragDownInfo info) {
    var touchPoint = info.eventPosition.game;
    if (running) {
      children.any((element) {
        if (element is Piece) {
          var potentialMoves =
              _potentialMoves(Vector2(element.x, element.y), element);
          if (element.containsPoint(touchPoint) && potentialMoves.isNotEmpty) {
            FlameAudio.audioCache.play('pickup.mp3');
            current = element;
            _showHints(potentialMoves, element);
            current!.addEffect(ColorEffect(
              Colors.deepOrange,
              const Offset(
                0.0,
                0.4,
              ),
              EffectController(
                duration: 1,
                reverseDuration: 1,
                infinite: true,
              ),
            ));
            return true;
          }
        }
        return false;
      });
    } else {
      children.any((element) {
        if (element is MenuButton && element.containsPoint(touchPoint)) {
          element.setOnState(true);
          element.onClick();
          return true;
        }
        return false;
      });
    }

    super.onPanDown(info);
  }

  void _showHints(List<Direction> potentialMoves, Piece piece) {
    for (var value in potentialMoves) {
      switch (value) {
        case Direction.up:
          hints.firstWhere((element) => !element.taken)
            ..x = piece.x
            ..y = piece.y - tileWidth
            ..taken = true;

          if (piece.width / tileWidth != 1) {
            hints.firstWhere((element) => !element.taken)
              ..x = piece.x + tileWidth
              ..y = piece.y - tileWidth
              ..taken = true;
          }
          break;
        case Direction.down:
          var d = piece.height / tileWidth;
          hints.firstWhere((element) => !element.taken)
            ..x = piece.x
            ..y = piece.y + d * tileWidth
            ..taken = true;
          if (piece.width / tileWidth != 1) {
            hints.firstWhere((element) => !element.taken)
              ..x = piece.x + tileWidth
              ..y = piece.y + d * tileWidth
              ..taken = true;
          }
          break;
        case Direction.left:
          hints.firstWhere((element) => !element.taken)
            ..x = piece.x - tileWidth
            ..y = piece.y
            ..taken = true;
          if (piece.height / tileWidth != 1) {
            hints.firstWhere((element) => !element.taken)
              ..x = piece.x - tileWidth
              ..y = piece.y + tileWidth
              ..taken = true;
          }
          break;
        case Direction.right:
          var hintComponent = hints.firstWhere((element) => !element.taken);
          if (piece.width == tileWidth) {
            hintComponent
              ..x = piece.x + tileWidth
              ..y = piece.y
              ..taken = true;
          } else {
            hintComponent
              ..x = piece.x + tileWidth * 2
              ..y = piece.y
              ..taken = true;
          }
          if (piece.height / tileWidth != 1) {
            var hintComponent = hints.firstWhere((element) => !element.taken);
            if (piece.width == tileWidth * 2) {
              hintComponent
                ..x = piece.x + tileWidth * 2
                ..y = piece.y + tileWidth
                ..taken = true;
            } else {
              hintComponent
                ..x = piece.x + tileWidth
                ..y = piece.y + tileWidth
                ..taken = true;
            }
          }
          break;
        case Direction.center:
          break;
      }
    }
  }

  List<Direction> potentialPawnMoves(Vector2 position) {
    List<Direction> directions = [];
    bool canMoveUp = position.y != 0 &&
        !children.any((element) =>
            element is Piece &&
            element.containsPoint(Vector2(
                position.x + tileWidth / 2, position.y - tileWidth / 2)));
    if (canMoveUp) {
      directions.add(Direction.up);
    }

    bool canMoveDown = position.y != tileWidth * 4 &&
        !children.any((element) =>
            element is Piece &&
            element.containsPoint(Vector2(
                position.x + tileWidth / 2, position.y + tileWidth * 1.5)));
    if (canMoveDown) {
      directions.add(Direction.down);
    }

    bool canMoveLeft = position.x != 0 &&
        !children.any((element) =>
            element is Piece &&
            element.containsPoint(Vector2(
                position.x - tileWidth / 2, position.y + tileWidth / 2)));
    if (canMoveLeft) {
      directions.add(Direction.left);
    }

    bool canMoveRight = position.x != tileWidth * 3 &&
        !children.any((element) =>
            element is Piece &&
            element.containsPoint(Vector2(
                position.x + tileWidth * 1.5, position.y + tileWidth / 2)));

    if (canMoveRight) {
      directions.add(Direction.right);
    }
    return directions;
  }

  List<Direction> potentialCommanderMoves(Vector2 position) {
    List<Direction> directions = [];
    bool canMoveUp = position.y != 0 &&
        !children.any((element) =>
            element is Piece &&
            element.containsPoint(Vector2(
                position.x + tileWidth / 2, position.y - tileWidth / 2))) &&
        !children.any(((element) =>
            element is Piece &&
            element.containsPoint(Vector2(
                position.x + tileWidth * 1.5, position.y - tileWidth / 2))));

    if (canMoveUp) {
      directions.add(Direction.up);
    }

    bool canMoveDown = position.y != tileWidth * 3 &&
        !children.any((element) =>
            element is Piece &&
            element.containsPoint(Vector2(
                position.x + tileWidth / 2, position.y + tileWidth * 2.5))) &&
        !children.any((element) =>
            element is Piece &&
            element.containsPoint(Vector2(
                position.x + tileWidth * 1.5, position.y + tileWidth * 2.5)));
    if (canMoveDown) {
      directions.add(Direction.down);
    }

    bool canMoveLeft = position.x != 0 &&
        !children.any((element) =>
            element is Piece &&
            element.containsPoint(Vector2(
                position.x - tileWidth / 2, position.y + tileWidth / 2))) &&
        !children.any((element) =>
            element is Piece &&
            element.containsPoint(Vector2(
                position.x - tileWidth / 2, position.y + tileWidth * 1.5)));
    if (canMoveLeft) {
      directions.add(Direction.left);
    }

    bool canMoveRight = position.x != tileWidth * 3 &&
        !children.any((element) =>
            element is Piece &&
            element.containsPoint(Vector2(
                position.x + tileWidth * 2.5, position.y + tileWidth / 2))) &&
        !children.any((element) =>
            element is Piece &&
            element.containsPoint(Vector2(
                position.x + tileWidth * 2.5, position.y + tileWidth * 1.5)));
    if (canMoveRight) {
      directions.add(Direction.right);
    }

    return directions;
  }

  List<Direction> potentialVerticalRectangleMoves(Vector2 position) {
    List<Direction> directions = [];

    bool canMoveUp = position.y != 0 &&
        !children.any((element) =>
            element is Piece &&
            element.containsPoint(Vector2(
                position.x + tileWidth / 2, position.y - tileWidth / 2)));
    if (canMoveUp) {
      directions.add(Direction.up);
    }

    bool canMoveDown = position.y != tileWidth * 3 &&
        !children.any((element) =>
            element is Piece &&
            element.containsPoint(Vector2(
                position.x + tileWidth / 2, position.y + tileWidth * 2.5)));
    if (canMoveDown) {
      directions.add(Direction.down);
    }

    bool canMoveLeft = position.x != 0 &&
        !children.any((element) =>
            element is Piece &&
            element.containsPoint(Vector2(
                position.x - tileWidth / 2, position.y + tileWidth / 2))) &&
        !children.any((element) =>
            element is Piece &&
            element.containsPoint(Vector2(
                position.x - tileWidth / 2, position.y + tileWidth * 1.5)));
    if (canMoveLeft) {
      directions.add(Direction.left);
    }

    bool canMoveRight = position.x != tileWidth * 3 &&
        !children.any((element) =>
            element is Piece &&
            element.containsPoint(Vector2(
                position.x + tileWidth * 1.5, position.y + tileWidth / 2))) &&
        !children.any((element) =>
            element is Piece &&
            element.containsPoint(Vector2(
                position.x + tileWidth * 1.5, position.y + tileWidth * 1.5)));
    if (canMoveRight) {
      directions.add(Direction.right);
    }

    return directions;
  }

  List<Direction> potentialHorizontalRectangleMoves(Vector2 position) {
    List<Direction> directions = [];

    bool canMoveUp = position.y != 0 &&
        !children.any((element) =>
            element is Piece &&
            element.containsPoint(Vector2(
                position.x + tileWidth / 2, position.y - tileWidth / 2))) &&
        !children.any((element) =>
            element is Piece &&
            element.containsPoint(Vector2(
                position.x + tileWidth * 1.5, position.y - tileWidth / 2)));
    if (canMoveUp) {
      directions.add(Direction.up);
    }

    bool canMoveDown = position.y != tileWidth * 4 &&
        !children.any((element) =>
            element is Piece &&
            element.containsPoint(Vector2(
                position.x + tileWidth / 2, position.y + tileWidth * 1.5))) &&
        !children.any((element) =>
            element is Piece &&
            element.containsPoint(Vector2(
                position.x + tileWidth * 1.5, position.y + tileWidth * 1.5)));
    if (canMoveDown) {
      directions.add(Direction.down);
    }

    bool canMoveLeft = position.x != 0 &&
        !children.any((element) =>
            element is Piece &&
            element.containsPoint(Vector2(
                position.x - tileWidth / 2, position.y + tileWidth / 2)));
    if (canMoveLeft) {
      directions.add(Direction.left);
    }

    bool canMoveRight = position.x != tileWidth * 2 &&
        !children.any((element) =>
            element is Piece &&
            element.containsPoint(Vector2(
                position.x + tileWidth * 2.5, position.y + tileWidth / 2)));
    if (canMoveRight) {
      directions.add(Direction.right);
    }

    return directions;
  }

  List<Direction> _potentialMoves(Vector2 position, Piece piece) {
    if (piece.width == piece.height) {
      //pawn
      if (piece.width == tileWidth) {
        return potentialPawnMoves(position);
      } // commander
      else {
        return potentialCommanderMoves(position);
      }
    } else if (piece.height - piece.width == piece.width) {
      return potentialVerticalRectangleMoves(position);
    } else {
      return potentialHorizontalRectangleMoves(position);
    }
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    if (current != null && running) {
      var touchPoint = info.eventPosition.game;
      var delta = info.delta.game;
      var initialPosition = current!.movements.last.destination;
      var potentialMoves = _potentialMoves(initialPosition, current!);
      if (delta.x > 0) {
        potentialMoves.any((element) {
          if (element == Direction.right) {
            if (touchPoint.x >=
                initialPosition.x + current!.width + tileWidth / 2) {
              current!.addAnimation(Movement(
                  direction: Direction.right,
                  destination: Vector2(
                      initialPosition.x + tileWidth, initialPosition.y)));
            }
            return true;
          }
          return false;
        });
      } else {
        potentialMoves.any((element) {
          if (element == Direction.left) {
            if (touchPoint.x + tileWidth / 2 <= initialPosition.x) {
              current!.addAnimation(Movement(
                  direction: Direction.left,
                  destination: Vector2(
                      initialPosition.x - tileWidth, initialPosition.y)));
            }
            return true;
          }
          return false;
        });
      }
      if (delta.y > 0) {
        potentialMoves.any((element) {
          if (element == Direction.down) {
            if (touchPoint.y >=
                initialPosition.y + current!.height + tileWidth / 2) {
              current!.addAnimation(Movement(
                  direction: Direction.down,
                  destination: Vector2(
                      initialPosition.x, initialPosition.y + tileWidth)));
            }
            return true;
          }
          return false;
        });
      } else {
        potentialMoves.any((element) {
          if (element == Direction.up) {
            if (touchPoint.y + tileWidth / 2 <= initialPosition.y) {
              current!.addAnimation(Movement(
                  direction: Direction.up,
                  destination: Vector2(
                      initialPosition.x, initialPosition.y - tileWidth)));
            }
            return true;
          }
          return false;
        });
      }
    }
    super.onPanUpdate(info);
  }

  @override
  void onPanEnd(DragEndInfo info) {
    if (running) {
      if (current != null) {
        FlameAudio.audioCache.play('dropoff.mp3');
      }
      for (var hint in hints) {
        hint.x = -200;
        hint.y = -200;
        hint.taken = false;
      }
      current?.stopEffect();
      current = null;
      super.onPanEnd(info);
    } else {
      {
        for (var value in children) {
          if (value is MenuButton) {
            value.setOnState(false);
          }
        }
      }
    }
  }

  @override
  void onPanCancel() {
    if (running) {
      current = null;
    }
    super.onPanCancel();
  }

  @override
  void onRemove() {
    playingBGM.pause();
    super.onRemove();
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    playingBGM = await FlameAudio.audioCache.loop('rain.mp3', volume: 0.2);
    _buildGameBoard();
  }

  void _buildGameBoard() async {
    playingBGM.resume();
    children.removeWhere(
        (element) => (element is Piece || element is HintComponent));
    hints.clear();
    running = true;
    tileWidth = (size / 4).x;
    add(SpriteComponent(
      sprite: Sprite(
        await images.load('lubu.jpg'),
      ),
    )
      ..x = 0
      ..y = 0
      ..width = tileWidth * 4
      ..height = tileWidth * 5);

    add(SpriteComponent(sprite: Sprite(await images.load('huarongdao.jpg')))
      ..x = tileWidth
      ..y = tileWidth * 4
      ..width = tileWidth * 2
      ..height = tileWidth);

    var color1 = Colors.blue.withAlpha(200);
    var color2 = Colors.lightGreen.withAlpha(200);

    var hintComponent =
        HintComponent(color1: color1, color2: color2, side: tileWidth);
    add(hintComponent);
    hints.add(hintComponent
      ..x = -200
      ..y = -200);
    var hintComponent2 =
        HintComponent(color1: color1, color2: color2, side: tileWidth);
    add(hintComponent2
      ..x = -200
      ..y = -200);
    hints.add(hintComponent2);

    var pawn = await images.load('pawn.jpg');
    var pawn2 = await images.load('pawn2.jpg');
    add(
      Piece(
        sprite: Sprite(pawn),
      )
        ..x = 0
        ..y = 0
        ..width = tileWidth
        ..height = tileWidth
        ..recordPosition(),
    );
    add(
      Piece(
        sprite: Sprite(pawn2),
      )
        ..x = tileWidth * 3
        ..y = 0
        ..width = tileWidth
        ..height = tileWidth
        ..recordPosition(),
    );
    add(
      Piece(
        sprite: Sprite(pawn),
      )
        ..x = tileWidth * 1
        ..y = tileWidth * 3
        ..width = tileWidth
        ..height = tileWidth
        ..recordPosition(),
    );
    add(
      Piece(
        sprite: Sprite(pawn2),
      )
        ..x = tileWidth * 2
        ..y = tileWidth * 3
        ..width = tileWidth
        ..height = tileWidth
        ..recordPosition(),
    );

    add(
      Piece(
          sprite: Sprite(await images.load('caocao.jpg')),
          callback: () {
            children.any((element) {
              if (element is Piece &&
                  element.y == tileWidth * 3 &&
                  element.x == tileWidth &&
                  element.width == element.height &&
                  element.width == tileWidth * 2) {
                victory.setOpacity(1);
                playingBGM.stop();
                FlameAudio.audioCache.play('winner.mp3');
                showMenu();
                element.stopEffect();
                running = false;
                return true;
              }
              return false;
            });
          })
        ..x = tileWidth
        ..y = tileWidth
        ..width = tileWidth * 2
        ..height = tileWidth * 2
        ..recordPosition(),
    );

    add(
      Piece(
        sprite: Sprite(await images.load('zhangfei.jpg')),
      )
        ..x = 0
        ..y = tileWidth
        ..width = tileWidth
        ..height = tileWidth * 2
        ..recordPosition(),
    );

    add(
      Piece(
        sprite: Sprite(await images.load('zhaoyun.jpg')),
      )
        ..x = tileWidth * 3
        ..y = tileWidth
        ..width = tileWidth
        ..height = tileWidth * 2
        ..recordPosition(),
    );

    add(
      Piece(
        sprite: Sprite(await images.load('machao.jpg')),
      )
        ..x = 0
        ..y = tileWidth * 3
        ..width = tileWidth
        ..height = tileWidth * 2
        ..recordPosition(),
    );

    add(Piece(
      sprite: Sprite(await images.load('guanyu.jpg')),
    )
      ..x = tileWidth
      ..y = 0
      ..width = tileWidth * 2
      ..height = tileWidth
      ..recordPosition());

    add(
      Piece(
        sprite: Sprite(await images.load('huangzhong.jpg')),
      )
        ..x = tileWidth * 3
        ..y = tileWidth * 3
        ..width = tileWidth
        ..height = tileWidth * 2
        ..recordPosition(),
    );

    var map = await images.load('map.jpg');
    var remainingY = size.y - tileWidth * 5;
    var scaleFactor = _getTargetDimension(Vector2(tileWidth * 4, remainingY),
        Vector2(map.width.toDouble(), map.height.toDouble()));
    add(SpriteComponent(
      sprite: Sprite(
        map,
      ),
    )
      ..scale = Vector2(scaleFactor, scaleFactor)
      ..x = 0
      ..y = tileWidth * 5);

    var round = await images.load('round.png');
    var spriteComponent = SpriteComponent(sprite: Sprite(round))
      ..x = tileWidth * 2
      ..y = tileWidth * 5
      ..width = tileWidth * 2
      ..height = (round.height * tileWidth * 2) / round.width
      ..anchor = Anchor.topCenter;
    add(spriteComponent);

    victory = SpriteAnimationComponent(
      animation: SpriteAnimation.spriteList(
        await Future.wait([0, 1, 2].map((i) => Sprite.load('victory_$i.png'))),
        stepTime: 0.3,
      ),
      size: Vector2.all(64.0),
    )
      ..x = tileWidth * 2
      ..y = tileWidth * 2.5
      ..width = tileWidth * 2
      ..anchor = Anchor.center
      ..height = tileWidth;
    victory.scale = Vector2(2, 2);
    victory.setOpacity(0);
    add(victory);
  }

  void showMenu() {
    async.Timer(const Duration(seconds: 5), () async {
      victory.setOpacity(0);
      add(RectangleComponent(
          size: size,
          position: Vector2(0, 0),
          paint: Paint()..color = Colors.black.withAlpha(130)));
      var winningImage = await images.load('winning-menu.png');
      var menu = SpriteComponent(sprite: Sprite(winningImage))
        ..size = Vector2(
            size.x * .9, size.x * .9 * winningImage.height / winningImage.width)
        ..position = Vector2(size.x * .05, tileWidth);
      add(menu);
      var backImage = Sprite(await images.load('ingame-menu-back.png'));
      var backOnImage = Sprite(await images.load('ingame-menu-back-on.png'));
      add(MenuButton(
        normal: backImage,
        pressed: backOnImage,
        onClick: () => {Navigator.pop(buildContext!)},
      )
        ..size = Vector2(size.x * .45,
            size.x * .45 * backImage.image.height / backImage.image.width)
        ..position = Vector2(
            size.x * .05,
            tileWidth +
                size.x * .9 * winningImage.height / winningImage.width +
                20));

      var resetImage = Sprite(await images.load('ingame-menu-reset.png'));
      var resetOnImage = Sprite(await images.load('ingame-menu-reset-on.png'));
      add(MenuButton(
        normal: resetImage,
        pressed: resetOnImage,
        onClick: () => {_buildGameBoard()},
      )
        ..size = Vector2(size.x * .45,
            size.x * .45 * resetImage.image.height / resetImage.image.width)
        ..position = Vector2(
            size.x * .5,
            tileWidth +
                size.x * .9 * winningImage.height / winningImage.width +
                20));
    });
  }

  double _getTargetDimension(Vector2 target, Vector2 source) {
    if (target.x * source.y < target.y * source.x) {
      var xScale = source.x / target.x;
      var yScale = source.y / target.y;
      if (xScale < yScale) {
        return 1 / yScale;
      } else {
        return 1 / xScale;
      }
    } else {
      var xScale = target.x / source.x;
      var yScale = target.y / source.y;
      if (xScale > yScale) {
        return xScale;
      } else {
        return yScale;
      }
    }
  }
}
