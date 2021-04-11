import 'dart:async';
import 'dart:math';

import 'package:biblosphere/model/FilterCubitOld.dart';
import 'package:biblosphere/model/FilterState.dart';
import 'package:biblosphere/model/ViewType.dart';
import 'package:biblosphere/secret.dart';
import 'package:biblosphere/ui/camera/MapCubit.dart';
import 'package:biblosphere/ui/home/HomeCubit.dart';
import 'package:biblosphere/ui/home/home_screen.dart';
import 'package:biblosphere/ui/home/home_screen_old.dart';
import 'package:biblosphere/util/Colors.dart';
import 'package:biblosphere/util/Enums.dart';

// Camera plugin
import 'package:camera/camera.dart';

// Firebase auth
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

// BLoC patterns
import 'package:flutter_cubit/flutter_cubit.dart';

// Plugin for subscriptions
import 'package:purchases_flutter/purchases_flutter.dart';

import 'model/FilterCubit.dart';

List<CameraDescription> cameras;

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
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiCubitProvider(
        providers: [
          CubitProvider<FilterCubitOld>(
            create: (BuildContext context) => FilterCubitOld(),
          ),
          CubitProvider<FilterCubit>(
            create: (BuildContext context) => FilterCubit(),
          ),
          CubitProvider<HomeCubit>(
            create: (BuildContext context) => HomeCubit(),
          ),
          CubitProvider<MapCubit>(
            create: (BuildContext context) => MapCubit(),
          ),
        ],
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
            home: CubitBuilder<HomeCubit, FilterState>(
                builder: (context, state) {
              if (state.status == LoginStatus.subscribed) {
                return MainPage(cameras);
              } else {
                return MainPage(cameras);
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
