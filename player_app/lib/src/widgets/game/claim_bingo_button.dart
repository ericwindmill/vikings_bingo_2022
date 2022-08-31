import 'package:flutter/material.dart';
import 'package:shared/bingo_card.dart';
import 'package:shared/player.dart';

import '../../../firestore_service.dart';
import '../../style/spacing.dart';
import 'bingo_table_header_row.dart';

class ClaimBingoButton extends StatefulWidget {
  final BingoCard card;
  final String gameId;
  final Player player;

  const ClaimBingoButton({
    Key? key,
    required this.card,
    required this.gameId,
    required this.player,
  }) : super(key: key);

  @override
  State<ClaimBingoButton> createState() => _ClaimBingoButtonState();
}

class _ClaimBingoButtonState extends State<ClaimBingoButton> {
  bool isCalm = true;
  void _startIsCalmTimer() {
    setState(() {
      isCalm = false;
    });
    Future.delayed(Duration(seconds: 15), () {}).then((value) {
      setState(() {
        isCalm = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: widget.card.hasBingo,
      builder: (context, bool value, child) {
        var enabled = value && isCalm;
        return ElevatedButton(
          onPressed: enabled
              ? () {
                  _startIsCalmTimer();
                  FirestoreService.submitBingo(
                    widget.player,
                    widget.gameId,
                  );
                }
              : null,
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith(
              (state) {
                if (state.contains(MaterialState.disabled)) {
                  return palette.primaryLight;
                }
                return palette.buttonBackground;
              },
            ),
            foregroundColor: MaterialStateProperty.all(
              palette.buttonText,
            ),
            textStyle: MaterialStateProperty.all(
              Theme.of(context).textTheme.headlineSmall,
            ),
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
    );
  }
}
