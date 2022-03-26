import 'package:crud/services/provider.dart';
import 'package:crud/shared/constant.dart';
import 'package:crud/shared/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VerifyPage extends StatefulWidget {
  const VerifyPage({Key? key, this.verificationId}) : super(key: key);
  final verificationId;

  @override
  State<VerifyPage> createState() => _VerifyPageState();
}

class _VerifyPageState extends State<VerifyPage> {
  CrudProvider crudProvider = CrudProvider();
  GlobalKey<FormState> otpFormKey = GlobalKey<FormState>();
  TextEditingController otp_1 = TextEditingController();
  TextEditingController otp_2 = TextEditingController();
  TextEditingController otp_3 = TextEditingController();
  TextEditingController otp_4 = TextEditingController();
  TextEditingController otp_5 = TextEditingController();
  TextEditingController otp_6 = TextEditingController();
  String otp = "";
  @override
  Widget build(BuildContext context) {
    print(widget.verificationId);
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(36),
        child: Form(
          key: otpFormKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Verify your phone",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
              ),
              const SizedBox(
                height: 52,
              ),
              Text(
                "Enter Code",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: primaryButtonColor,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  otpBox(first: true, last: false, controller: otp_1),
                  otpBox(first: false, last: false, controller: otp_2),
                  otpBox(first: false, last: false, controller: otp_3),
                  otpBox(first: false, last: false, controller: otp_4),
                  otpBox(first: false, last: false, controller: otp_5),
                  otpBox(first: false, last: true, controller: otp_6),
                ],
              ),
              const SizedBox(
                height: 62,
              ),
              Center(
                child: SharedWidget().sharedTextButton(
                  text: "VERIFY",
                  onPressed: () {
                    if (otpFormKey.currentState!.validate()) {
                      otpFormKey.currentState!.save();
                      print(otp);
                      crudProvider.verifyOtp(
                        otp: otp,
                        verificationId: widget.verificationId,
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

  otpBox({required bool first, required bool last, required controller}) {
    return SizedBox(
      height: 60,
      width: 50,
      child: TextFormField(
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: (String? value) {
          if (value == null || value.isEmpty) {
            return '';
          }
          return null;
        },
        autofocus: true,
        textAlign: TextAlign.center,
        controller: controller,
        maxLength: 1,
        onChanged: (value) {
          if (value.length == 1 && last == false) {
            FocusScope.of(context).nextFocus();
          }
          if (value.isEmpty && first == false) {
            FocusScope.of(context).previousFocus();
          }
        },
        onSaved: (value) {
          otp = otp_1.text +
              otp_2.text +
              otp_3.text +
              otp_4.text +
              otp_5.text +
              otp_6.text;
        },
        keyboardType: TextInputType.phone,
        showCursor: false,
        decoration: const InputDecoration(
          counter: Offstage(),
          border: OutlineInputBorder(
            borderSide: BorderSide(),
            borderRadius: BorderRadius.all(
              Radius.circular(4),
            ),
          ),
        ),
      ),
    );
  }
}
