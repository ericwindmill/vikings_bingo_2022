import 'player_status.dart';

class Player {
  final String uid;
  final String name;
  PlayerStatus status;
  String? hostMessage;

  Player({
    required this.uid,
    required this.name,
    this.status = PlayerStatus.inLobby,
    this.hostMessage,
  });

  static Player fromJson(Map<String, dynamic> json, {String? uid}) {
    return Player(
      uid: json['uid'] ?? uid,
      name: json['name'],
      status: statusFromString[json['status']] ?? PlayerStatus.inLobby,
      hostMessage: json['hostMessage'],
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'uid': uid,
      'status': status.value,
    };
  }

  bool get isInGame {
    return status == PlayerStatus.waitingForCards ||
        status == PlayerStatus.cardsDealt ||
        status == PlayerStatus.playing ||
        status == PlayerStatus.falseBingo ||
        status == PlayerStatus.claimingBingo;
  }
}
