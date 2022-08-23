import 'dart:async';
import 'dart:math';

import 'package:charts_flutter/flutter.dart' as chart;
import 'package:charts_painter/chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

// ignore_for_file: avoid_print

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
      home: const MyHomePage(title: 'Bingo 3000 Host'),
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
  Stream<String> gameIdStream = _getCurrentGameStream();
  String gameId = "Loading...";
  Stream<QuerySnapshot> playersStream = _getGamePlayersStream("none");
  List<QueryDocumentSnapshot> currentPlayers = [];
  Stream<List<String>> numbersStream = _getNumbersStream("none");
  List<String> currentNumbers = [];
  Stream<QuerySnapshot> cardsStream = _getCardsStream("none");
  List<QueryDocumentSnapshot> currentCards = [];
  final symbolCount = 75;
  final cardCountPerPlayer = 3;

  Map<int, int> currentScores = {};

  @override
  void initState() {
    super.initState();

    gameIdStream.listen((gameId) {
      setState(() {
        this.gameId = gameId;
      });
      playersStream = _getGamePlayersStream(gameId);
      playersStream.listen((snapshot) => {
            setState(() {
              currentPlayers = snapshot.docs;
            })
          });
      numbersStream = _getNumbersStream(gameId);
      cardsStream = _getCardsStream(gameId);
      playersStream.listen((snapshot) {
        if (kDebugMode) print('Got ${snapshot.docs.length} player docs');
        for (var doc in snapshot.docs) {
          var playerId = doc.id;
          var data = doc.data()! as Map;
          if (data['status'] == 'waiting for cards') {
            _generateCardsForPlayer(gameId, playerId, cardCountPerPlayer, symbolCount);
          }
          if (data['status'] == 'claiming bingo') {
            _claimBingoForPlayer(gameId, playerId, currentNumbers, symbolCount);
          }
        }
      });
      cardsStream.listen((cardsSnapshot) {
        setState(() {
          currentCards = cardsSnapshot.docs;
        });
        numbersStream.listen((numbers) {
          Map<int, int> result = {};
          for (var card in cardsSnapshot.docs) {
            var cardId = int.parse(card.id);
            var score = _getScoreForCard(numbers, cardId, symbolCount);
            result[cardId] = score;
          }
          print('Card scores: $result');
          setState(() {
            currentNumbers = numbers;
            currentScores = result;
          });
        });
      });
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
            Text(
              gameId,
              style: Theme.of(context).textTheme.headline6,
            ),
            ElevatedButton(
              child: const Text('Start new game'),
              onPressed: () {  _startNewGame(cardCountPerPlayer, symbolCount); }
            ),
            const Text("Player count: "),
            Text(
              currentPlayers.length.toString(),
              style: Theme.of(context).textTheme.headline6
            ),
            // StreamBuilder<QuerySnapshot>(
            //   stream: FirebaseFirestore.instance.collection('Games/$gameId/Players').snapshots(),
            //   builder: (context, asyncSnapshot) {
            //     if (asyncSnapshot.hasData) {
            //       var querySnapshot = asyncSnapshot.data!;
            //       return Text(querySnapshot.size.toString());
            //     }
            //     if (asyncSnapshot.hasError) {
            //       return Text('Error: ${asyncSnapshot.error}');
            //     }
            //     return const CircularProgressIndicator();
            //   }
            // ),

            const Text("Card count"),
            Text(
              currentCards.length.toString(),
              style: Theme.of(context).textTheme.headline6,
            ),
            const Text("Latest number(s):"),
            Row(
                children: currentNumbers.reversed
                    .take(10)
                    .toList()
                    .asMap()
                    .entries
                    .map((entry) {
              return (entry.key == 0)
                  ? Text(entry.value,
                      style: Theme.of(context).textTheme.headline3)
                  : Text(" ${entry.value}",
                      style: TextStyle(fontSize: 25.0 - 2.0 * entry.key));
            }).toList()),
            ElevatedButton(
              child: const Text("Draw"),
              onPressed: () {
                _generateNextNumber(gameId, currentNumbers, symbolCount);
              },
            ),
            const Text("Scores"),
            AnimatedChart(
              height: 200,
              state: ChartState.bar(
                ChartData.fromList(
                    [1, 2, 3, 4, 5]
                        .map((score) => BarValue(1.0 *
                            currentScores.values
                                .where((e) => e == score)
                                .length))
                        .toList(),
                    axisMax: 1.0 * currentScores.length),
              ),
              duration: const Duration(seconds: 1),
            ),
            ElevatedButton(
              child: const Text("Show winners"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) =>
                        ShowWinnersDialog(gameId: gameId),
                    fullscreenDialog: true,
                  ),
                );
              },
            ),
            ElevatedButton(
              child: const Text("Test time to winner"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => TestGameTimeDialog(),
                    fullscreenDialog: true,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ShowWinnersDialog extends StatelessWidget {
  String gameId;

  ShowWinnersDialog({Key? key, required this.gameId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Winners'),
      ),
      body: Center(
          child: StreamBuilder(
        stream: _getWinners(gameId),
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.hasData) {
            var winners = asyncSnapshot.data! as List<QueryDocumentSnapshot>;
            print('Got ${winners.length} winners: $winners');
            return ListView(
                children: winners.map((winner) {
              var data = winner.data()! as Map;
              var name = data["name"];
              var time = (data['bingoClaimTime'] as Timestamp).toDate();
              var msg = (data['hostMessage'] ?? '-');
              return ListTile(
                isThreeLine: true,
                title: Text(winner.id),
                subtitle: Text('$name\nwon at $time\nmsg: "$msg"'),
                trailing: IconButton(
                  icon: const Icon(Icons.sports_martial_arts_rounded),
                  onPressed: () {
                    db.doc('Games/$gameId/Players/${winner.id}').update(
                        {'hostMessage': Random().nextInt(100000).toString()});
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
      )),
    );
  }
}

var db = FirebaseFirestore.instance;
//void _getWinners(List<QueryDocumentSnapshot> players) {
Stream<List<QueryDocumentSnapshot>> _getWinners(String gameId) {
  return db
      .collection('Games/$gameId/Players')
      .where('status', isEqualTo: 'wonBingo')
      .orderBy('bingoClaimTime', descending: true)
      .snapshots()
      .map((event) => event.docs);
}

Future<void> _startNewGame(int cardCountPerPlayer, int dictionarySize) {
  var db = FirebaseFirestore.instance;
  final batch = db.batch();

  var gameId = FirebaseFirestore.instance.collection("Games").doc().id;

  batch.set(db.collection('Globals').doc('Bootstrap'), {'currentGame': gameId}, SetOptions(merge: true));
  batch.set(db.collection('Games').doc(gameId), {
    'createdAt': Timestamp.now(),
    'cardCountPerPlayer': cardCountPerPlayer,
    'dictionarySize': dictionarySize,
  });

  return batch.commit();
}

Stream<String> _getCurrentGameStream() {
  return FirebaseFirestore.instance
      .doc('Globals/Bootstrap')
      .snapshots()
      .map((docSnapshot) {
    if (docSnapshot.exists) {
      final data = docSnapshot.data() as Map<String, dynamic>;
      return data['currentGame'];
    } else {
      return '-none-';
    }
  });
}

Stream<QuerySnapshot> _getGamePlayersStream(String gameId) {
  return FirebaseFirestore.instance
      .collection('Games')
      .doc(gameId)
      .collection('Players')
      .snapshots();
}

Stream<List<String>> _getNumbersStream(String gameId) {
  return FirebaseFirestore.instance
      .collection('Games')
      .doc(gameId)
      .snapshots()
      .map((docSnapshot) {
    // TODO: Unhandled Exception: type 'Null' is not a subtype of type 'Map<String, dynamic>' in type cast
    if (docSnapshot.exists &&
        docSnapshot.data() != null &&
        docSnapshot.data()!.containsKey('numbers')) {
      final data = docSnapshot.data() as Map<String, dynamic>;
      return List<String>.from(data['numbers']);
    } else {
      return ['-none-'];
    }
  });
}

Stream<QuerySnapshot> _getCardsStream(String gameId) {
  var path = '/Games/$gameId';
  return FirebaseFirestore.instance
      .collectionGroup("Cards")
      .orderBy(FieldPath.documentId)
      .startAt([path]).endAt(['$path\uf8ff']).snapshots();
}

Future<void> _generateNextNumber(
    String gameId, List<String> numbers, int symbolCount) {
  var number = "willnevershowup";
  do {
    number = (1 + random.nextInt(symbolCount)).toString();
  } while (numbers.contains(number) && numbers.length < symbolCount);
  return FirebaseFirestore.instance.collection('Games').doc(gameId).update({
    'numbers': FieldValue.arrayUnion([number])
  });
}

Random random = Random(); // main randomizer

Future<void> _generateCardsForPlayer(
    String gameId, String playerId, cardCount, symbolCount) {
  var db = FirebaseFirestore.instance;
  final batch = db.batch();

  for (var i=0; i < cardCount; i++) {
    var cardId = random.nextInt(1 << 32);
    var card = _getNumbersForCardId(cardId, symbolCount);
    batch.set(db.doc('Games/$gameId/Players/$playerId/Cards/$cardId'), {
      'createdAt': Timestamp.now(),
      'numbers': card,
    });
    batch.update(
        db.doc('Games/$gameId/Players/$playerId'), {'status': 'cards dealt'});
  }

  return batch.commit();
}

Future<bool> _claimBingoForPlayer(String gameId, String playerId,
    List<String> numbers, int symbolCount) async {
  var hasBingo = false;
  // get cards for player
  var snapshot = await FirebaseFirestore.instance
      .collection('Games/$gameId/Players/$playerId/Cards/')
      .get();
  var cardIds = snapshot.docs.map((doc) => int.parse(doc.id));
  for (var cardId in cardIds) {
    // if this card has a score of 5, the claim is correct
    if (_getScoreForCard(numbers, cardId, symbolCount) >= 5) {
      hasBingo = true;
    }
  }

  await FirebaseFirestore.instance
      .doc('Games/$gameId/Players/$playerId')
      .update({'status': hasBingo ? 'wonBingo' : 'false bingo'});

  return hasBingo;
}

List<String> _getNumbersForCardId(int cardId, int symbolCount) {
  assert(symbolCount >= 24);
  assert(symbolCount % 5 == 0);

  var cardGenerator = Random(cardId);
  var symbolCountPerColumn = (symbolCount/5).round();
  print('symbolCountPerColumn=$symbolCountPerColumn');
  List<String> numbers = List.generate(25, (i) => "");
  for (var col=0; col < 5; col++) {
    for (var row=0; row < 5; row++) {
      late String num;
      do { 
        num = (1 + col * symbolCountPerColumn + cardGenerator.nextInt(symbolCountPerColumn)).toString();
      } while (numbers.contains(num));
      numbers[col*5 + row] = num;
    }
  }
  numbers.removeAt(13); // Remove free square
  return numbers;
}

int _getScoreForCard(List<String> numbers, int cardId, symbolCount) {
  return _getScoreForCardNumbers(
      numbers, _getNumbersForCardId(cardId, symbolCount), cardId);
}

int _getScoreForCardNumbers(List<String> numbers, List<String> cardNumbers, [int cardId = -1]) {
  const lines = [
    [1, 2, 3, 4, 5],
    [6, 7, 8, 9, 10],
    [11, 12, 13, 14],
    [15, 16, 17, 18, 19],
    [20, 21, 22, 23, 24],
    [1, 6, 11, 15, 20],
    [2, 7, 12, 16, 21],
    [3, 8, 17, 22],
    [4, 9, 13, 18, 23],
    [5, 10, 14, 19, 24],
    [1, 6, 18, 23],
    [5, 9, 16, 20]
  ];

  var maxLength = 0;
  for (var line in lines) {
    var length = line.length == 4 ? 1 : 0;
    for (var index in line) {
      if (numbers.contains(cardNumbers[index - 1])) {
        length++;
      }
    }
    if (length > maxLength) {
      maxLength = length;
    }
  }
  return maxLength;
}

int _calculateWinnerTime(
    int playerCount, int cardsPerPlayerCount, int symbolCount) {
  var cards = {};
  for (var playerIndex = 0; playerIndex < playerCount; playerIndex++) {
    for (var playerCardIndex = 0;
        playerCardIndex < cardsPerPlayerCount;
        playerCardIndex++) {
      var cardId = random.nextInt(1 << 32);
      var card = _getNumbersForCardId(cardId, symbolCount);
      cards[cardId] = card;
    }
  }
  var drawCount = 0, bestScore = 0, numbers = <String>[];
  do {
    var number = (1 + random.nextInt(symbolCount)).toString();
    numbers.add(number);
    var scores = cards.keys
        .map((cardId) => _getScoreForCardNumbers(numbers, cards[cardId]));
    bestScore = scores.reduce(max);
    drawCount++;
  } while (bestScore < 5 && drawCount < 100);
  print('Found a winner after $drawCount draws');
  return drawCount;
}

class TestGameTimeDialog extends StatefulWidget {
  TestGameTimeDialog({Key? key}) : super(key: key);

  @override
  State<TestGameTimeDialog> createState() => _TestGameTimeState();
}

class _TestGameTimeState extends State<TestGameTimeDialog> {
  var drawCounts = <int, int>{};
  var drawCountKeys = <int>[];
  var playerCount = 100;
  var cardsPerPlayerCount = 3;
  var symbolCount = 75;

  @override
  void initState() {
    super.initState();
  }

  void _runSimulations() {
    for (var i = 0; i < 10; i++) {
      var count =
          _calculateWinnerTime(playerCount, cardsPerPlayerCount, symbolCount);
      if (drawCounts.containsKey(count)) {
        drawCounts[count] = drawCounts[count]! + 1;
      } else {
        drawCounts[count] = 1;
        drawCountKeys.add(count);
        drawCountKeys.sort();
      }
    }
    return setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Draw count until winner'),
        ),
        body: Center(
            child: Column(children: [
          ElevatedButton(
              child: const Text("Run 10 simulations"),
              onPressed: () {
                _runSimulations();
              }),
          const Text("Player count"),
          Slider(
            value: 1.0 * playerCount,
            min: 50,
            max: 500,
            divisions: 9,
            label: playerCount.toString(),
            onChanged: (double value) {
              setState(() {
                playerCount = value.round();
              });
            },
          ),
          const Text("Cards per player"),
          Slider(
            value: 1.0 * cardsPerPlayerCount,
            min: 1,
            max: 5,
            divisions: 4,
            label: cardsPerPlayerCount.toString(),
            onChanged: (double value) {
              setState(() {
                cardsPerPlayerCount = value.round();
              });
            },
          ),
          const Text("Symbol count"),
          Slider(
            value: 1.0 * symbolCount,
            min: 25,
            max: 75,
            divisions: 2,
            label: symbolCount.toString(),
            onChanged: (double value) {
              setState(() {
                symbolCount = value.round();
              });
            },
          ),
          drawCounts.isEmpty
              ? const Text('No data to show yet')
              : SizedBox(
                  height: 300,
                  child: chart.BarChart(
                    [
                      chart.Series<int, String>(
                        id: 'draw counts',
                        data: drawCountKeys,
                        domainFn: (k, v) => k.toString(),
                        measureFn: (k, v) => drawCounts[k],
                      )
                    ],
                    animate: true,
                  ),
                ),
          ElevatedButton(
              child: const Text("Clear"),
              onPressed: () {
                drawCounts.clear();
                drawCountKeys.clear();
                setState(() {});
              }),
        ])));
  }
}
