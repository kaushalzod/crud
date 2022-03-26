import 'dart:io';

import 'package:crud/services/provider.dart';
import 'package:crud/shared/constant.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SharedWidget {
  sharedTextButton(
      {required void Function()? onPressed, required String text}) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      style: TextButton.styleFrom(
        backgroundColor: primaryButtonColor,
        primary: whiteColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        padding:
            const EdgeInsets.only(left: 24, right: 24, top: 10, bottom: 10),
      ),
    );
  }

  modalSheet(
      {required String title,
      bool isEdit = false,
      dynamic data,
      required BuildContext context}) {
    TextEditingController titleController = isEdit
        ? TextEditingController(text: data['title'])
        : TextEditingController();
    TextEditingController descController = isEdit
        ? TextEditingController(text: data['desc'])
        : TextEditingController();
    GlobalKey<FormState> formKey = GlobalKey<FormState>();
    String itemTitle = "";
    String itemDesc = "";
    var image;
    bool imageError = false;

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (context) {
        return SingleChildScrollView(
          child: StatefulBuilder(builder: (context, setState) {
            return Form(
              key: formKey,
              child: Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: Padding(
                  padding: const EdgeInsets.all(31),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      InkWell(
                        onTap: () async {
                          final imagePicker = ImagePicker();
                          final galleryImage = await imagePicker.pickImage(
                              source: ImageSource.gallery);
                          if (galleryImage != null) {
                            image = File(galleryImage.path);
                            imageError = false;
                            setState(() {});
                          }
                        },
                        child: SizedBox(
                          width: 109,
                          height: 109,
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: image != null
                                    ? Image.file(
                                        image,
                                        height: 109,
                                        width: 109,
                                        fit: BoxFit.cover,
                                      )
                                    : data == null
                                        ? Image.asset('assets/images/media.png')
                                        : Image.network(
                                            data['image'],
                                            height: 109,
                                            width: 109,
                                            fit: BoxFit.cover,
                                          ),
                              ),
                              Positioned(
                                bottom: 0,
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.all(5),
                                  child: Text(
                                    isEdit ? "Change" : "Pick",
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  width: 109,
                                  decoration: BoxDecoration(
                                    color: imagebackgroundColor,
                                    borderRadius: const BorderRadius.only(
                                      bottomRight: Radius.circular(12),
                                      bottomLeft: Radius.circular(12),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Visibility(
                        child: Text(
                          "Select Image to add Item",
                          style: TextStyle(color: deleteSliderColor),
                        ),
                        visible: imageError,
                      ),
                      const SizedBox(
                        height: 22,
                      ),
                      TextFormField(
                        controller: titleController,
                        validator: (String? value) {
                          if (value == null || value.length <= 1) {
                            return 'Title should be atleast one characters.';
                          }
                          return null;
                        },
                        onSaved: (String? value) {
                          itemTitle = value!;
                        },
                        decoration: const InputDecoration(
                          counterText: '',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(),
                            borderRadius: BorderRadius.all(
                              Radius.circular(4),
                            ),
                          ),
                          hintText: "Enter Title Here",
                          labelText: "Title",
                        ),
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      TextFormField(
                        controller: descController,
                        validator: (String? value) {
                          if (value == null || value.length <= 4) {
                            return 'Description should be atleast four characters.';
                          }
                          return null;
                        },
                        onSaved: (String? value) {
                          itemDesc = value!;
                        },
                        decoration: const InputDecoration(
                            counterText: '',
                            border: OutlineInputBorder(
                              borderSide: BorderSide(),
                              borderRadius: BorderRadius.all(
                                Radius.circular(4),
                              ),
                            ),
                            hintText: "Enter Description Here",
                            labelText: "Description"),
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: sharedTextButton(
                          text: "SAVE",
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              if (isEdit) {
                                formKey.currentState!.save();
                                CrudProvider().updateItem(
                                    title: itemTitle,
                                    desc: itemDesc,
                                    image: image,
                                    oldData: data);
                              } else {
                                if (image != null && imageError == false) {
                                  formKey.currentState!.save();
                                  CrudProvider().addItem(
                                      title: itemTitle,
                                      desc: itemDesc,
                                      image: image);
                                } else {
                                  imageError = true;
                                  setState(() {});
                                }
                              }
                            }
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
