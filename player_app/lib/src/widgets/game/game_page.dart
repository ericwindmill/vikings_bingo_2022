import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared/bingo_card.dart';
import 'package:shared/player.dart';
import 'package:shared/player_status.dart';
import 'package:vikings_bingo/firestore_service.dart';
import 'package:vikings_bingo/src/widgets/game/bingo_table_header_row.dart';
import 'package:vikings_bingo/src/widgets/shared/confetti_animation.dart';

import '../../style/spacing.dart';
import '../game/bingo_board_table.dart';
import '../shared/keep_alive_page.dart';

class GamePage extends StatefulWidget {
  final String gameId;
  final Player player;
  const GamePage({Key? key, required this.gameId, required this.player})
      : super(key: key);

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  bool hasWonBingo = false;

  @override
  void initState() {
    super.initState();
    _listenForPlayerStatusUpdates();
    if (widget.player.status == PlayerStatus.wonBingo) {
      hasWonBingo = true;
    }
  }

  void _listenForPlayerStatusUpdates() {
    FirestoreService.getPlayerStream(widget.gameId).listen(
      (Player player) async {
        if (player.status == PlayerStatus.falseBingo) {
          await showDialog(
              context: context,
              builder: (context) {
                int second = 3;
                return StatefulBuilder(builder: (context, setState) {
                  Timer.periodic(Duration(milliseconds: 1500), (Timer timer) {
                    if (second > 0) {
                      setState(() {
                        second--;
                      });
                    } else {
                      timer.cancel();
                    }
                  });

                  return AlertDialog(
                    content: Image.asset('ec5.gif'),
                    actions: [
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.resolveWith(
                            (state) {
                              if (state.contains(MaterialState.disabled)) {
                                return palette.primaryLight;
                              }
                              return palette.buttonBackground;
                            },
                          ),
                          foregroundColor:
                              MaterialStateProperty.all(palette.buttonText),
                          textStyle: MaterialStateProperty.all(
                              Theme.of(context).textTheme.headlineSmall),
                          padding: MaterialStateProperty.all(
                            const EdgeInsets.symmetric(
                              horizontal: spacingUnit * 10,
                              vertical: spacingUnit * 2,
                            ),
                          ),
                        ),
                        onPressed: second == 0
                            ? () {
                                Navigator.of(context).pop();
                              }
                            : null,
                        child: Text('Dismiss in $second seconds...'),
                      )
                    ],
                  );
                });
              });

          FirestoreService.updatePlayerStatus(
            PlayerStatus.playing,
            widget.player,
            widget.gameId,
          );
        }
        if (player.status == PlayerStatus.wonBingo) {
          setState(() {
            hasWonBingo = true;
          });

          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  scrollable: true,
                  title: Text('You win!'),
                  content: Center(
                    child: Text(
                        'Show this code to the host: ${player.hostMessage ?? '123XYZ'}'),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Dismiss'),
                    )
                  ],
                );
              });
        }
      },
    );
  }

  final controller = PageController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (hasWonBingo) Confetti(),
          Align(
            alignment: AlignmentDirectional.topCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: spacingUnit * 8),
              child: Text(
                'Player: ${widget.player.name}',
              ),
            ),
          ),
          if (hasWonBingo)
            Align(
              alignment: AlignmentDirectional.topCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: spacingUnit * 8),
                child: Text(
                  'Winner Code: ${widget.player.hostMessage ?? '123XYZ'}',
                ),
              ),
            ),
          StreamBuilder<List<BingoCard>>(
            stream: FirestoreService.getCardsForPlayerStream(
              widget.gameId,
              widget.player,
            ),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              final cards = snapshot.data!;
              return PageView(
                controller: controller,
                children: [
                  for (var card in cards)
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
                                          FirestoreService.submitBingo(
                                            widget.player,
                                            widget.gameId,
                                          );
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
                        ),
                      ],
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
