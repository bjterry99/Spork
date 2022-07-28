import 'package:flutter/material.dart';
import 'package:spork/components/recipe_cards.dart';

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
          child: const Padding(
            padding: EdgeInsets.only(top: 15),
            child: MenuList(),
          ),
        ),),
    );
  }
}