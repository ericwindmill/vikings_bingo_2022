import 'package:flutter/material.dart';
import 'package:shared/cell.dart';
import 'package:vikings_bingo/src/style/spacing.dart';

import '../../style/palette.dart';

typedef SelectBingoCellCallback = Function(Cell value);

class BingoTableCell extends StatefulWidget {
  const BingoTableCell({
    super.key,
    required this.bingoCell,
    this.onTapCell,
    this.highlightedColor,
    this.height,
    this.isPlayableCell = true,
  });

  final Cell bingoCell;

  final SelectBingoCellCallback? onTapCell;

  final Color? highlightedColor;

  final double? height;

  final bool isPlayableCell;

  @override
  State<BingoTableCell> createState() => _BingoTableCellState();
}

class _BingoTableCellState extends State<BingoTableCell> {
  onTapCell() {
    setState(() {
      if (widget.onTapCell != null) widget.onTapCell!(widget.bingoCell);
    });
  }

  @override
  Widget build(BuildContext context) {
    final h = widget.height ?? MediaQuery.of(context).size.height / 9;
    final highlighterSize = h - spacingUnit;
    final isHighlighted = (!widget.isPlayableCell || widget.bingoCell.selected);
    final palette = Palette();

    return GestureDetector(
      onTap: onTapCell,
      child: SizedBox(
        height: h, // 6 row + padding
        child: Stack(
          children: [
            Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: isHighlighted ? highlighterSize : 0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isHighlighted
                      ? widget.highlightedColor ?? palette.randomColor
                      : Colors.white,
                ),
              ),
            ),
            Center(
              child: Text(
                widget.bingoCell.value,
                style: TextStyle(
                    color: isHighlighted ? palette.lightInk : palette.mainInk,
                    fontSize: widget.bingoCell.value == 'Free' ? 12.0 : 16.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
