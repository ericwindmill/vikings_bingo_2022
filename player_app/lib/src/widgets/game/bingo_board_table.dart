import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/bingo_card.dart';
import 'package:shared/cell.dart';
import 'package:vikings_bingo/src/widgets/shared/shadow.dart';

import '../../style/palette.dart';
import 'bingo_table_header_row.dart';
import 'bingo_table_rows.dart';

class BingoCardTable extends StatelessWidget {
  const BingoCardTable({Key? key, required this.card}) : super(key: key);

  final BingoCard card;

  onTapCell(Cell bingoCell) {
    card.onCellSelection(bingoCell);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.read<Palette>();

    return GradientDropShadow(
      backgroundColor: palette.primaryLight,
      offset: Offset(-5, 6),
      gradient: LinearGradient(
        colors: palette.cascadeBrandSwatch.reversed.toList(),
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: [
          .7,
          .75,
          .8,
        ],
      ),
      child: Table(
        children: [
          BingoTableHeaderRow(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: palette.white,
                ),
              ),
            ),
          ),
          BingoTableRow(values: card.firstRow, onTapCell: onTapCell),
          BingoTableRow(values: card.secondRow, onTapCell: onTapCell),
          BingoTableRow(values: card.thirdRow, onTapCell: onTapCell),
          BingoTableRow(values: card.fourthRow, onTapCell: onTapCell),
          BingoTableRow(values: card.fifthRow, onTapCell: onTapCell),
        ],
      ),
    );
  }
}
