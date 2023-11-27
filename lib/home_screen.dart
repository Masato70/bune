import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'home_viewModel.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> _friendRequests = ['Friend 1', 'Friend 2', 'Friend 3'];

  @override
  void initState() {
    super.initState();
    HomeViewModel().getFriendRequests();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HomeViewModel(),
      child: Consumer<HomeViewModel>(
        builder: (context, _viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('ホーム'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            '友達検索',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: TextField(
                                  controller: _viewModel.friendIdController,
                                  decoration: const InputDecoration(
                                    hintText: '友達のIDを入力してください',
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.search),
                                onPressed: () {
                                  _viewModel.searchFriend();
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16.0),
                          const Text(
                            '検索結果',
                            style: TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          _viewModel.searchResults.isNotEmpty
                              ? Card(
                                  child: ListTile(
                                  leading: _viewModel.searchResults[0]
                                                  .accountIconUrl !=
                                              null &&
                                          _viewModel.searchResults[0]
                                              .accountIconUrl!.isNotEmpty
                                      ? ClipOval(
                                          child: AspectRatio(
                                            aspectRatio: 1 / 1, // アスペクト比を1:1に設定
                                            child: Image.network(
                                                _viewModel.searchResults[0]
                                                    .accountIconUrl!,
                                                fit: BoxFit.cover),
                                          ),
                                        )
                                      : Icon(
                                          IconData(
                                            _viewModel.searchResults[0]
                                                .accountIconCodePoint!,
                                            fontFamily: 'MaterialIcons',
                                          ),
                                        ),
                                  title: Text(
                                      _viewModel.searchResults[0].accountName),
                                  subtitle: Text(
                                      _viewModel.searchResults[0].accountId),
                                  trailing: IconButton(
                                    icon: Icon(
                                      Icons.add,
                                      size: 30,
                                    ),
                                    color: Colors.green,
                                    iconSize: 30.0,
                                    onPressed: () {
                                      String friendId =
                                          _viewModel.friendIdController.text;
                                      _viewModel.addFriendRequest(friendId);
                                    },
                                  ),
                                ))
                              : Text('検索結果はありません。'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    '承認待ち一覧',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _viewModel.friendsearchResults.isNotEmpty
                      ? Expanded(
                          child: ListView.builder(
                            itemCount: _viewModel.friendsearchResults.length,
                            itemBuilder: (context, index) {
                              return Card(
                                child: ListTile(
                                  leading: const Icon(Icons.person),
                                  title: Text(_viewModel
                                      .friendsearchResults[index].accountName),
                                  subtitle: Text(_viewModel
                                      .friendsearchResults[index].accountId),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      IconButton(
                                        icon: const Icon(Icons.check),
                                        onPressed: () {},
                                        color: Colors.green,
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close),
                                        onPressed: () {},
                                        color: Colors.red,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      : const Text('友達のリクエストはありません。'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// void main() {
//   runApp(MaterialApp(
//     home: HomeScreen(),
//   ));
// }
