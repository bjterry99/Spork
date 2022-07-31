import 'package:flutter/material.dart';
import 'package:spork/screens/menu_screen/menu_list.dart';

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
          child: const Padding(
            padding: EdgeInsets.only(top: 15),
            child: MenuList(),
          ),
        ),),
    );
  }
}