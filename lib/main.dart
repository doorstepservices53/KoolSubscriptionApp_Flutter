import 'dart:io';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'WebViewScreen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    OneSignal.initialize("2f3212a0-677f-471f-931a-ca2d0ce6227a");
    OneSignal.Notifications.requestPermission(true);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kool Subscriptions App',
      initialRoute: '/webview',
      routes: {
        '/webview'  : (context) => const WebViewScreen(),
      },
    );
  }
}

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}
