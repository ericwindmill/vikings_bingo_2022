import 'player_status.dart';

class Player {
  final String uid;
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
}
