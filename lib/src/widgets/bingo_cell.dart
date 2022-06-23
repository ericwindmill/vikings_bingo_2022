import 'package:flutter/material.dart';
import 'package:vikings_bingo/src/style/spacing.dart';

import '../style/palette.dart';

typedef BingoCellCallback<String> = Function(String value);

class BingoCell extends StatefulWidget {
  const BingoCell({
    super.key,
    required this.bingoValue,
    this.onTapCell,
    this.highlightedColor,
    this.height,
    this.isPlayableCell = true,
  });

  final String bingoValue;

  final BingoCellCallback? onTapCell;

  final Color? highlightedColor;

  final double? height;

  final bool isPlayableCell;

  @override
  State<BingoCell> createState() => _BingoCellState();
}

class _BingoCellState extends State<BingoCell> {
  bool _isSelected = false;

  _toggleIsSelected() {
    // playable cells do not have toggle-able backgrounds
    if (!widget.isPlayableCell) return;

    setState(() {
      _isSelected = !_isSelected;
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = widget.height ?? MediaQuery.of(context).size.height / 8;
    final highlighterSize = height - spacingUnit;
    final isHighlighted = (!widget.isPlayableCell || _isSelected);
    final palette = Palette();

    return GestureDetector(
      onTap: () {
        _toggleIsSelected();
        if (widget.onTapCell != null) widget.onTapCell!(widget.bingoValue);
      },
      child: SizedBox(
        height: height, // 6 row + padding
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
                widget.bingoValue,
                style: TextStyle(
                    color: isHighlighted ? palette.lightInk : palette.mainInk,
                    fontSize: 20.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
