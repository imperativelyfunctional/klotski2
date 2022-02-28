import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game/game.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setPortrait();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: _MainPage(),
  ));
}

class _MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/guanyu-unicorn.jpg'),
              fit: BoxFit.cover)),
      child: Column(
        children: [
          Flexible(
            flex: 3,
            child: Container(
              alignment: Alignment.bottomCenter,
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: Image(
                  image: AssetImage('assets/images/hrd.png'),
                ),
              ),
            ),
          ),
          Flexible(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(50),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _GameButton(
                        normalImage: 'assets/images/menu.png',
                        pressedImage: 'assets/images/menu_on.png',
                        callback: () => {
                          Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => Game()))
                        },
                      ),
                      const _GameButton(
                          normalImage: 'assets/images/menu2.png',
                          pressedImage: 'assets/images/menu2_on.png'),
                      const _GameButton(
                          normalImage: 'assets/images/menu3.png',
                          pressedImage: 'assets/images/menu3_on.png'),
                    ]),
              )),
          const Spacer(
            flex: 1,
          )
        ],
      ),
    );
  }
}

class _GameButton extends StatefulWidget {
  final VoidCallback? callback;
  final String normalImage;
  final String pressedImage;

  const _GameButton(
      {required this.normalImage, required this.pressedImage, this.callback});

  @override
  State<StatefulWidget> createState() {
    return _GameButtonState();
  }
}

class _GameButtonState extends State<_GameButton> {
  bool normalState = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTapDown: (TapDownDetails _) {
          setState(() {
            normalState = false;
          });
        },
        onTapUp: (TapUpDetails _) {
          setState(() {
            normalState = true;
          });
          var callback = widget.callback;
          if (callback != null) {
            callback();
          }
        },
        onTapCancel: () {
          setState(() {
            normalState = true;
          });
        },
        child: Stack(
          children: [
            Opacity(
              opacity: normalState ? 1 : 0,
              child: Image(
                image: AssetImage(widget.normalImage),
              ),
            ),
            Opacity(
              opacity: normalState ? 0 : 1,
              child: Image(
                image: AssetImage(widget.pressedImage),
              ),
            )
          ],
        ));
  }
}
