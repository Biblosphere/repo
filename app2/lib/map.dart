part of 'main.dart';

Future<BitmapDescriptor> getGroupIcon(
  int clusterSize,
  double width,
) async {
  final PictureRecorder pictureRecorder = PictureRecorder();
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
  final data = await image.toByteData(format: ImageByteFormat.png);
  return BitmapDescriptor.fromBytes(data.buffer.asUint8List());
}

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

Future<Set<Marker>> markersFor(
    BuildContext context, Map<String, Set<MarkerData>> map) async {
  if (map == null || map.length == 0) return Set();

  // Flat map with hashes into single list of marker data
  List<MarkerData> data = map.values.expand((e) => e).toList();

  // Calculate sizes for cluster icons
  List<int> lengths = data.map((value) => value.books.length).toList();
  int maxGroup = lengths.reduce(max);
  int minGroup = lengths.reduce(min);
  double minR = 30.0, maxR = 45.0;

  // Icon for single book
  BitmapDescriptor bookBitmap =
      await getBookIcon(40.0 * MediaQuery.of(context).devicePixelRatio);

  // Create icons of different sizes
  Set<Marker> markers = Set();

  await Future.forEach(data, (d) async {
    if (d.books.length > 1) {
      double radius =
          ((d.books.length - minGroup) / (maxGroup - minGroup) * (maxR - minR) +
                  minR) *
              MediaQuery.of(context).devicePixelRatio;

      markers.add(Marker(
          markerId: MarkerId(d.geohash),
          position: d.position,
          icon: await getGroupIcon(
            d.books.length,
            radius,
          ),
          infoWindow:
              // TODO: retrieve actual list of languages
              InfoWindow(title: '${d.books.length} books', snippet: 'RUS, ENG'),
          onTap: () {
            context.bloc<FilterCubit>().markerPressed(d);
          }));
    } else {
      markers.add(Marker(
          markerId: MarkerId(d.geohash),
          position: d.position,
          icon: bookBitmap,
          infoWindow: InfoWindow(
              title: d.books.first.title,
              snippet: d.books.first.authors.join(', ')),
          onTap: () {
            context.bloc<FilterCubit>().markerPressed(d);
          }));
    }
  });

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

            print('!!!DEBUG Total markers: ${markers.length}');

            return GoogleMap(
                myLocationButtonEnabled: false,
                mapToolbarEnabled: false,
                zoomControlsEnabled: false,
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(
                  target: filters.center,
                  zoom: filters.zoom,
                ),
                onCameraIdle: () async {
                  print('!!!DEBUG: Map move completed');
                  // TODO: Add condition for significant moves only
                  context.bloc<FilterCubit>().mapMoved(
                      _position, await _controller.getVisibleRegion());
                },
                onCameraMove: (position) {
                  _position = position;
                },
                onMapCreated: (GoogleMapController controller) {
                  //TODO: Keep controller to retrieve visible region
                  _controller = controller;
                  context.bloc<FilterCubit>().setController(controller);
                },
                markers: markers);
          });
      // Add markers for all visible geo-hashes to single set
    });
  }
}
