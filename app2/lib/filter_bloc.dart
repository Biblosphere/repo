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

enum FilterType { wish, title, author, contacts, place, genre, language }

enum FilterGroup { book, genre, language, place }

class Filter extends Equatable {
  final FilterType type;
  final String value;
  final Book book;
  final Place place;
  final bool selected;

  @override
  List<Object> get props => [type, value, selected];

  const Filter(
      {@required this.type, this.value, this.book, this.place, this.selected});

  FilterGroup get group {
    switch (type) {
      case FilterType.author:
      case FilterType.title:
      case FilterType.wish:
        return FilterGroup.book;

      case FilterType.genre:
        return FilterGroup.genre;

      case FilterType.language:
        return FilterGroup.language;

      case FilterType.place:
      case FilterType.contacts:
        return FilterGroup.place;
    }
    //TODO: report in the crashalytics
    return null;
  }

  Filter copyWith({
    FilterType type,
    String value,
    String book,
    bool selected,
  }) {
    return Filter(
      type: type ?? this.type,
      value: value ?? this.value,
      book: book ?? this.book,
      place: place ?? this.place,
      selected: selected ?? this.selected,
    );
  }
}

String up(String geohash) {
  int len = geohash.length;

  if (len >= 1) {
    int lastChar = geohash.codeUnitAt(len - 1);
    return geohash.substring(0, len - 1) + String.fromCharCode(lastChar + 1);
  } else {
    return geohash;
  }
}

class MarkerData extends Equatable {
  final String geohash;
  final LatLng position;
  final List<Book> books;

  MarkerData({this.geohash, this.position, this.books});

  @override
  List<Object> get props => [geohash, position];
}

enum Panel { hiden, minimized, open, full }

enum ViewType { map, camera, list, details }

class FilterState extends Equatable {
  // Current filters
  final List<Filter> filters;
  // List of the ISBNs to filter the books
  final List<String> isbns;
  // If input of genres and language allowed
  final bool genreInput;
  final bool languageInput;
  // Ids of places from my address book
  final List<String> favorite;

  // Current view (map, list, details, camera) and panel open/close position
  final ViewType view;
  // Position of search/camera panel
  final Panel panel;
  // Current filter froup for detailed filter (panel.full)
  final FilterGroup group;
  // Coordinates and zoom of the map camera
  final LatLng center;
  final double zoom;
  // Current geohashes on the map
  final Set<String> geohashes;

  // List of books for the list view
  final List<Book> books;
  // Currently selected book for details view
  final Book selected;
  // Corrent markers for map view
  final Map<String, Set<MarkerData>> markers;
  // Corrent markers for map view
  final List<Filter> suggestions;

  // Places near the current location
  final List<Place> places;

  @override
  List<Object> get props => [
        filters,
        isbns,
        genreInput,
        languageInput,
        favorite,
        panel,
        group,
        center,
        zoom,
        geohashes,
        view,
        books,
        selected,
        markers,
        suggestions,
        places
      ];

  const FilterState(
      {this.filters = const [
        Filter(type: FilterType.wish, selected: false),
        Filter(type: FilterType.contacts, selected: false),
      ],
      this.genreInput = true,
      this.languageInput = true,
      this.favorite,
      this.isbns = const [],
      this.panel = Panel.minimized,
      this.group,
      this.center = const LatLng(49.8397, 24.0297),
      this.zoom = 5.0,
      this.geohashes = const {'u8c5d'},
      this.view = ViewType.map,
      this.books,
      this.selected,
      this.markers,
      this.suggestions = const [],
      this.places});

  FilterState copyWith(
      {List<Filter> filters,
      bool genreInput,
      bool languageInput,
      List<String> favorite,
      List<String> isbns,
      Panel panel,
      FilterGroup group,
      LatLng center,
      double zoom,
      ViewType view,
      Set<String> geohashes,
      List<Book> books,
      Book selected,
      Map<String, Set<MarkerData>> markers,
      List<Filter> suggestions,
      List<Place> places}) {
    return FilterState(
      filters: filters ?? this.filters,
      genreInput: genreInput ?? this.genreInput,
      languageInput: languageInput ?? this.languageInput,
      favorite: favorite ?? this.favorite,
      isbns: isbns ?? this.isbns,
      panel: panel ?? this.panel,
      group: group ?? this.group,
      center: center ?? this.center,
      zoom: zoom ?? this.zoom,
      view: view ?? this.view,
      geohashes: geohashes ?? this.geohashes,
      books: books ?? this.books,
      selected: selected ?? this.selected,
      markers: markers ?? this.markers,
      suggestions: suggestions ?? this.suggestions,
      places: places ?? this.places,
    );
  }

  List<Filter> getFilters(FilterGroup group) {
    return filters.where((f) => f.group == group).toList();
  }

  List<Filter> get compact {
    // Return all filters 3 or below
    if (filters.length <= 3) return filters;

    List<Filter> selected = filters.where((f) => f.selected).toList();
    return selected;
  }

  Future<List<Book>> booksFor(String geohash) async {
    String low = (geohash + '000000000').substring(0, 9);
    String high = (geohash + 'zzzzzzzzz').substring(0, 9);

    QuerySnapshot bookSnap;

    if (isbns == null || isbns.length == 0) {
      bookSnap = await FirebaseFirestore.instance
          .collection('books')
          .where('location.geohash', isGreaterThanOrEqualTo: low)
          .where('location.geohash', isLessThan: high)
          .limit(2000)
          .get();
    } else {
      bookSnap = await FirebaseFirestore.instance
          .collection('books')
          .where('isbn', whereIn: isbns)
          .limit(2000)
          .get();
    }

    // Group all books for geohash areas one level down
    List<Book> books =
        bookSnap.docs.map((doc) => Book.fromJson(doc.id, doc.data())).toList();

    print('!!!DEBUG: booksFor reads ${books.length} books');

    return books;
  }

  Future<List<Place>> placesFor(String geohash) async {
    /*
    String geohash = GeoHasher()
        .encode(here.longitude, here.latitude)
        .substring(0, hashLevel);
    */

    String low = (geohash + '000000000').substring(0, 9);
    String high = (geohash + 'zzzzzzzzz').substring(0, 9);

    QuerySnapshot placeSnap = await FirebaseFirestore.instance
        .collection('bookplaces')
        .where('location.geohash', isGreaterThanOrEqualTo: low)
        .where('location.geohash', isLessThan: high)
        .limit(2000)
        .get();

    // Group all books for geohash areas one level down
    List<Place> places = placeSnap.docs
        .map((doc) => Place.fromJson(doc.id, doc.data()))
        .toList();

    print('!!!DEBUG: placesFor reads ${places.length} books');

    return places;
  }

  Future<Set<MarkerData>> markersFor(String geohash, List<Book> books) async {
    int level = min(geohash.length + 2, 9);

    Set<MarkerData> markers = Set();

    if (books != null && books.length > 0) {
      // Group all books for geohash areas one level down
      Map<String, List<Book>> booktree =
          groupBy(books, (book) => book.geohash.substring(0, level));

      await Future.forEach(booktree.keys, (key) async {
        List<Book> value = booktree[key];
        // Calculate position for the marker via average geo-hash code
        // for positions of individual books
        double lat = 0.0, lng = 0.0;
        value.forEach((b) {
          lat += b.location.latitude;
          lng += b.location.longitude;
        });

        lat /= value.length;
        lng /= value.length;

        markers.add(
            MarkerData(geohash: key, position: LatLng(lat, lng), books: value));
      });
    }

    print('!!!DEBUG markersFor: ${markers.length}');

    return markers;
  }
}

// Return length of longest common prefix
int lcp(String s1, String s2) {
  for (int i = 0; i <= min(s1.length, s2.length); i++)
    if (s1.codeUnitAt(i) != s2.codeUnitAt(i)) return i;
  return min(s1.length, s2.length);
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
  return d * 1000; // Meters
}

String distanceString(LatLng p1, LatLng p2) {
  double d = distanceBetween(p1, p2);
  return d < 1000
      ? d.toStringAsFixed(0) + " m"
      : (d / 1000).toStringAsFixed(0) + " km";
}

class FilterCubit extends Cubit<FilterState> {
  GoogleMapController _mapController;
  SnappingSheetController _snappingControler;
  TextEditingController _searchController;

  FilterCubit() : super(FilterState()) {
    List<Book> books = [];
    List<Place> places = [];
    Map<String, Set<MarkerData>> markers = {};
    Future.forEach(state.geohashes, (hash) async {
      books.addAll(await state.booksFor(hash));
      places.addAll(await state.placesFor(hash));
      markers[hash] = await state.markersFor(hash, books);
    }).then((value) {
      emit(state.copyWith(
        books: books,
        places: places,
        markers: markers,
        view: ViewType.map,
      ));
    });
  }

  @override
  Future<void> close() async {
    _searchController.removeListener(_onSearchChanged);
    super.close();
  }

  double screenInKm() {
    return 156543.03392 *
        cos(state.center.latitude * pi / 180) /
        pow(2, state.zoom) *
        600.0 /
        1000;
  }

  List<Filter> toggle(List<Filter> filters, FilterType type, bool selected) {
    return filters.map((f) {
      if (f.type == type)
        return f.copyWith(selected: selected);
      else
        return f;
    }).toList();
  }

  Future<List<Filter>> findTitleSugestions(String query) async {
    if (query.length < 4) return const <Filter>[];

    var lowercase = query.toLowerCase();

    List<Book> books = await searchByText(lowercase);

    // TODO: Check it for long query in case widget are not mounted already

    // If no books returned return empty list
    if (books == null) return const <Filter>[];

    print('!!!DEBUG: Catalog query return ${books?.length} records');

    // If author match use FilterType.author, otherwise FilterType.title
    return books
        //  .where((b) =>
        //      b.title.toLowerCase().contains(lowercase) ||
        //      b.authors.join().toLowerCase().contains(lowercase))
        .map((b) {
          String matchAuthor = b.authors.firstWhere(
              (a) => lowercase
                  .split(' ')
                  .every((word) => a.toLowerCase().contains(word)),
              orElse: () => null);

          if (matchAuthor != null)
            return Filter(
                type: FilterType.author, selected: false, value: matchAuthor);
          else
            return Filter(
                type: FilterType.title,
                selected: false,
                value: b.title,
                book: b);
        })
        .toSet()
        .toList();
  }

  static List<Filter> findGenreSugestions(String query) {
    List<String> keys;

    if (query.length == 0) {
      keys = genres.keys.take(15).toList();
    } else {
      keys = genres.keys
          .where(
              (key) => genres[key].toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    return keys
        .map((key) =>
            Filter(type: FilterType.genre, selected: false, value: key))
        .toList(growable: false);
  }

  Future<List<Filter>> findPlaceSugestions(String query) async {
    // TODO: If access to address book is allowed (contacts is not null)
    //       add all contacts to the list with it's distance.

    // Query bookplaces in a radius of 5 km (same hash length 5) to current
    // location. Sort it by distance ascending (closest places first).

    // TODO: Take care about locations near equator and 0/180 longitude.
    List<Place> places = state.places;

    // Query places if it's empty
    // TODO: Make a procedure for that
    if (places == null || places.length == 0) {
      places = [];
      await Future.forEach(state.geohashes, (hash) async {
        places.addAll(await state.placesFor(hash));
      });

      places.sort((a, b) => (distanceBetween(a.location, state.center) -
              distanceBetween(b.location, state.center))
          .round());

      emit(state.copyWith(places: places));
    }

    if (query.length == 0) {
      print('!!!DEBUG length 0');
      places = places.take(15).toList();
    } else if (query.length > 0) {
      places = places.where((p) {
        return p.name.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }

    // No need to sort as places already sorted by distance
    return places
        .map((p) => Filter(
            type: FilterType.place, value: p.name, selected: false, place: p))
        .toList(growable: false);
  }

  static List<Filter> findLanguageSugestions(String query) {
    List<String> keys;

    if (query.length == 0) {
      keys = mainLanguages.toList();
    } else {
      keys = languages.keys
          .where((key) =>
              key.toLowerCase().contains(query.toLowerCase()) ||
              languages[key].toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    return keys
        .map((key) =>
            Filter(type: FilterType.language, selected: false, value: key))
        .toList(growable: false);
  }

  Future<List<Filter>> findSugestions(String query, FilterGroup group) async {
    if (group == FilterGroup.book)
      return findTitleSugestions(query);
    else if (group == FilterGroup.genre)
      return findGenreSugestions(query);
    else if (group == FilterGroup.place)
      return findPlaceSugestions(query);
    else if (group == FilterGroup.language)
      return findLanguageSugestions(query);
    else
      return [];
  }

  Future<void> scanContacts() async {
    // Get all contacts on device
    Iterable<Contact> addressBook = await ContactsService.getContacts();

    print('!!!DEBUG ${addressBook.length} contacts found');

    List<String> all = [];
    List<String> places = [];

    // Search each contact in Biblosphere
    await Future.forEach(addressBook, (c) async {
      // Get all contacts (phones/emails) for the person
      List<String> contacts = [
        ...c.phones.map((p) => p.value),
        ...c.emails.map((e) => e.value)
      ];

      // Look for the book places with these contacts
      // TODO: Only first 10 contacts for the same person are taken
      QuerySnapshot placeSnap = await FirebaseFirestore.instance
          .collection('bookplaces')
          .where('contacts', arrayContainsAny: contacts.take(10).toList())
          .get();

      // If places are found link it in both direction: from user
      // to place and from place to user
      if (placeSnap.docs.length > 0) {
        // List of book places ids
        List<String> ids = placeSnap.docs.map((d) => d.id).toList();

        // Add to places of this user
        places.addAll(ids);

        // Update link from the place to the user
        // Add current user to found bookplaces
        await Future.forEach(ids, (id) async {
          await FirebaseFirestore.instance
              .collection('bookplaces')
              .doc(id)
              .update({
            'users':
                FieldValue.arrayUnion([FirebaseAuth.instance.currentUser.uid])
          });
        });
      }

      // Extend list of all contacts
      all.addAll(contacts);
    });

    // Update user record if any information are there
    Map<String, dynamic> data = {};
    if (all.length > 0) data['contacts'] = FieldValue.arrayUnion(all);

    if (places.length > 0) data['places'] = FieldValue.arrayUnion(places);

    // Update found contacts to the user record
    if (data.length > 0)
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser.uid)
          .update(data);

    // TODO: Inform user with snackbar if new users found from address book

    // Emit state with updated places if any
    if (places.length > 0)
      emit(state.copyWith(
        favorite: places,
      ));
  }

  // FILTER PANEL:
  // - Author/title filter changed => FILTER
  // - Places filter changed => FILTER (permission for Address Book if My Places)
  // - Language filter changed => FILTER
  // - Genre filter changed => FILTER
  void deleteFilter(Filter filter) async {
    // Block removing wish filter and contacts filter
    List<Filter> filters = state.filters;

    // Do not remove WISH and CONTACT. Just unselect.
    if (filter.type == FilterType.wish || filter.type == FilterType.contacts) {
      filters = toggle(filters, FilterType.wish, false);
    } else {
      filters = filters.where((f) => f != filter).toList();
    }

    emit(state.copyWith(filters: filters));
  }

  // FILTER PANEL:
  // - Author/title filter changed => FILTER
  // - Places filter changed => FILTER (permission for Address Book if My Places)
  // - Language filter changed => FILTER
  // - Genre filter changed => FILTER
  void addFilter(Filter filter) async {
    List<Filter> filters = state.filters;

    // Do nothing if filter already there
    if (filters.contains(filter)) return;

    if (filter.type == FilterType.title) {
      // If title filter add unselect wish filter
      filters = toggle(filters, FilterType.wish, false);
      // If title filter add drop genres filters
      filters = filters.where((f) => f.type != FilterType.genre).toList();
    } else if (filter.type == FilterType.place) {
      // If place filter add unselect contacts filter
      filters = toggle(filters, FilterType.contacts, false);
    } else if (filter.type == FilterType.genre) {
      // If genre filter add drop title filters
      filters = filters.where((f) => f.type != FilterType.title).toList();
    } else if (filter.type == FilterType.author &&
        filters.any((f) => f.type == FilterType.author)) {
      // If more than 1 author drop genres filters if more than 1 value
      if (filters.where((f) => f.type == FilterType.genre).length > 1)
        filters = filters.where((f) => f.type != FilterType.genre).toList();

      // If more than 1 author drop language filters if more than 1 value
      if (filters.where((f) => f.type == FilterType.language).length > 1)
        filters = filters.where((f) => f.type != FilterType.language).toList();
    }

    // Remove this filter from suggestions
    List<Filter> suggestions = state.suggestions
        .where((f) => f.type != filter.type || f.value != filter.value)
        .toList();

    filters = [...filters, filter]
      ..sort((a, b) => a.type.index.compareTo(b.type.index));

    emit(state.copyWith(filters: filters, suggestions: suggestions));
  }

  // FILTER PANEL:
  // - Author/title filter changed => FILTER
  // - Places filter changed => FILTER (permission for Address Book if My Places)
  // - Language filter changed => FILTER
  // - Genre filter changed => FILTER
  void toggleFilter(FilterType type, Filter filter) async {
    print('!!!DEBUG Toggle filter ${filter.type}');

    // Only toggle wish and contacts filter
    if (filter.type != FilterType.contacts && filter.type != FilterType.wish)
      return;

    // If contacts filter selected we have to check/request contacts permission
    if (filter.type == FilterType.contacts && !filter.selected) {
      if (!await Permission.contacts.isGranted) {
        // Initiate contacts for a first time then permission is granted
        if (await Permission.contacts.request().isGranted) {
          print('!!!DEBUG CONTACTS permission granted for a first time');
          // Async procedure, no wait
          scanContacts();
        } else {
          // Return without toggle if contacts permission is not granted
          return;
        }
      }
      // Either the permission was already granted before or the user just granted it.
      print('!!!DEBUG CONTACTS permission checked');
    }

    List<Filter> filters = state.filters;

    // Drop all places filters if contacts is selected
    if (filter.type == FilterType.contacts && !filter.selected)
      filters = filters.where((f) => f.type != FilterType.place).toList();

    // Drop all title filters if wish is selected
    if (filter.type == FilterType.wish && !filter.selected)
      filters = filters.where((f) => f.type != FilterType.title).toList();

    filters = toggle(filters, filter.type, !filter.selected);

    emit(state.copyWith(
      filters: filters,
    ));
  }

  // FILTER PANEL:
  // - Button with group icon or tap on group line to edit details
  void searchEditComplete() async {
    _searchController.text = '';
    _snappingControler.snapToPosition(_snappingControler.snapPositions.last);
  }

  // FILTER PANEL:
  // - Button with group icon or tap on group line to edit details
  void groupSelectedForSearch(FilterGroup group) async {
    _searchController.text = '';
    _snappingControler.snapToPosition(
      SnapPosition(
          positionPixel: 280.0,
          snappingCurve: Curves.elasticOut,
          snappingDuration: Duration(milliseconds: 750)),
    );
    emit(state.copyWith(group: group, panel: Panel.full));

    List<Filter> suggestions = await findSugestions('', group);
    emit(state.copyWith(suggestions: suggestions));
  }

  // FILTER PANEL:
  // - Filter panel opened => FILTER
  void panelOpened() async {
    print('!!!DEBUG PANEL OPEN');

    // TODO: Load near by book places and keep it in the state object
    emit(state.copyWith(
      panel: Panel.open,
    ));
  }

  // FILTER PANEL:
  // - Filter panel minimized => FILTER
  void panelMinimized() {
    print('!!!DEBUG PANEL MINIMIZED');
    emit(state.copyWith(
      panel: Panel.minimized,
    ));
  }

  // FILTER PANEL:
  // - Filter panel closed => FILTER
  void panelHiden() {
    print('!!!DEBUG PANEL HIDDEN');
    emit(state.copyWith(
      panel: Panel.hiden,
    ));
  }

  // TRIPLE BUTTON
  // - Map button pressed (selected) => FILTER
  void mapButtonPressed() async {
    Position loc = await Geolocator.getCurrentPosition();

    print('!!!DEBUG New location ${LatLng(loc.latitude, loc.longitude)}');

    // TODO: Calculate zoom based on the book availability at a location

    if (_mapController != null)
//      _controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
//          target: LatLng(loc.latitude, loc.longitude), zoom: 10.0)));

      _mapController.moveCamera(
          CameraUpdate.newLatLng(LatLng(loc.latitude, loc.longitude)));

    // TODO: Check if zoom reset is a good thing. Do we need to
    //       auto-calculate zoom to always contain some book search results.

    // TODO: query books/places based on new location and current filters
  }

  // TRIPLE BUTTON
  // - List button pressed (selected) => FILTER
  void listButtonPressed() {
    // TODO: Which function is appropriate for list view button?
  }

  // TRIPLE BUTTON
  // - Set view => FILTER
  void setView(ViewType view) {
    if (view == ViewType.list) {
      // Sort books based on a distance to the center of the Map screen
      // List<Book> books = state.books;

      // Restore books from visible markers (otherwise cut by clicking on marker)
      List<Book> books = state.markers.values
          .expand((e1) => e1.expand((e2) => e2.books))
          .toList();

      books.sort((a, b) => (distanceBetween(a.location, state.center) -
              distanceBetween(b.location, state.center))
          .round());

      print('!!!DEBUG books sorted around ${state.center}');

      emit(state.copyWith(
        books: books,
        view: ViewType.list,
      ));
    } else {
      emit(state.copyWith(
        view: view,
      ));
    }
  }

  // MAP VIEW
  // - Set controller
  void setMapController(GoogleMapController controller) {
    _mapController = controller;
  }

  // MAP VIEW
  // - Set controller
  void setSnappingController(SnappingSheetController controller) {
    _snappingControler = controller;
  }

  // Function to identify that typing is other. To minimize number
  // of queries to DB
  Timer _debounce;
  int _debouncetime = 500;

  _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(Duration(milliseconds: _debouncetime), () async {
      if (_searchController.text != "") {
        // Perform your search only if typing is over
        print('!!!DEBUG text from search field: ${_searchController.text}');
        List<Filter> suggestions =
            await findSugestions(_searchController.text, state.group);

        emit(state.copyWith(suggestions: suggestions));
      }
    });
  }

  // MAP VIEW
  // - Set controller
  void setSearchController(TextEditingController controller) {
    if (_searchController == null) {
      _searchController = controller;
      _searchController.addListener(_onSearchChanged);
    }
  }

  // MAP VIEW
  // - Map move => FILTER
  void mapMoved(CameraPosition position, LatLngBounds bounds) async {
    print('!!!DEBUG mapMoved: starting hashes ${state.geohashes.join(',')}');

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
    String center = position != null
        ? gc.encode(position.target.longitude, position.target.latitude)
        : gc.encode(state.center.longitude, state.center.latitude);

    // Find longest common starting substring for center and corners
    int level = max(max(lcp(center, ne), lcp(center, sw)),
        max(lcp(center, nw), lcp(center, se)));

    Set<String> hashes = [
      ne.substring(0, level),
      sw.substring(0, level),
      nw.substring(0, level),
      se.substring(0, level)
    ].toSet();

    print('!!!DEBUG mapMoved: new hashes ${hashes.join(',')}');

    // Old level of geo hashes
    int oldLevel = state.geohashes.first.length;

    // Do nothing if all new geo-hashes already present in the state
    // Reset target if it's not null
    if (oldLevel == level && state.geohashes.containsAll(hashes)) return;

    List<Book> books = state.books;
    List<Place> places = state.places;

    // Only list hashes which are of higher level or not included in current
    // set of hashes and not a sub-hashes.
    Set<String> toAddBooks = hashes
        .where((hash) =>
            hash.length < oldLevel ||
            !state.geohashes.contains(hash.substring(0, oldLevel)))
        .toSet();

    // Remove books which are out of the hash areas
    if (books != null) {
      books.removeWhere((b) => !hashes.contains(b.geohash.substring(0, level)));
    } else {
      print('!!!DEBUG books is NULL');
      books = [];
    }

    if (places != null) {
      places
          .removeWhere((p) => !hashes.contains(p.geohash.substring(0, level)));
    } else {
      print('!!!DEBUG books is NULL');
      places = [];
    }

    // Add books only for missing areas
    await Future.forEach(toAddBooks, (hash) async {
      books.addAll(await state.booksFor(hash));
      places.addAll(await state.placesFor(hash));
    });

    // Remove duplicates (Duplicates appeared on zoom-out)
    books = books.toSet().toList();

    // Remove duplicates (Duplicates appeared on zoom-out)
    places = places.toSet().toList();

    Map<String, Set<MarkerData>> markers = state.markers;
    // Remove markers clusters. If same level remove hiden, otherwise all.
    if (level == oldLevel)
      markers.removeWhere((key, value) => !hashes.contains(key));
    else
      markers.clear();

    Set<String> toAddMarkers = hashes.difference(state.geohashes);

    // Add markers for extra geo-hashes
    await Future.forEach(toAddMarkers, (hash) async {
      markers[hash] = await state.markersFor(hash, books);
    });

    // !!!DEBUG
    markers.forEach((key, value) {
      print('!!!DEBUG $key: ${value.length} markers');
    });

    // Sort books
    books.sort((a, b) => (distanceBetween(a.location, state.center) -
            distanceBetween(b.location, state.center))
        .round());
    // Emit state with updated markers

    places.sort((a, b) => (distanceBetween(a.location, state.center) -
            distanceBetween(b.location, state.center))
        .round());

    // Refresh suggestions if map moved once detailed place filters are open
    if (state.panel == Panel.full && state.group == FilterGroup.place) {
      List<Filter> suggestions = await findSugestions('', state.group);
      emit(state.copyWith(
          center: position != null ? position.target : state.center,
          zoom: position != null ? position.zoom : state.zoom,
          geohashes: hashes,
          books: books,
          places: places,
          suggestions: suggestions,
          markers: markers));
    } else {
      emit(state.copyWith(
          center: position != null ? position.target : state.center,
          zoom: position != null ? position.zoom : state.zoom,
          geohashes: hashes,
          books: books,
          places: places,
          markers: markers));
    }
  }

  // MAP VIEW
  // - Tap on Marker => FILTER
  void markerPressed(MarkerData marker) {
    print('!!!DEBUG Marker pressed ${marker.position}');
    if (marker.books.length == 1) {
      // Open detailes screen if marker is for one book
      emit(state.copyWith(
        selected: marker.books.first,
        view: ViewType.details,
        center: marker.position,
      ));
    } else if (marker.books.length > 1) {
      List<Book> books = marker.books;
      books.sort((a, b) => (distanceBetween(a.location, marker.position) -
              distanceBetween(b.location, marker.position))
          .round());
      // Zoom in if marker has too many books
      emit(state.copyWith(
        books: books,
        view: ViewType.list,
        center: marker.position,
      ));
    }

    // TODO: If group marker contains too many books zoom-in map
    //       instead of opening list view.
  }

  // DETAILS
  // - Search button pressed => FILTER
  void searchBookPressed(Book book) async {
    // NOT WORKING NOW!!!!!!!!!!!!!!!

    // TODO: Set filter for given book, so only this book is displayed
    //       probably zoom out to contains more copies of this book.

    List<Book> books;
    Map<String, Set<MarkerData>> markers;
    await Future.forEach(state.geohashes, (hash) async {
      books.addAll(await state.booksFor(hash));
      // TODO: Add places as well???
      markers[hash] = await state.markersFor(hash, books);
    });

    emit(state.copyWith(
      books: books,
      markers: markers,
      view: ViewType.map,
    ));
  }
}
