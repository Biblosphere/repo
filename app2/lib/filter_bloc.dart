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
- Map change scale => FILTER 
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
  final ViewType view;

  @override
  List<Object> get props => [filters, position, center, zoom, view];

  const FilterState(
      {this.filters = const {
        FilterType.title: [Filter(type: FilterType.wish, selected: false)],
        FilterType.genre: [],
        FilterType.place: [Filter(type: FilterType.contacts, selected: false)],
        FilterType.language: [],
      },
      this.position = PanelPosition.minimized,
      this.center = const LatLng(37.42796133580664, -122.085749655962),
      this.zoom = 14.4746,
      this.view});

  FilterState copyWith(
      {Map<FilterType, List<Filter>> filters,
      PanelPosition position,
      LatLng center,
      double zoom,
      ViewType view}) {
    return FilterState(
      filters: filters ?? this.filters,
      position: position ?? this.position,
      center: center ?? this.center,
      zoom: zoom ?? this.zoom,
      view: view ?? this.view,
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
  FilterCubit() : super(FilterState());

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
  void mapMoved(LatLng center) {
    // TODO: If moved significantly emit state to have list of books refreshed
    // with the new center
    emit(state.copyWith(
      center: center,
    ));
  }

  // MAP VIEW
  // - Map change scale => FILTER
  void mapZoomed(double zoom) {
    // TODO: If zoomed significantly emit state to have list of books refreshed
    // with the new zoom
    emit(state.copyWith(
      zoom: zoom,
    ));
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
  }
}
