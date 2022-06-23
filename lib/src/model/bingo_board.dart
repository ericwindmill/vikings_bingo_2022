import 'package:vikings_bingo/src/util/bingo_util.dart';

class BingoBoard {
  late List<String> numbers;

  BingoBoard() {
    numbers = generateSingleBingoBoardNumbers().toList();
  }

  List<String> get firstRow => numbers.sublist(0, 5);

  List<String> get secondRow => numbers.sublist(5, 10);

  List<String> get thirdRow {
    return [
      ...numbers.sublist(10, 12),
      "Free",
      ...numbers.sublist(12, 14),
    ];
  }

  List<String> get fourthRow => numbers.sublist(14, 19);

  List<String> get fifthRow => numbers.sublist(19, 24);
}

class BingoValue {
  final String letter;
  final String number;

  BingoValue(this.letter, this.number);
}
