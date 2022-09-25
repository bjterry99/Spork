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
import 'package:swipeable_page_route/swipeable_page_route.dart';

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
      await Provider.of<AppProvider>(context, listen: false).login(phone, updateItems);
    }

    Future<void> verify() async {
      bool verify = await Provider.of<AppProvider>(context, listen: false).sync(null, verificationId, codeController.text);

      if (verify) {
        await Provider.of<AppProvider>(context, listen: false).syncUser();

        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const Home()), (Route<dynamic> route) => false);
      }
    }

    return Scaffold(
      appBar: Provider.of<AppProvider>(context, listen: false).getZeroAppBar(CustomColors.white),
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Material(
                    elevation: 3,
                    color: CustomColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: SvgPicture.asset(
                        "assets/spork.svg",
                        height: 100,
                        width: 100,
                        color: CustomColors.white,
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
                        if (Platform.isIOS) {
                          Navigator.of(context).push(SwipeablePageRoute(
                              builder: (BuildContext context) => const Register(),
                              canOnlySwipeFromEdge: true
                          ));
                        } else {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) => const Register(),
                          ));
                        }
                      }),
                      const Spacer(),
                      !enterCode
                          ? PrimaryButton(
                        text: 'login',
                        action: submit,
                        isActive: (phone.length == 12),
                      )
                          : PrimaryButton(
                        text: 'Verify',
                        action: verify,
                        isActive: (codeController.text.length == 6),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
