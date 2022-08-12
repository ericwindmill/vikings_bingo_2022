import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:google_fonts/google_fonts.dart';
import 'package:shared/player.dart';
import 'package:shared/player_status.dart';
import 'package:vikings_bingo/firestore_service.dart';
import 'package:vikings_bingo/src/widgets/start/start_page_refactor.dart';

class AppShell extends StatelessWidget {
  final Player player;
  const AppShell({Key? key, required this.player}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BingoApp(
        player: player,
      ),
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
  final Player player;
  const BingoApp({Key? key, required this.player}) : super(key: key);

  @override
  State<BingoApp> createState() => _BingoAppState();
}

class _BingoAppState extends State<BingoApp> {
  Stream<String> gameIdStream = FirestoreService.gameIdStream();
  bool initialLoading = true;

  @override
  void initState() {
    super.initState();
    gameIdStream.listen((newGId) async {
      await FirestoreService.joinLobby(gameId: newGId, player: widget.player);
      setState(() {
        initialLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
        stream: gameIdStream,
        builder: (context, AsyncSnapshot<String> gameIdSnapshot) {
          bool shouldShowStartPageWithDisabledButton =
              gameIdSnapshot.connectionState == ConnectionState.waiting ||
                  !gameIdSnapshot.hasData ||
                  gameIdSnapshot.data == 'none' ||
                  widget.player.status == PlayerStatus.newPlayer;

          if (shouldShowStartPageWithDisabledButton) {
            return StartPageRefactor(
              onPressed: initialLoading
                  ? null
                  : () {
                      FirestoreService.updatePlayerStatus(
                        PlayerStatus.inLobby,
                        widget.player,
                        gameIdSnapshot.data!,
                      );
                    },
            );
          }

          final newGameId = gameIdSnapshot.data!;
          return StreamBuilder<Player>(
            stream: FirestoreService.getPlayerStream(newGameId),
            builder:
                (BuildContext context, AsyncSnapshot<Player> playerSnapshot) {
              if (playerSnapshot.hasError) {
                return Text('player snapshot has error');
              }

              if (playerSnapshot.connectionState == ConnectionState.waiting) {
                return Text('loading player');
              }

              final player = playerSnapshot.data!;
              return Scaffold(
                body: Column(
                  children: [
                    Text('Game ID: $newGameId'),
                    Text('Player id: ${player.uid}'),
                  ],
                ),
              );
            },
          );
        });
  }
}
