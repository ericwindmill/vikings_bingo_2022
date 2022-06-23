import 'dart:math';

const List<String> bingo = ['B', 'I', 'N', 'G', 'O'];
final rand = Random();

// generates a set of 24 random, non-repeating nums
Set<String> generateSingleBingoBoardNumbers() {
  final currentSet = <String>{};

  // 25 spaces per board minus 1 for "Free"
  while (currentSet.length < 25) {
    final num = rand.nextInt(76);
    currentSet.add(num.toString());
  }

  return currentSet;
}
