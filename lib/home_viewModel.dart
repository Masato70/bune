import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SearchResult {
  final int? accountIconCodePoint; // アイコンのコードポイントを格納するフィールドを
  final String? accountIconUrl; // アイコンの画像URLを格納するフィールド
  final String accountName;
  final String accountId;


  SearchResult(
    this.accountIconCodePoint,
    this.accountIconUrl,
    this.accountName,
    this.accountId,
  );
}

class HomeViewModel extends ChangeNotifier {
  TextEditingController friendIdController = TextEditingController();
  List<SearchResult> searchResults = [];
  List<SearchResult> friendsearchResults = [];
  List<String> friendRequests = ['Friend 1', 'Friend 2', 'Friend 3'];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> getCurrentAccountId() async {
    DocumentSnapshot currentUserDoc =
        await _firestore.collection('users').doc(_auth.currentUser!.uid).get();
    Map<String, dynamic> currentUserData =
        currentUserDoc.data() as Map<String, dynamic>;
    return currentUserData['account_id'];
  }

  void searchFriend() async {
    String friendId = friendIdController.text.trim();
    String myAccountId = await getCurrentAccountId();

    // 検索前に検索結果をクリア
    searchResults.clear();

    if (friendId != myAccountId) {
      Map<String, dynamic>? friendDetails =
          await getUserDetailsByAccountId(friendId);

      if (friendDetails != null) {
        String iconValue = friendDetails['account_icon'];

        if (iconValue.startsWith('http')) {
          // アイコンがURLの場合
          // URLをそのまま文字列として扱う
          SearchResult searchResult = SearchResult(
            null,
            iconValue,
            friendDetails['account_name'],
            friendDetails['account_id'],
          );
          searchResults.add(searchResult);
          print("URLです。アイコン: ${searchResults[0].accountIconUrl}");
        } else {
          // アイコンがコードポイントの場合
          int iconCodePoint = int.parse(iconValue);
          SearchResult searchResult = SearchResult(
            iconCodePoint,
            "",
            friendDetails['account_name'],
            friendDetails['account_id'],
          );
          searchResults.add(searchResult);
          print("アイコン画像でした。アイコン: ${searchResults[0].accountIconCodePoint}");
        }
      }
      //検索結果があるかどうかを確認してからnotifyListenersを呼ぶ
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> getUserDetailsByAccountId(
      String accountId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('account_id', isEqualTo: accountId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data() as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching user details: $e');
      return null;
    }
  }

  Future<void> addFriendRequest(String friendId) async {
    final User? user = _auth.currentUser;
    final uid = user?.uid;

    //自分のアカウントのドキュメントを取得
    DocumentReference myAccountDoc = _firestore.collection('users').doc(uid);

    // 友達申請のフィールドを更新
    await myAccountDoc.update({
      'friend_request': FieldValue.arrayUnion([friendId])
    });

    //友達のアカウントのドキュメントを取得
    QuerySnapshot friendAccountSnapshot = await _firestore
        .collection('users')
        .where('account_id', isEqualTo: friendId)
        .get();

    if (friendAccountSnapshot.docs.isNotEmpty) {
      DocumentReference friendAccountDoc =
          friendAccountSnapshot.docs.first.reference;

      // 自分のアカウントの詳細を取得
      DocumentSnapshot myAccountSnapshot = await myAccountDoc.get();
      Map<String, dynamic> myAccountDetails =
          myAccountSnapshot.data() as Map<String, dynamic>;
      String myAccountId = myAccountDetails['account_id'];

      //友達のアカウントに受信した友達申請のフィールドを更新
      return friendAccountDoc.update({
        'friend_request_received': FieldValue.arrayUnion([myAccountId])
      });
    }
  }

  Future<void> getFriendRequests() async {
    final User? user = _auth.currentUser;
    final uid = user?.uid;

    DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
    List friendRequestIds = userDoc?['friend_request_received'] ?? [];

    friendsearchResults.clear();

    for (String id in friendRequestIds) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('account_id', isEqualTo: id)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot friendDoc = querySnapshot.docs.first;
        Map<String, dynamic> friendData = friendDoc.data() as Map<String, dynamic>;

        String iconValue = friendData['account_icon'];
        int? iconCodePoint;
        String? iconUrl;

        if (iconValue.startsWith('http')) {
          iconUrl = iconValue;
        } else {
          iconCodePoint = int.parse(iconValue);
        }

        SearchResult searchResult = SearchResult(
          iconCodePoint,
          iconUrl,
          friendData['account_name'],
          friendData['account_id'],
        );
        friendsearchResults.add(searchResult);
        print("ですよー${"${searchResult.accountName}, ${searchResult.accountId}, ${searchResult.accountIconCodePoint}, ${searchResult.accountIconUrl}"}");
      } else {
        print('IDが $id のユーザーが見つかりません。');
      }
    }
    notifyListeners();
  }

}
