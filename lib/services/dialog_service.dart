import 'package:flutter/material.dart';
import 'package:spork/theme.dart';

class DialogService {
  static Future<bool?> dialogBox({
    required BuildContext context,
    String? title,
    Widget? body,
    required List<Widget> actions,
  }) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        if (title != null && body != null) {
          return NotificationFriendlyPopupShell(
            corners: 20,
            body: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AlertDialog(
                  insetPadding: const EdgeInsets.all(0),
                  title: Builder(builder: (context) {
                    return SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Text(
                          title,
                          style: InfoBoxTextStyle.title,
                        ));
                  }),
                  titlePadding:
                  const EdgeInsets.only(top: 30, left: 30, right: 30),
                  contentPadding:
                  const EdgeInsets.only(top: 7.5, left: 30, right: 30),
                  actionsPadding: const EdgeInsets.only(
                      bottom: 22.5, left: 22.5, right: 22.5, top: 7.5),
                  buttonPadding: const EdgeInsets.all(0),
                  actionsOverflowButtonSpacing: 0,
                  content: body,
                  actions: actions,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ],
            ),
            padding: 0,
          );
        } else if (title != null) {
          return NotificationFriendlyPopupShell(
            corners: 20,
            padding: 0,
            body: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AlertDialog(
                  insetPadding: const EdgeInsets.all(0),
                  title: Builder(builder: (context) {
                    return SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Text(
                          title,
                          style: InfoBoxTextStyle.title,
                        ));
                  }),
                  titlePadding:
                  const EdgeInsets.only(top: 30, left: 30, right: 30),
                  actionsPadding: const EdgeInsets.only(
                      bottom: 22.5, left: 22.5, right: 22.5, top: 7.5),
                  buttonPadding: const EdgeInsets.all(0),
                  actionsOverflowButtonSpacing: 0,
                  actions: actions,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ],
            ),
          );
        } else {
          return NotificationFriendlyPopupShell(
            padding: 0,
            corners: 20,
            body: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AlertDialog(
                  insetPadding: const EdgeInsets.all(0),
                  contentPadding:
                  const EdgeInsets.only(top: 30, left: 30, right: 30),
                  actionsPadding: const EdgeInsets.only(
                      bottom: 22.5, left: 22.5, right: 22.5, top: 7.5),
                  buttonPadding: const EdgeInsets.all(0),
                  actionsOverflowButtonSpacing: 0,
                  content: Builder(builder: (context) {
                    return SizedBox(
                        width: MediaQuery.of(context).size.width, child: body);
                  }),
                  actions: actions,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

class NotificationFriendlyPopupShell extends StatelessWidget {
  const NotificationFriendlyPopupShell(
      {required this.body,
        required this.padding,
        required this.corners,
        Key? key})
      : super(key: key);
  final double padding;
  final Widget body;
  final double corners;

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        onPanDown: (_) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Dialog(
          insetPadding: const EdgeInsets.all(15),
          backgroundColor: Colors.transparent,
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: Colors.transparent,
              body: Center(
                child: Container(
                  padding: EdgeInsets.all(padding),
                  decoration: BoxDecoration(
                    color: CustomColors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(corners),
                    ),
                  ),
                  child: body,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}