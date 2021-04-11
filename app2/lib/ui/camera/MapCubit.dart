import 'dart:math';

import 'package:biblosphere/model/FilterState.dart';
import 'package:biblosphere/model/Panel.dart';
import 'package:biblosphere/model/Place.dart';
import 'package:biblosphere/model/Privacy.dart';
import 'package:biblosphere/repository/map_repository.dart';
import 'package:biblosphere/secret.dart';
import 'package:biblosphere/ui/home/HomeCubit.dart';
import 'package:biblosphere/util/Enums.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:cubit/cubit.dart';
import 'package:flutter_cubit/flutter_cubit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
import 'package:permission_handler/permission_handler.dart';

class MapCubit extends Cubit<FilterState> {
  MapRepository _booksRepository;
  GooglePlace googlePlace = GooglePlace(GooglePlaceKey);

  MapCubit() : super(FilterState()) {
    _booksRepository = MapRepository();

    emit(state.copyWith(place: _booksRepository.place));
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

  // CAMERA PANEL:
  // - Click on location icon or current place chip to eddit current location
  //   for the photo
  void selectPlaceForPhoto() async {
    HomeCubit _postBloc = CubitProvider.;

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

  Future<LatLng> currentLatLng() async {
    var pos = await Geolocator.getCurrentPosition();
    return LatLng(pos.latitude, pos.longitude);
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

  // FILTER PANEL:
  // - Button with group icon or tap on group line to edit details
  // void searchEditComplete() async {
  //   _searchController.text = '';
  //   _snappingControler.snapToPosition(_snappingControler.snapPositions.last);
  //
  //   List<MarkerData> markers = [];
  //
  //   // TODO: Reuse below code as a function (used the same in several places)
  //
  //   // Make markers based on BOOKS
  //   if (state.select == QueryType.books) {
  //     Set<Book> books = Set();
  //
  //     // Add books only for missing areas
  //     await Future.forEach(state.geohashes, (hash) async {
  //       books.addAll(await state.booksFor(hash));
  //     });
  //
  //     // Calculate markers based on the books
  //     markers = await state.markersFor(
  //         points: books, bounds: state.bounds, hashes: state.geohashes);
  //
  //     // Make markers based on PLACES
  //   } else if (state.select == QueryType.places) {
  //     Set<Photo.Photo> photos = Set();
  //     // Add places only for missing areas
  //     await Future.forEach(state.geohashes, (hash) async {
  //       photos.addAll(await state.photosFor(hash));
  //     });
  //
  //     // Calculate markers based on the places
  //     markers = await state.markersFor(
  //         points: photos, bounds: state.bounds, hashes: state.geohashes);
  //   }
  //
  //   // Sort markers by distance
  //   markers.sort((a, b) => (distanceBetween(a.position, state.center) -
  //       distanceBetween(b.position, state.center))
  //       .round());
  //
  //   // Emit state with updated markers
  //   emit(state.copyWith(markers: markers));
  //
  //   // TODO: Should we emit "books" if search by places?
  // }

  void panelOpened() async {
    // TODO: Load near by book places and keep it in the state object
    emit(state.copyWith(
      panel: Panel.open,
    ));
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
