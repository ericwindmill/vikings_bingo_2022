import 'player_status.dart';

class Player {
  final String uid;
  final String name;
  PlayerStatus status;

  Player({
    required this.uid,
    required this.name,
    this.status = PlayerStatus.waitingForCards,
  });

  static Player fromJson(Map<String, dynamic> json) {
    return Player(
      uid: json['uid'],
      name: json['name'],
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

class AppUser {
  final String uid;
  final String name;

  AppUser({
    required this.uid,
    required this.name,
  });
}
