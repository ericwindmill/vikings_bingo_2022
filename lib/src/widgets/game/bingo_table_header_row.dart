import 'package:flutter/material.dart';

import '../../style/palette.dart';
import '../../style/spacing.dart';
import '../../util/bingo_util.dart';

final palette = Palette();

/// Everything in this file is static
class BingoTableHeaderRow extends TableRow {
  const BingoTableHeaderRow({
    super.key,
    height,
    super.decoration,
  });

  @override
  List<Widget>? get children {
    final widgets = <Widget>[];
    for (var el in bingo) {
      widgets.add(
        BingoHeaderCell(
          textValue: el,
        ),
      );
    }

    return widgets;
  }
}

class BingoHeaderCell extends StatelessWidget {
  final String textValue;

  const BingoHeaderCell({Key? key, required this.textValue}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cellHeight = MediaQuery.of(context).size.height / 8;
    final highlighterSize = cellHeight - spacingUnit;

    return SizedBox(
      height: cellHeight,
      child: Center(
        child: Container(
          height: highlighterSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: palette.backgroundSecondary,
          ),
          child: Center(
            child: Text(
              textValue,
              style: TextStyle(
                color: palette.lightInk,
                fontSize: spacingUnit * 6,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
