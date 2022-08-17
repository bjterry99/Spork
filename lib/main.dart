import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:spork/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:spork/notification_service.dart';
import 'package:spork/provider.dart';
import 'package:spork/screens/sign_in/sign_in.dart';
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
      child: Builder(
        builder: (context) {
          return MaterialApp(
            scaffoldMessengerKey: NotificationService.key,
            debugShowCheckedModeBanner: false,
            theme: theme,
            home: Builder(
              builder: (context) {
                if (Provider.of<AppProvider>(context).fireUser == null) {
                  return const SignIn();
                } else {
                  return const Home();
                }
              },
            ),
          );
        },
      ),
    );
  }
}
