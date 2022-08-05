import 'package:flutter/material.dart';
import 'package:spork/components/buttons/ghost_button.dart';
import 'package:spork/provider.dart';
import 'package:spork/screens/menu_screen/menu_list.dart';
import 'package:provider/provider.dart';
import 'package:spork/screens/sign_in/sign_in.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          onPanDown: (_) {
            FocusScope.of(context).unfocus();
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Column(
              children: [
                GhostButton(
                    text: 'Sign out',
                    action: () async {
                      Provider.of<AppProvider>(context, listen: false)
                          .signOut();
                      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const SignIn()), (Route<dynamic> route) => false);
                    }),
                const MenuList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
