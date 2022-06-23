import 'package:flutter/material.dart';

import '../model/bingo_board.dart';
import '../style/palette.dart';
import '../style/spacing.dart';
import 'bingo_table_header_row.dart';
import 'bingo_table_rows.dart';

final palette = Palette();

class BingoBoardTable extends StatelessWidget {
  const BingoBoardTable({super.key, required this.board});

  final BingoBoard board;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(spacingUnit),
        decoration: BoxDecoration(
          color: palette.white,
          borderRadius: BorderRadius.circular(spacingUnit * 3),
        ),
        child: Table(
          children: [
            const BingoTableHeaderRow(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            BingoTableRow(values: board.firstRow),
            BingoTableRow(values: board.secondRow),
            BingoTableRow(values: board.thirdRow),
            BingoTableRow(values: board.fourthRow),
            BingoTableRow(values: board.fifthRow),
          ],
        ),
      ),
    );
  }
}
