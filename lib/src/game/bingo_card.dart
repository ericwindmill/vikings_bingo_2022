import 'package:flutter/material.dart';

import '../util/bingo_util.dart';
import 'cell.dart';

/// BingoCard represents the card that players can interact with.
/// It's also _purposefully_ complicated, because we want users to be able to
/// claim bingo when they haven't achieved it.
///
/// That means we need to treat win conditions more like tic-tac-toe -- we have
/// to check the lines (rows, columns, and diagonal) for completeness, rather
/// than checking the selected items against the bingo numbers that have been called
/// thus far. This app has no concept of what has been called, it can only submit
/// a winning bingo "line", and Firebase will respond with whether it is a true win
/// or a cheat :)
///
class BingoCard {
  BingoCard() {
    final List<int> nums = generateSingleBingoBoardNumbers().toList();
    _board = List.generate(5, (int row) {
      return List.generate(5, (int col) {
        // Free Cell
        if (row == 2 && col == 2) {
          return Cell(row, col, value: 'Free');
        }

        return Cell(row, col, value: nums.removeLast().toString());
      }, growable: false);
    }, growable: false);
  }

  // These nested lists represent a 5x5 grid
  late final List<List<Cell>> _board;

  ValueNotifier<bool> hasBingo = ValueNotifier(false);

  Cell getCell(int row, int col) {
    return _board[row][col];
  }

  List<Cell> getCol(int col) {
    final newCol = <Cell>[];
    for (var row in _board) {
      newCol.add(row[col]);
    }
    return newCol;
  }

  onCellSelection(Cell cell) {
    cell.select();
    var bingo = _checkForBingo(cell);
    hasBingo.value = bingo;
  }

  // Checks against the cell that was just selected
  _checkForBingo(Cell cell) {
    final row = _board[cell.row];
    final col = getCol(cell.col);
    final rowWin = row.every((element) => element.selected);
    final colWin = col.every((element) => element.selected);
    final diag1Win =
        diagonalTopLeftToBottomRight.every((element) => element.selected);
    final diag2Win =
        diagonalTopRightToBottomLeft.every((element) => element.selected);

    return (rowWin || colWin || diag1Win || diag2Win);
  }

  // convenience methods for win conditions
  List<Cell> get firstRow => _board[0];
  List<Cell> get secondRow => _board[1];
  List<Cell> get thirdRow => _board[2];
  List<Cell> get fourthRow => _board[3];
  List<Cell> get fifthRow => _board[4];

  List<Cell> get firstCol => getCol(0);
  List<Cell> get secondCol => getCol(1);
  List<Cell> get thirdCol => getCol(2);
  List<Cell> get fourthCol => getCol(3);
  List<Cell> get fifthCol => getCol(4);

  List<Cell> get diagonalTopLeftToBottomRight {
    return [
      getCell(0, 0),
      getCell(1, 1),
      getCell(2, 2),
      getCell(3, 3),
      getCell(4, 4),
    ];
  }

  List<Cell> get diagonalTopRightToBottomLeft {
    return [
      getCell(0, 4),
      getCell(1, 3),
      getCell(2, 2),
      getCell(3, 1),
      getCell(4, 0),
    ];
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BingoCard &&
          runtimeType == other.runtimeType &&
          _board == other._board;

  @override
  int get hashCode => _board.hashCode;
}
