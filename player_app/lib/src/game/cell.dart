class Cell {
  final int row;
  final int col;
  final String value;
  bool selected = false;

  Cell(
    this.row,
    this.col, {
    required this.value,
  });

  void select() => selected = !selected;

  String get letter {
    switch (col) {
      case 0:
        return 'B';
      case 1:
        return 'I';
      case 2:
        return 'N';
      case 3:
        return 'G';
      case 4:
        return 'O';
      default:
        return 'error';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Cell && runtimeType == other.runtimeType && value == other.value;

  @override
  int get hashCode => value.hashCode;
}
