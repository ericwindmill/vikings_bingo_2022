import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vikings_bingo/src/style/button_style.dart';

import '../../game/game_state.dart';
import '../../style/spacing.dart';

class SetupPage extends StatelessWidget {
  const SetupPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: spacingUnit * 3),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name:',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.left,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: spacingUnit * 4),
              child: Text(
                context.select((GameState s) => s.playerName),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(
              width: 20,
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                OutlinedButton(
                  style: secondaryButtonStyle,
                  onPressed: () => gameState.regenerateName(),
                  child: const Text(
                    'Change Name',
                  ),
                ),
                OutlinedButton(
                  style: outlineButtonStyle,
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/play');
                  },
                  child: const Text(
                    'Start',
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
