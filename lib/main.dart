import 'package:flutter/material.dart';
import 'package:HyperGarageSale/services/authentication.dart';
import 'package:HyperGarageSale/pages/root_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Container(
      child: MaterialApp(
        title: 'HyperGarageSale',
        theme: ThemeData(
          primaryColor: new Color(0xff075E54),
          accentColor: new Color(0xff25D366),
        ),
        // remove debug label at the upper right corner
        debugShowCheckedModeBanner: false,
        home: new RootPage(auth: new Auth()),
      ),
    );
  }
}