import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:yarisma/main_page/camera_page.dart';
import 'package:yarisma/question_page/question_page.dart';
import 'package:yarisma/user_page/userPage.dart';

class BottomMenu extends StatefulWidget {
  const BottomMenu({super.key});

  @override
  State<BottomMenu> createState() => _BottomMenuState();
}

class _BottomMenuState extends State<BottomMenu> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const CameraPage(),
    const QuestionsPage(),
    const Userpage(),
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(top: 8.0, bottom: 16.0),
        color: Colors.black,
        child: GNav(
          gap: 8,
          activeColor: Colors.black,
          iconSize: 25,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          duration: const Duration(milliseconds: 300),
          tabBackgroundColor: Colors.white,
          color: Colors.white,
          tabs: const [
            GButton(
              icon: Icons.home,
              text: 'Ana sayfa',
            ),
            GButton(
              icon: Icons.question_answer,
              text: 'Sorular',
            ),
            GButton(
              icon: Icons.person,
              text: 'Kullanıcı',
            ),
          ],
          selectedIndex: _selectedIndex,
          onTabChange: _onItemTapped,
        ),
      ),
    );
  }
}
