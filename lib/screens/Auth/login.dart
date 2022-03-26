import 'package:crud/services/provider.dart';
import 'package:crud/shared/constant.dart';
import 'package:crud/shared/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  CrudProvider crudProvider = CrudProvider();
  TextEditingController mobileNumber = TextEditingController();
  String phoneNumber = "+91";
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(36),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Continue with Phone",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
              ),
              const SizedBox(
                height: 52,
              ),
              TextFormField(
                controller: mobileNumber,
                keyboardType: TextInputType.phone,
                validator: (String? value) {
                  if (value == null || value.length != 10) {
                    return 'Please Enter valid Mobile Number.';
                  }
                  return null;
                },
                onSaved: (String? value) {
                  phoneNumber = phoneNumber + value!;
                },
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 10,
                showCursor: false,
                decoration: const InputDecoration(
                    counterText: '',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(),
                      borderRadius: BorderRadius.all(
                        Radius.circular(4),
                      ),
                    ),
                    hintText: "Mobile Number",
                    labelText: "Mobile Number"),
              ),
              const SizedBox(
                height: 62,
              ),
              Center(
                child: SharedWidget().sharedTextButton(
                  text: "CONTINUE",
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();
                      crudProvider.login(
                        phoneNumber: phoneNumber,
                        context: context,
                      );
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
