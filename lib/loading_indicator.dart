import 'package:flutter/material.dart';

class CustomLoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 60.0,
        height: 60.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.deepPurple, // ローディングアニメーションの色
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
    );
  }
}