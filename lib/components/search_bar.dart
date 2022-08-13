import 'package:flutter/material.dart';
import 'package:spork/theme.dart';

class SearchBar extends StatelessWidget {
  const SearchBar({
    Key? key,
    required this.search,
    required this.text,
    required this.controller,
  }) : super(key: key);

  final Function search;
  final String text;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: CustomColors.white,
      borderRadius: BorderRadius.circular(30.0),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 10,
          right: 10,
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 5, right: 5),
          child: TextFormField(
            controller: controller,
            onChanged: (value) {
              search(value);
            },
            cursorColor: CustomColors.primary,
            decoration: InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              icon: const Icon(
                Icons.search_rounded,
              ),
              hintText: text,
            ),
          ),
        ),
      ),
    );
  }
}