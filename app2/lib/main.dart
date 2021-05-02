import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

//import 'dart:typed_data';
//import 'dart:ui';
import 'dart:ui' as ui;

// Import slidable actions for book card
//import 'package:flutter_slidable/flutter_slidable.dart';
// Cached network images
import 'package:cached_network_image/cached_network_image.dart';

// Camera plugin
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:collection/collection.dart";

// Contacts plugin
import 'package:contacts_service/contacts_service.dart';

// Pick a git phone code
import 'package:country_code_picker/country_code_picker.dart';

// Geo hashes
import 'package:dart_geohash/dart_geohash.dart';

// Compare objects by content
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Firebase auth
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_storage/firebase_storage.dart';

// Gesture detector and URL launcher for PP and TOS
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// BLoC patterns
import 'package:flutter_bloc/flutter_bloc.dart';

// Geo location
import 'package:geolocator/geolocator.dart';

// Google map
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Google places
import 'package:google_place/google_place.dart';

// HTTP requests for API calls
import 'package:http/http.dart';

// Files and directories to save images
import 'package:path_provider/path_provider.dart';

// Permission handler
import 'package:permission_handler/permission_handler.dart';

// Fuulscree image view
import 'package:photo_view/photo_view.dart';

// Plugin for subscriptions
import 'package:purchases_flutter/purchases_flutter.dart';

// Share the book link to others
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Panel widget for filters and camera
import 'package:snapping_sheet/snapping_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

import 'colors.dart';

part 'books.dart';

part 'camera.dart';

part 'catalog.dart';

part 'filter.dart';

part 'filter_bloc.dart';

part 'login.dart';

part 'map.dart';

part 'secret.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  print('!!!DEBUG Available Cameras: $cameras');
  await Firebase.initializeApp();

  runApp(MyApp());

  // TODO: Switch dedug OFF
  Purchases.setDebugLogsEnabled(true);
  // TODO: Keep API Key in security values in Firebase (Security)
  await Purchases.setup(PurchasesKey);
}

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void dispose() {
    api.client.close();
    super.dispose();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (BuildContext context) => FilterCubit(),
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Biblosphere',
            theme: ThemeData(
                // This is the theme of your application.
                //
                // Try running your application with "flutter run". You'll see the
                // application has a blue toolbar. Then, without quitting the app, try
                // changing the primarySwatch below to Colors.green and then invoke
                // "hot reload" (press "r" in the console where you ran "flutter run",
                // or simply save your changes to "hot reload" in a Flutter IDE).
                // Notice that the counter didn't reset back to zero; the application
                // is not restarted.
                primarySwatch: Colors.blue,
                // This makes the visual density adapt to the platform that you run
                // the app on. For desktop platforms, the controls will be smaller and
                // closer together (more dense) than on mobile platforms.
                visualDensity: VisualDensity.adaptivePlatformDensity,
                backgroundColor: Color(0xfff5f4f3),
                textTheme: TextTheme(
                  button: TextStyle(
                      fontSize: 14.0, fontFamily: 'Hind', color: Colors.white),
                ),
                buttonTheme: ButtonThemeData(
                  height: 50,
                  buttonColor: Color(0xff598a99),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0),
                      side: BorderSide(color: Colors.transparent)),
                )),
            home: BlocBuilder<FilterCubit, FilterState>(
                builder: (context, state) {
              if (state.status == LoginStatus.subscribed) {
                return MainPage();
              } else {
                return LoginPage();
              }
            })));
  }
}

String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

class TripleButton extends StatefulWidget {
  final int selected;
  final List<VoidCallback> onPressed;
  final List<VoidCallback> onPressedSelected;
  final List<VoidCallback> onLongPress;
  final List<IconData> icons;

  TripleButton(
      {this.selected,
      this.onPressed,
      this.onPressedSelected,
      this.onLongPress,
      this.icons});

  @override
  TripleButtonState createState() => TripleButtonState(
      selected: selected,
      onPressed: onPressed,
      onPressedSelected: onPressedSelected,
      onLongPress: onLongPress,
      icons: icons);
}

class TripleButtonState extends State<TripleButton>
    with SingleTickerProviderStateMixin {
  final double rMin = 25.0;

  // Radius of bigger circle
  final double rMax = 34.0;

  int selected;
  int oldSelected;

  List<VoidCallback> onPressed;
  List<VoidCallback> onPressedSelected;
  List<VoidCallback> onLongPress;
  List<IconData> icons;

  AnimationController _animationController;
  Animation _activateColorTween,
      _deactivateColorTween,
      _angleTween,
      _radiusTweenOld,
      _radiusTweenNew;

  TripleButtonState(
      {this.selected,
      this.onPressed,
      this.onPressedSelected,
      this.onLongPress,
      this.icons}) {
    oldSelected = selected;
  }

  @override
  void didUpdateWidget(covariant TripleButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selected != widget.selected) {
      // oldSelected = oldWidget.selected;
      animate(widget.selected);
    }
  }

  void animate(int i) {
    oldSelected = selected;
    selected = i;
    double dir = ((oldSelected - selected) % 3 - 1.5) * 2.0;
    _angleTween = Tween<double>(
            begin: (dir - selected) * pi * 2.0 / 3.0,
            end: -selected * pi * 2.0 / 3.0)
        .animate(_animationController);
    _animationController.reset();
    _animationController.forward();
  }

  @override
  void initState() {
    super.initState();

    print('!!!DEBUG triple button init!');

    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));

    _activateColorTween =
        ColorTween(begin: Colors.transparent, end: buttonBackground)
            .animate(_animationController);
    _deactivateColorTween =
        ColorTween(begin: buttonBackground, end: Colors.transparent)
            .animate(_animationController);

    if (selected == ViewType.list.index) {
      _angleTween = Tween<double>(begin: pi * 2.0 / 3.0, end: pi * 4.0 / 3.0)
          .animate(_animationController);
    } else if (selected == ViewType.camera.index) {
      _angleTween = Tween<double>(begin: -pi * 2.0 / 3.0, end: 0.0)
          .animate(_animationController);
    } else {
      _angleTween = Tween<double>(begin: 0.0, end: pi * 2.0 / 3.0)
          .animate(_animationController);
    }

    _radiusTweenOld =
        Tween<double>(begin: rMax, end: rMin).animate(_animationController);

    _radiusTweenNew =
        Tween<double>(begin: rMin, end: rMax).animate(_animationController);
  }

  @override
  Widget build(BuildContext context) {
    // Radius of rotation
    final double rR = rMin / cos(pi / 6.0);

    print('!!!DEBUG triple button build!');

    return AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          double theta = _angleTween.value;
          List<double> r = [rMin, rMin, rMin];
          if (_animationController.isAnimating) {
            r[oldSelected] = _radiusTweenOld.value;
            r[selected] = _radiusTweenNew.value;
          } else {
            r[oldSelected] = rMin;
            r[selected] = rMax;
          }
          // Sort the buttons so that the selected one will be on top
          List<int> indexes = [0, 1, 2]..sort((a, b) => b == selected ? -1 : 1);
          return SizedBox(
              width: 2.0 * (rMax + rR),
              height: 2.0 * (rMax + rR),
              child: Container(
                  alignment: Alignment.bottomRight,
                  //color: Colors.yellow,
                  child: Stack(
                      children: indexes.map((i) {
                    Color color = Colors.transparent;
                    if (i == selected) {
                      if (_animationController.isAnimating)
                        color = _activateColorTween.value;
                      else
                        color = buttonBackground;
                    } else if (i == oldSelected)
                      color = _deactivateColorTween.value;

                    return Positioned(
                        left: rR +
                            rMax -
                            r[i] -
                            rR * sin(theta + i * 2.0 / 3.0 * pi),
                        top: rR +
                            rMax -
                            r[i] +
                            rR * cos(theta + i * 2.0 / 3.0 * pi),
                        child: SizedBox(
                            width: 2.0 * r[i],
                            height: 2.0 * r[i],
                            child: MaterialButton(
                              onPressed: () {
                                if (i == selected)
                                  onPressedSelected[i]();
                                else {
                                  onPressed[i]();
                                }
                              },
                              onLongPress: () {
                                if (i == selected && onLongPress[i] != null)
                                  onLongPress[i]();
                              },
                              color: color,
                              //.transparent,
                              textColor: Colors.white,
                              child: Icon(
                                icons[i],
                                size: rMin,
                              ),
                              padding: EdgeInsets.all(rMin / 2.0),
                              shape: CircleBorder(),
                            )));
                  }).toList())));
        });
  }
}

class MainPage extends StatefulWidget {
  MainPage({Key key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  //List<Filter> filters = [];
  //bool collapsed = true;
  SnappingSheetController _controller = SnappingSheetController();
  double _snapPosition = 0.0;

  CameraController cameraCtrl;
  AnimationController _animationController;
  Animation _imageWidthTween;

  File _pictureFile;

  @override
  void initState() {
    print('!!!DEBUG: $cameras');
    super.initState();
    // Always choose a front camera
    if (cameras != null && cameras.length > 0) {
      cameraCtrl = CameraController(
          cameras[0],
          //.where((c) => c.lensDirection == CameraLensDirection.front)
          //.toList()[0],
          ResolutionPreset.ultraHigh,
          enableAudio: false);
      cameraCtrl.initialize().then((_) {
        cameraCtrl.lockCaptureOrientation(DeviceOrientation.portraitUp);
        if (mounted) {
          setState(() {});
        }
      });
    }

    // Animation for camera taken picture
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 2000))
          ..stop();
    final Animation _curve = CurvedAnimation(
        parent: _animationController,
        curve: Curves.ease); // Try Curves.ease, Curves.bounceOut
    _imageWidthTween = Tween<double>(begin: 1.0, end: 0.0).animate(_curve);
  }

  @override
  void didChangeDependencies() {
    // TODO: Make a code to do it only once at first call afer initState
    context.read<FilterCubit>().setSnappingController(_controller);

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    if (cameraCtrl != null) cameraCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body:
            BlocBuilder<FilterCubit, FilterState>(builder: (context, filters) {
          return Stack(children: [
            SnappingSheet(
              //sheetAbove: SnappingSheetContent(
              //    child: ),
              onSnapEnd: () {
                if (_snapPosition < 10.0)
                  context.read<FilterCubit>().panelHiden();
                else if (_snapPosition < 100.0)
                  context.read<FilterCubit>().panelMinimized();
                else if (_snapPosition < 240.0)
                  context.read<FilterCubit>().panelOpened();

                setState(() {});
              },
              onMove: (moveAmount) {
                setState(() {
                  _snapPosition = moveAmount;
                });
              },
              snappingSheetController: _controller,
              snapPositions: [
                SnapPosition(
                    positionPixel: 0.0,
                    snappingCurve: Curves.elasticOut,
                    snappingDuration: Duration(milliseconds: 750)),
                SnapPosition(
                    positionPixel: 56.0,
                    snappingCurve: Curves.elasticOut,
                    snappingDuration: Duration(milliseconds: 750)),
                if (filters.view == ViewType.camera)
                  SnapPosition(
                      positionPixel: 112.0,
                      snappingCurve: Curves.elasticOut,
                      snappingDuration: Duration(milliseconds: 750)),
                if (filters.view != ViewType.camera)
                  SnapPosition(
                      positionPixel: 224.0,
                      snappingCurve: Curves.elasticOut,
                      snappingDuration: Duration(milliseconds: 750)),
              ],
              child: Stack(children: [
                MapWidget(),
                AnimatedBuilder(
                    animation: _animationController,
                    child: _pictureFile != null
                        ? Image.file(_pictureFile)
                        : Container(),
                    builder: (context, child) {
                      // Usinf function to make a selection
/*
                      if (filters.selected != null)
                        return DetailsPage();
                            return Positioned(
                                child: DetailsPage(),
                                left: 0.0,
                                right: 0.0,
                                top: 0.0,
                                bottom: 0.0);
                      else 
*/
                      if (filters.view == ViewType.list)
                        return BooksWidget();
                      else if (filters.view == ViewType.camera) {
                        double width = MediaQuery.of(context).size.width *
                            _imageWidthTween.value;
                        double height = MediaQuery.of(context).size.height *
                            _imageWidthTween.value;

                        // TODO: Stack is needed otherwise map is blinking on the start of the animation
                        return Stack(children: [
                          // TODO: Improve animation:
                          //        - make it precise to the right point on the map
                          //        - make the marker on the map
                          //        - make a path smoth (liner despite the upper panel and full screen)
                          Center(
                              child: SingleChildScrollView(
                                  child: Container(
                                      //color: Colors.blue,
                                      width: width,
                                      height: height,
                                      child: child))),
                          if (cameraCtrl != null &&
                                  !_animationController.isAnimating ||
                              _animationController.value < 0.05)
                            Container(
                                color: Colors.white.withOpacity(0.8),
                                child: Center(
                                    child: SingleChildScrollView(
                                        //child: AspectRatio(
                                        //    aspectRatio: 1/cameraCtrl.value.aspectRatio,
                                        child: CameraPreview(cameraCtrl))))
                          //  )
                        ]);
                      } else
                        return Container();
                    }),
                InviteWidget(),
              ]),
              grabbingHeight: MediaQuery.of(context).padding.bottom + 40,
              grabbing: GrabSection(),
              sheetBelow: SnappingSheetContent(
                  child: Container(
                      decoration: boxDecoration(),
                      child: filters.view == ViewType.camera
                          ? CameraPanel()
                          : SearchPanel())),
            ),
            Positioned(
                bottom: max(_snapPosition - 35.0, 10.0),
                right: 5.0,
                child: TripleButton(
                  selected: filters.view.index,
                  onPressed: [
                    //onPressed for MAP
                    () {
                      // TODO: remember a position and restore it
                      _controller.snapToPosition(SnapPosition(
                        positionPixel: 60.0,
                      ));
                      context.read<FilterCubit>().setView(ViewType.map);
                    },
                    //onPressed for CAMERA
                    () {
                      // TODO: Make it 0.0 position if place is already confirmed
                      _controller.snapToPosition(SnapPosition(
                        positionPixel: 60.0,
                      ));
                      context.read<FilterCubit>().setView(ViewType.camera);
                    },
                    //onPressed for LIST
                    () {
                      // TODO: remember a position and restore it
                      _controller.snapToPosition(SnapPosition(
                        positionPixel: 60.0,
                      ));
                      context.read<FilterCubit>().setView(ViewType.list);
                    }
                  ],
                  onPressedSelected: [
                    // onPressedSelected for MAP
                    () {
                      context.read<FilterCubit>().mapButtonPressed();
                    },
                    // onPressedSelected for CAMERA
                    () async {
                      if (cameraCtrl == null ||
                          !cameraCtrl.value.isInitialized) {
                        //TODO: do exceptional processing for not initialized camera
                        //showInSnackBar('Error: select a camera first.');
                        print('EXCEPTION: Camera controller not initialized');
                        return;
                      }

                      if (cameraCtrl != null &&
                          cameraCtrl.value.isTakingPicture) {
                        // A capture is already pending, do nothing.
                        print(
                            'EXCEPTION: Camera controller in pogress (taking picture)');
                        return null;
                      }

                      _animationController.reset();

                      setState(() {
                        _pictureFile = null;
                      });

                      final Directory extDir =
                          await getApplicationDocumentsDirectory();
                      final String filePath =
                          '${extDir.path}/Pictures/Biblosphere';
                      await Directory(filePath).create(recursive: true);
                      final String fileName = '${timestamp()}.jpg';
                      File file;

                      try {
                        await cameraCtrl.unlockCaptureOrientation();
                        file = File((await cameraCtrl.takePicture()).path);
                        cameraCtrl.lockCaptureOrientation(
                            DeviceOrientation.portraitUp);
                      } on CameraException catch (e) {
                        await FirebaseCrashlytics.instance
                            .recordError(e, StackTrace.current, reason: 'a non-fatal error');
                        //TODO: Do exception processing for the camera;
                        print('EXCEPTION: Camera controller exception: $e');
                        return null;
                      }

                      setState(() {
                        _pictureFile = file;
                      });

                      _animationController.forward();

                      context
                          .read<FilterCubit>()
                          .cameraButtonPressed(file, fileName);
                    },
                    () {}
                  ],
                  onLongPress: [
                    //onLongPress for MAP
                    () {
                      context.read<FilterCubit>().mapButtonLongPress();
                    },
                    //onLongPress for CAMERA
                    () {},
                    //onLongPress for LIST
                    () {}
                  ],
                  icons: [Icons.location_pin, Icons.camera_alt, Icons.list_alt],
                ))
          ]);
        }));
  }
}

class InviteWidget extends StatefulWidget {
  const InviteWidget({Key key}) : super(key: key);

  @override
  _InviteWidget createState() => _InviteWidget();
}

/// This is the private State class that goes with MyStatefulWidget.
class _InviteWidget extends State<InviteWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 30, 8, 0),
      child: Align(
        alignment: Alignment.topRight,
        child: IconButton(
          icon: const Icon(Icons.ios_share),
          color: progressIndicatorColor,
          onPressed: () {
            context.read<FilterCubit>().shareInviteLink();
          },
        ),
      ),
    );
  }
}

class GrabSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: boxDecoration(),
      child: Center(
        child: Container(
          width: 81.0,
          height: 4.0,
          margin: EdgeInsets.only(left: 20, right: 20),
          color: Color(0xffadacbc),
        ),
      ),
    );
  }
}

// Default box decoration
BoxDecoration boxDecoration() {
  return BoxDecoration(
    color: Color(0xffe3e3e1).withOpacity(0.8),
/*
    boxShadow: [
      BoxShadow(
        blurRadius: 20.0,
        color: Colors.black.withOpacity(0.2),
      )
    ],
*/
    /*
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15.0),
          topRight: Radius.circular(15.0),
        ),
        */
  );
}

// Default box decoration
BoxDecoration placeDecoration() {
  return BoxDecoration(
    color: Colors.white,
/*
    boxShadow: [
      BoxShadow(
        blurRadius: 20.0,
        color: Colors.black.withOpacity(0.2),
      )
    ],
*/
    borderRadius: BorderRadius.all(
      Radius.circular(24.0),
    ),
  );
}

Widget shaderScroll(Widget child) {
  return ShaderMask(
      shaderCallback: (Rect rect) {
        return LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [
            Colors.purple,
            Colors.transparent,
            Colors.transparent,
            Colors.purple
          ],
          stops: [
            0.0,
            0.1,
            0.985,
            1.0
          ], // 10% purple, 80% transparent, 10% purple
        ).createShader(rect);
      },
      blendMode: BlendMode.dstOut,
      child: child);
}

InputDecoration inputDecoration(String label) {
  // TODO: Get rid of '\n' need a better way to locate the labelText
  //       it's either too high or too low

  return InputDecoration(
      labelText: label + '\n',
      labelStyle: inputLabelStyle,
      border: OutlineInputBorder(borderSide: BorderSide.none),
      isCollapsed: true,
//        isDense: true,
      floatingLabelBehavior: FloatingLabelBehavior.always);
}

Widget detailsButton(
    {IconData icon, VoidCallback onPressed, bool selected = false}) {
  return Container(
      width: 45.0,
      height: 45.0,
      //margin: EdgeInsets.all(2.0),
      padding: EdgeInsets.all(2.0),
      child: MaterialButton(
        elevation: 0.0,
        onPressed: onPressed,
        color: selected ? buttonSelectedBackground : buttonUnselectedBackground,
        textColor: selected ? buttonSelectedText : buttonUnselectedText,
        child: Icon(
          icon,
          size: 20,
        ),
        padding: EdgeInsets.all(0.0),
        shape: CircleBorder(
            side: BorderSide(
                color: selected ? buttonSelectedBorder : buttonBorder,
                width: 2.0)),
      ));
}
