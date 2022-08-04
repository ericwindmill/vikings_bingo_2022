import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared/player.dart';
import 'package:vikings_bingo/firestore_service.dart';
import 'package:vikings_bingo/src/widgets/setup/setup_page.dart';

import 'widgets/game/game_page.dart';
import 'widgets/start/start_page.dart';

class BingoPlayerApp extends StatefulWidget {
  final Player player;
  const BingoPlayerApp({Key? key, required this.player}) : super(key: key);

  @override
  State<BingoPlayerApp> createState() => _BingoPlayerAppState();
}

class _BingoPlayerAppState extends State<BingoPlayerApp> {
  final Stream<String?> gameIdStream = FirestoreService.gameIdStream();
  String? gameId;

  @override
  void initState() {
    super.initState();
    // when the app boots OR the gameId updates, get the gameId and player,
    // and set them as variable that we'll use for everything else.
    gameIdStream.listen((gId) async {
      // when gameId updates, we want to re-load the entire app
      setState(() {
        gameId = gId;
        // todo: reload game or something
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: AppScrollBehavior(),
      routes: {
        '/': (context) => const StartPage(),
        '/setup': (context) => SetupPage(player: widget.player),
        '/play': (context) => GamePage(
              player: widget.player,
              gameId: gameId!,
            ),
      },
      initialRoute: '/',
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
