import 'package:flutter/material.dart';
import 'package:spork/components/profile_image.dart';
import 'package:spork/models/models.dart';
import 'package:spork/screens/create_recipe.dart';
import 'package:spork/screens/discover/discover_page.dart';
import 'package:spork/screens/profile_screen/profile.dart';
import 'package:spork/theme.dart';
import 'package:provider/provider.dart';
import 'package:spork/provider.dart';
import 'screens/grocery_screen/grocery_screen.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;
  final PageController controller = PageController(initialPage: 0);
  bool isFabVisible = true;
  bool isInputVisible = false;
  TextEditingController textController = TextEditingController();
  final FocusNode myFocusNode = FocusNode();

  @override
  void dispose() {
    textController.dispose();
    controller.dispose();
    myFocusNode.dispose();
    super.dispose();
  }

  void onTappedBar(int index) {
    controller.animateToPage(
      index,
      duration: kThemeAnimationDuration,
      curve: Curves.linear,
    );
    setState(() {
      _currentIndex = index;
    });
  }

  void _changePage(int index) async {
    setState(() {
      _currentIndex = index;
    });
  }

  void toggleButtonOn() {
    setState(() {
      isFabVisible = true;
    });
  }

  void toggleButtonOff() {
    setState(() {
      isFabVisible = false;
    });
  }

  void toggleInputOn() {
    setState(() {
      isInputVisible = true;
    });
  }

  void toggleInputOff() {
    setState(() {
      isInputVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    AppUser user = Provider.of<AppProvider>(context).user;

    final List<Widget> _children = [
      ProfileScreen(
        buttonOff: toggleButtonOff,
        buttonOn: toggleButtonOn,
      ),
      GroceryScreen(
        buttonOn: toggleButtonOn,
        buttonOff: toggleButtonOff,
        toggleInputOff: toggleInputOff,
        isInputVisible: isInputVisible,
        controller: textController,
        myFocusNode: myFocusNode,
      ),
      DiscoverPage(buttonOn: toggleButtonOn, buttonOff: toggleButtonOff),
    ];

    void buttonAction() {
      if (_currentIndex == 1) {
        toggleInputOn();
        myFocusNode.requestFocus();
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CreateRecipe(),
          ),
        );
      }
    }

    return Scaffold(
        appBar: Provider.of<AppProvider>(context, listen: false)
            .getZeroAppBar(CustomColors.white),
        floatingActionButton: isFabVisible
            ? Padding(
                padding: const EdgeInsets.all(15.0),
                child: FloatingActionButton(
                  elevation: 1,
                  backgroundColor: CustomColors.primary,
                  child: const Icon(
                    Icons.add_rounded,
                    color: CustomColors.white,
                  ),
                  onPressed: buttonAction,
                ),
              )
            : null,
        body: SafeArea(
          child: PageView(
            controller: controller,
            onPageChanged: _changePage,
            children: _children,
          ),
        ),
        bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20), topLeft: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black38, spreadRadius: 0, blurRadius: 1.5),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
              child: BottomNavigationBar(
                elevation: 1,
                onTap: onTappedBar,
                currentIndex: _currentIndex,
                selectedItemColor: CustomColors.white,
                backgroundColor: CustomColors.primary,
                items: [
                  BottomNavigationBarItem(
                      icon: Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: ProfileImage(user.photoUrl, 25, 20),
                      ),
                      label: user.name),
                  const BottomNavigationBarItem(
                      icon: Icon(Icons.shopping_cart_rounded),
                      label: 'Grocery'),
                  const BottomNavigationBarItem(
                      icon: Icon(Icons.public), label: 'Discover'),
                ],
              ),
            )));
  }
}
