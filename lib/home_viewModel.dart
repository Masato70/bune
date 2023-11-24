import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchResult {
  final String accountIcon;
  final String accountName;
  final String accountId;

  SearchResult(this.accountIcon, this.accountName, this.accountId);
}

class HomeViewModel extends ChangeNotifier {
  TextEditingController friendIdController = TextEditingController();
  List<SearchResult> searchResults = [];
  List<String> friendRequests = ['Friend 1', 'Friend 2', 'Friend 3'];

  void searchFriend() async {
    String friendId = friendIdController.text.trim();

    // 検索前に検索結果をクリア
    searchResults.clear();

    // HomeViewModelから詳細を取得
    Map<String, dynamic>? friendDetails =
    await getUserDetailsByAccountId(friendId);

    if (friendDetails != null) {
      SearchResult searchResult = SearchResult(
        friendDetails['account_icon'],
        friendDetails['account_name'],
        friendDetails['account_id'],
      );
      searchResults.add(searchResult);
      print("こちら${searchResults[0].accountName}");
    }

    // 検索結果があるかどうかを確認してからnotifyListenersを呼ぶ
    notifyListeners();
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
}
