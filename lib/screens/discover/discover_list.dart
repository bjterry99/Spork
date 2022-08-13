import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:spork/screens/grocery_screen/grocery_card.dart';
import 'package:spork/models/models.dart';
import 'package:spork/theme.dart';
import 'package:spork/provider.dart';
import 'package:provider/provider.dart';

class DiscoverList extends StatelessWidget {
  const DiscoverList({required this.query, Key? key}) : super(key: key);
  final String query;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AppUser>>(
      stream: Provider.of<AppProvider>(context, listen: false).userStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final items = snapshot.data;
          List<Widget> list = [];

          for (var item in items!) {
            list.add(Text(item.name));
          }
          return SingleChildScrollView(
            child: Column(
              children: [
                ListView(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: EdgeInsets.only(
                    right: 15,
                    left: 15,
                    top: 15,
                  ),
                  children: list,
                ),
              ],
            ),
          );
        } else {
          return const Center(
            child: SpinKitRing(
              color: CustomColors.primary,
              size: 50.0,
            ),
          );
        }
      },
    );
  }
}