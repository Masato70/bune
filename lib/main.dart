import 'package:bune/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 追加

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'content.dart';
import 'firebase_options.dart';
import 'home_screen.dart';
import 'home_viewModel.dart';
import 'loading_indicator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => HomeViewModel(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> checkIfUserIsLoggedIn() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // ユーザーがログインしている場合
      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        // Firestoreにユーザーのドキュメントが存在する場合
        return true; // HomeScreenに遷移
      } else {
        // Firestoreにユーザーのドキュメントが存在しない場合
        return false; // LoginScreenに遷移
      }
    } else {
      // ユーザーがログインしていない場合
      return false; // LoginScreenに遷移
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'bune',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: FutureBuilder<bool>(
        future: checkIfUserIsLoggedIn(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // return CustomLoadingIndicator();
            // return CircularProgressIndicator();
            return Container(); // 追加したコード
          } else {
            return snapshot.data! ? Content() : LoginScreen();
          }
        },
      ),
    );
  }
}
