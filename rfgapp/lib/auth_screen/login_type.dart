import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rfgapp/auth_screen/authScreen.dart';
import 'package:rfgapp/screens/manager/manager_home.dart';


class LoginType extends StatefulWidget {
  @override
  _LoginTypeState createState() => _LoginTypeState();
}

class _LoginTypeState extends State<LoginType> {
  var dummy;
  @override
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  _signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  void initState() {
  //  _signOut();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, userSnapshot) {
          if (userSnapshot.hasData) {
            return ManagerHome();
          }

          //   Future.delayed(Duration(seconds: 4), () async {
          //  print('start search');
          //  print( Provider.of<UserIformationsManager>(context, listen: false).id );

          /*   var x = await FirebaseFirestore.instance
                  .collection('user')
                  .doc(Provider.of<UserIformationsManager>(context,
                          listen: false)
                      .id)
                  .get(); */

          /*      switch (x.data['userType']) {
                case 'customer':
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (ctx) {
                    return CustomerScreen();
                  }));
                  break;
                case 'manager':
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (ctx) {
                    return ManagerScreen();
                  }));
                  break;
                case 'worker':
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (ctx) {
                    return WorkerScreen();
                  }));
                  break;
                case 'delivery':
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (ctx) {
                    return DeliveryScreen();
                  }));
                  break;

                default:
                  AuthScreen();
              } */

          return AuthScreen();
        });
  }
}
