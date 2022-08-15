import 'package:flutter/material.dart';
import 'package:shared/player.dart';
import 'package:vikings_bingo/src/style/button_style.dart';

import '../../../firestore_service.dart';
import '../../style/spacing.dart';

class SetupPage extends StatelessWidget {
  final Stream<String> gameIdStream;
  final Player player;
  const SetupPage({
    Key? key,
    required this.gameIdStream,
    required this.player,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: spacingUnit * 3),
        child: StreamBuilder<String?>(
          stream: FirestoreService.gameIdStream(),
          builder: (context, gameIdSnapshot) {
            final gameId = gameIdSnapshot.data;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Game ID:',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.left,
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: spacingUnit * 4),
                  child: Text(
                    gameIdSnapshot.connectionState == ConnectionState.waiting
                        ? 'Waiting for game...'
                        : gameId!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Text(
                  'Name:',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.left,
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: spacingUnit * 4),
                  child: Text(player.name ?? 'No player',
                      style: Theme.of(context).textTheme.bodyMedium),
                ),
                const SizedBox(
                  width: 20,
                  height: 20,
                ),
                Center(
                  child: OutlinedButton(
                    style: outlineButtonStyle,
                    onPressed: (gameIdSnapshot.hasData)
                        ? () {
                            FirestoreService.joinGame(
                              gameId: gameId!,
                              player: player,
                            );
                            Navigator.pushReplacementNamed(context, '/play');
                          }
                        : null,
                    child: const Text('Join Game'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
