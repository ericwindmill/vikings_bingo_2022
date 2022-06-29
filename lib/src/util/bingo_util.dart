import 'dart:math';

import '../game/cell.dart';

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

printListOfCells(List<Cell> l, {String? label}) {
  var values = l.map((cell) => '${cell.letter}${cell.value}');
  print('${label ?? ""} ${values.join(' - ')}');
}
