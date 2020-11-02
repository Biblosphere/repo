part of 'main.dart';

class MapWidget extends StatefulWidget {
  MapWidget({Key key}) : super(key: key);

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  bool mapsIsLoading = true;
  GoogleMapController _controller;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterCubit, FilterState>(builder: (context, filters) {
      print('!!!DEBUG Cubit builder ${DateTime.now().millisecondsSinceEpoch}');
      Set<Marker> markers = Set();
      if (filters.stream != null)
        markers = filters.stream.map((document) {
          GeoPoint point = document.data()['location']['geopoint'];
          return Marker(
              markerId: MarkerId(document.id),
              //icon: markerIcon,
              position: LatLng(point.latitude, point.longitude),
              infoWindow: InfoWindow(
                  title: document.data()['title'],
                  snippet: document.data()['authors'].join(', ')),
              onTap: () {});
        }).toSet();

      print('!!!DEBUG: Number of books ${markers.length}');

      return GoogleMap(
          myLocationButtonEnabled: false,
          mapToolbarEnabled: false,
          zoomControlsEnabled: false,
          mapType: MapType.normal,
          initialCameraPosition: CameraPosition(
            target: filters.center,
            zoom: filters.zoom,
          ),
          onCameraMove: (position) async {
            print('!!!DEBUG: Map moves');
            // TODO: Add condition for significant moves only
            context
                .bloc<FilterCubit>()
                .mapMoved(position, await _controller.getVisibleRegion());
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
