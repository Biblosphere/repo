import 'dart:math';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
//import 'dart:ui';
import 'dart:ui' as ui;
import 'dart:convert';
import 'package:flutter/material.dart';
import "package:collection/collection.dart";

// HTTP requests for API calls
import 'package:http/http.dart';
// BLoC patterns
import 'package:flutter_bloc/flutter_bloc.dart';
// Pick a git phone code
import 'package:country_code_picker/country_code_picker.dart';
// Google map
import 'package:google_maps_flutter/google_maps_flutter.dart';
// Import slidable actions for book card
import 'package:flutter_slidable/flutter_slidable.dart';
// Cached network images
import 'package:cached_network_image/cached_network_image.dart';
// Panel widget for filters and camera
import 'package:snapping_sheet/snapping_sheet.dart';
// Camera plugin
import 'package:camera/camera.dart';
// Files and directories to save images
import 'package:path_provider/path_provider.dart';
// Plugin for subscriptions
import 'package:purchases_flutter/purchases_flutter.dart';
// Compare objects by content
import 'package:equatable/equatable.dart';
// Firebase auth
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
// Geo hashes
import 'package:dart_geohash/dart_geohash.dart';
// Geo location
import 'package:geolocator/geolocator.dart';
// Google places
import 'package:google_place/google_place.dart';
// Contacts plugin
import 'package:contacts_service/contacts_service.dart';
// Permission handler
import 'package:permission_handler/permission_handler.dart';
// Gesture detector and URL launcher for PP and TOS
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

part 'login.dart';
part 'login_bloc.dart';
part 'camera.dart';
part 'books.dart';
part 'map.dart';
part 'filter.dart';
part 'filter_bloc.dart';
part 'catalog.dart';
part 'secret.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
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
    return MaterialApp(
        title: 'Flutter Demo',
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
        home: Builder(builder: (context) {
          return MultiBlocProvider(
              providers: [
                BlocProvider(create: (BuildContext context) => FilterCubit()),
                BlocProvider(create: (BuildContext context) => LoginCubit())
              ],
              child: BlocBuilder<LoginCubit, LoginState>(
                  buildWhen: (prev, curr) => prev.status != curr.status,
                  builder: (context, login) {
                    if (login.status == LoginStatus.subscribed) {
                      return MainPage();
                    } else {
                      return LoginPage();
                    }
                  }));
        }));
  }
}

String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

class TripleButton extends StatefulWidget {
  final int selected;
  final List<VoidCallback> onPressed;
  final List<VoidCallback> onPressedSelected;
  final List<IconData> icons;

  TripleButton(
      {this.selected, this.onPressed, this.onPressedSelected, this.icons});

  @override
  TripleButtonState createState() => TripleButtonState(
      selected: selected,
      onPressed: onPressed,
      onPressedSelected: onPressedSelected,
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
  List<IconData> icons;

  AnimationController _animationController;
  Animation _activateColorTween,
      _deactivateColorTween,
      _angleTween,
      _radiusTweenOld,
      _radiusTweenNew;

  TripleButtonState(
      {this.selected, this.onPressed, this.onPressedSelected, this.icons}) {
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
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));

    _activateColorTween =
        ColorTween(begin: Colors.transparent, end: Colors.blue)
            .animate(_animationController);
    _deactivateColorTween =
        ColorTween(begin: Colors.blue, end: Colors.transparent)
            .animate(_animationController);
    _angleTween = Tween<double>(begin: 0.0, end: pi * 2.0 / 3.0)
        .animate(_animationController);

    _radiusTweenOld =
        Tween<double>(begin: rMax, end: rMin).animate(_animationController);

    _radiusTweenNew =
        Tween<double>(begin: rMin, end: rMax).animate(_animationController);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Radius of rotation
    final double rR = rMin / cos(pi / 6.0);

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
                        color = Colors.blue;
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
                              color: color, //.transparent,
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
    super.initState();
    // Always choose a front camera
    cameraCtrl = CameraController(
        cameras[0],
        //.where((c) => c.lensDirection == CameraLensDirection.front)
        //.toList()[0],
        ResolutionPreset.ultraHigh,
        enableAudio: false);
    cameraCtrl.initialize().then((_) {
      if (mounted) {
        setState(() {});
      }
    });

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
    context.bloc<FilterCubit>().setSnappingController(_controller);

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    cameraCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocBuilder<FilterCubit, FilterState>(
            buildWhen: (previous, current) => previous.view != current.view,
            builder: (context, filters) {
              return Stack(children: [
                SnappingSheet(
                  sheetAbove: SnappingSheetContent(
                      child: AnimatedBuilder(
                          animation: _animationController,
                          child: _pictureFile != null
                              ? Image.file(_pictureFile)
                              : Container(),
                          builder: (context, child) {
                            // Usinf function to make a selection
                            if (filters.view == ViewType.list)
                              return ListWidget();
                            else if (filters.view == ViewType.camera) {
                              double width = MediaQuery.of(context).size.width *
                                  _imageWidthTween.value;
                              double height =
                                  MediaQuery.of(context).size.height *
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
                                if (!_animationController.isAnimating ||
                                    _animationController.value < 0.05)
                                  SingleChildScrollView(
                                      child: AspectRatio(
                                          aspectRatio:
                                              cameraCtrl.value.aspectRatio,
                                          child: CameraPreview(cameraCtrl)))
                              ]);
                            } else if (filters.view == ViewType.details)
                              return DetailsPage();
                            else
                              return Container();
                          })),
                  onSnapEnd: () {
                    if (_snapPosition < 10.0)
                      context.bloc<FilterCubit>().panelHiden();
                    else if (_snapPosition < 100.0)
                      context.bloc<FilterCubit>().panelMinimized();
                    else if (_snapPosition < 210.0)
                      context.bloc<FilterCubit>().panelOpened();

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
                        positionPixel: 55.0,
                        snappingCurve: Curves.elasticOut,
                        snappingDuration: Duration(milliseconds: 750)),
                    if (filters.view == ViewType.camera)
                      SnapPosition(
                          positionPixel: 150.0,
                          snappingCurve: Curves.elasticOut,
                          snappingDuration: Duration(milliseconds: 750)),
                    if (filters.view != ViewType.camera)
                      SnapPosition(
                          positionPixel: 205.0,
                          snappingCurve: Curves.elasticOut,
                          snappingDuration: Duration(milliseconds: 750)),
                  ],
                  child: MapWidget(),
                  grabbingHeight: filters.view != ViewType.details
                      ? MediaQuery.of(context).padding.bottom + 40
                      : 0.0,
                  grabbing: filters.view != ViewType.details
                      ? GrabSection()
                      : Container(
                          width: 0.0,
                          height: 0.0), //Container(color: Colors.grey),
                  sheetBelow: SnappingSheetContent(
                      child: filters.view != ViewType.details
                          ? Container(
                              color: Colors.white,
                              child: filters.view == ViewType.camera
                                  ? CameraPanel()
                                  : SearchPanel())
                          : Container(width: 0.0, height: 0.0)),
                ),
                Positioned(
                    bottom: max(_snapPosition - 35.0, 10.0),
                    right: 5.0,
                    child: filters.view != ViewType.details
                        ? TripleButton(
                            selected: filters.view.index,
                            onPressed: [
                              //onPressed for MAP
                              () {
                                // TODO: remember a position and restore it
                                _controller.snapToPosition(SnapPosition(
                                  positionPixel: 60.0,
                                ));
                                setState(() {
                                  context
                                      .bloc<FilterCubit>()
                                      .setView(ViewType.map);
                                });
                              },
                              //onPressed for CAMERA
                              () {
                                // TODO: Make it 0.0 position if place is already confirmed
                                _controller.snapToPosition(SnapPosition(
                                  positionPixel: 150.0,
                                ));
                                setState(() {
                                  context
                                      .bloc<FilterCubit>()
                                      .setView(ViewType.camera);
                                });
                              },
                              //onPressed for LIST
                              () {
                                // TODO: remember a position and restore it
                                _controller.snapToPosition(SnapPosition(
                                  positionPixel: 60.0,
                                ));
                                context
                                    .bloc<FilterCubit>()
                                    .setView(ViewType.list);
                              }
                            ],
                            onPressedSelected: [
                              // onPressedSelected for MAP
                              () {
                                context.bloc<FilterCubit>().mapButtonPressed();
                              },
                              // onPressedSelected for CAMERA
                              () async {
                                print(
                                    '!!!DEBUG Selected button pressed for CAMERA');

                                if (!cameraCtrl.value.isInitialized) {
                                  //TODO: do exceptional processing for not initialized camera
                                  //showInSnackBar('Error: select a camera first.');
                                  print(
                                      '!!!DEBUG Camera controller not initialized');
                                  return;
                                }

                                if (cameraCtrl.value.isTakingPicture) {
                                  // A capture is already pending, do nothing.
                                  print(
                                      '!!!DEBUG Camera controller in pogress (taking picture)');
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
                                await Directory(filePath)
                                    .create(recursive: true);
                                final String fileName = '${timestamp()}.jpg';
                                final File file = File('$filePath/$fileName');
                                print('!!!DEBUG file path ${file.path}');

                                try {
                                  await cameraCtrl.takePicture(file.path);
                                } on CameraException catch (e) {
                                  //TODO: Do exception processing for the camera;
                                  print(
                                      '!!!DEBUG Camera controller exception: $e');
                                  return null;
                                }

                                print(
                                    '!!!DEBUG: Is controller animating: ${_animationController.isAnimating}');

                                setState(() {
                                  _pictureFile = file;
                                });

                                _animationController.forward();

                                context
                                    .bloc<FilterCubit>()
                                    .cameraButtonPressed(file, fileName);
                              },
                              () {}
                            ],
                            icons: [
                              Icons.location_pin,
                              Icons.camera_alt,
                              Icons.list_alt
                            ],
                          )
                        : Container(width: 0.0, height: 0.0))
              ]);
            }));
  }
}

class GrabSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 20.0,
            color: Colors.black.withOpacity(0.2),
          )
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15.0),
          topRight: Radius.circular(15.0),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            width: 100.0,
            height: 10.0,
            margin: EdgeInsets.only(top: 15.0),
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.all(Radius.circular(5.0))),
          ),
          Container(
            height: 2.0,
            margin: EdgeInsets.only(left: 20, right: 20),
            color: Colors.grey[300],
          ),
        ],
      ),
    );
  }
}
