import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rfgapp/providers/variables.dart';
import 'package:rfgapp/screens/manager/add_new.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:rfgapp/screens/manager/balance.dart';
import 'package:rfgapp/screens/manager/ductshop.dart';
import 'package:rfgapp/screens/manager/grillshop.dart';
import 'package:rfgapp/screens/manager/install.dart';
import 'package:rfgapp/screens/manager/orders/orders.dart';
import 'package:rfgapp/screens/manager/payment/payments.dart';
import 'package:rfgapp/screens/manager/purchase/purchase.dart';
import 'package:rfgapp/screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(RFGApp());
}

class RFGApp extends StatelessWidget {
  // Create the initilization Future outside of `build`:
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider<Variables>(create: (ctx) => Variables()),
            ],
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'rfg app',
              // home: SplashScreen(),
              home: HomeApp(),
              // initialRoute: '/',
              routes: {
                //   '/': (ctx) => SplashScreen(),
                Accountant.routeName: (ctx) => Accountant(),
                Purchase.routeName: (ctx) => Purchase(),
                Install.routeName: (ctx) => Install(),
                Orders.routeName: (ctx) => Orders(),
                DuctShop.routeName: (ctx) => DuctShop(),
                GrillShop.routeName: (ctx) => GrillShop(),
                Payments.routeName: (ctx) => Payments(),
                Balance.routeName: (ctx) => Balance(),
              },
            ),
          );
        }
        //l

        // Otherwise, show something whilst waiting for initialization to complete
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}

class HomeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SplashScreen(),
    );
  }
}
