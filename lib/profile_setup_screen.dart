import 'dart:io';
import 'package:bune/home_screen.dart';
import 'package:bune/profile_setup_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class ProfileSetupScreen extends StatefulWidget {
  @override
  _ProfileSetupScreenState createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  ProfileSetupViewModel viewModel = ProfileSetupViewModel(
    imagePicker: ImagePicker(), // ImagePicker のインスタンスを渡す
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('プロフィール設定'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _showIconPicker,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[200],
                child: (viewModel.selectedIconOrImage is IconData)
                    ? Icon(
                        viewModel.selectedIconOrImage,
                        size: 50,
                      )
                    : Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: FileImage(viewModel.selectedIconOrImage),
                          ),
                        ),
                      ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: viewModel.idController,
              decoration: InputDecoration(
                labelText: 'ID',
                hintText: 'あなたのIDを決めてください',
                errorText:
                    (viewModel.idError != null && viewModel.idError.isNotEmpty)
                        ? viewModel.idError
                        : null,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_-]')),
              ],
            ),
            TextField(
              controller: viewModel.nameController,
              decoration: InputDecoration(
                labelText: '名前',
                hintText: 'あなたの名前を入力してください',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (viewModel.idController.text.isEmpty ||
                    viewModel.nameController.text.isEmpty) {
                  // IDが入力されていない場合
                  print("IDと名前を入力されていないです");
                } else {
                  viewModel.saveProfile(onSuccess: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                    print("保存完了");
                  }, onIdNotUnique: () {
                    setState(() {
                      viewModel.idError = 'このIDは既に使用されています';
                    });
                  });
                }
              },
              child: Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  // アイコン選択のダイアログを表示するメソッド
  void _showIconPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('アイコンを選択'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildIconSelection(Icons.person),
                    _buildIconSelection(Icons.favorite),
                    _buildIconSelection(Icons.star),
                  ],
                ),
                SizedBox(height: 20),
                TextButton.icon(
                  onPressed: () async {
                    final pickedFile = await ImagePicker()
                        .pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      File selectedImage = File(pickedFile.path);

                      print("ImageのPath: ${selectedImage.path}");
                      setState(() {
                        viewModel.selectedIconOrImage = selectedImage;
                      });
                    }
                  },
                  icon: Icon(
                    Icons.image,
                    color: Colors.black,
                  ),
                  label: Text(
                    '画像を選択',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    primary: Colors.black,
                    side: BorderSide(color: Colors.grey),
                    padding: EdgeInsets.symmetric(horizontal: 70, vertical: 15),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  // アイコン選択ウィジェットを構築するメソッド
  Widget _buildIconSelection(dynamic iconOrImage) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (iconOrImage is IconData) {
            viewModel.selectedIconOrImage = iconOrImage;
            print("IconDataでした。");
          } else if (iconOrImage is File) {
            viewModel.selectedIconOrImage = iconOrImage;
            print("ImageのPathです。: ${iconOrImage.path}");
          }
        });
        Navigator.pop(context); // ダイアログを閉じる
      },
      child: CircleAvatar(
        radius: 30,
        backgroundColor: Colors.grey[200],
        child: (iconOrImage is IconData)
            ? Icon(
                iconOrImage,
                size: 30,
              )
            : Image.file(
                iconOrImage,
                width: 30,
                height: 30,
                fit: BoxFit.cover,
              ),
      ),
    );
  }
}
