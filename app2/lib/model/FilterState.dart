import 'dart:math';

import 'package:biblosphere/filter_bloc.dart';
import 'package:biblosphere/model/Book.dart';
import 'package:biblosphere/model/Filter.dart';
import 'package:biblosphere/model/MarkerData.dart';
import 'package:biblosphere/model/Panel.dart';
import 'package:biblosphere/model/Photo.dart';
import 'package:biblosphere/model/Place.dart';
import 'package:biblosphere/model/Point.dart';
import 'package:biblosphere/model/Privacy.dart';
import 'package:biblosphere/model/Shelf.dart';
import 'package:biblosphere/model/ViewType.dart';
import 'package:biblosphere/util/Enums.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code.dart';
import 'package:dart_geohash/dart_geohash.dart';
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:purchases_flutter/offerings_wrapper.dart';
import 'package:purchases_flutter/package_wrapper.dart';

class FilterState extends Equatable {
  // LOGIN STATE
  final LoginStatus status;
  final CountryCode country;
  final String phone;
  final String name;
  final String code;
  final String verification; // VereficationId from Firebase
  final Package package;
  final bool pp;
  final bool tos;
  final Offerings offerings;

  // USER STATE
  final List<String> bookmarks;
  final LatLng location;

  // FILTERS
  // Current filters
  final List<Filter> filters;

  // List of the ISBNs to filter the books
  final List<String> isbns;

  // Ids of places from my address book
  final List<String> favorite;

  // VIEW AND MAP
  // Current view (map, list, details, camera) and panel open/close position
  final ViewType view;

  // Position of search/camera panel
  final Panel panel;

  // Current filter froup for detailed filter (panel.full)
  final FilterGroup group;

  // Coordinates and bounds of the map camera
  final LatLng center;
  final LatLngBounds bounds;

  // Current geohashes on the map
  final Set<String> geohashes;

  // FILTERS SUGGESTIONS
  // Places for the markers
  // final List<Place> places;
  // List of photos for the list view
  // final List<Photo> photos;
  // Current markers for map view
  final List<MarkerData> markers;

  // Total number of shelves for current markers
  final int maxShelves;

  // List of shelves (photo + books)
  final List<Shelf> shelfList;

  // Current shelf to display
  final int shelfIndex;

  // Suggestions for the filter edit for filters (MAP/VIEW)
  final List<Filter> filterSuggestions;

  // Suggestions for the filter edit for places (CAMERA)
  final List<Place> placeSuggestions;

  // CAMERA STATE
  // Currently selected place (name, contact, privacy)
  final Place place;

  // Privacy for the photo
  final Privacy privacy;

  // List of nearby places or address book contacts to add books to
  final List<Place> candidates;

  @override
  List<Object> get props => [
        status,
        phone,
        name,
        verification,
        country,
        code,
        package,
        pp,
        tos,
        offerings,
        location,
        bookmarks,
        filters,
        isbns,
        favorite,
        panel,
        group,
        center,
        bounds,
        geohashes,
        view,
        markers,
        maxShelves,
        shelfList,
        shelfIndex,
        filterSuggestions,
        placeSuggestions,
        place,
        privacy,
        candidates
      ];

  static const List<Filter> empty = const [
    Filter(type: FilterType.wish, selected: false),
    Filter(type: FilterType.contacts, selected: false),
  ];

  const FilterState({
    this.status = LoginStatus.unknown,
    this.phone = '',
    this.name = '',
    this.country,
    this.verification,
    this.code = '',
    this.package,
    this.pp = false,
    this.tos = false,
    this.offerings,
    this.filters = empty,
    this.favorite,
    this.isbns = const [],
    this.panel = Panel.minimized,
    this.group,
    this.center = const LatLng(49.8397, 24.0297),
    this.bounds,
    this.geohashes = const {'u8c5d'},
    this.view = ViewType.map,
    this.markers,
    this.maxShelves,
    this.shelfList,
    this.shelfIndex,
    this.filterSuggestions = const [],
    this.placeSuggestions = const [],
    this.place,
    this.privacy = Privacy.all,
    this.candidates = const [],
    this.location,
    this.bookmarks,
  });

  FilterState copyWith({
    String phone,
    String name,
    CountryCode country,
    String code,
    String verification,
    LoginStatus status,
    Package package,
    bool pp,
    bool tos,
    Offerings offerings,
    List<Filter> filters,
    bool genreInput,
    bool languageInput,
    List<String> favorite,
    List<String> isbns,
    Panel panel,
    FilterGroup group,
    LatLng center,
    LatLngBoundsCallback bounds,
    ViewType view,
    Set<String> geohashes,
    List<MarkerData> markers,
    int maxShelves,
    List<Shelf> shelfList,
    int shelfIndex,
    List<Filter> filterSuggestions,
    List<Place> placeSuggestions,
    Place place,
    Privacy privacy,
    List<Place> candidates,
    LatLng location,
    List<String> bookmarks,
  }) {
    return FilterState(
      status: status ?? this.status,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      country: country ?? this.country,
      code: code ?? this.code,
      verification: verification ?? this.verification,
      package: package ?? this.package,
      pp: pp ?? this.pp,
      tos: tos ?? this.tos,
      offerings: offerings ?? this.offerings,
      filters: filters ?? this.filters,
      favorite: favorite ?? this.favorite,
      isbns: isbns ?? this.isbns,
      panel: panel ?? this.panel,
      group: group ?? this.group,
      center: center ?? this.center,
      bounds: bounds != null ? bounds() : this.bounds,
      view: view ?? this.view,
      geohashes: geohashes ?? this.geohashes,
      markers: markers ?? this.markers,
      maxShelves: maxShelves ?? this.maxShelves,
      shelfList: shelfList ?? this.shelfList,
      shelfIndex: shelfIndex ?? this.shelfIndex,
      filterSuggestions: filterSuggestions ?? this.filterSuggestions,
      placeSuggestions: placeSuggestions ?? this.placeSuggestions,
      place: place ?? this.place,
      privacy: privacy ?? this.privacy,
      candidates: candidates ?? this.candidates,
      location: location ?? this.location,
      bookmarks: bookmarks ?? this.bookmarks,
    );
  }

  String get mobile => country != null && phone != null && phone.isNotEmpty
      ? country.dialCode + phone
      : null;

  bool get loginAllowed =>
      pp && phone.isNotEmpty && name.isNotEmpty && country != null;

  bool get confirmAllowed => code.length >= 4;

  bool get subscriptionAllowed => tos && status == LoginStatus.signedIn;

  bool isUserBookmark(Book book) {
    return bookmarks != null && bookmarks.contains(book.isbn);
  }

  List<Filter> getFilters({FilterGroup group, FilterType type}) {
    assert(group != null || type != null,
        'Filter type or group has to be defined');
    if (group != null)
      return filters.where((f) => f.group == group).toList();
    else if (type != null) return filters.where((f) => f.type == type).toList();
    return [];
  }

  List<Filter> get compact {
    // Return all filters 3 or below
    if (filters.length == 2) return filters;

    List<Filter> selected = filters.where((f) => f.selected).toList();
    return selected;
  }

  QueryType get select {
    // For list view always select books
    if (view == ViewType.list)
      return QueryType.books;

    // For map view with precise query select books
    else if (view == ViewType.map &&
        (filters.any((f) =>
                f.type == FilterType.title || f.type == FilterType.author) ||
            // TODO: Change || to && once statistics are available in places and clusters
            filters.any((f) => f.type == FilterType.genre) ||
            filters.any((f) => f.type == FilterType.language) ||
            filters.any((f) => f.type == FilterType.wish && f.selected)))
      return QueryType.books;

    // Else select places
    else
      return QueryType.places;
  }

  // Return set of hashes for the current map view
  Set<String> hashesFor(LatLng position, LatLngBounds bounds) {
    GeoHasher gc = GeoHasher();
    String ne =
        gc.encode(bounds.northeast.longitude, bounds.northeast.latitude);
    String sw =
        gc.encode(bounds.southwest.longitude, bounds.southwest.latitude);
    String nw =
        gc.encode(bounds.southwest.longitude, bounds.northeast.latitude);
    String se =
        gc.encode(bounds.northeast.longitude, bounds.southwest.latitude);
    String center = gc.encode(position.longitude, position.latitude);

    // Find longest common starting substring for center and corners
    int level = max(max(lcp(center, ne), lcp(center, sw)),
            max(lcp(center, nw), lcp(center, se))) +
        1;

    String seed =
        gc.encode(position.longitude, position.latitude).substring(0, level);
    Set<String> inside = Set();
    Set<String> hashes = {seed};

    // Do not expand if highest level
    if (level <= 1) return hashes;

    Set<String> neighbors = gc.neighbors(seed).values.toSet();
    hashes.addAll(neighbors);
    int i = 0;

    do {
      // All neighbours which are inside the boundaries
      inside = neighbors.where((h) {
        List<double> c = gc.decode(h);
        return bounds.contains(LatLng(c[1], c[0]));
      }).toSet();
      // Find all new neighbors which are not in hashes yet
      neighbors = {};
      inside.forEach((i) {
        neighbors.addAll(gc.neighbors(seed).values.toSet().difference(hashes));
      });

      // Add all neigbours to the hashes
      hashes.addAll(neighbors);

      i++;
    } while (inside.length > 0 || i > 10);

    return hashes;
  }

  List<String> isbnsFor(List<Filter> filters) {
    List<String> isbns = [];

    if (filters.any((f) => f.type == FilterType.wish && f.selected)) {
      if (bookmarks != null) isbns.addAll(bookmarks);
      print('!!!DEBUG bookmarks [$bookmarks]');
    }

    filters.forEach((f) {
      if (f.type == FilterType.title && f?.book?.isbn != null)
        isbns.add(f?.book?.isbn);
    });

    return isbns;
  }

  Future<Set<Book>> booksFor(String geohash) async {
    String low = (geohash + '000000000').substring(0, 9);
    String high = (geohash + 'zzzzzzzzz').substring(0, 9);

    QuerySnapshot bookSnap;

    Query query;

    if (isbns == null || isbns.length == 0) {
      // Query by conditions
      query = FirebaseFirestore.instance
          .collection('books')
          .where('location.geohash', isGreaterThanOrEqualTo: low)
          .where('location.geohash', isLessThan: high);

      bool multiple = false;

      // Add author(s) to the query if present
      List<String> authors = filters
          .where((f) => f.type == FilterType.author)
          .map((a) => a.value)
          .toList();

      // Firestore only support up to 10 values in the list for the query
      if (authors.length > 10) {
        authors = authors.take(10).toList();
        print('EXCEPTION: more than 10 authors in a query');
        // TODO: Report an exception to analyse why it happens
      }

      if (authors.length > 1) {
        query = query.where('author', whereIn: authors);
        multiple = true;
      } else if (authors.length == 1) {
        query = query.where('author', isEqualTo: authors.first);
      }

      // Add place(s) to the query if present
      List<String> places = filters
          .where((f) => f.type == FilterType.place)
          .map((p) => p.place.id)
          .toList();

      // Firestore only support up to 10 values in the list for the query
      if (places.length > 10) {
        places = places.take(10).toList();
        print('EXCEPTION: more than 10 places in a query');
        // TODO: Report an exception to analyse why it happens
      }

      if (places.length > 1) {
        if (multiple) {
          print('EXCEPTION: Already multiple query. Places filters ignored.');
          // TODO: Report an exception
        } else {
          query = query.where('bookplace', whereIn: places);
          multiple = true;
        }
      } else if (places.length == 1) {
        query = query.where('bookplace', isEqualTo: places.first);
      }

      // Add genre(s) to the query if present
      List<String> genres = filters
          .where((f) => f.type == FilterType.genre)
          .map((g) => g.value)
          .toList();

      // Firestore only support up to 10 values in the list for the query
      if (genres.length > 10) {
        genres = genres.take(10).toList();
        print('EXCEPTION: more than 10 genres in a query');
        // TODO: Report an exception to analyse why it happens
      }

      if (genres.length > 1) {
        if (multiple) {
          print('EXCEPTION: Already multiple query. Genres filters ignored.');
          // TODO: Report an exception
        } else {
          query = query.where('genre', whereIn: genres);
          multiple = true;
        }
      } else if (genres.length == 1) {
        query = query.where('genre', isEqualTo: genres.first);
      }

      // Add genre(s) to the query if present
      List<String> langs = filters
          .where((f) => f.type == FilterType.language)
          .map((l) => l.value)
          .toList();

      // Firestore only support up to 10 values in the list for the query
      if (langs.length > 10) {
        langs = langs.take(10).toList();
        print('EXCEPTION: more than 10 languages in a query');
        // TODO: Report an exception to analyse why it happens
      }

      if (langs.length > 1) {
        if (multiple) {
          print(
              'EXCEPTION: Already multiple query. Languages filters ignored.');
          // TODO: Report an exception
        } else {
          query = query.where('language', whereIn: langs);
          multiple = true;
        }
      } else if (langs.length == 1) {
        query = query.where('language', isEqualTo: langs.first);
      }
    } else {
      print('!!!DEBUG Search by ISBNs $isbns');

      if (isbns.length > 10) {
        print('EXCEPTION: number of ISBNs in query more than 10.');
        // TODO: Report exception in analytic
      }

      // Query by list of books (ISBN)
      query = FirebaseFirestore.instance
          .collection('books')
          .where('isbn', whereIn: isbns.take(10).toList());
    }

    query = query.limit(100);

    bookSnap = await query.get();

    // Group all books for geohash areas one level down
    Set<Book> books =
        bookSnap.docs.map((doc) => Book.fromJson(doc.id, doc.data())).toSet();

    print('!!!DEBUG books before bounds ${books.length}');

    if (bounds != null) {
      print('!!!DEBUG filter books by bounds');
      books = books.where((b) => bounds.contains(b.location)).toSet();
    }

    print('!!!DEBUG: booksFor reads ${books.length} books');

    return books;
  }

  Future<List<Photo>> photosFor(String geohash) async {
    String low = (geohash + '000000000').substring(0, 9);
    String high = (geohash + 'zzzzzzzzz').substring(0, 9);

    QuerySnapshot photoSnap = await FirebaseFirestore.instance
        .collection('photos')
        .where('location.geohash', isGreaterThanOrEqualTo: low)
        .where('location.geohash', isLessThan: high)
        .limit(2000)
        .get();

    // Group all photos for geohash areas one level down
    List<Photo> photos = photoSnap.docs
        .map((doc) => Photo.fromJson(doc.id, doc.data()))
        .toList();

    print('!!!DEBUG: photosFor reads ${photos.length} photos');

    return photos;
  }

  // Group points (Books or Places) into clusters based on the geo-hash
  Future<List<MarkerData>> markersFor(
      {List<MarkerData> markers,
      Set<Point> points,
      LatLngBounds bounds,
      Set<String> hashes}) async {
    // Two levels down compare to hashes of the state
    int level = 9;
    points = Set<Point>.from(points);
    if (hashes != null && hashes.length > 0)
      level = min(hashes.first.length + 1, 9);

    // Add points from previous markers to the list
    if (markers != null)
      markers.forEach((m) {
        points.addAll(m.points);
      });

    // Refresh markers
    markers = [];

    if (points != null && points.length > 0) {
      // Group points which are visible on the screen based on geohashes
      // 2 level down

      if (bounds != null) {
        points = points.where((p) => bounds.contains(p.location)).toSet();
      }

      Map<String, List<Point>> clusters =
          groupBy(points, (p) => p.geohash.substring(0, level));

      await Future.forEach(clusters.keys, (key) async {
        List<Point> value = clusters[key];
        // Calculate position for the marker via average geo-hash code
        // for positions of individual books
        double lat = 0.0, lng = 0.0;
        value.forEach((p) {
          lat += p.location.latitude;
          lng += p.location.longitude;
        });

        lat /= value.length;
        lng /= value.length;

        int count = 0;
        if (value.first is Book)
          count = value.length;
        else
          value.forEach((p) {
            count += (p is Photo) ? p.count ?? 1 : 1;
          });

        Set<Place> places = value
            .where((p) => (p is Photo) && p.type == PlaceType.place)
            .map((p) => (p as Photo).place)
            .toSet();

        markers.add(MarkerData(
            geohash: key,
            position: LatLng(lat, lng),
            size: count,
            points: List<Point>.from(value),
            bounds: boundsFromPoints(value),
            places: places));
      });
    }

    return markers.toList();
  }
}
