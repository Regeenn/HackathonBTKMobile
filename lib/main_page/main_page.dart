import 'package:flutter/material.dart';
import 'package:yarisma/bottom_navbar/bottom_menu.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: BottomMenu(),
    );
  }
}
