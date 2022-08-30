import 'package:flutter/material.dart';
import 'package:shared/player.dart';
import 'package:vikings_bingo/src/style/button_style.dart';

import '../../style/spacing.dart';

class SetupPageRefactor extends StatelessWidget {
  final String gameId;
  final Player player;
  final VoidCallback? onPressedJoin;

  const SetupPageRefactor({
    Key? key,
    required this.gameId,
    required this.player,
    required this.onPressedJoin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: spacingUnit * 3),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Game ID:',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.left,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: spacingUnit * 4),
              child: Text(
                gameId,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Text(
              'Name:',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.left,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: spacingUnit * 4),
              child: Text(player.name!,
                  style: Theme.of(context).textTheme.bodyMedium),
            ),
            const SizedBox(
              width: 20,
              height: 20,
            ),
            Center(
              child: OutlinedButton(
                style: outlineButtonStyle,
                onPressed: onPressedJoin,
                child: const Text('Join Game'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
