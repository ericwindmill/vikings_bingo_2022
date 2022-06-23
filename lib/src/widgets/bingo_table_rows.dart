import 'package:flutter/material.dart';

import 'bingo_cell.dart';

class BingoTableRow extends TableRow {
  const BingoTableRow({
    super.key,
    super.decoration,
    required this.values,
    this.height,
  });

  final List<String> values;

  final double? height;

  @override
  List<Widget>? get children => [
        for (var el in values)
          BingoCell(
            bingoValue: el,
            height: height,
            onTapCell: (bingoValue) {},
          ),
      ];
}
