import 'package:flutter/material.dart';

typedef BingoCellCallback<String> = String Function(String value);

class BingoCell extends StatelessWidget {
  const BingoCell({
    super.key,
    required this.bingoValue,
    this.onTapCell,
  });

  final String bingoValue;

  final BingoCellCallback? onTapCell;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60.0,
      width: 30.0,
      child: Center(
        child: Text(bingoValue),
      ),
    );
  }
}
