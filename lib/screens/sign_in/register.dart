import 'package:provider/provider.dart';
import 'package:spork/components/buttons/my_text_button.dart';
import 'package:spork/components/buttons/primary_button.dart';
import 'package:spork/home.dart';
import 'package:spork/models/models.dart';
import 'package:spork/notification_service.dart';
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
    if (nameError == null && handleError == null && phone.length == 12) {
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
              .userNameExists(userName);
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
            photoUrl: '');
        await Provider.of<AppProvider>(context, listen: false)
            .createAccount(appUser);

        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const Home()), (Route<dynamic> route) => false);
      }
    }

    return Scaffold(
      appBar: Provider.of<AppProvider>(context, listen: false)
          .getZeroAppBar(CustomColors.white),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            onPanDown: (_) {
              FocusScope.of(context).unfocus();
            },
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 100,
                  ),
                  const Center(
                    child: Text(
                      'Create Account',
                      style: TextStyle(
                          fontSize: CustomFontSize.large,
                          fontWeight: FontWeight.w700,
                          color: CustomColors.primary),
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  if (!enterCode)
                    TextFormField(
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                        errorText: nameError,
                        labelText: 'Name',
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