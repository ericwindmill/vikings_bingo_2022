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

  static Player fromJson(Map<String, dynamic> json) {
    return Player(
      uid: json['uid'],
      name: json['name'],
      status: json['status'],
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
}
