import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared/player.dart';
import 'package:shared/player_status.dart';
import 'package:vikings_bingo/firestore_service.dart';
import 'package:vikings_bingo/src/widgets/start/start_page.dart';

import 'widgets/game/game_page.dart';
import 'widgets/setup/setup_page.dart';

class BingoPlayerApp extends StatefulWidget {
  final Player player;
  const BingoPlayerApp({Key? key, required this.player}) : super(key: key);

  @override
  State<BingoPlayerApp> createState() => _BingoPlayerAppState();
}

class _BingoPlayerAppState extends State<BingoPlayerApp> {
  final Stream<String> gameIdStream = FirestoreService.gameIdStream();
  Stream<Player> playerStream = FirestoreService.getPlayerStream('none');
  String gameId = 'none';
  late Player player;

  _BingoPlayerAppState() {
    player = widget.player;
  }

  @override
  void initState() {
    super.initState();
    gameIdStream.listen((gId) async {
      if (gId != gameId) {
        // On new game: update GameId And Player's status to inLobby
        FirestoreService.updatePlayerStatus(
            PlayerStatus.inLobby, player, gameId);
        setState(() {
          gameId = gId;
        });
      }

      playerStream = FirestoreService.getPlayerStream(gId);
      playerStream.listen((Player p) {
        setState(() {
          player = p;
        });
      });
    });

    FirestoreService.getPlayerStream(gameId).listen((Player player) {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: AppScrollBehavior(),
      onGenerateRoute: (RouteSettings routeSettings) {
        if (routeSettings.name == '/') {
          return MaterialPageRoute(
              builder: (context) => StartPage(player: widget.player));
        }

        if (routeSettings.name == '/setup') {
          return MaterialPageRoute(
            builder: (context) => SetupPage(
              player: widget.player,
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
              player: widget.player,
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
