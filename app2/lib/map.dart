part of 'main.dart';

Future<BitmapDescriptor> getClusterMarker(
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

class BookMarker extends Marker {
  final Book book;

  BookMarker({MarkerId markerId, this.book})
      : super(
            markerId: markerId,
            position: book.location,
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow:
                InfoWindow(title: book.title, snippet: book.authors.join(', ')),
            onTap: () {
              // TODO: Open book details view
            });
}

class GroupMarker extends Marker {
  final List<Book> books;

  GroupMarker(
      {MarkerId markerId,
      String geohash,
      LatLng position,
      BitmapDescriptor icon,
      this.books})
      : super(
            markerId: markerId,
            position: position,
            icon: icon,
            infoWindow:
                // TODO: retrieve actual list of languages
                InfoWindow(title: '${books.length} books', snippet: 'RUS, ENG'),
            onTap: () {
              // TODO: Open list view for froup below 100
              //       and zoom in for bigger groups
            });
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
      // Add markers for all visible geo-hashes to single set
      Set<Marker> markers = {};

      print('!!!DEBUG BUILD MAP');

      if (filters.markers != null)
        filters.markers.forEach((key, value) {
          print('!!!DEBUG build MAP add ${value.length} markers');
          markers.addAll(value);
        });

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
                _position,
                await _controller.getVisibleRegion(),
                MediaQuery.of(context).devicePixelRatio);
          },
          onCameraMove: (position) {
            _position = position;
          },
          onMapCreated: (GoogleMapController controller) {
            //TODO: Keep controller to retrieve visible region
            _controller = controller;
            //controller.getVisibleRegion();
          },
          markers: markers);
    });
  }
}
