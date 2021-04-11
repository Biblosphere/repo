import 'dart:io';
import 'dart:math';

import 'package:biblosphere/model/FilterCubit.dart';
import 'package:biblosphere/model/FilterState.dart';
import 'package:biblosphere/model/ViewType.dart';
import 'package:biblosphere/ui/camera/CameraPanel.dart';
import 'package:biblosphere/ui/camera/MapCubit.dart';
import 'package:biblosphere/ui/home/HomeCubit.dart';
import 'package:biblosphere/ui/library/BooksWidget.dart';
import 'package:biblosphere/ui/search/SearchPanel.dart';
import 'package:biblosphere/ui/search/map.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// BLoC patterns
import 'package:flutter_cubit/flutter_cubit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:snapping_sheet/snapping_sheet.dart';

import '../../main.dart';

class MainPage extends StatefulWidget {
  MainPage(List<CameraDescription> cameras, {Key key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState(cameras);
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

  _MainPageState(List<CameraDescription> cameras);

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
    context.cubit<HomeCubit>().setSnappingController(_controller);

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
        body: CubitBuilder<HomeCubit, FilterState>(builder: (context, filters) {
          return Stack(children: [
            SnappingSheet(
              //sheetAbove: SnappingSheetContent(
              //    child: ),
              onSnapEnd: () {
                if (_snapPosition < 10.0)
                  context.cubit<HomeCubit>().panelHiden();
                else if (_snapPosition < 100.0) {
                  context.cubit<HomeCubit>().panelMinimized();
                } else if (_snapPosition < 240.0) {
                  context.cubit<HomeCubit>().panelOpened();
                  context.cubit<FilterCubit>().panelOpened();
                  context.cubit<MapCubit>().panelOpened();
                } else  {
                  context.cubit<HomeCubit>().panelOpened();
                  context.cubit<FilterCubit>().panelOpened();
                  context.cubit<MapCubit>().panelOpened();
                }

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
                    })
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
                      context.cubit<HomeCubit>().setView(ViewType.map);
                    },
                    //onPressed for CAMERA
                    () {
                      // TODO: Make it 0.0 position if place is already confirmed
                      _controller.snapToPosition(SnapPosition(
                        positionPixel: 60.0,
                      ));
                      context.cubit<HomeCubit>().setView(ViewType.camera);
                    },
                    //onPressed for LIST
                    () {
                      // TODO: remember a position and restore it
                      _controller.snapToPosition(SnapPosition(
                        positionPixel: 60.0,
                      ));
                      context.cubit<HomeCubit>().setView(ViewType.list);
                    }
                  ],
                  onPressedSelected: [
                    // onPressedSelected for MAP
                    () {
                      // context.cubit<HomeCubit>().mapButtonPressed();
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
                        //TODO: Do exception processing for the camera;
                        print('EXCEPTION: Camera controller exception: $e');
                        return null;
                      }

                      setState(() {
                        _pictureFile = file;
                      });

                      _animationController.forward();

                      // context
                      //     .cubit<HomeCubit>()
                      //     .cameraButtonPressed(file, fileName);
                    },
                    () {}
                  ],
                  onLongPress: [
                    //onLongPress for MAP
                    () {
                      // context.cubit<HomeCubit>().mapButtonLongPress();
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
