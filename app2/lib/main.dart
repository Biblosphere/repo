import 'dart:math';
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
// BLoC patterns
import 'package:flutter_bloc/flutter_bloc.dart';
// Pick a git phone code
import 'package:country_code_picker/country_code_picker.dart';
// Google map
import 'package:google_maps_flutter/google_maps_flutter.dart';
// Input chips
import 'package:flutter_chips_input/flutter_chips_input.dart';
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

part 'login.dart';
part 'login_bloc.dart';
part 'camera.dart';
part 'books.dart';
part 'map.dart';
part 'filter.dart';
part 'filter_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
        ),
        home: MultiBlocProvider(
            providers: [
              BlocProvider(create: (BuildContext context) => FilterCubit()),
              BlocProvider(create: (BuildContext context) => CameraCubit()),
              BlocProvider(create: (BuildContext context) => LoginCubit())
            ],
            child:
                BlocBuilder<LoginCubit, LoginState>(builder: (context, login) {
              if (login.status == LoginStatus.subscribed) {
                return MainPage();
              } else {
                return LoginPage();
              }
            })));
  }
}

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
                                  oldSelected = selected;
                                  selected = i;
                                  double dir =
                                      ((oldSelected - selected) % 3 - 1.5) *
                                          2.0;
                                  _angleTween = Tween<double>(
                                          begin:
                                              (dir - selected) * pi * 2.0 / 3.0,
                                          end: -selected * pi * 2.0 / 3.0)
                                      .animate(_animationController);
                                  _animationController.reset();
                                  _animationController.forward();

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

class _MainPageState extends State<MainPage> {
  ViewType _view = ViewType.map;
  List<Filter> filters = [];
  bool collapsed = true;
  var _controller = SnappingSheetController();
  double _snapPosition = 0.0;

  CameraController cameraCtrl;

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
  }

  @override
  void dispose() {
    cameraCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
      SnappingSheet(
        sheetAbove: SnappingSheetContent(
            child: _view == ViewType.list
                ? ListWidget()
                : (_view == ViewType.camera && cameraCtrl.value.isInitialized)
                    ? SingleChildScrollView(
                        child: AspectRatio(
                            aspectRatio: cameraCtrl.value.aspectRatio,
                            child: CameraPreview(cameraCtrl)))
                    : Container()),
        onSnapEnd: () {
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
              positionPixel: _view == ViewType.camera ? 0.0 : 60.0,
              snappingCurve: Curves.elasticOut,
              snappingDuration: Duration(milliseconds: 750)),
          SnapPosition(
            positionPixel: _view == ViewType.camera ? 150.0 : 290.0,
          ),
          //SnapPosition(positionFactor: 0.4),
        ],
        child: MapWidget(),
        grabbingHeight: MediaQuery.of(context).padding.bottom + 40,
        grabbing: GrabSection(), //Container(color: Colors.grey),
        sheetBelow: SnappingSheetContent(
            child: Container(
                color: Colors.white,
                child: _view == ViewType.camera
                    ? CameraPanel(collapsed: _snapPosition < 150.0)
                    : SearchPanel(collapsed: _snapPosition < 290.0))),
      ),
      Positioned(
          bottom: max(_snapPosition - 35.0, 10.0),
          right: 5.0,
          child: TripleButton(
            selected: 0,
            onPressed: [
              //onPressed for MAP
              () {
                // TODO: remember a position and restore it
                _controller.snapToPosition(SnapPosition(
                  positionPixel: 60.0,
                ));
                setState(() {
                  _view = ViewType.map;
                });
              },
              //onPressed for CAMERA
              () {
                // TODO: Make it 0.0 position if place is already confirmed
                _controller.snapToPosition(SnapPosition(
                  positionPixel: 150.0,
                ));
                setState(() {
                  _view = ViewType.camera;
                });
              },
              //onPressed for LIST
              () {
                // TODO: remember a position and restore it
                _controller.snapToPosition(SnapPosition(
                  positionPixel: 60.0,
                ));
                setState(() {
                  _view = ViewType.list;
                });
              }
            ],
            onPressedSelected: [
              () {},
              // onPressedSelected for CAMERA
              () {
                print('!!!DEBUG Selected button pressed for CAMERA');
                takePicture(cameraCtrl);
              },
              () {}
            ],
            icons: [Icons.location_pin, Icons.camera_alt, Icons.list_alt],
          ))
    ]));
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
