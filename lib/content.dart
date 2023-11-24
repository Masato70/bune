import 'package:flutter/material.dart';
import 'bottom_navigation.dart';

class Content extends StatefulWidget {
  @override
  _ContentState createState() => _ContentState();
}

class _ContentState extends State<Content> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationContent();
  }
}