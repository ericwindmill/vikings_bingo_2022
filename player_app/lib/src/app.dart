import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:google_fonts/google_fonts.dart';
import 'package:shared/player.dart';
import 'package:shared/player_status.dart';
import 'package:vikings_bingo/firestore_service.dart';
import 'package:vikings_bingo/src/widgets/start/start_page.dart';

import 'util/game_util.dart';
import 'widgets/game/game_page.dart';
import 'widgets/setup/setup_page.dart';

class BingoPlayerApp extends StatefulWidget {
  const BingoPlayerApp({Key? key}) : super(key: key);

  @override
  State<BingoPlayerApp> createState() => _BingoPlayerAppState();
}

class _BingoPlayerAppState extends State<BingoPlayerApp> {
  final Stream<String> gameIdStream = FirestoreService.gameIdStream();
  String gameId = 'none';
  bool playerHasCards = false;
  bool initialLoading = true;
  Player? player;

  _initCurrentPlayer() async {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user == null) return;
      if (user.displayName == null) {
        final name = generateRandomPlayerName();
        player = Player(uid: user.uid, name: name);
        user.updateDisplayName(generateRandomPlayerName());
      } else {
        player = Player(uid: user.uid, name: user.displayName);
      }
      _initGameIdStream();
    });
  }

  _initGameIdStream() {
    gameIdStream.listen((gId) async {
      // On new game: update GameId And add player to "lobby".
      await FirestoreService.joinLobby(gameId: gId, player: player!);
      final hasCards = await FirestoreService.playerHasCards(gId);

      if (hasCards) {
        await FirestoreService.updatePlayerStatus(
          PlayerStatus.playing,
          player!,
          gId,
        );
      }

      setState(() {
        gameId = gId;
        playerHasCards = hasCards;
        initialLoading = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _initCurrentPlayer();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: AppScrollBehavior(),
      onGenerateRoute: (RouteSettings routeSettings) {
        if (routeSettings.name == '/') {
          return MaterialPageRoute(
            builder: (context) => StartPage(
              shouldSkipSetup: playerHasCards,
              loading: initialLoading,
            ),
          );
        }

        if (routeSettings.name == '/setup') {
          return MaterialPageRoute(
            builder: (context) => SetupPage(
              player: player!,
              gameIdStream: gameIdStream,
            ),
          );
        }

        if (routeSettings.name == '/play') {
          if (gameId == 'none') {
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          }

          return MaterialPageRoute(
            builder: (context) => GamePage(
              player: player!,
              gameId: gameId,
            ),
          );
        }
      },
      theme: ThemeData(
        textTheme: GoogleFonts.pressStart2pTextTheme(
          const TextTheme(
            displayLarge: TextStyle(fontSize: 24.0),
            displayMedium: TextStyle(fontSize: 20.0),
            displaySmall: TextStyle(fontSize: 18.0),
            bodySmall: TextStyle(fontSize: 12.0),
            bodyMedium: TextStyle(fontSize: 14.0),
            bodyLarge: TextStyle(fontSize: 16.0),
            labelLarge: TextStyle(fontSize: 11.0),
            labelMedium: TextStyle(fontSize: 9.0),
            labelSmall: TextStyle(fontSize: 9.0),
          ),
        ),
      ),
    );
  }
}

/// This class overrides gesture behavior, and allows us to use the mouse to trigger
/// drag gestures. In this case, it allows us to swipe on the "PageView" widget
/// while running the app on the Web.
class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
