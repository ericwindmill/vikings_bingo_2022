import 'dart:math';

import '../cell.dart';

const List<String> bingo = ['B', 'I', 'N', 'G', 'O'];
final rand = Random();

// generates a set of 24 random, non-repeating nums
Set<int> generateSingleBingoBoardNumbers() {
  final currentSet = <int>{};
  // 25 spaces per board minus 1 for "Free"
  while (currentSet.length < 25) {
    final num = rand.nextInt(76);
    currentSet.add(num);
  }

  return currentSet;
}

// used for local development. These bingo cards will come from the host app later
List<List<Cell>> generateBingoCard() {
  final List<int> nums = generateSingleBingoBoardNumbers().toList();
  return List.generate(5, (int row) {
    return List.generate(5, (int col) {
      // Free Cell
      if (row == 2 && col == 2) {
        return Cell(row: row, col: col, value: 'Free');
      }

      return Cell(row: row, col: col, value: nums.removeLast().toString());
    }, growable: false);
  }, growable: false);
}

void printListOfCells(List<Cell> l, {String? label}) {
  var values = l.map((cell) => '${cell.letter}${cell.value}');
  // ignore: avoid_print
  print('${label ?? ""} ${values.join(' - ')}');
}
