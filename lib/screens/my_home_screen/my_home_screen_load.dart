import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:spork/models/models.dart';
import 'package:spork/provider.dart';
import 'package:provider/provider.dart';
import 'package:spork/screens/my_home_screen/my_home.dart';
import 'package:spork/screens/my_home_screen/no_home.dart';
import 'package:spork/theme.dart';

class MyHomeScreenLoad extends StatelessWidget {
  const MyHomeScreenLoad({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppUser user = Provider.of<AppProvider>(context).user;

    return FutureBuilder<MyHome?>(
      future: Provider.of<AppProvider>(context).fetchHome(user.homeId),
      builder: (builder, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            MyHome myHome = snapshot.data!;
            return MyHomeScreen(myHome: myHome);
          } else {
            return const NoHome();
          }
        }
        return Scaffold(
          appBar: Provider.of<AppProvider>(context, listen: false).getZeroAppBar(CustomColors.white),
          body: const Center(
            child: SpinKitRing(
              color: CustomColors.primary,
              size: 50.0,
            ),
          ),
        );
      },
    );
  }
}