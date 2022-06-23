import 'package:flutter/material.dart';

import 'bingo_cell.dart';

const String tableHeadRowValues = 'BINGO';
final bingoNumbers = List<int>.generate(75, (index) => index + 1);

class BingoBoard extends StatelessWidget {
  const BingoBoard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Table(
          border: TableBorder.all(),
          children: [
            TableRow(
              decoration: const BoxDecoration(
                color: Colors.tealAccent,
              ),
              children: [
                for (var el in tableHeadRowValues.characters)
                  BingoCell(
                    bingoValue: el,
                  ),
              ],
            ),
          ],
        )
      ],
    );
  }
}
