import 'package:flutter/material.dart';

class ManagerHome extends StatefulWidget {
  @override
  _ManagerHomeState createState() => _ManagerHomeState();
}

class _ManagerHomeState extends State<ManagerHome> {
  Widget btn(String name) {
    return Container(
      width: 110,
      height: 90,
      child: RaisedButton(
          color: Colors.blueAccent[200],
          elevation: 2,
          child: Text(
            name,
            style: TextStyle(color: Colors.white, fontSize: 15),
          ),
          onPressed: () {
            Navigator.pushNamed(context, '/$name');
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                btn('AddNew'),
                btn('Purchase'),
                btn('Payments')
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                btn('DuctShop'),
                btn('GrillShop'),
                btn('Install')
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                btn('Orders'),
                btn('Balance'),
              ],
            ),
          ],
        ),
      ),
    ));
  }
}
