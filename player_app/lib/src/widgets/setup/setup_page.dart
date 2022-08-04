import 'package:flutter/material.dart';
import 'package:shared/player.dart';
import 'package:vikings_bingo/src/style/button_style.dart';

import '../../../firestore_service.dart';
import '../../style/spacing.dart';

class SetupPage extends StatelessWidget {
  final Player player;
  const SetupPage({
    Key? key,
    required this.player,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: spacingUnit * 3),
        child: StreamBuilder<String?>(
            stream: FirestoreService.gameIdStream(),
            builder: (context, snapshot) {
              final gameId = snapshot.data;
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
                      gameId ?? 'Waiting for game...',
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
                    child: Text(
                      player.name,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                    height: 20,
                  ),
                  Center(
                    child: OutlinedButton(
                      style: outlineButtonStyle,
                      onPressed: snapshot.data != null
                          ? () {
                              FirestoreService.joinGame(
                                  gameId: gameId!, player: player);
                              Navigator.pushReplacementNamed(context, '/play');
                            }
                          : null,
                      child: const Text(
                        'Join Game',
                      ),
                    ),
                  )
                ],
              );
            }),
      ),
    );
  }
}
