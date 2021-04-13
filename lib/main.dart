import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_firebase_auth/res/color.dart';
import 'package:flutter_firebase_auth/route/routes.dart';
import 'package:flutter_firebase_auth/screen/home_screen.dart';
import 'package:flutter_firebase_auth/screen/login_screen.dart';
import 'package:flutter_firebase_auth/service/firebase/firebase_auth_service.dart';
import 'package:getwidget/components/loader/gf_loader.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: colorPrimaryDark,
      systemNavigationBarColor: colorPrimaryDark,
    ),
  );
  runApp(
    StreamProvider(
      create: (BuildContext context) => FirebaseAuthService.firebaseListner,
      child: MaterialApp(
        theme: ThemeData(
          primaryColorDark: colorPrimaryDark,
          accentColor: colorPrimaryDark,
          primaryColor: colorPrimary,
        ),
        debugShowCheckedModeBanner: false,
        onGenerateRoute: Routes.generateRoute,
        home: MyHomePage(),
      ),
    ),
  );
}


class MyApp extends StatefulWidget {


  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return myAppState();
  }}
class myAppState extends State<MyApp>{
  ProgressDialog pr;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
          // Check for errors


          // Once complete, show your application
          if (snapshot.connectionState == ConnectionState.done) {

            return Provider.of<User>(context) == null
                ? LoginScreen()
                : HomeScreen();

          }
          return GFLoader(loaderColorOne: Colors.black26)
          ;});}
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);



  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  ProgressDialog pr;

  var _visible = true;
  startTime() async {
    var _duration = new Duration(seconds: 3);
    return new Timer(_duration, navigationPage);
  }
  getProducts() async{

    // cartproductscat= await wooCommerce.getProductCategories();

    setState(() {

    });

  }
  Future<void> navigationPage() async {


    pr.show();
    Future.delayed(Duration(seconds: 2))
        .then((value) {
      pr.hide().whenComplete(() {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) =>
                    MyApp()
            ),);

      });
    });








  }

  @override
  Future<void> initState()  {
    super.initState();

    setState(() {
      _visible = !_visible;
    });
    startTime();
  }

  @override
  Widget build(BuildContext context) {
    pr = new ProgressDialog(context, showLogs: true);
    pr.style(message: 'Loading...');
    var Height= MediaQuery.of(context).size.height;
    var Width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[

          new Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                child: Stack(children: [Center(
                    child: Container(
                      decoration: BoxDecoration(

                          image: DecorationImage(
                            image: AssetImage('assets/images/logo.png'),

                          )
                      ),
                    )  )],),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height ,

                decoration: BoxDecoration(
                  color: Colors.white,

                ),

              ),

            ],
          ),
        ],
      ),
    );
  }
}