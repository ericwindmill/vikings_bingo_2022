enum PlayerStatus {
  waitingForCards,
  playing,
  claimingBingo,
}

class Player {
  final String uid;
  final List<String> cardIds = [];
  final String name;
  PlayerStatus status = PlayerStatus.waitingForCards;

  Player({
    required this.uid,
    required this.name,
  });

  static Player fromJson(Map<String, dynamic> json) {
    return Player(
      uid: json['uid'],
      name: json['name'],
    );
  }

  void addCards(List<String> ids) {
    cardIds.addAll(ids);
  }

  void updateStatus(PlayerStatus newStatus) {
    status = newStatus;
  }
}
