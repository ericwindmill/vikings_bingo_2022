import 'package:flutter/material.dart';
import 'package:vikings_bingo/src/style/spacing.dart';

import '../../style/button_style.dart';
import '../shared/shooting_stars_background.dart';

class StartPage extends StatelessWidget {
  final bool shouldSkipSetup;
  final bool loading;

  const StartPage({
    Key? key,
    required this.shouldSkipSetup,
    required this.loading,
  }) : super(key: key);

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
                  onPressed: loading
                      ? null
                      : () {
                          // if the player refreshed the browser, don't go through
                          // setup again, just get back to the game
                          if (!shouldSkipSetup) {
                            Navigator.pushReplacementNamed(context, '/setup');
                          } else {
                            Navigator.pushReplacementNamed(context, '/play');
                          }
                        },
                  child: const Text('Start'),
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
