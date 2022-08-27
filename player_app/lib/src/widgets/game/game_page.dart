import 'package:flutter/material.dart';
import 'package:shared/bingo_card.dart';
import 'package:shared/player.dart';
import 'package:shared/player_status.dart';
import 'package:vikings_bingo/firestore_service.dart';
import 'package:vikings_bingo/src/widgets/game/bingo_table_header_row.dart';
import 'package:vikings_bingo/src/widgets/game/claim_bingo_button.dart';
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
  bool isCalm = true;

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
                return AlertDialog(
                  content: Image.asset('assets/images/ec5.gif'),
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
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Dismiss'),
                    )
                  ],
                );
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
                  child: Text(player.hostMessage != null
                      ? 'Show this code to the host: ${player.hostMessage}'
                      : ''),
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
            },
          );
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
          StreamBuilder<Player>(
            stream: FirestoreService.getPlayerStream(widget.gameId),
            builder: (context, snapshot) {
              var text = (hasWonBingo && snapshot.data!.hostMessage != null)
                  ? 'Winner code: ${snapshot.data!.hostMessage}'
                  : 'Player: ${widget.player.name}';
              return Align(
                alignment: AlignmentDirectional.topCenter,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: spacingUnit * 8),
                  child: Text(
                    text,
                  ),
                ),
              );
            },
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
                            child: ClaimBingoButton(
                              gameId: widget.gameId,
                              player: widget.player,
                              card: card,
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
