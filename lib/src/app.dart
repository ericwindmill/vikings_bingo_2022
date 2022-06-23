import 'package:flutter/material.dart';
import 'package:vikings_bingo/src/widgets/bingo_board.dart';

class BingoPlayerApp extends StatelessWidget {
  const BingoPlayerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: const Text("Flutter Vikings 2022"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: BingoPageViewWrapper(),
        ),
      ),
    ));
  }
}

class BingoPageViewWrapper extends StatelessWidget {
  BingoPageViewWrapper({Key? key}) : super(key: key);
  final controller = PageController();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: PageView(controller: controller, children: const [
        BingoBoard(),
        BingoBoard(),
        BingoBoard(),
      ]),
    );
  }
}
