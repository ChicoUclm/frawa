import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'package:excursiona/helper/helper_functions.dart';
import 'package:excursiona/shared/constants.dart';
import 'package:excursiona/view/auth_page.dart';
import 'package:excursiona/view/home_page.dart';
import 'package:excursiona/view/states/streamingroom_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isUserLoggedIn = false;

  @override
  void initState() {
    super.initState();
    // initializeFirebaseMessaging();
    _getIsUserLoggedIn();
    _askPermissions();

    HelperFunctions.initLocalNotifications();
  }

  void _askPermissions() async {
    await Permission.storage.request();

    await Permission.locationAlways.request();
  }

  void _getIsUserLoggedIn() async {
    await HelperFunctions.getUserLoggedInStatus().then((value) {
      if (value != null) {
        setState(() {
          _isUserLoggedIn = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StreamingRoomProvider(),
      builder: (context, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
            value: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
            ),
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Excursiona',
              theme: ThemeData(
                primaryColor: Constants.indigoDye,
                textTheme:
                    GoogleFonts.interTextTheme(Theme.of(context).textTheme),
              ),
              home: _isUserLoggedIn ? const HomePage() : const AuthPage(),
            ));
      },
    );
  }
}
