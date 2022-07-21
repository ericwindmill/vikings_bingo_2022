import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'firebase_options.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (!kReleaseMode) {
    try {
      FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
      await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    } catch (e) {
      debugPrint(e.toString());
    }
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Stream<String> currentGameId = _getCurrentGameStream();
  Map<String,String> playerStates = {};

  @override
  void initState() {
    super.initState();

    _getCurrentGameStream().listen((gameId) {
      _getGamePlayersStream(gameId).listen((snapshot) {
        if (kDebugMode) print('Got ${snapshot.docs.length} player docs');
        for (var doc in snapshot.docs) {
          var playerId = doc.id;
          var data = doc.data()! as Map;
          if (data['state'] == 'Waiting for cards') {
            _generateCardsForPlayer(gameId, playerId);
          }
        };
      });
    });
  }

  void _incrementCounter() {
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text("Current game: "),
            StreamBuilder(
              stream: currentGameId,
              builder: (buildContext, AsyncSnapshot<String> asyncSnapshot) {
                if (asyncSnapshot.hasData) {
                  return Column(children: [ 
                    Text(
                      asyncSnapshot.data!,
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    const Text("Player count: "),
                    StreamBuilder(
                      stream: _getGamePlayersStream(asyncSnapshot.data!),
                      builder: (buildCcontext, AsyncSnapshot<QuerySnapshot> asyncSnapshot) {
                        if (asyncSnapshot.hasData) {
                          return Text(
                            '${asyncSnapshot.data!.docs.length}',
                            style: Theme.of(context).textTheme.headline4,
                          );
                        }
                        if (asyncSnapshot.hasError) {
                          return Text('${asyncSnapshot.error}');
                        }
                        return const CircularProgressIndicator();
                      }
                    ),
                  ]);
                }
                if (asyncSnapshot.hasError) {
                  return Text('${asyncSnapshot.error}');
                }
                return const CircularProgressIndicator();
              }
            ),
            ElevatedButton(
              child: const Text('Start new game'),
              onPressed: () {
                // TODO: find a simpler ID generator
                var uuid = new Uuid();
                _setCurrentGameId(uuid.v1());
              }
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

Future<void> _setCurrentGameId(String gameId) {
  var db = FirebaseFirestore.instance;
  final batch = db.batch();

  batch.update(db.collection('Globals').doc('Bootstrap'), { 'currentGame': gameId });
  batch.set(db.collection('Games').doc(gameId), { 'createdAt': Timestamp.now() });

  return batch.commit();
}
Stream<String> _getCurrentGameStream() {
  return FirebaseFirestore.instance
      .collection('Globals')
      .doc('Bootstrap')
      .snapshots().map((docSnapshot) {
      final data = docSnapshot.data() as Map<String, dynamic>;
      return data['currentGame'];
  });
}

Stream<QuerySnapshot> _getGamePlayersStream(String gameId) {
  return FirebaseFirestore.instance
      .collection('Games')
      .doc(gameId)
      .collection('Players')
      .snapshots();
}

Random random = Random(); // main randomizer

Future<void> _generateCardsForPlayer(String gameId, String playerId) {
  var db = FirebaseFirestore.instance;
  final batch = db.batch();

  var cardId = random.nextInt(1<<32);
  var card = _generateCardFromCardId(cardId);
  batch.set(db.doc('Games/$gameId/Players/$playerId/Cards/$cardId'), { 
    'createdAt': Timestamp.now(),
    'numbers': card,
  });
  batch.set(db.doc('Games/$gameId/Players/$playerId'), { 'state': 'Cards dealt: [$cardId]' });

  return batch.commit();
}

List<String> _generateCardFromCardId(int cardId) {
  var cardGenerator = Random(cardId);
  List<String> numbers = [];
  for (var i=0; i< 24; i++) {
    numbers.add(cardGenerator.nextInt(75).toString());
  }
  return numbers;
}