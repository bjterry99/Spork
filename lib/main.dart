import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spork/notification_service.dart';
import 'package:spork/provider.dart';
import 'package:spork/screens/recipes_screen/recipes_screen.dart';
import 'package:spork/screens/menu_screen/menu_screen.dart';
import 'package:spork/screens/grocery_screen/grocery_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:spork/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: Builder(builder: (context) {
        return MaterialApp(
          scaffoldMessengerKey: NotificationService.key,
          debugShowCheckedModeBanner: false,
          theme: theme,
          home: const MyNavBar(),
        );
      }),
    );
  }
}

class MyNavBar extends StatefulWidget {
  const MyNavBar({Key? key}) : super(key: key);

  @override
  _MyNavBarState createState() => _MyNavBarState();
}

class _MyNavBarState extends State<MyNavBar> {
  int _currentIndex = 0;
  final PageController controller = PageController(initialPage: 0);

  final List<Widget> _children = [
    const RecipesScreen(),
    const GroceryScreen(),
    const MenuScreen(),
  ];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Provider.of<AppProvider>(context, listen: false).getZeroAppBar(CustomColors.white),
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
                    color: Colors.black38, spreadRadius: 0, blurRadius: 10),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
              child: BottomNavigationBar(
                elevation: 6,
                onTap: onTappedBar,
                currentIndex: _currentIndex,
                selectedItemColor: CustomColors.white,
                backgroundColor: CustomColors.primary,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.restaurant_menu_rounded),
                    label: 'Recipes',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.shopping_cart_rounded),
                    label: 'Grocery',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.menu_book_rounded),
                    label: 'Menu',
                  ),
                ],
              ),
            )));
  }
}
