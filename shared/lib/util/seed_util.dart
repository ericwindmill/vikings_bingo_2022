import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emojis/emoji.dart';

final emoji = Emoji.all();

/// This is just for development, can be deleted once we're using a real firebase project
void seedFirebase(DocumentReference userDoc) {
  final emjois = emoji.take(24).map((e) => e.char).toList();

  userDoc.collection('Cards').add({
    'cards': emjois,
  });
}
