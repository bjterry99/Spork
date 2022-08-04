import 'package:provider/provider.dart';
import 'package:spork/components/buttons/my_text_button.dart';
import 'package:spork/components/buttons/primary_button.dart';
import 'package:spork/provider.dart';
import 'package:flutter/material.dart';
import 'package:spork/theme.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
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
                    'Create Account',
                    style: TextStyle(
                        fontSize: CustomFontSize.large,
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
                      MyTextButton(text: 'cancel', action: (){
                        Navigator.pop(context);
                      }),
                      const Spacer(),
                      PrimaryButton(
                        text: 'Register',
                        action: () async {
                          await Provider.of<AppProvider>(context, listen: false).createAccount(email, password);
                        },
                        isActive: (email.isNotEmpty && password.isNotEmpty),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
