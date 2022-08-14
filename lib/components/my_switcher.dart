import 'package:flutter/material.dart';
import 'package:spork/theme.dart';

class MySwitcher extends StatelessWidget {
  const MySwitcher({
    Key? key,
    required this.change,
    required this.isOnFollow,
    required this.iconLeft,
    required this.iconRight,
  }) : super(key: key);

  final Function change;
  final bool isOnFollow;
  final IconData iconRight;
  final IconData iconLeft;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        change();
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 5),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              alignment: isOnFollow ? Alignment.bottomLeft : Alignment.bottomRight,
              curve: Curves.easeInOutQuint,
              child: Material(
                elevation: 3,
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                child: Container(
                  height: 40,
                  width: MediaQuery.of(context).size.width / 4,
                  decoration: BoxDecoration(
                    color: CustomColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: MediaQuery.of(context).size.width / 10.7, right: MediaQuery.of(context).size.width / 10.9, top: 8),
              child: Row(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(child: child, opacity: animation,);
                    },
                    child: Icon(
                      iconRight,
                      key: ValueKey<bool>(isOnFollow),
                      color: isOnFollow ? CustomColors.white : CustomColors.primary,),
                  ),
                  const Spacer(),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(child: child, opacity: animation,);
                    },
                    child: Icon(
                      iconLeft,
                      key: ValueKey<bool>(isOnFollow),
                      color: !isOnFollow ? CustomColors.white : CustomColors.primary,),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}