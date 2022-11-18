import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:spork/theme.dart';

class SporkSpinner extends StatefulWidget {
  const SporkSpinner({Key? key}) : super(key: key);

  @override
  State<SporkSpinner> createState() => _SporkSpinnerState();
}

class _SporkSpinnerState extends State<SporkSpinner> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RotationTransition(
        turns: Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOutQuint)),
        child: Material(
          elevation: 3,
          color: CustomColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: SizedBox(
              height: 50,
              width: 50,
              child: SvgPicture.asset(
                "assets/spork.svg",
                color: CustomColors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
