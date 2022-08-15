import 'player_status.dart';

class Player {
  final String uid;
  final String? name;
  PlayerStatus? status;
  String? hostMessage;

  Player({
    required this.uid,
    required this.name,
    this.status,
    this.hostMessage,
  });

  static Player fromJson(Map<String, dynamic> json, {String? uid}) {
    return Player(
      uid: json['uid'] ?? uid,
      name: json['name'],
      status: statusFromString[json['status']] ?? PlayerStatus.newPlayer,
      hostMessage: json['hostMessage'],
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'uid': uid,
      if (status != null) 'status': status!.value,
    };
  }
}
