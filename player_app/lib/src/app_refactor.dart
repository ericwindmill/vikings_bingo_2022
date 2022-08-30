import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:google_fonts/google_fonts.dart';
import 'package:shared/player.dart';
import 'package:shared/player_status.dart';
import 'package:vikings_bingo/firestore_service.dart';
import 'package:vikings_bingo/src/util/game_util.dart';
import 'package:vikings_bingo/src/widgets/start/start_page_refactor.dart';

import 'widgets/game/game_page.dart';
import 'widgets/setup/setup_page_refactor.dart';

class AppShell extends StatelessWidget {
  const AppShell({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BingoApp(),
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
      scrollBehavior: AppScrollBehavior(),
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

class BingoApp extends StatefulWidget {
  const BingoApp({Key? key}) : super(key: key);

  @override
  State<BingoApp> createState() => _BingoAppState();
}

class _BingoAppState extends State<BingoApp> {
  Stream<String?> gameIdStream = FirestoreService.gameIdStream();
  bool initialLoading = true;
  Player? player;

  _initCurrentPlayer() async {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      // if signed out, return
      if (user == null) return;

      // if the player doesn't exist, generate a name and create the player.
      if (player == null) {
        if (user.displayName == null) {
          final name = generateRandomPlayerName();
          player = Player(
            uid: user.uid,
            name: name,
            status: PlayerStatus.newPlayer,
          );
          // update name in Firebase
          user.updateDisplayName(name);
        } else {
          player = Player(
            uid: user.uid,
            name: user.displayName,
            status: PlayerStatus.newPlayer,
          );
        }
      }
      _initGameIdStream();
    });
  }

  _initGameIdStream() {
    gameIdStream.listen((String? newGId) async {
      if (newGId == null) return;
      await FirestoreService.updatePlayerStatus(
        PlayerStatus.newPlayer,
        player!,
        newGId,
      );
      setState(() {
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
    return StreamBuilder<String?>(
      stream: gameIdStream,
      builder: (context, AsyncSnapshot<String?> gameIdSnapshot) {
        bool shouldShowStartPageWithDisabledButton =
            gameIdSnapshot.connectionState == ConnectionState.waiting ||
                !gameIdSnapshot.hasData ||
                gameIdSnapshot.data == null ||
                player == null ||
                player!.status == PlayerStatus.newPlayer;

        if (shouldShowStartPageWithDisabledButton) {
          return StartPageRefactor(
            onPressed: initialLoading
                ? null
                : () async {
                    await FirestoreService.updatePlayerStatus(
                      PlayerStatus.inLobby,
                      player!,
                      gameIdSnapshot.data!,
                    );
                    setState(() {});
                  },
          );
        }

        final newGameId = gameIdSnapshot.data!;
        return Builder(
          builder: (BuildContext context) {
            final shouldShowLobbyScreen =
                player!.status == PlayerStatus.inLobby;

            if (shouldShowLobbyScreen) {
              return SetupPageRefactor(
                gameId: newGameId,
                player: player!,
                onPressedJoin: initialLoading
                    ? null
                    : () async {
                        await FirestoreService.updatePlayerStatus(
                          PlayerStatus.waitingForCards,
                          player!,
                          gameIdSnapshot.data!,
                        );
                        setState(() {});
                      },
              );
            }

            return GamePage(
              player: player!,
              gameId: newGameId,
            );
          },
        );
      },
    );
  }
}
