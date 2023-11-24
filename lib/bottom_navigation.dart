import 'package:flutter/material.dart';

import 'home_screen.dart';

class BottomNavigationContent extends StatefulWidget {
  @override
  _BottomNavigationContentState createState() => _BottomNavigationContentState();
}

class _BottomNavigationContentState extends State<BottomNavigationContent> {
  int _currentIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentIndex == 0
          ? HomeScreen() // ホームが選択された場合はHomeScreenを表示
          : Container(), // 他のアイテムが選択された場合は空のコンテナを表示（ここで他のページを追加できます）
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'ホーム',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'トーク',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_box),
            label: 'マイページ',
          ),
        ],
        currentIndex: _currentIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}