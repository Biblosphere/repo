import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:biblosphere/model/Book.dart';
import 'package:biblosphere/model/Filter.dart';
import 'package:biblosphere/model/FilterState.dart';
import 'package:biblosphere/model/MarkerData.dart';
import 'package:biblosphere/model/Panel.dart';
import 'package:biblosphere/model/Photo.dart' as Photo;
import 'package:biblosphere/model/Place.dart';
import 'package:biblosphere/model/Point.dart';
import 'package:biblosphere/model/Privacy.dart';
import 'package:biblosphere/model/Shelf.dart';
import 'package:biblosphere/model/ViewType.dart';
import 'package:biblosphere/repository/books_repository.dart';
import 'package:biblosphere/secret.dart';
import 'package:biblosphere/util/Consts.dart';
import 'package:biblosphere/util/Enums.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';

// Pick a git phone code
import 'package:country_code_picker/country_code_picker.dart';
import 'package:cubit/cubit.dart';
import 'package:dart_geohash/dart_geohash.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

// BLoC patterns
import 'package:geolocator/geolocator.dart';

// Google map
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
import 'package:permission_handler/permission_handler.dart';

// Plugin for subscriptions
import 'package:purchases_flutter/purchases_flutter.dart';

// Panel widget for filters and camera
import 'package:snapping_sheet/snapping_sheet.dart';

class FilterCubit extends Cubit<FilterState> {
  BooksRepository _booksRepository;

  GoogleMapController _mapController;
  SnappingSheetController _snappingControler;
  TextEditingController _searchController;

  // ScrollController _scrollController;
  GooglePlace googlePlace = GooglePlace(GooglePlaceKey);

  FilterCubit() : super(FilterState()) {
    _booksRepository = BooksRepository();

    // Initialize FireBase
    init();
  }

  @override
  Future<void> close() async {
    _searchController.removeListener(_onSearchChanged);
    super.close();
  }

  Future<LatLng> currentLatLng() async {
    Position pos = await Geolocator.getCurrentPosition();
    return LatLng(pos.latitude, pos.longitude);
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

    List<Book> books = await _booksRepository.searchByText(lowercase);

    // TODO: Check it for long query in case widget are not mounted already

    // If no books returned return empty list
    if (books == null) return const <Filter>[];

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

    // TODO: Performance profiling for below code
    Set<Place> placesSet;

    state.markers.forEach((m) {
      if (m.places != null) placesSet.addAll(m.places);
    });

    List<Place> places = placesSet.toList();

    places.sort((a, b) => (distanceBetween(a.location, state.center) -
            distanceBetween(b.location, state.center))
        .round());

    if (query.length == 0) {
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

  List<Filter> findLanguageSugestions(String query) {
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

    List<String> selectedLaguages = state
        .getFilters(type: FilterType.language)
        .map((f) => f.value)
        .toList();

    // Remove languages which are already selected
    if (selectedLaguages.length > 0)
      keys = keys.where((k) => !selectedLaguages.contains(k)).toList();

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

  // Emit state with the filters on Deep link
  Future<void> processDeepLink(Uri deepLink) async {
    if (deepLink.path == "/book") {
      String isbn = deepLink.queryParameters['isbn'];
      String title = deepLink.queryParameters['title'];

      if (isbn == null || isbn.isEmpty || title == null || title.isEmpty) {
        print('EXCEPTION: Isbn or Title is empty in a deep link');
        // TODO: Report an exception
      } else {
        // Search all books with this ISBN and show on map
        searchAndShowBook(book: Book(isbn: isbn, title: title));
      }
    } else if (deepLink.path == "/photo") {
      String id = deepLink.queryParameters['id'];
      //String name = deepLink.queryParameters['name'];

      print('!!!DEBUG deep link parameters ${deepLink.path}');
      print('!!!DEBUG deep link parameters ${deepLink.queryParameters}');

      if (id == null || id.isEmpty) {
        print('EXCEPTION: Id or Title is empty in a deep link');
        // TODO: Report an exception
      } else {
        DocumentSnapshot doc =
            await FirebaseFirestore.instance.collection('photos').doc(id).get();

        if (!doc.exists) {
          // TODO: Report an exception
          print('EXCEPTION: No photo for deep link id = $id');
        } else {
          // Search all books with this ISBN and show on map
          getAndShowPhoto(photo: Photo.Photo.fromJson(doc.id, doc.data()));
        }
      }
    }
  }

  void emitInitial() async {
    print('!!!DEBUG emitInitial before emit!');

    // Confirm that user is subscribed
    emit(state.copyWith(
      status: LoginStatus.subscribed,
      view: ViewType.map,
    ));

    print('!!!DEBUG before setting link callback!');

    // Set a call back for the deep link
    // TODO: Do I need to cancel/unsubscribe from onLink listener?
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) {
      return Future.delayed(Duration.zero, () async {
        final Uri deepLink = dynamicLink?.link;

        if (deepLink != null) {
          await processDeepLink(deepLink);
        } else {
          print('EXCEPTION: Empty deep link');
          // TODO: Report into crashalytic
        }
      });
    }, onError: (OnLinkErrorException e) {
      return Future.delayed(Duration.zero, () {
        // TODO: Add to Crashalitics
        print('EXCEPTION: onLinkError ${e.message}');
      });
    });

    print('!!!DEBUG before geting deep link!');

    // Check if app is started by dynamic link
    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();

    final Uri deepLink = data?.link;
    if (deepLink != null) {
      print('!!!DEBUG deep link is there $deepLink!');
      processDeepLink(deepLink);
    } else {
      print('!!!DEBUG going to check a permission!');
      // Check the location permission
      if (!await Permission.locationWhenInUse.isGranted) {
        // Initiate contacts for a first time then permission is granted
        if (await Permission.locationWhenInUse.request().isGranted) {
          print('!!!DEBUG Location permission requested and granted');
        } else {
          // TODO: What to do without location
          print('!!!DEBUG Location permission requested and denied');
          return;
        }
      }

      print('!!!DEBUG going to get current location!');

      // Get current location and initial markers
      LatLng center = await currentLatLng();

      print('!!!DEBUG after getting current location!');

      Set<Photo.Photo> photos = Set();

      // Get geohash of the current location and neighbours ~ 60 km
      String geohash = GeoHasher().encode(center.longitude, center.latitude);

      Map<String, String> neighbors =
          GeoHasher().neighbors(geohash.substring(0, 4));

      Set<String> geohashes = [geohash, ...neighbors.values].toSet();

      await Future.forEach(geohashes, (hash) async {
        photos.addAll(await state.photosFor(hash));
      });

      List<MarkerData> markers =
          await state.markersFor(points: photos, hashes: geohashes);

      emit(state.copyWith(
        geohashes: geohashes,
        location: center,
        center: center,
        markers: markers,
      ));

      // Move map if map view controller is available
      if (_mapController != null)
        _mapController.moveCamera(CameraUpdate.newLatLng(center));
    }
  }

  // LOGIN SCREENS
  Future<void> init() async {
    FirebaseAuth.instance.authStateChanges().listen((User user) async {
      if (user == null) {
        print('!!!DEBUG Login USER IS NULL');
        emit(state.copyWith(status: LoginStatus.unauthorized));
      } else {
        print('!!!DEBUG Login user $user');
        // Update user name in the Firebase profile
        if (state.name != null && state.name.isNotEmpty) {
          await user.updateProfile(displayName: state.name);
          await user.reload();
        }

        // To be sure that displayName is loaded
        await user.reload();

        // Check if user exist in Firestore. Create if missing. Add to state.
        DocumentReference ref =
            FirebaseFirestore.instance.collection('users').doc(user.uid);

        DocumentSnapshot doc = await ref.get();

        print('!!!DEBUG User ${user.uid} exist=${doc.exists}');

        if (doc.exists && doc.data().containsKey('bookmarks')) {
          emit(state.copyWith(
              bookmarks: List<String>.from(doc.data()['bookmarks'])));

          print('!!!DEBUG [${doc.data()['bookmarks']}] [${state.bookmarks}]');
        }

/*
        AppUser currentUser;
        if (doc.exists) {
          currentUser = AppUser.fromJson(doc.id, doc.data());
        } else {
          currentUser = AppUser(
              id: user.uid, name: user.displayName, mobile: state.mobile);
          ref.set(currentUser.toJson());
        }
*/
        // !!!DEBUG FOR IOS TESTING (Does not support Purchase on Simulator)
        // Uncomment following lines to test on IPhone simulator
        // emitInitial();
        // return;

        try {
          // Register user in Purchases
          print('!!!DEBUG User Id ${user.uid}');
          PurchaserInfo purchaser = await Purchases.identify(user.uid);

          // Check if user already subscribed and skip the purchase screen
          if (purchaser?.entitlements?.all["basic"]?.isActive ?? false) {
            emitInitial();
            return;
          }

          // Retrieve offerings
          Offerings offerings = await Purchases.getOfferings();

          if (offerings == null || offerings.current == null)
            throw Exception('Offerings are missing $offerings');

          // Add listener for the successful purchase
          Purchases.addPurchaserInfoUpdateListener((info) async {
            if (info.entitlements.all["basic"].isActive) {
              emitInitial();
            } else {
              emit(state.copyWith(status: LoginStatus.unauthorized));
            }
          });

          // Inform UI to show subscription screen with offerings
          emit(state.copyWith(
              status: LoginStatus.signedIn,
              offerings: offerings,
              package: offerings.current.monthly));
        } catch (e, stack) {
          print('EXCEPTION: Purchases exception: $e $stack');
          // TODO: Inform about failed sugn-in
          // TODO: Logg in crashalytic
          emit(state.copyWith(status: LoginStatus.unauthorized));
        }
      }
    });

    // UserCredential userCredential =
    // await FirebaseAuth.instance.signOut();
    // await FirebaseAuth.instance.signInAnonymously();
  }

  // Enter country code => LOGIN
  void countryCodeEntered(CountryCode value) {
    emit(state.copyWith(
      country: value,
    ));
  }

  // Enter phone => LOGIN
  void phoneEntered(String value) {
    emit(state.copyWith(
      phone: value,
    ));
  }

  // Enter name => LOGIN
  void nameEntered(String value) {
    emit(state.copyWith(
      name: value,
    ));
  }

  // Check/Uncheck PP => LOGIN
  void privacyPolicyEntered(bool value) {
    emit(state.copyWith(
      pp: value,
    ));
  }

  // Press Login button => LOGIN
  void signinPressed() {
    FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: state.mobile,
        timeout: Duration(seconds: 60),
        verificationCompleted: (AuthCredential authCredential) {
          FirebaseAuth.instance
              .signInWithCredential(authCredential)
              .catchError((e) {
            print('EXCEPTION on signin: $e');
            // TODO: Keep in crashalitics
            emit(state.copyWith(
              status: LoginStatus.unauthorized,
            ));
          });

          // Sign-in in progress
          emit(state.copyWith(
            status: LoginStatus.signInInProgress,
          ));
        },
        verificationFailed: (FirebaseAuthException authException) {
          print('EXCEPTION: Auth exception: ${authException.message}');
          // TODO: Keep in crashalitics
          emit(state.copyWith(
            status: LoginStatus.unauthorized,
          ));
        },
        codeSent: (String verificationId, [int forceResendingToken]) {
          //show screen to take input from the user
          emit(state.copyWith(
              status: LoginStatus.codeRequired, verification: verificationId));
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print("WARNING: Code autoretrieval timeout exceeded");
          // TODO: Logg event to crashalytic

          if (state.status == LoginStatus.phoneVerifying)
            emit(state.copyWith(
                status: LoginStatus.codeRequired,
                verification: verificationId));
        });

    emit(state.copyWith(
      status: LoginStatus.phoneVerifying,
    ));
  }

  // Enter confirmation code => LOGIN
  void codeEntered(String value) {
    emit(state.copyWith(code: value));
  }

  // Press Confirm button => LOGIN
  void confirmPressed() {
    AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: state.verification, smsCode: state.code);

    FirebaseAuth.instance.signInWithCredential(credential).catchError((e) {
      print('EXCEPTION: Signin with code exception $e');
      // TODO: Keep in crashalitics
      emit(state.copyWith(
        status: LoginStatus.unauthorized,
      ));
    });

    // TODO: Add code to validate code
    emit(state.copyWith(status: LoginStatus.signInInProgress));
  }

  // Choose subscription plan => LOGIN
  void planSelected(Package value) {
    emit(state.copyWith(package: value));
  }

  // Check/Uncheck TOS => LOGIN
  void termsOfServiceEntered(bool value) {
    emit(state.copyWith(
      tos: value,
    ));
  }

  // Press Subscribe button => LOGIN
  void subscribePressed() async {
    emit(state.copyWith(status: LoginStatus.subscriptionInProgress));
    try {
      await Purchases.purchasePackage(state.package);
    } catch (e, stack) {
      print('EXCEPTION: Purchase failed $e $stack');
      // TODO: Keep in crashalitics
      emit(state.copyWith(
        status: LoginStatus.unauthorized,
      ));
    }
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

    List<String> isbns = state.isbns;
    // Remove ISBN from isbn list
    if (filter.type == FilterType.title || filter.type == FilterType.wish) {
      isbns = state.isbnsFor(filters);
    }

    emit(state.copyWith(filters: filters, isbns: isbns));
  }

  // FILTER PANEL:
  // - Author/title filter changed => FILTER
  // - Places filter changed => FILTER (permission for Address Book if My Places)
  // - Language filter changed => FILTER
  // - Genre filter changed => FILTER
  void addFilter(Filter filter, {bool resetType = false}) async {
    List<Filter> filters = state.filters;
    LatLngBounds bounds = state.bounds;

    // Do nothing if filter already there
    if (filters.contains(filter)) return;

    if (filter.type == FilterType.title) {
      // If title filter add unselect wish filter
      filters = toggle(filters, FilterType.wish, false);
      // If title filter add drop genres filters
      filters = filters.where((f) => f.type != FilterType.genre).toList();
      // Drop bounds if search by ISBNs
      if (filter.selected) {
        bounds = null;
      }
    } else if (filter.type == FilterType.place) {
      // If place filter add unselect contacts filter
      filters = toggle(filters, FilterType.contacts, false);
    } else if (filter.type == FilterType.genre) {
      // If genre filter add drop title filters
      filters = filters.where((f) => f.type != FilterType.title).toList();
    } else if (filter.type == FilterType.author) {
      // Drop bounds if search by author(s)
      if (filter.selected) {
        bounds = null;
      }

      if (filters.any((f) => f.type == FilterType.author)) {
        // If more than 1 author drop genres filters if more than 1 value
        if (filters.where((f) => f.type == FilterType.genre).length > 1)
          filters = filters.where((f) => f.type != FilterType.genre).toList();

        // If more than 1 author drop language filters if more than 1 value
        if (filters.where((f) => f.type == FilterType.language).length > 1)
          filters =
              filters.where((f) => f.type != FilterType.language).toList();
      }
    }

    // Remove this filter from suggestions
    List<Filter> suggestions = state.filterSuggestions
        .where((f) => f.type != filter.type || f.value != filter.value)
        .toList();

    // Remove filters of the same type if flag resetType is true
    if (resetType)
      filters = filters.where((f) => f.type != filter.type).toList();

    filters = [...filters, filter]
      ..sort((a, b) => a.type.index.compareTo(b.type.index));

    List<String> isbns = state.isbnsFor(filters);

    print('!!!DEBUG ISBNs [${isbns.join(',')}]');

    emit(state.copyWith(
        filters: filters,
        isbns: isbns,
        bounds: () => bounds,
        filterSuggestions: suggestions));
  }

  // FILTER PANEL:
  // - Author/title filter changed => FILTER
  // - Places filter changed => FILTER (permission for Address Book if My Places)
  // - Language filter changed => FILTER
  // - Genre filter changed => FILTER
  void toggleFilter(FilterType type, Filter filter) async {
    // Only toggle wish and contacts filter
    if (filter.type != FilterType.contacts && filter.type != FilterType.wish)
      return;

    // If contacts filter selected we have to check/request contacts permission
    if (filter.type == FilterType.contacts && !filter.selected) {
      if (!await Permission.contacts.isGranted) {
        // Initiate contacts for a first time then permission is granted
        if (await Permission.contacts.request().isGranted) {
          // Async procedure, no wait
          scanContacts();
        } else {
          // Return without toggle if contacts permission is not granted
          return;
        }
      }
      // Either the permission was already granted before or the user just granted it.
    }

    List<Filter> filters = state.filters;

    // Drop all places filters if contacts is selected
    if (filter.type == FilterType.contacts && !filter.selected)
      filters = filters.where((f) => f.type != FilterType.place).toList();

    // Drop all title filters if wish is selected
    if (filter.type == FilterType.wish && !filter.selected)
      filters = filters.where((f) => f.type != FilterType.title).toList();

    filters = toggle(filters, filter.type, !filter.selected);

    List<String> isbns = state.isbns;
    LatLngBounds bounds = state.bounds;
    if (filter.type == FilterType.wish) {
      isbns = state.isbnsFor(filters);
      print('!!!DEBUG ISBNs in toggle [${isbns.join(',')}]');
      // Drop bounds if search by ISBNs (wish WAS not selected)
      if (!filter.selected) {
        print('!!!DEBUG Set bounds to NULL');
        bounds = null;
      }
    }

    emit(state.copyWith(filters: filters, isbns: isbns, bounds: () => bounds));
  }

  // FILTER PANEL:
  // - Button with group icon or tap on group line to edit details
  void searchEditComplete() async {
    _searchController.text = '';
    _snappingControler.snapToPosition(_snappingControler.snapPositions.last);

    List<MarkerData> markers = [];

    // TODO: Reuse below code as a function (used the same in several places)

    // Make markers based on BOOKS
    if (state.select == QueryType.books) {
      Set<Book> books = Set();

      // Add books only for missing areas
      await Future.forEach(state.geohashes, (hash) async {
        books.addAll(await state.booksFor(hash));
      });

      // Calculate markers based on the books
      markers = await state.markersFor(
          points: books, bounds: state.bounds, hashes: state.geohashes);

      // Make markers based on PLACES
    } else if (state.select == QueryType.places) {
      Set<Photo.Photo> photos = Set();
      // Add places only for missing areas
      await Future.forEach(state.geohashes, (hash) async {
        photos.addAll(await state.photosFor(hash));
      });

      // Calculate markers based on the places
      markers = await state.markersFor(
          points: photos, bounds: state.bounds, hashes: state.geohashes);
    }

    // Sort markers by distance
    markers.sort((a, b) => (distanceBetween(a.position, state.center) -
            distanceBetween(b.position, state.center))
        .round());

    // Emit state with updated markers
    emit(state.copyWith(markers: markers));

    // TODO: Should we emit "books" if search by places?
  }

  // FILTER PANEL:
  // - Button with group icon or tap on group line to edit details
  void groupSelectedForSearch(FilterGroup group) async {
    _searchController.text = '';
    _snappingControler.snapToPosition(
      SnapPosition(
          positionPixel: 530.0,
          snappingCurve: Curves.elasticOut,
          snappingDuration: Duration(milliseconds: 750)),
    );
    emit(state.copyWith(group: group, panel: Panel.full));

    List<Filter> suggestions = await findSugestions('', group);
    emit(state.copyWith(filterSuggestions: suggestions));
  }

  // FILTER PANEL:
  // - Filter panel opened => FILTER
  void panelOpened() async {
    // TODO: Load near by book places and keep it in the state object
    emit(state.copyWith(
      panel: Panel.open,
    ));
  }

  // FILTER PANEL:
  // - Filter panel minimized => FILTER
  void panelMinimized() {
    emit(state.copyWith(
      panel: Panel.minimized,
    ));
  }

  // FILTER PANEL:
  // - Filter panel closed => FILTER
  void panelHiden() {
    emit(state.copyWith(
      panel: Panel.hiden,
    ));
  }

  // TRIPLE BUTTON
  // - Map button pressed (selected) => FILTER
  void mapButtonPressed() async {
    searchAndShow(state);
  }

  // TRIPLE BUTTON
  // - Map button pressed long (selected) => FILTER
  void mapButtonLongPress() async {
    LatLng location = await currentLatLng();

    // Inform about new position if distance more than 50 meters
    // And drop place candidates for the camera
    if (distanceBetween(location, state.location) > 50.0)
      emit(state.copyWith(location: location, candidates: []));

    // TODO: Calculate zoom based on the book availability at a location

    if (_mapController != null)
      _mapController.moveCamera(CameraUpdate.newLatLng(location));
  }

  // TRIPLE BUTTON
  // - List button pressed (selected) => FILTER
  void listButtonPressed() {
    // TODO: Which function is appropriate for list view button?
  }

  // TRIPLE BUTTON
  // - Set view => FILTER
  void setView(ViewType view) async {
    if (view == ViewType.list) {
      // Switch to list view immediately and then build the list of books
      print('!!!DEBUG Are we here at all???');

      // Switch view to unblock UI
      emit(state.copyWith(
        view: view,
      ));
    } else if (view == ViewType.camera) {
      emit(state.copyWith(
        view: view,
      ));

      LatLng pos = await currentLatLng();
      String hash = GeoHasher().encode(pos.longitude, pos.latitude);

      Place place = state.place;

      if (place == null || place.name == null)
        place = Place(
            // TODO: DisplayName is null. Investigate.
            name: FirebaseAuth.instance.currentUser.displayName,
            phones: FirebaseAuth.instance.currentUser.phoneNumber != null
                ? [FirebaseAuth.instance.currentUser.phoneNumber]
                : [],
            emails: FirebaseAuth.instance.currentUser.email != null
                ? [FirebaseAuth.instance.currentUser.email]
                : [],
            privacy: Privacy.all,
            type: PlaceType.me,
            contact: FirebaseAuth.instance.currentUser.phoneNumber ??
                FirebaseAuth.instance.currentUser.email,
            location: pos,
            geohash: hash);
      else
        place = place.copyWith(location: pos, geohash: hash);

      print('!!!DEBUG Place geohash ${place.geohash}');

      emit(state.copyWith(
        location: pos,
        place: place,
      ));

      // Move map to the current user location
      if (_mapController != null)
        _mapController.moveCamera(CameraUpdate.newLatLng(pos));
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

        if (state.view == ViewType.camera) {
          List<Place> suggestions =
              await findCandidateSugestions(_searchController.text);

          emit(state.copyWith(placeSuggestions: suggestions));
        } else {
          List<Filter> suggestions =
              await findSugestions(_searchController.text, state.group);

          emit(state.copyWith(filterSuggestions: suggestions));
        }
      }
    });
  }

  // MAP VIEW
  // - Set controller
  void setSearchController(TextEditingController controller) {
    print('!!!DEBUG Set search controller $_searchController $controller');
    _searchController = controller;

    print('!!!DEBUG Add a listener to TextController');
    _searchController.addListener(_onSearchChanged);
    print('!!!DEBUG Listener added!');
  }

  // MAP VIEW
  // - Map move => FILTER
  void mapMoved(CameraPosition position, LatLngBounds bounds) async {
    print('!!!DEBUG mapMoved: starting hashes ${state.geohashes.join(',')}');

    // Recalculate geo-hashes from camera position and bounds

    Set<String> hashes = state.hashesFor(
        position != null ? position.target : state.center, bounds);

    print('!!!DEBUG mapMoved: new hashes ${hashes.join(',')}');

    // Old and new levels of geo hashes
    int oldLevel = state.geohashes.first.length;
    int newLevel = hashes.first.length;

    // Find which goe-hashes are apeared and which one are gone
    Set<String> extraHashes;
    Set<String> oddHashes;

    if (oldLevel == newLevel) {
      extraHashes = hashes.difference(state.geohashes);
      oddHashes = state.geohashes.difference(hashes);
    } else {
      extraHashes = hashes;
      // Do not remove the old hash if one of new hashes are inside
      oddHashes = state.geohashes
          .where((h1) =>
              h1.length > newLevel || hashes.every((h2) => !h2.startsWith(h1)))
          .toSet();
    }

    print('!!!DEBUG new hashes: ${extraHashes.join(', ')}');
    print('!!!DEBUG odd hashes: ${oddHashes.join(', ')}');

    List<MarkerData> markers = state.markers ?? [];

    // Remove markers from odd hashes and duplicates
    if (oldLevel <= newLevel)
      markers = markers
          .where((m) => !oddHashes.contains(m.geohash.substring(0, oldLevel)))
          .toList();

    // TODO: Reuse below code
    if (state.select == QueryType.books) {
      // Make markers based on BOOKS
      Set<Book> books = Set();

      // Add books only for missing areas
      await Future.forEach(extraHashes, (hash) async {
        books.addAll(await state.booksFor(hash));
      });

      // Calculate markers based on the books
      markers = await state.markersFor(
          markers: markers, points: books, bounds: bounds, hashes: hashes);
    } else if (state.select == QueryType.places) {
      // Make markers based on PLACES
      Set<Photo.Photo> photos = Set();

      // print('!!!DEBUG Markers based on PLACES Filters: ${state.filters.length} Books: ${state.books.length}');
      // Add places only for missing areas
      await Future.forEach(extraHashes, (hash) async {
        photos.addAll(await state.photosFor(hash));
      });

      // Calculate markers based on the places
      markers = await state.markersFor(
          markers: markers, points: photos, bounds: bounds, hashes: hashes);
    }

    // Sort markers by distance
    markers.sort((a, b) => (distanceBetween(a.position, state.center) -
            distanceBetween(b.position, state.center))
        .round());

    // Emit state with updated markers
    // Refresh suggestions if map moved once detailed place filters are open
    emit(state.copyWith(
      center: position != null ? position.target : state.center,
      bounds: () => bounds != null ? bounds : state.bounds,
      geohashes: hashes,
      filterSuggestions:
          (state.panel == Panel.full && state.group == FilterGroup.place)
              ? await findSugestions('', state.group)
              : null,
      markers: markers,
      // Emit total number of shelves and empty shelf list
      maxShelves: markers.fold(0, (t, e) => t + e.points.length),
      shelfList: [],
      shelfIndex: 0,
    ));

    // Fetch first 3 shelves and emit
    fetchShelves(markers: markers, start: 0, count: 3);
  }

  Future<void> shelvesFetched() async {
    print('!!!DEBUG Extra shelves requested');
    print(
        '!!!DEBUG Shelves = ${state.shelfList.length} ,Markers = [${state.markers.map((m) => m.points.length).join(',')}]');
    fetchShelves(
        markers: state.markers, start: state.shelfList.length, count: 3);
  }

  void fetchShelves({List<MarkerData> markers, int start, int count}) async {
    // Ignore if requesting shelves abothe max count
    if (start >= state.maxShelves) {
      print('EXCEPTION: Request shelves above max number of items');
      return;
    }

    List<Shelf> shelves = state.shelfList ?? [];

    // Reduce count if not enough shelves left
    if (start + count > state.maxShelves) count = state.maxShelves - start;

    // Skip markers till start position within the marker
    int skipped = 0, m = 0;
    while (m < markers.length && start - skipped >= markers[m].points.length) {
      skipped += markers[m].points.length;
      m += 1;
    }

    // Set index to the first requested point (book/photo)
    int index = start - skipped;

    // Iterate through markers and create shelves
    while (count > 0 && m < markers.length) {
      if (shelves.length > skipped + index) {
        count--;
        print('EXCEPTION: shelf re-read: skipped = $skipped, index = $index');
        continue;
      }

      Point point = markers[m].points[index];
      Shelf s;
      if (point is Book) {
        s = await Shelf.fromBook(point);
      } else if (point is Photo.Photo) {
        s = await Shelf.fromPhoto(point);
      }

      if (s != null) {
        if (shelves.length > skipped + index) {
          print('EXCEPTION: shelf re-read: skipped = $skipped, index = $index');
        } else {
          shelves.add(s);
        }
        count--;
      }

      // Iterate to the next item
      index += 1;
      if (index >= markers[m].points.length) {
        skipped += markers[m].points.length;
        index -= markers[m].points.length;
        m += 1;
      }
    }

    emit(state.copyWith(
      shelfList: shelves,
    ));
  }

  // MAP VIEW
  // - Tap on Marker => FILTER
  void markerPressed(MarkerData marker) async {
    if (marker.points.length > 1 &&
        distanceBetween(marker.bounds.northeast, marker.bounds.southwest) >
            200.0) {
      // Zoom in if more than one book/photo inside marker and they are
      // more than 200m apart
      _mapController
          .moveCamera(CameraUpdate.newLatLngBounds(marker.bounds, 100.0));
    } else {
      // Otherwise just move camera to the marker
      _mapController.moveCamera(CameraUpdate.newLatLng(marker.position));
    }

    // Shelf list will be rearanged automaticaly after camera move
  }

  void searchAndShow(FilterState newState) async {
    // Search book globally
    Set<Book> books = await newState.booksFor('');
    List<MarkerData> markers = await newState.markersFor(points: books);
    print('!!!DEBUG ${books.length} books found');

    // Markers will be sorted after the move

    // Emit a NEW state with books and map view
    emit(newState.copyWith(
      markers: markers,
      view: ViewType.map,
    ));

    // Move map view to given bounds
    // Set a bounds of the map to all found books (if more than 1)
    if (books.length > 1) {
      LatLngBounds bounds = boundsFromPoints(books.toList());
      print('!!!DEBUG move camera to bounds $bounds');
      _mapController.moveCamera(CameraUpdate.newLatLngBounds(bounds, 100.0));
    } else if (books.length == 1) {
      print('!!!DEBUG move camera to location ${books.first.location}');
      _mapController.moveCamera(CameraUpdate.newLatLng(books.first.location));
    } else {
      // TODO: Show message that books not found. Encourage to add more books
      print('EXCEPTION: No books found for given filters');
    }

    // Shelf list will be updated as part of the camera move
  }

  void searchAndShowBook({Book book}) async {
    FilterState newState = state.copyWith(filters: [
      ...FilterState.empty,
      Filter(
          type: FilterType.title, value: book.title, book: book, selected: true)
    ], isbns: [
      book.isbn
    ]);
    print('!!!DEBUG Search and show books by ISBN ${book.isbn}');

    searchAndShow(newState);
  }

  void getAndShowPhoto({Photo.Photo photo}) async {
    print('!!!DEBUG Search and show photo ${photo.name}');

    List<MarkerData> markers = await state.markersFor(points: [photo].toSet());

    // Emit a NEW state with one shelf to display
    emit(state.copyWith(
      filters: FilterState.empty,
      markers: markers,
      maxShelves: 1,
      shelfList: [await Shelf.fromPhoto(photo)],
      shelfIndex: 0,
      view: ViewType.list,
    ));
  }

  // DETAILS
  // - Search button pressed => FILTER
  void searchBookPressed(Book book) async {
    // Modify filter to add given book
    // Modify list of ISBN to search

    searchAndShowBook(book: book);
  }

  // DETAILS
  // - Add bookmark => FILTER
  void addUserBookmark(Book book) async {
    print('!!!DEBUG User bookmark to be added');

    if (book == null || book.isbn == null) {
      // TODO: Record an exception
      print('EXCEPTION: Bookmarks are not available to add');
      return;
    }

    List<String> bookmarks = state.bookmarks;

    if (bookmarks == null) {
      bookmarks = [book.isbn];
    } else {
      if (!bookmarks.contains(book.isbn)) {
        bookmarks.add(book.isbn);
      }
    }

    print('!!!DEBUG Emit new user value [${bookmarks.join(',')}]');
    emit(state.copyWith(
      bookmarks: bookmarks,
    ));

    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .set({
      'bookmarks': FieldValue.arrayUnion([book.isbn])
    }, SetOptions(merge: true));
  }

  // DETAILS
  // - Remove bookmark => FILTER
  void removeUserBookmark(Book book) async {
    print('!!!DEBUG Bookmark to be removed');

    if (book == null || book.isbn == null) {
      // TODO: Record an exception
      print('EXCEPTION: Bookmarks are not available to remove');
      return;
    }

    List<String> bookmarks = state.bookmarks;

    if (bookmarks == null) {
      // TODO: Record an exception
      print('EXCEPTION: Bookmarks missing while removing by UI');
      bookmarks = [];
    } else {
      if (bookmarks.contains(book.isbn)) {
        bookmarks.remove(book.isbn);
      } else {
        // TODO: Record an exception
        print('EXCEPTION: ISBN value missing while removing by UI');
      }
    }

    print('!!!DEBUG Emit new user value [${bookmarks.join(',')}]');
    emit(state.copyWith(
      bookmarks: bookmarks,
    ));

    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .set({
      'bookmarks': FieldValue.arrayRemove([book.isbn])
    }, SetOptions(merge: true));
  }

  // CAMERA PANEL
  // - Place choosen for the current photo => FILTER
  void setPlace(Place place) {
    print('!!!DEBUG current place changed: ${place.name}');

    if (place != state.place) {
      List<Place> suggestions =
          state.placeSuggestions.where((p) => p.name != place.name).toList();

      // TODO: Old places appeared even if not match the filter query. Filter it!
      suggestions.add(state.place);

      // Sort places by distance
      suggestions.sort((a, b) {
        if (a.type == PlaceType.me)
          return 0;
        else if (b.type == PlaceType.me)
          return 100000000;
        else if (a.type == PlaceType.place && b.type == PlaceType.place)
          return (distanceBetween(a.location, state.center) -
                  distanceBetween(b.location, state.center))
              .round();
        else if (a.type == PlaceType.contact && b.type == PlaceType.contact)
          return a.name.compareTo(b.name);
        else if (a.type == PlaceType.contact && b.type == PlaceType.place)
          return 50000000;
        else if (a.type == PlaceType.place && b.type == PlaceType.contact)
          return 0;
        else
          return a.name.compareTo(b.name);
      });

      emit(state.copyWith(place: place, placeSuggestions: suggestions));
    }
  }

  // CAMERA PANEL
  // - Privacy choosen for the current photo => FILTER
  void setPrivacy(Privacy privacy) {
    emit(state.copyWith(privacy: privacy));
  }

// Function which try to convert local mobile numbers into international ones
  String internationalPhone(String phone) {
    if (phone.startsWith('+'))
      return phone;
    else if (phone.startsWith('00'))
      return '+' + phone.substring(2);
    else if (phone.startsWith('8') && phone.length == 11)
      // TODO: Add validation that country code of user is Russia
      return '+7' + phone.substring(1);
    else
      // TODO: Add condition country code of user??
      return phone;
  }

  // CAMERA PANEL:
  // - Find candidates for camera photo location
  Future<List<Place>> findCandidateSugestions(String query) async {
    // Get current location of the user
    LatLng location = await currentLatLng();
    print(
        '!!!DEBUG New location ${LatLng(location.latitude, location.longitude)}');

    List<Place> candidates = state.candidates;

    // Refresh candidates if current location is changed compare to
    // the previous more than 50 meters
    // Or if candidate places are empty at all
    if (candidates == null ||
        candidates.isEmpty ||
        distanceBetween(location, state.location) > 50.0) {
      // Get all places from Google places in a radius of 50 meters
      NearBySearchResponse result = await googlePlace.search.getNearBySearch(
          Location(lat: location.latitude, lng: location.longitude), 300);

      print(
          '!!!DEBUG places query result: ${result.status}, number ${result.results.length}');

      // TODO: Place contacts is not available at this search. Details required
      candidates = result.results
          .map((r) => Place(
              placeId: r.placeId,
              name: r.name,
              location:
                  LatLng(r.geometry.location.lat, r.geometry.location.lng),
              privacy: Privacy.all,
              type: PlaceType.place))
          .toList();

      // Sort places by distance
      candidates.sort((a, b) => (distanceBetween(a.location, state.center) -
              distanceBetween(b.location, state.center))
          .round());

      // If address book access is granted add all contacts
      if (await Permission.contacts.isGranted) {
        Iterable<Contact> addressBook = await ContactsService.getContacts();
        print('!!!DEBUG ${addressBook.length} contacts found');

        addressBook.forEach((c) {
          c.phones.forEach((p) {
            print('!!!DEBUG: ${c.displayName} ${p.label} ${p.value}');
          });

          List<String> phones =
              c.phones.map((p) => internationalPhone(p.value)).toList();
          List<String> emails = c.emails.map((e) => e.value).toList();
          String contact;
          if (phones.length > 0)
            contact = phones.first;
          else if (emails.length > 0) contact = emails.first;

          if (contact != null)
            candidates.add(Place(
                name: c.displayName,
                // TODO: Take only phones with "mobile" label
                phones: phones,
                emails: emails,
                contact: contact,
                privacy: Privacy.contacts,
                type: PlaceType.contact));
        });
      }

      // Update state with newly retrieved candidates
      emit(state.copyWith(candidates: candidates, location: location));
    }

    List<Place> suggestions;

    // If query is empty return 10 closest places
    if (query == null || query.length == 0)
      suggestions = candidates.take(10).toList();

    // If query is not empty filter by query
    else if (query.length > 0)
      suggestions = candidates
          .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
          .toList();

    print('!!!DEBUG number of suggestions: ${suggestions.length}');

    // No need to sort as places already sorted by distance
    // Exclude selected place
    return suggestions.where((p) => p.name != state.place.name).toList();
  }

  // CAMERA PANEL:
  // - Click on location icon or current place chip to eddit current location
  //   for the photo
  void selectPlaceForPhoto() async {
    _searchController.text = '';
    _snappingControler.snapToPosition(
      SnapPosition(
          positionPixel: 530.0,
          snappingCurve: Curves.elasticOut,
          snappingDuration: Duration(milliseconds: 750)),
    );
    emit(state.copyWith(panel: Panel.full));

    List<Place> suggestions = await findCandidateSugestions('');
    emit(state.copyWith(placeSuggestions: suggestions));
  }

  // Function to find place in Firestore DB or create a new one if not exist
  Future<Place> getPlaceFromDb(Place place) async {
    if (place.id != null) {
      // Place already found in DB
      print('!!!DEBUG: Place already in DB');
      return place;
    } else if (place.type == PlaceType.place) {
      // If place is a Google map place search by id
      DocumentReference ref = FirebaseFirestore.instance
          .collection('bookplaces')
          .doc('P' + place.placeId);
      DocumentSnapshot doc = await ref.get();

      if (doc.exists) {
        // If place exist in DB merge it with current one
        place = place.merge(Place.fromJson(doc.id, doc.data()));
      } else {
        // If place is not in DB create it

        // Check if contact is there. If not query GooglePlaces
        if (place.contact == null) {
          DetailsResponse details =
              await googlePlace.details.get(place.placeId);

          // TODO: Find constant for this value 'OK'
          if (details.status == 'OK') {
            if (details.result.internationalPhoneNumber != null)
              place = place.copyWith(
                  contact: details.result.internationalPhoneNumber);
            else if (details.result.website != null)
              place = place.copyWith(contact: details.result.website);
            else
              place = place.copyWith(
                  contact:
                      'https://www.google.com/maps/search/?api=1&query=${place.name}&query_place_id=${place.placeId}');
          } else {
            // TODO: Report an exception. Most probably it means some garbage!
            place = place.copyWith(
                contact:
                    'https://www.google.com/maps/search/?api=1&query=${place.name}&query_place_id=${place.placeId}');
          }
        }

        if (place.geohash == null || place.geohash.isEmpty) {
          print('EXCEPTION: geohash is empty. Investigate!');
          place = place.copyWith(
              geohash: GeoHasher()
                  .encode(place.location.longitude, place.location.latitude));
        }

        place = place.copyWith(id: ref.id);
        ref.set(place.toJson());
      }
    } else if (place.type == PlaceType.contact) {
      // If place is a contact search by phones and emails
      // TODO: Only search in a near geohash:7 to minimize query
      Query query;

      if (place.phones != null && place.phones.isNotEmpty)
        query = FirebaseFirestore.instance
            .collection('bookplaces')
            .where('phones', arrayContainsAny: state.place.phones);
      else if (place.emails != null && place.emails.isNotEmpty)
        query = FirebaseFirestore.instance
            .collection('bookplaces')
            .where('phones', arrayContainsAny: place.phones);
      else {
        // TODO: Record an exception: either phone or email should be filled in contact
        print(
            'Exception: nither phone nor email available for the contact ${place.name}');
      }

      // Query places from DB
      List<Place> places = (await query.get())
          .docs
          .map((d) => Place.fromJson(d.id, d.data()))
          .toList();

      // Sort places based on distance to center of screen
      places.sort((a, b) => (distanceBetween(a.location, state.location) -
              distanceBetween(b.location, state.location))
          .round());

      if (places.length > 0 &&
          distanceBetween(places.first.location, state.location) < 200) {
        // If place is found and it does not far away (less than 200 meters)
        place = place.merge(places.first);
      } else {
        // Create a place in DB if not found or too far
        DocumentReference ref =
            FirebaseFirestore.instance.collection('bookplaces').doc();
        ref.set(place.toJson());
        place = place.copyWith(id: ref.id);
      }
    } else if (state.place.type == PlaceType.me) {
      // Check if my own location is already exist near the current location
      DocumentReference ref = FirebaseFirestore.instance
          .collection('bookplaces')
          .doc('U' +
              FirebaseAuth.instance.currentUser.uid +
              ':' +
              place.geohash.substring(0, 7));
      DocumentSnapshot doc = await ref.get();

      if (doc.exists) {
        print('!!!DEBUG Place exist in DB merge');
        // If place exist in DB merge it with current one
        place = place.merge(Place.fromJson(doc.id, doc.data()));
      } else {
        print('!!!DEBUG Create place in DB ${ref.id}');
        // If place is not in DB create it
        place = place.copyWith(id: ref.id);
        await ref.set(place.toJson());
      }
    }

    return place;
  }

  // CAMERA PANEL:
  // - Complete button on a keyboard for place selection
  void placeEditComplete() async {
    _searchController.text = '';
    _snappingControler.snapToPosition(_snappingControler.snapPositions.last);
  }

  // Upload image to GCS
  Future<Reference> uploadPicture(File image, String path) async {
    final Reference ref = FirebaseStorage.instance.ref().child(path);
    final UploadTask uploadTask = ref.putFile(
      image,
      new SettableMetadata(
        contentType: 'image/jpeg',
        // To enable Client-side caching you can set the Cache-Control headers here. Uncomment below.
        cacheControl: 'public,max-age=3600',
        customMetadata: <String, String>{'activity': 'test'},
      ),
    );

    // Wait upload to finish
    await uploadTask;

    // Return reference to get url and path
    return ref;
  }

/* DO IT BY TRIGGER IN FIRESTORE PYTHON
  // Trigger image recognition
  Future recognizeImage(String photoId) async {
    try {
      String token = await FirebaseAuth.instance.currentUser.getIdToken();

      String body = json.encode({
        'photo': photoId,
      });
      //print('!!!DEBUG: JSON body = $body');

      // Call Python service to recognize image
      Response res = await api.client.post(
          'https://biblosphere-api-ihj6i2l2aq-uc.a.run.app/add_user_books_from_image',
          body: body,
          headers: {
            HttpHeaders.authorizationHeader: "Bearer $token",
            HttpHeaders.contentTypeHeader: "application/json"
          });

      if (res.statusCode != 200) {
        print('Exception: Recognition request failed');
        // TODO: Add event into analytics
      }
      //print('!!!DEBUG: ${res.body}');
      //print('!!!DEBUG: Request for recognition queued');
    } catch (e, stack) {
      print("Exception: Failed to recognize image: " +
          e.toString() +
          stack.toString());
      // TODO: Add event into analytics
    }
  }
*/

  // CAMERA PANEL:
  // - Tripple button with a camera
  Future<void> cameraButtonPressed(File file, String fileName) async {
    print('!!!DEBUG Image recognition started');

    // Find place if it exist or create it in Firestore DB
    Place place = await getPlaceFromDb(state.place);

    print('!!!DEBUG Place found/created: ${place.id}');

    // TODO: Validate that place.id is not null and throw exception

    print('!!!DEBUG Image taken: images/${place.id}/$fileName');

    // Upload picture to GCS
    Reference ref = await uploadPicture(file, 'images/${place.id}/$fileName');
    print('!!!DEBUG Image uploaded: images/${place.id}/$fileName');

    String thumbnail =
        'https://storage.googleapis.com/biblosphere-210106.appspot.com/thumbnails/${place.id}/$fileName';
    print('!!!DEBUG Thumbnail reference: $thumbnail');

    // Create a photo record for the given place and uploaded image
    DocumentReference doc =
        FirebaseFirestore.instance.collection('photos').doc();

    doc.set({
      'id': doc.id,
      'bookplace': place.id,
      'location': {
        'geopoint': GeoPoint(place.location.latitude, place.location.longitude),
        'geohash': place.geohash
      },
      'photo': ref.fullPath,
      'url': await ref.getDownloadURL(),
      'thumbnail': thumbnail,
      'reporter': FirebaseAuth.instance.currentUser.uid
    });

    print('!!!DEBUG photo record created');
  }
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

LatLngBounds boundsFromPoints(List<Point> points) {
  assert(points.isNotEmpty);

  double north = points.first.location.latitude;
  double south = points.first.location.latitude;

  for (var i = 0; i < points.length; i++) {
    if (points[i].location.latitude > north)
      north = points[i].location.latitude;
    else if (points[i].location.latitude < south)
      south = points[i].location.latitude;
  }

  List<double> lng = points.map((p) => p.location.longitude).toList();
  lng.sort();

  double gap = lng.first - lng.last + 360.0;
  double west = lng.first, east = lng.last;

  for (var i = 1; i < lng.length - 1; i++) {
    if (lng[i] - lng[i - 1] > gap) {
      gap = lng[i] - lng[i - 1];
      east = lng[i - 1];
      west = lng[i];
    }
  }

  return LatLngBounds(
      northeast: LatLng(north, east), southwest: LatLng(south, west));
}
