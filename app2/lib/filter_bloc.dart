part of "main.dart";

/*
*******************************************
***************** Events ******************
*******************************************

FILTER PANEL:
- Author/title filter changed => FILTER
- Places filter changed => FILTER (permission for Address Book if My Places)
- Language filter changed => FILTER
- Genre filter changed => FILTER
- Filter panel opened => FILTER
- Filter panel minimized => FILTER
- Filter panel closed => FILTER

TRIPLE BUTTON
- Map button pressed => FILTER
- List button pressed => FILTER
- Set view => FILTER

MAP VIEW
- Map move => FILTER
- Tap on Marker => FILTER

DETAILS
- Search button pressed => FILTER

*******************************************
***************** States ******************
*******************************************

FILTER => Map scale and position
FILTER => Book filter changed

*/

enum FilterType { author, title, genre, language, place, wish, contacts }

class Filter extends Equatable {
  final FilterType type;
  final String value;
  final bool selected;

  @override
  List<Object> get props => [type, value, selected];

  const Filter({@required this.type, this.value, this.selected});

  Filter copyWith({
    FilterType type,
    String value,
    bool selected,
  }) {
    return Filter(
      type: type ?? this.type,
      value: value ?? this.value,
      selected: selected ?? this.selected,
    );
  }
}

enum PanelPosition { hiden, minimized, open }

enum ViewType { map, list, details, camera }

class FilterState extends Equatable {
  final Map<FilterType, List<Filter>> filters;
  final PanelPosition position;
  final LatLng center;
  final double zoom;
  final List<String> geohashes;
  final ViewType view;
  final List<DocumentSnapshot> stream;

  @override
  List<Object> get props =>
      [filters, position, center, zoom, geohashes, view, stream];

  const FilterState(
      {this.filters = const {
        FilterType.title: [Filter(type: FilterType.wish, selected: false)],
        FilterType.genre: [],
        FilterType.place: [Filter(type: FilterType.contacts, selected: false)],
        FilterType.language: [],
      },
      this.position = PanelPosition.minimized,
      this.center = const LatLng(37.42796133580664, -122.085749655962),
      this.zoom = 5.0,
      this.geohashes,
      this.view,
      this.stream});

  FilterState copyWith(
      {Map<FilterType, List<Filter>> filters,
      PanelPosition position,
      LatLng center,
      double zoom,
      ViewType view,
      List<String> geohashes,
      List<DocumentSnapshot> stream}) {
    return FilterState(
      filters: filters ?? this.filters,
      position: position ?? this.position,
      center: center ?? this.center,
      zoom: zoom ?? this.zoom,
      view: view ?? this.view,
      geohashes: geohashes ?? this.geohashes,
      stream: stream ?? this.stream,
    );
  }

  List<Filter> getSelected() {
    return [
      ...filters[FilterType.title]
          .where((f) =>
              (f.type == FilterType.author || f.type == FilterType.title) &&
              f.selected)
          .toList(),
      ...filters[FilterType.genre].where((f) => f.selected).toList(),
      ...filters[FilterType.place]
          .where((f) => (f.type == FilterType.place) && f.selected)
          .toList(),
      ...filters[FilterType.language].where((f) => f.selected).toList(),
    ];
  }
}

class FilterCubit extends Cubit<FilterState> {
  FilterCubit() : super(FilterState()) {
    queryBooks();
  }

  double screenInKm() {
    return 156543.03392 *
        cos(state.center.latitude * pi / 180) /
        pow(2, state.zoom) *
        600.0 /
        1000;
  }

  double distanceBetween(LatLng p1, LatLng p2) {
    double lat1 = p1.latitude;
    double lon1 = p1.longitude;
    double lat2 = p2.latitude;
    double lon2 = p2.longitude;

    double R = 6378.137; // Radius of earth in KM
    double dLat = lat2 * pi / 180 - lat1 * pi / 180;
    double dLon = lon2 * pi / 180 - lon1 * pi / 180;
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) *
            cos(lat2 * pi / 180) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double d = R * c;
    return d; // Km
  }

  // Function to refresh stream with books and emit it
  void queryBooks({LatLng center, double zoom}) async {
    print('!!!DEBUG Query books ${state.center}');

    if (center == null) center = state.center;
    if (zoom == null) zoom = state.zoom;

    // Get a filters, map center and radius and query books
    // Emit state with updated stream
    GeoFirePoint point = Geoflutterfire()
        .point(latitude: center.latitude, longitude: center.longitude);

    // Kilometers fit to screen asuming screen width is 600px
    double radius = screenInKm();

    List<DocumentSnapshot> stream = await Geoflutterfire()
        .collection(
            collectionRef: FirebaseFirestore.instance.collection('books'))
        .within(center: point, radius: radius, field: 'location')
        .first;

    emit(state.copyWith(stream: stream, center: center, zoom: zoom));
  }

  // FILTER PANEL:
  // - Author/title filter changed => FILTER
  // - Places filter changed => FILTER (permission for Address Book if My Places)
  // - Language filter changed => FILTER
  // - Genre filter changed => FILTER
  void changeFilters(FilterType type, List<Filter> filter) {
    Map<FilterType, List<Filter>> filters = Map.from(state.filters);
    filters[type] = filter;
    emit(state.copyWith(
      filters: filters,
    ));

    queryBooks();
  }

  // FILTER PANEL:
  // - Author/title filter changed => FILTER
  // - Places filter changed => FILTER (permission for Address Book if My Places)
  // - Language filter changed => FILTER
  // - Genre filter changed => FILTER
  void toggleFilter(FilterType type, Filter filter) {
    Map<FilterType, List<Filter>> filters = Map.from(state.filters);
    filters[type][filters[type].indexOf(filter)] =
        filter.copyWith(selected: !filter.selected);
    emit(state.copyWith(
      filters: filters,
    ));

    queryBooks();
  }

  // FILTER PANEL:
  // - Filter panel opened => FILTER
  void panelOpened() {
    emit(state.copyWith(
      position: PanelPosition.open,
    ));
  }

  // FILTER PANEL:
  // - Filter panel minimized => FILTER
  void panelMinimized() {
    emit(state.copyWith(
      position: PanelPosition.minimized,
    ));
  }

  // FILTER PANEL:
  // - Filter panel closed => FILTER
  void panelHiden() {
    emit(state.copyWith(
      position: PanelPosition.hiden,
    ));
  }

  // TRIPLE BUTTON
  // - Map button pressed (selected) => FILTER
  void mapButtonPressed() {
    // TODO: Resenter and scale map based on location, filter values
    // and number of available books. Iterate via queries to find the
    // best scale
    emit(state.copyWith(
      center: state.center, // TODO: Replace with current location
      zoom: state.zoom, // TODO: Replace with calculated zoom
    ));

    queryBooks();
  }

  // TRIPLE BUTTON
  // - List button pressed (selected) => FILTER
  void listButtonPressed() {
    // TODO: Query books based on the filters. Several iteratiions might needed
    // to find the best radius
    emit(state.copyWith(
      center: state.center, // TODO: Replace with current location
      zoom: state.zoom, // TODO: Replace with calculated zoom
    ));

    queryBooks();
  }

  // TRIPLE BUTTON
  // - Set view => FILTER
  void setView(ViewType view) {
    emit(state.copyWith(
      view: view,
    ));
  }

  // MAP VIEW
  // - Map move => FILTER
  void mapMoved(CameraPosition position, LatLngBounds bounds) {
    // Recalculate geo-hashes from camera position and bounds
    GeoHasher gc = GeoHasher();
    String ne =
        gc.encode(bounds.northeast.longitude, bounds.northeast.latitude);
    String sw =
        gc.encode(bounds.southwest.longitude, bounds.southwest.latitude);
    String nw =
        gc.encode(bounds.southwest.longitude, bounds.northeast.latitude);
    String se =
        gc.encode(bounds.northeast.longitude, bounds.southwest.latitude);
    String center =
        gc.encode(position.target.longitude, position.target.latitude);

    // Find longest common starting substring for center and corners

    // TODO: If moved significantly emit state to have list of books refreshed
    // with the new center

    // Only emit if more than half of the screen is moved
    if (distanceBetween(state.center, position.target) > screenInKm() / 2.0) {
      print(
          '!!!DEBUG distance shifted ${distanceBetween(state.center, position.target)}');
      // Only refresh query if move is significant
      queryBooks(center: position.target, zoom: position.zoom);
    }
  }

  // MAP VIEW
  // - Tap on Marker => FILTER
  void markerPressed(Marker marker) {
    // TODO: Set filter for this marker and switch the view. If only one book in
    // the marker switch to Details. If many books switch to the list.
    Map<FilterType, List<Filter>> filters = Map.from(state.filters);
    // TODO: Get id of the place from the marker. For group markers set center
    // and radius instead of the place..
    filters[FilterType.place] = [
      Filter(type: FilterType.place, value: marker.markerId.value)
    ];

    emit(state.copyWith(
      center: marker.position,
      zoom: state.zoom, // TODO: Set zoom based on the calculated radius
      view: ViewType.list,
    ));

    queryBooks();
  }

  // DETAILS
  // - Search button pressed => FILTER
  void searchBookPressed(Book book) {
    // TODO: Check other filters and clean if necessary. For example location.
    // Use adaptive filtering to loose it step by step: increase radius and
    // search in all locations if no such books in the contacts.
    Map<FilterType, List<Filter>> filters = Map.from(state.filters);
    filters[FilterType.title] = filters[FilterType.title]
      ..addAll([
        Filter(type: FilterType.author, value: book.authors[0]),
        Filter(type: FilterType.title, value: book.title),
      ]);

    emit(state.copyWith(
      filters: filters,
    ));

    queryBooks();
  }
}
