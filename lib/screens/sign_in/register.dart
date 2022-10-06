import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:spork/components/buttons/my_text_button.dart';
import 'package:spork/components/buttons/primary_button.dart';
import 'package:spork/home.dart';
import 'package:spork/models/models.dart';
import 'package:spork/services/notification_service.dart';
import 'package:spork/provider.dart';
import 'package:flutter/material.dart';
import 'package:spork/theme.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  String phone = '';
  String userName = '';
  String name = '';
  String verificationId = '';
  bool enterCode = false;
  String photoUrl = '';
  bool check = false;
  TextEditingController codeController = TextEditingController();

  String? get handleError {
    final text = userName;
    if (text.length < 3) {
      return 'Must be at least 3 characters';
    }
    if (text.length > 20) {
      return '20 character limit';
    }
    if (text.contains(' ')) {
      return 'Cannot contain spaces';
    }
    return null;
  }

  String? get nameError {
    final text = name;
    if (text.length < 3) {
      return 'Must be at least 3 characters';
    }
    if (text.length > 30) {
      return '20 character limit';
    }
    return null;
  }

  bool get validated {
    if (nameError == null && handleError == null && phone.length == 12 && check) {
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void updateItems(verify) {
      NotificationService.notify('Verification code sent.');
      setState(() {
        verificationId = verify;
        enterCode = true;
      });
    }

    Future<void> submit() async {
      bool userNameCheck =
          await Provider.of<AppProvider>(context, listen: false)
              .userNameExists(userName, null);
      if (userNameCheck) {
        NotificationService.notify('Username already taken.');
        return;
      }

      await Provider.of<AppProvider>(context, listen: false)
          .verifyPhoneNumber(phone, updateItems);
    }

    Future<void> verify() async {
      bool verify = await Provider.of<AppProvider>(context, listen: false)
          .sync(null, verificationId, codeController.text);
      if (verify) {
        AppUser appUser = AppUser(
            id: '',
            name: name,
            userName: userName,
            phone: phone,
            followers: <String>[],
            queryName: name.toLowerCase(),
            photoUrl: photoUrl,
            homeId: '');
        await Provider.of<AppProvider>(context, listen: false)
            .createAccount(appUser);

        await Provider.of<AppProvider>(context, listen: false).syncUser();

        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const Home()),
            (Route<dynamic> route) => false);
      }
    }

    void choosePicture() async {
      String string64 = await Provider.of<AppProvider>(context, listen: false)
          .choosePicture();
      setState(() {
        if (string64 != '') {
          photoUrl = string64;
        }
      });
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      onPanDown: (_) {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: Provider.of<AppProvider>(context, listen: false)
            .getZeroAppBar(CustomColors.white),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 100,
                  ),
                  const Center(
                    child: Text(
                      'Create Profile',
                      style: TextStyle(
                          fontSize: CustomFontSize.large,
                          fontWeight: FontWeight.w700,
                          color: CustomColors.primary),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  if (!enterCode)
                    Center(
                      child: GestureDetector(
                        onTap: choosePicture,
                        child: CircleAvatar(
                          radius: 70,
                          backgroundColor: CustomColors.grey2,
                          child: photoUrl == ''
                              ? const Icon(
                                  Icons.portrait_rounded,
                                  color: CustomColors.grey4,
                                  size: 40,
                                )
                              : null,
                          backgroundImage: photoUrl == ''
                              ? null
                              : Image.memory(base64Decode(photoUrl)).image,
                        ),
                      ),
                    ),
                  if (!enterCode)
                    const SizedBox(
                      height: 5,
                    ),
                  if (!enterCode)
                    TextFormField(
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                        errorText: nameError,
                        labelText: 'Name',
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: CustomColors.grey3),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: CustomColors.grey3),
                        ),
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          name = newValue!;
                        });
                      },
                    ),
                  if (!enterCode)
                    TextFormField(
                      decoration: InputDecoration(
                        errorText: handleError,
                        labelText: 'Username',
                        prefixText: '@',
                        // border: InputBorder.none,
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: CustomColors.grey3),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: CustomColors.grey3),
                        ),
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          userName = newValue!;
                        });
                      },
                    ),
                  !enterCode
                      ? TextFormField(
                          maxLength: 10,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(
                              color: CustomColors.black,
                              fontWeight: FontWeight.w400,
                              fontSize: CustomFontSize.primary),
                          cursorColor: CustomColors.primary,
                          onChanged: (String? newValue) {
                            setState(() {
                              phone = '+1$newValue';
                            });
                          },
                          decoration: const InputDecoration(
                            prefixText: '+1',
                            labelText: '(###) ###-####',
                            border: InputBorder.none,
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: CustomColors.grey3),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: CustomColors.grey3),
                            ),
                          ),
                        )
                      : TextFormField(
                          maxLength: 6,
                          controller: codeController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                              color: CustomColors.black,
                              fontWeight: FontWeight.w400,
                              fontSize: CustomFontSize.primary),
                          cursorColor: CustomColors.primary,
                          decoration: const InputDecoration(
                            labelText: 'enter code',
                            border: InputBorder.none,
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: CustomColors.grey3),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: CustomColors.grey3),
                            ),
                          ),
                        ),
                  Row(
                    children: [
                      Checkbox(
                        value: check,
                        onChanged: (value) {
                          setState(() {
                            check = value!;
                          });
                        },
                        activeColor: CustomColors.secondary,
                      ),
                      Flexible(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              color: CustomColors.grey4,
                              fontWeight: FontWeight.w400,
                              fontSize: CustomFontSize.secondary
                            ),
                            children: <TextSpan>[
                              const TextSpan(
                                  text: 'A have read and agree to the '),
                              TextSpan(
                                  text: 'Terms of Service and Privacy Policy',
                                  style: const TextStyle(
                                      color: CustomColors.linkBlue,
                                      fontWeight: FontWeight.w500,
                                      fontSize: CustomFontSize.secondary
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () async {
                                      await Provider.of<AppProvider>(context, listen: false).openUrl("https://sites.google.com/view/spork-recipebook/home");
                                    }),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        MyTextButton(
                            text: 'cancel',
                            action: () {
                              Navigator.pop(context);
                            }),
                        const Spacer(),
                        !enterCode
                            ? PrimaryButton(
                                text: 'Register',
                                action: submit,
                                isActive: (validated),
                              )
                            : PrimaryButton(
                                text: 'Verify',
                                action: verify,
                                isActive: (codeController.text.length == 6),
                              )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
