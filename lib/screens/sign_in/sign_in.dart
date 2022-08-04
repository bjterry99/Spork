import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:spork/components/buttons/ghost_button.dart';
import 'package:spork/components/buttons/primary_button.dart';
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
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
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
                const Center(
                  child: Text(
                    'Spork',
                    style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.w700,
                        color: CustomColors.primary
                    ),
                  ),
                ),
                const SizedBox(height: 40,),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(
                      color: CustomColors.black,
                      fontWeight: FontWeight.w400,
                      fontSize: CustomFontSize.primary),
                  cursorColor: CustomColors.primary,
                  onChanged: (String? newValue) {
                    setState(() {
                      email = newValue!;
                    });
                  },
                  decoration: const InputDecoration(
                      labelText: 'email address',
                      border: InputBorder.none,
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: CustomColors.grey3),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: CustomColors.grey3),
                      ),),
                ),
                TextFormField(
                  obscureText: true,
                  keyboardType: TextInputType.text,
                  style: const TextStyle(
                      color: CustomColors.black,
                      fontWeight: FontWeight.w400,
                      fontSize: CustomFontSize.primary),
                  cursorColor: CustomColors.primary,
                  onChanged: (String? newValue) {
                    setState(() {
                      password = newValue!;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'password',
                    border: InputBorder.none,
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: CustomColors.grey3),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: CustomColors.grey3),
                    ),),
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
                      PrimaryButton(
                        text: 'Login',
                        action: (){},
                        isActive: (email.isNotEmpty && password.isNotEmpty),
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
