import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud/services/provider.dart';
import 'package:crud/shared/constant.dart';
import 'package:crud/shared/widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CrudProvider crudProvider = CrudProvider();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "ITEMS",
          style: TextStyle(color: darkColor),
        ),
        centerTitle: true,
        backgroundColor: backgroundColor,
        actions: [
          IconButton(
              onPressed: () {
                crudProvider.logout();
              },
              icon: Icon(
                Icons.logout,
                color: iconColor,
              ))
        ],
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(right: 10, bottom: 10),
        height: 69,
        width: 69,
        child: FloatingActionButton(
          elevation: 3,
          backgroundColor: addItembackgroundColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(16),
            ),
          ),
          child: Icon(
            Icons.add,
            color: darkColor,
            size: 28,
          ),
          onPressed: () {
            SharedWidget().modalSheet(
              title: "Add Item",
              context: context,
            );
          },
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('items')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.only(top: 12),
              child: ListView(
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data =
                    document.data()! as Map<String, dynamic>;
                data['docId'] = document.id;
                print(data);
                return itemList(data: data, id: data);
              }).toList()),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Widget itemList({dynamic id, required dynamic data}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
      height: 80,
      decoration: BoxDecoration(
        color: deleteSliderColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Dismissible(
        onDismissed: (direction) {
          crudProvider.deleteItem(data);
        },
        direction: DismissDirection.startToEnd,
        background: Container(
          alignment: Alignment.centerLeft,
          child: SvgPicture.asset('assets/icons/delete.svg'),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: deleteSliderColor),
        ),
        key: ObjectKey(id),
        child: Container(
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                blurRadius: 6,
                spreadRadius: 2,
                offset: Offset(0, 2),
                color: Color.fromARGB(15, 0, 0, 0),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(
                      data['image'],
                    ),
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['title'],
                      maxLines: 1,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 16),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      data["desc"],
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  SharedWidget().modalSheet(
                    isEdit: true,
                    title: "Edit Item",
                    data: data,
                    context: context,
                  );
                },
                style: TextButton.styleFrom(
                    backgroundColor: iconBackgroundColor,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(10)),
                child: SvgPicture.asset('assets/icons/edit.svg'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
