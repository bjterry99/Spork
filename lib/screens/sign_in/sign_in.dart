import 'dart:io';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:spork/components/buttons/ghost_button.dart';
import 'package:spork/components/buttons/primary_button.dart';
import 'package:spork/home.dart';
import 'package:spork/services/notification_service.dart';
import 'package:spork/provider.dart';
import 'package:flutter/material.dart';
import 'package:spork/screens/sign_in/register.dart';
import 'package:spork/theme.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  String phone = '';
  TextEditingController codeController = TextEditingController();
  bool enterCode = false;
  String verificationId = '';
  String code = '';
  bool allowPress = true;

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  void updateItems(verify) {
    NotificationService.notify('Verification code sent.');
    setState(() {
      verificationId = verify;
      enterCode = true;
    });
  }

  Future<void> submit() async {
    setState(() {
      allowPress = false;
    });
    await Provider.of<AppProvider>(context, listen: false).login(phone, updateItems);
  }

  Future<void> verify() async {
    bool verify = await Provider.of<AppProvider>(context, listen: false).sync(null, verificationId, codeController.text);

    if (verify) {
      await Provider.of<AppProvider>(context, listen: false).syncUser();

      await Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const Home()), (Route<dynamic> route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Provider.of<AppProvider>(context, listen: false).getZeroAppBar(CustomColors.white),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          if (Platform.isAndroid) {
            FocusScope.of(context).unfocus();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            keyboardDismissBehavior: Platform.isIOS ? ScrollViewKeyboardDismissBehavior.onDrag : ScrollViewKeyboardDismissBehavior.manual,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 120,),
                Center(
                  child: Material(
                    elevation: 3,
                    color: CustomColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: SizedBox(
                        height: 100,
                        width: 100,
                        child: SvgPicture.asset(
                          "assets/spork.svg",
                          color: CustomColors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40,),
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
                  onChanged: (value) {
                    setState(() {
                      code = value;
                    });
                  },
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
                const SizedBox(height: 20,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      GhostButton(text: 'register', action: (){
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => const Register(),
                        ));
                      }),
                      const Spacer(),
                      !enterCode
                          ? PrimaryButton(
                        text: 'login',
                        action: submit,
                        isActive: (phone.length == 12 && allowPress),
                      )
                          : PrimaryButton(
                        text: 'Verify',
                        action: verify,
                        isActive: (code.length == 6),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 200,),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
