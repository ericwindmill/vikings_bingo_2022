import 'package:flutter/material.dart';
import 'package:vikings_bingo/src/style/spacing.dart';

import '../../style/button_style.dart';
import '../shared/shooting_stars_background.dart';

class StartPage extends StatelessWidget {
  const StartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Flutter Vikings',
                  style: TextStyle(fontSize: 22.0),
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: EdgeInsets.only(
                    bottom: spacingUnit * 10,
                    top: spacingUnit * 5,
                  ),
                  child: Text(
                    'Bingo 3000',
                    style: TextStyle(fontSize: 30.0),
                    textAlign: TextAlign.center,
                  ),
                ),
                OutlinedButton(
                  style: outlineButtonStyle,
                  onPressed: () {
                    // TODO: Biz logic: Register as player in Firebase game or whatever
                    Navigator.pushReplacementNamed(context, '/setup');
                  },
                  child: const Text('Join Game'),
                ),
              ],
            ),
          ),
          SizedBox.expand(
            child: Visibility(
              visible: true,
              child: IgnorePointer(
                child: ShootingStarsBackground(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
