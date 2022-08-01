import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vikings_bingo/src/widgets/game/bingo_table_header_row.dart';

import '../../game/game_state.dart';
import '../../style/spacing.dart';
import '../game/bingo_board_table.dart';
import '../shared/keep_alive_page.dart';

class GamePage extends StatefulWidget {
  const GamePage({Key? key}) : super(key: key);

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final controller = PageController();

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();

    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: AlignmentDirectional.topCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: spacingUnit * 8),
              child: Text('Player: ${gameState.player.name}'),
            ),
          ),
          if (gameState.cards.isEmpty)
            Center(
              child: CircularProgressIndicator(),
            ),
          if (gameState.cards.isNotEmpty)
            PageView(
              controller: controller,
              children: [
                for (var card in gameState.cards)
                  Stack(
                    children: [
                      Align(
                        alignment: AlignmentDirectional.center,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: spacingUnit * 3),
                          child: KeepAlivePage(
                            child: BingoCardTable(
                              card: card,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: spacingUnit * 10),
                          child: ValueListenableBuilder<bool>(
                            valueListenable: card.hasBingo,
                            builder: (context, bool value, child) {
                              return ElevatedButton(
                                onPressed: value
                                    ? () {
                                        gameState.submitBingo(card);
                                      }
                                    : null,
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.resolveWith(
                                    (state) {
                                      if (state
                                          .contains(MaterialState.disabled)) {
                                        return palette.primaryLight;
                                      }
                                      return palette.buttonBackground;
                                    },
                                  ),
                                  foregroundColor: MaterialStateProperty.all(
                                      palette.buttonText),
                                  textStyle: MaterialStateProperty.all(
                                      Theme.of(context)
                                          .textTheme
                                          .headlineSmall),
                                  padding: MaterialStateProperty.all(
                                    const EdgeInsets.symmetric(
                                      horizontal: spacingUnit * 10,
                                      vertical: spacingUnit * 2,
                                    ),
                                  ),
                                ),
                                child: const Text('BINGO!'),
                              );
                            },
                          ),
                        ),
                      )
                    ],
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
