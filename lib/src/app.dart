import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vikings_bingo/src/widgets/setup/setup_page.dart';

import 'widgets/game/game_page.dart';
import 'widgets/start/start_page.dart';

class BingoPlayerApp extends StatelessWidget {
  const BingoPlayerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (context) => const StartPage(),
        '/setup': (context) => const SetupPage(),
        '/play': (context) => const GamePage(),
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
