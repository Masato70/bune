import 'package:bune/profile_setup_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Future<User?> signInWithGoogle() async {
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount!.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final UserCredential authResult =
        await firebaseAuth.signInWithCredential(credential);
    final User? user = authResult.user;

    if (user != null) {
      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);
      final User? currentUser = firebaseAuth.currentUser;
      assert(user.uid == currentUser!.uid);

      DocumentSnapshot<Map<String, dynamic>> userData =
      await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (userData.exists) {
        // Firestoreにデータが存在する場合はHomeScreenに遷移
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        // Firestoreにデータが存在しない場合はProfileSetupScreenに遷移
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfileSetupScreen()),
        );
      }
      print('signInWithGoogle succeeded: $user');

      return user;
    }
    return null;
  }

  // void signOutGoogle() async {
  //   await googleSignIn.signOut();
  //   print("User Signed Out");
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ログイン'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton.icon(
              icon: Image.asset(
                'assets/google-icon-3.png',
                width: 20.0,
                height: 20.0,
              ),
              label: Text("Googleでログイン"),
              style: TextButton.styleFrom(
                primary: Colors.black, // テキストの色を黒に変更
                side: BorderSide(color: Colors.grey), // ボタンをグレーの線で囲む
              ),
              onPressed: () async {
                User? user = await signInWithGoogle();
              },
            ),
          ],
        ),
      ),
    );
  }
}
