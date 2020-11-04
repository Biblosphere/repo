part of 'main.dart';

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

  GroupMarker({MarkerId markerId, String geohash, LatLng position, this.books})
      : super(
            markerId: markerId,
            position: position,
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
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
            context
                .bloc<FilterCubit>()
                .mapMoved(_position, await _controller.getVisibleRegion());
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
