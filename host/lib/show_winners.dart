import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ShowWinnersDialog extends StatefulWidget {
  const ShowWinnersDialog({Key? key, required this.gameId}) : super(key: key);

  final String gameId;

  @override
  State<ShowWinnersDialog> createState() => _ShowWinnersState();
}

class _ShowWinnersState extends State<ShowWinnersDialog> {
  late String gameId;
  final db = FirebaseFirestore.instance;

  @override void initState() {
    super.initState();
    gameId = widget.gameId;
  }

  Stream<List<QueryDocumentSnapshot>> _getWinners(String gameId) {
    return db
        .collection('Games/$gameId/Players')
        .where('status', isEqualTo: 'wonBingo')
        .orderBy('bingoClaimTime', descending: true)
        .snapshots()
        .map((event) => event.docs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Winners'),
      ),
      body: Column(children: [
        FutureBuilder(
          future: FirebaseFirestore.instance.collection('Games').orderBy('createdAt', descending: true).get(),
          builder: (context, AsyncSnapshot<QuerySnapshot> asyncSnapshot) {
            if (!asyncSnapshot.hasData) return const CircularProgressIndicator();
            return DropdownButton<String>(
              value: gameId,
              items: asyncSnapshot.data!.docs.map((doc) => DropdownMenuItem(value: doc.id, child: Text((doc.get("createdAt") as Timestamp).toDate().toString()))).toList(),
              onChanged: (String? newValue) {
                setState(() { gameId = newValue!; });
              },
            );
          }
        ),
        Center(child: StreamBuilder(
          stream: _getWinners(gameId),
          builder: (context, asyncSnapshot) {
            if (asyncSnapshot.hasData) {
              var winners = asyncSnapshot.data! as List<QueryDocumentSnapshot>;
              print('Got ${winners.length} winners: ${winners.map((d) => d.id)}');
              return ListView(shrinkWrap: true, children: winners.map((winner) {
                var data = winner.data()! as Map;
                var name = data["name"];
                var time = (data['bingoClaimTime'] as Timestamp).toDate();
                var msg = (data['hostMessage'] ?? '-');
                return ListTile(
                  isThreeLine: true,
                  title: Text(winner.id),
                  subtitle: Text('$name\nwon at $time\nmsg: "$msg"'),
                  trailing: IconButton(
                    icon: const Icon(Icons.message_sharp),
                    onPressed: () {
                      db.doc('Games/$gameId/Players/${winner.id}').update(
                        {'hostMessage': Random().nextInt(100000).toString()}
                      );
                    },
                  ),
                );
              }).toList());
            }
            if (asyncSnapshot.hasError) {
              return Text('Error: ${asyncSnapshot.error}');
            }
            return const CircularProgressIndicator();
          },
        ))
      ]),
    );
  }
}

