import 'dart:io';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/app/AppConstants.dart';
import 'package:flutter_firebase_auth/app/AppPreferences.dart';
import 'package:flutter_firebase_auth/res/color.dart';
import 'package:flutter_firebase_auth/res/style.dart';
import 'package:flutter_firebase_auth/service/firebase/firebase_auth_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocation/geolocation.dart';
import 'package:getwidget/components/loader/gf_loader.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return HomeState();
  }
}

class HomeState extends State<HomeScreen> {
  final picker = ImagePicker();
  bool morethan = false;
  bool Statusofbutton = true;

  File _imageFile = null;
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  String emplocationid;
  Map<String, dynamic> map = Map();

  @override
  void initState() {
//  _initializeCamera();
    getData();
    getCheckindata();

    super.initState();
  }

  getData() async {
    final User user = await FirebaseAuth.instance.currentUser;
    final String uid = user.uid.toString();
    FirebaseFirestore.instance
        .collection('users')
        .doc('$uid')
        .get()
        .then((value) {
      setState(() {
        // print(value.data());
        map = value.data();
        print(map);
        emplocationid = value.data()['empLocationId'];
      });
      return value.data();
    });
  }

  void checkServiceStatus(
      BuildContext context, LocationPermissionLevel permissionLevel) {
    LocationPermissions()
        .checkServiceStatus()
        .then((ServiceStatus serviceStatus) {
      final SnackBar snackBar =
          SnackBar(content: Text(serviceStatus.toString()));

      Scaffold.of(context).showSnackBar(snackBar);
    });
  }

  getCheckindata() async {
    DateTime now = DateTime.now();
    print(now);
    Timestamp myTimeStamp = Timestamp.fromDate(now);

    String formattedDate = DateFormat('M-d-yyyy').format(DateTime.now());
    final User user = await FirebaseAuth.instance.currentUser;
    final String uid = user.uid.toString();
    FirebaseFirestore.instance.collection('attendence').where('uid', isEqualTo: uid).where('date', isEqualTo: formattedDate).get().then((QuerySnapshot documentSnapshot) {


        documentSnapshot.docs.forEach((element) {
          print(element.id);

          print(element.data()['checkin']);
          setState(() {
            if (element.data()['checkin'] != null &&
                element.data()['checkout'] == null) {
              Statusofbutton = false;
            } else if (element.data()['checkin'] == null &&
                element.data()['checkout'] != null) {
              Statusofbutton = true;
            } else if (element.data()['checkin'] != null &&
                element.data()['checkout'] != null) {
              morethan=true;
            }
          });
        });



    });
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    _controller = CameraController(firstCamera, ResolutionPreset.high);
    _initializeControllerFuture = _controller.initialize();
    if (!mounted) {
      return;
    }
    setState(() {
      //  isCameraReady = true;
    });
  }
ProgressDialog pr;
  var ImagePath;

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  String latitude = '00.00000';
  String longitude = '00.00000';

  _getCurrentLocation() async {
    Geolocation.enableLocationServices().then((result) {
      // Request location
      // print(result);
    }).catchError((e) {
      // Location Services Enablind Cancelled
      // print(e);
    });

    Geolocation.currentLocation(accuracy: LocationAccuracy.best)
        .listen((result) {
      if (result.isSuccessful) {
        setState(() {
          latitude = result.location.latitude.toString();
          longitude = result.location.longitude.toString();

          print("aaaaaaaaaaaaaaaaaaaaaaaaaa");
          print(longitude);
        });
      }
    });
  }

  Future pickImage(bool checkin, bool checkout) async {
    final pickedFile = await picker.getImage(
        source: ImageSource.camera,
        imageQuality: 25,
        maxHeight: 480,
        maxWidth: 640,
        preferredCameraDevice: CameraDevice.front);

    setState(() {
      _imageFile = File(pickedFile.path);
      pr.show();
      Future.delayed(Duration(seconds: 2))
          .then((value) {
        pr.hide().whenComplete(() {


        });
      });

      uploadImageToFirebase(context, _imageFile, checkin, checkout);
    });
  }

  FirebaseStorage _storage = FirebaseStorage.instance;


  Future uploadImageToFirebase(BuildContext context, File imageFIle, bool checkin, bool Checkout) async {
    final User user = await FirebaseAuth.instance.currentUser;
    final String uid = user.uid.toString();
    DateTime now = DateTime.now();
    print(now);
    Timestamp myTimeStamp = Timestamp.fromDate(now);

    // String formattedDate = DateFormat('kk:mm:ss \n EEE d MMM').format(now);
    Reference firebaseStorageRef = FirebaseStorage.instance
        .ref()
        .child('attendence')
        .child('${uid}')
        .child('${myTimeStamp.seconds}')
        .child('image')
        .child('${myTimeStamp.millisecondsSinceEpoch}');
    UploadTask uploadTask = firebaseStorageRef.putFile(imageFIle);
    uploadTask.then((res) {
      res.ref.getDownloadURL().then((value) {
        setState(() {
          UploadDataFireStore(value, checkin, Checkout);
        });
      });
    });
  }

  Future<String> inputData() async {
    final User user = await FirebaseAuth.instance.currentUser;
    final String uid = user.uid.toString();
    return uid;
  }

  UploadDataFireStore(String Imagedata, bool checkin, bool checkout) async {
    final User user = await FirebaseAuth.instance.currentUser;
    final String uid = user.uid.toString();
    DateTime now = DateTime.now();
    print(now);
    Timestamp myTimeStamp = Timestamp.fromDate(now);

    String formattedDate = DateFormat('M-d-yyyy').format(DateTime.now());
    //  print(DateFormat.yMd().format(DateTime.now()));
    print(formattedDate);

    checkout==false?
    FirebaseFirestore.instance.collection('attendence').add({
      'officeLocation': emplocationid,
      'address': null,
      'date': formattedDate,
      'image': Imagedata,
      'checkin': checkin == true ? myTimeStamp.millisecondsSinceEpoch : null,
      'lat': latitude,
      'long': longitude,
      'checkout': checkout == true ? myTimeStamp.millisecondsSinceEpoch : null,
      'uid': uid
    }).then((value) {
      setState(() {
        print(value.get().then((DocumentSnapshot documentSnapshot) {
          if (documentSnapshot.exists) {
            print(documentSnapshot.data().toString());
            setState(() {
              Fluttertoast.showToast(
                  msg: "SuccessFully CheckIn",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.SNACKBAR,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                  fontSize: 16.0
              );
            });


          if( documentSnapshot.data()['checkout']!=null &&documentSnapshot.data()['checkin']==null){
            setState(() {
              Statusofbutton= true;
            });

          } else{
            setState(() {
              Statusofbutton= false;
            });

          }

          }
        }));
      });
    }): FirebaseFirestore.instance.collection('attendence').where('uid', isEqualTo: uid).where('date', isEqualTo: formattedDate).get().then((QuerySnapshot documentSnapshot) {

setState(() {
  documentSnapshot.docs.forEach((element) {
    print(element.id);
    if(documentSnapshot.docs.length==1){
      FirebaseFirestore.instance.collection('attendence').doc(element.id).update({
        'checkout':checkout == true ? myTimeStamp.millisecondsSinceEpoch : null,'image2':Imagedata
      }).then((value) {
        setState(() {
          Fluttertoast.showToast(
              msg: "SuccessFully CheckOut",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.SNACKBAR,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.black,
              textColor: Colors.white,
              fontSize: 16.0
          );
         getCheckindata();
        });
      });}
    print(element.data()['checkin']);

  });



});
});

  }

  @override
  Widget build(BuildContext context) {
    pr = new ProgressDialog(context, showLogs: true);
    pr.style(message: 'Loading...');
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).primaryColor,
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () => FirebaseAuthService.firebaseLogout(),
              tooltip: 'Logout',
            )
          ],
          title: Text(
            'Welcome',
            style: styleToolbar,
          ),
        ),
        body: Center(
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: map.isNotEmpty
                ? ListView(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      CircleAvatar(
                        radius: 55,
                        backgroundColor: Color(0xffFDCF09),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(map['photoURL']),
                        ),
                      ),
                      Divider(),
                      ListTile(
                        title: Text(
                          map['displayName'],
                          style: styleButtonText.copyWith(color: colorBlack),
                        ),
                        leading: Icon(
                          Icons.account_circle_outlined,
                          color: colorPrimary,
                        ),
                      ),
                      Divider(),
                      ListTile(
                        title: Text(
                          map['phoneNumber'].toString(),
                          style: styleButtonText.copyWith(color: colorBlack),
                        ),
                        leading: Icon(Icons.phone, color: colorPrimary),
                      ),
                      Divider(),
                      ListTile(
                        title: Text(
                          map['email'],
                          style: styleButtonText.copyWith(color: colorBlack),
                        ),
                        leading: Icon(
                          Icons.email,
                          color: colorPrimary,
                        ),
                      ),
                      Divider(),
                      ListTile(
                        title: Text(
                          map['empPosition'],
                          style: styleButtonText.copyWith(color: colorBlack),
                        ),
                        leading: Icon(
                          Icons.picture_in_picture_outlined,
                          color: colorPrimary,
                        ),
                      ),
                      Divider(),
                      ListTile(
                        title: Text(
                          map['empLocation'],
                          style: styleButtonText.copyWith(color: colorBlack),
                        ),
                        leading: Icon(
                          Icons.account_balance,
                          color: colorPrimary,
                        ),
                      ),
                      Divider(),
                      SizedBox(
                        height: 30,
                      ),
                      morethan == false
                          ? Container(
                              child: Statusofbutton == true
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 50.0),
                                      child: fabsinglemenu("CheckIn", () async {
                                        PermissionStatus permission = await LocationPermissions()
                                                .checkPermissionStatus();
                                        print(permission.toString());

                                        ServiceStatus serviceStatus =
                                            await LocationPermissions()
                                                .checkServiceStatus();
                                        print(serviceStatus.toString());
                                        PermissionStatus permissiona =
                                            await LocationPermissions()
                                                .requestPermissions();
                                        print(permissiona.toString());
                                        //set action for this menu
                                        if(serviceStatus.toString()!="ServiceStatus.disabled"){
                                          pickImage(true, false);
                                          _getCurrentLocation();
                                        }else{
                                          Fluttertoast.showToast(
                                              msg: "Please Enable your Device Location",
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.SNACKBAR,
                                              timeInSecForIosWeb: 1,
                                              backgroundColor: Colors.black,
                                              textColor: Colors.white,
                                              fontSize: 16.0
                                          );
                                        }

                                        // AppPreferences.setBool(AppConstants.btn_Data, true);
                                      }),
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 50.0),
                                      child: fabsinglemenu("Checkout", () async {

                                        PermissionStatus permission = await LocationPermissions()
                                            .checkPermissionStatus();
                                        print(permission.toString());

                                        ServiceStatus serviceStatus =
                                            await LocationPermissions()
                                            .checkServiceStatus();
                                        print(serviceStatus.toString());
                                        PermissionStatus permissiona =
                                            await LocationPermissions()
                                            .requestPermissions();
                                        print(permissiona.toString());
                                        //set action for this menu
                                        if(serviceStatus.toString()!="ServiceStatus.disabled"){
                                          pickImage(false, true);
                                          _getCurrentLocation();
                                        }else{
                                          Fluttertoast.showToast(
                                              msg: "Please Enable your Device Location",
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.SNACKBAR,
                                              timeInSecForIosWeb: 1,
                                              backgroundColor: Colors.black,
                                              textColor: Colors.white,
                                              fontSize: 16.0
                                          );
                                        }



                                        //   AppPreferences.setBool(AppConstants.btn_Data, false);
                                      }),
                                    ),
                            )
                          : Container(),
                    ],
                  )
                : GFLoader(loaderColorOne: Colors.black26),
            //FAB circular Menu
          ),
        ));
  }
}

Widget fabsinglemenu(String icon, Function onPressFunction) {
  return SizedBox(
      width: 125,
      height: 55,
      //height and width
      // for menu button

      child: RaisedButton(
        color: Color(0xFFFFD54F),
        child: Text(
          icon,
          style: styleSmallText.copyWith(
            color: Color(0xff04549C),
          ),
        ),
        onPressed: onPressFunction,
        shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(60.0),
        ),
      ));
}
