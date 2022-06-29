import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vikings_bingo/src/app.dart';
import 'package:vikings_bingo/src/style/palette.dart';

import 'src/game/game_state.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (context) => Palette()),
        ChangeNotifierProvider(create: (context) => GameState()),
      ],
      child: const BingoPlayerApp(),
    ),
  );
}
