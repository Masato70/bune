import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class ProfileSetupViewModel {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  dynamic selectedIconOrImage = Icons.person;
  dynamic aaa = null;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  Uint8List? bytes;
  final ImagePicker imagePicker;
  final firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  String idError = '';

  // コンストラクタで外部依存性を注入
  ProfileSetupViewModel({
    required this.imagePicker,
  });

  Future<String> uploadImage(File imageFile) async {
    // Firebase Storageへのアップロード処理
    print("写真をアップロード");
    firebase_storage.UploadTask uploadTask = storage
        .ref('profile_images/${DateTime.now().millisecondsSinceEpoch}')
        .putFile(imageFile);
    await uploadTask;

    String imageUrl = await uploadTask.snapshot.ref.getDownloadURL();

    return imageUrl;
  }

  Future<bool> isAccountIdUnique(String accountId) async {
    CollectionReference usersCollection = firestore.collection('users');

    try {
      QuerySnapshot querySnapshot =
          await usersCollection.where('account_id', isEqualTo: accountId).get();

      return querySnapshot.docs.isEmpty;
    } catch (e) {
      print('Firebaseエラー: $e');
      return false;
    }
  }

  Future<void> saveProfile(
      {required VoidCallback onSuccess,
      required VoidCallback onIdNotUnique}) async {

    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        // AuthenticationのユーザーUIDを取得
        String uid = currentUser.uid;

        String name = nameController.text;
        String id = idController.text;
        String imageUrl = '';

        // アカウントIDの一意性を確認
        bool isUnique = await isAccountIdUnique(id);

        if (isUnique) {
          if (selectedIconOrImage is File) {
            imageUrl = await uploadImage(selectedIconOrImage as File);
          } else if (selectedIconOrImage is IconData) {
            imageUrl = selectedIconOrImage.codePoint.toString();
          }

          // Firestoreにデータを保存
          await firestore.collection('users').doc(uid).set({
            "account_id": id,
            'account_name': name,
            'account_icon': imageUrl,
          });

          // 保存後の処理を通知
          onSuccess();
        } else {
          // アカウントIDが既に存在する場合の処理
          onIdNotUnique();
        }
      } else {
        // ユーザーがログインしていない場合のエラー処理
        print('Error: User not logged in');
      }
    } catch (e) {
      print('Error saving profile: $e');
    }
  }
}
