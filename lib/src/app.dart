import 'package:flutter/material.dart';
import 'package:vikings_bingo/src/widgets/bingo_board_table.dart';

import 'model/bingo_board.dart';
import 'style/palette.dart';
import 'style/spacing.dart';

final palette = Palette();

class BingoPlayerApp extends StatelessWidget {
  const BingoPlayerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      backgroundColor: palette.backgroundMain,
      appBar: AppBar(
        title: const Text("Flutter Vikings 2022"),
        backgroundColor: palette.backgroundSecondary,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: BingoPageViewWrapper(),
            ),
          ),
          TextButton(
              onPressed: () {
                // TODO: disable button unless the user "has bingo"
                // importantly, they will be able to tap _any_ square they want,
                // so as soon as they tap 5 in a row, they will be able to submit,
                // but it won't be checked against the server until they press submit
                // we'll use that to publically shame liars :)
                print('bingo!');
              },
              child: Text('Bingo!'))
        ],
      ),
    ));
  }
}

class BingoPageViewWrapper extends StatelessWidget {
  BingoPageViewWrapper({Key? key}) : super(key: key);
  final controller = PageController();

  final board = BingoBoard();

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: controller,
      children: [
        Padding(
          padding: const EdgeInsets.all(spacingUnit * 3),
          child: BingoBoardTable(board: board),
        ),
        Padding(
          padding: const EdgeInsets.all(spacingUnit * 4),
          child: BingoBoardTable(board: board),
        ),
      ],
    );
  }
}
