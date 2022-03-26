import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud/screens/Auth/login.dart';
import 'package:crud/screens/Auth/verify.dart';
import 'package:crud/screens/Home/home.dart';
import 'package:crud/shared/constant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CrudProvider {
  FirebaseAuth auth = FirebaseAuth.instance;
  String verificationIdReceived = "";
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  login({required String phoneNumber, required BuildContext context}) async {
    await auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {
          auth.signInWithCredential(credential).then((value) => print(value));
        },
        verificationFailed: (FirebaseAuthException exception) {
          print(exception.message);
        },
        codeSent: (String verificationId, int? resendToken) {
          verificationIdReceived = verificationId;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VerifyPage(verificationId: verificationId),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {});
  }

  // getItem() async {
  //   CollectionReference users = firestore.collection('users');

  //   var data = await users.doc(auth.currentUser!.uid);
  //   // print(data.);
  // }

  verifyOtp({required String otp, required verificationId}) async {
    AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: otp);

    try {
      await auth.signInWithCredential(credential).then((value) {
        print("You are signed In Successfully");
        navigatorKey.currentState!.pushReplacement(
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
      });
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-verification-code':
          print('invalid-verification-code');
          break;
        case 'invalid-verification-id':
          print('invalid-verification-id:');
          break;
        default:
      }
    }
  }

  addItem(
      {required String title,
      required String desc,
      required File image}) async {
    FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    // final imagePicker = ImagePicker();
    // final image = await imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // var file = File(image.path);
      var snapshot = await _firebaseStorage
          .ref()
          .child('images/' + DateTime.now().toString().split(" ").join(""))
          .putFile(image);

      final imageUrl = await snapshot.ref.getDownloadURL();
      await firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('items')
          .add({
        "title": title,
        "desc": desc,
        "image": imageUrl.toString(),
        "createdAt": DateTime.now().microsecondsSinceEpoch
      }).then((value) {
        print("Item Added");
        navigatorKey.currentState!.pop();
        snackbarKey.currentState!.showSnackBar(
          const SnackBar(
            content: Text("Item Added Successfully"),
          ),
        );
      }).catchError((error) => print("Failed to add Item: $error"));
    }
  }

  updateItem(
      {required String title,
      required String desc,
      File? image,
      dynamic oldData}) async {
    FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    if (image != null) {
      // var file = File(image.path);
      await FirebaseStorage.instance.refFromURL(oldData['image']).delete();
      var snapshot = await _firebaseStorage
          .ref()
          .child('images/' + DateTime.now().toString().split(" ").join(""))
          .putFile(image);

      final imageUrl = await snapshot.ref.getDownloadURL();
      await firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('items')
          .doc(oldData['docId'])
          .update({
        "title": title,
        "desc": desc,
        "image": imageUrl.toString(),
        "modifiedAt": DateTime.now().microsecondsSinceEpoch
      }).then((value) {
        print("Item Added");
        navigatorKey.currentState!.pop();
        snackbarKey.currentState!.showSnackBar(
          const SnackBar(
            content: Text("Item Updated Successfully"),
          ),
        );
      }).catchError((error) => print("Failed to add Item: $error"));
    } else {
      await firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('items')
          .doc(oldData['docId'])
          .update({
        "title": title,
        "desc": desc,
        "modifiedAt": DateTime.now().microsecondsSinceEpoch
      }).then((value) {
        print("Item Added");
        navigatorKey.currentState!.pop();
        snackbarKey.currentState!.showSnackBar(
          const SnackBar(
            content: Text("Item Updated Successfully"),
          ),
        );
      }).catchError((error) => print("Failed to add Item: $error"));
    }
  }

  void deleteItem(data) {
    try {
      firestore
          .collection('users')
          .doc(auth.currentUser!.uid)
          .collection('items')
          .doc(data['docId'])
          .delete()
          .then((value) =>
              {FirebaseStorage.instance.refFromURL(data['image']).delete()})
          .then((value) {
        snackbarKey.currentState!.showSnackBar(
          const SnackBar(
            content: Text("Item Deleted Successfully"),
          ),
        );
      });
    } catch (e) {
      print(e);
    }
  }

  logout() {
    auth.signOut();
    navigatorKey.currentState!.pushReplacement(MaterialPageRoute(
      builder: (context) => const LoginPage(),
    ));
  }
}
