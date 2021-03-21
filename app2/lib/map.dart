import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:biblosphere/model/FilterCubit.dart';
import 'package:biblosphere/model/FilterState.dart';
import 'package:biblosphere/model/MarkerData.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<BitmapDescriptor> getGroupIcon(
  int clusterSize,
  double width,
) async {
  final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(pictureRecorder);
  final Paint paint = Paint()..color = Colors.blue.withOpacity(0.55);
  final TextPainter textPainter = TextPainter(
    textDirection: TextDirection.ltr,
  );
  final double radius = width / 2;
  canvas.drawCircle(
    Offset(radius, radius),
    radius,
    paint,
  );
  textPainter.text = TextSpan(
    text: clusterSize.toString(),
    style: TextStyle(
      fontSize: radius - 5,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  );
  textPainter.layout();
  textPainter.paint(
    canvas,
    Offset(
      radius - textPainter.width / 2,
      radius - textPainter.height / 2,
    ),
  );
  final image = await pictureRecorder.endRecording().toImage(
        radius.toInt() * 2,
        radius.toInt() * 2,
      );
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  return BitmapDescriptor.fromBytes(data.buffer.asUint8List());
}

/*
Future<BitmapDescriptor> getBookIcon(double size) async {
  final pictureRecorder = PictureRecorder();
  final canvas = Canvas(pictureRecorder);
  final textPainter = TextPainter(textDirection: TextDirection.ltr);
  //Icons.menu_book_rounded
  String iconStr = String.fromCharCode(Icons.location_pin.codePoint);
  textPainter.text = TextSpan(
      text: iconStr,
      style: TextStyle(
          letterSpacing: 0.0,
          fontSize: size,
          fontFamily: Icons.location_pin.fontFamily,
          color: Colors.grey.withOpacity(0.6)));
  textPainter.layout();
  textPainter.paint(canvas, Offset(0.0, 0.0));

  iconStr = String.fromCharCode(Icons.menu_book_rounded.codePoint);
  textPainter.text = TextSpan(
      text: iconStr,
      style: TextStyle(
        letterSpacing: 0.0,
        fontSize: size * 0.45,
        fontFamily: Icons.menu_book_rounded.fontFamily,
        color: Colors.blue,
      ));
  textPainter.layout();
  textPainter.paint(canvas, Offset(size * 0.275, size * 0.152));

  final picture = pictureRecorder.endRecording();
  final image = await picture.toImage(size.round(), size.round());
  final bytes = await image.toByteData(format: ImageByteFormat.png);
  return BitmapDescriptor.fromBytes(bytes.buffer.asUint8List());
}
*/
Future<Set<Marker>> markersFor(
    BuildContext context, List<MarkerData> data) async {
  if (data == null || data.length == 0) return Set();

  // Calculate sizes for cluster icons
  List<int> sizes = data.map((d) => d.size).toList();
  int maxGroup = sizes.reduce(max);
  int minGroup = sizes.reduce(min);
  double minR = 30.0, maxR = 45.0;

  // Icon for single book
  // BitmapDescriptor bookBitmap =
  //    await getBookIcon(40.0 * MediaQuery.of(context).devicePixelRatio);

  // Create icons of different sizes
  Set<Marker> markers = Set();

  var m = data.iterator;

  //iterate over the list
  while (m.moveNext()) {
    MarkerData d = m.current;
    //print('!!!DEBUG Marker size ${d.size}');
    double radius;
    if (maxGroup != minGroup)
      radius =
          ((d.size - minGroup) / (maxGroup - minGroup) * (maxR - minR) + minR) *
              MediaQuery.of(context).devicePixelRatio;
    else
      radius = ((maxR + minR) / 2.0) * MediaQuery.of(context).devicePixelRatio;

    //print('!!!DEBUG Add marker size ${d.size} Radius: $radius');

    markers.add(Marker(
        markerId: MarkerId(d.geohash),
        position: d.position,
        icon: await getGroupIcon(
          d.size,
          radius,
        ),
        infoWindow:
            // TODO: retrieve actual list of languages
            InfoWindow(title: '${d.size} books', snippet: 'RUS, ENG'),
        onTap: () {
          context.read<FilterCubit>().markerPressed(d);
        }));
  }

  return markers;
}

class MapWidget extends StatefulWidget {
  MapWidget({Key key}) : super(key: key);

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  bool mapsIsLoading = true;
  GoogleMapController _controller;
  CameraPosition _position;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterCubit, FilterState>(builder: (context, filters) {
      return FutureBuilder(
          initialData: Set<Marker>(),
          future: markersFor(context, filters.markers),
          builder: (context, snapshot) {
            Set<Marker> markers = {};
            if (snapshot.hasData) markers = snapshot.data;

            //print(
            //    '!!!DEBUG Total markers: ${markers.length}. Has data ${snapshot.hasData}');

            return GoogleMap(
                myLocationButtonEnabled: false,
                mapToolbarEnabled: false,
                zoomControlsEnabled: false,
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(
                  target: filters.center,
                  zoom: 5.0,
                ),
                onCameraIdle: () async {
                  context.read<FilterCubit>().mapMoved(
                      _position, await _controller.getVisibleRegion());
                },
                onCameraMove: (position) {
                  _position = position;
                },
                onMapCreated: (GoogleMapController controller) {
                  //TODO: Keep controller to retrieve visible region
                  _controller = controller;
                  context.read<FilterCubit>().setMapController(controller);
                },
                markers: markers);
          });
      // Add markers for all visible geo-hashes to single set
    });
  }
}
