import 'package:flutter/material.dart';
import 'package:shared/cell.dart';

import 'bingo_table_cell.dart';

class BingoTableRow extends TableRow {
  const BingoTableRow({
    super.key,
    super.decoration,
    required this.values,
    this.height,
    this.onTapCell,
  });

  final List<Cell> values;

  final double? height;

  final SelectBingoCellCallback? onTapCell;

  @override
  List<Widget>? get children => [
        for (var el in values)
          BingoTableCell(
            bingoCell: el,
            height: height,
            onTapCell: onTapCell,
          ),
      ];
}
