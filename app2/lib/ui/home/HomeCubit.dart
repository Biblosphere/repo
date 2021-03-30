import 'package:biblosphere/model/FilterState.dart';
import 'package:biblosphere/model/Panel.dart';
import 'package:biblosphere/model/Place.dart';
import 'package:biblosphere/model/Privacy.dart';
import 'package:biblosphere/model/ViewType.dart';
import 'package:biblosphere/util/Enums.dart';
import 'package:cubit/cubit.dart';
import 'package:dart_geohash/dart_geohash.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:snapping_sheet/snapping_sheet.dart';

class HomeCubit extends Cubit<FilterState> {
  HomeCubit() : super(FilterState());

  SnappingSheetController _snappingControler;

  // MAP VIEW
  // - Set controller
  void setSnappingController(SnappingSheetController controller) {
    _snappingControler = controller;
  }

  /* FILTER PANL */
  // - Filter panel closed => FILTER
  void panelHiden() {
    emit(state.copyWith(
      panel: Panel.hiden,
    ));
  }

  // - Filter panel minimized => FILTER
  void panelMinimized() {
    emit(state.copyWith(
      panel: Panel.minimized,
    ));
  }

  // - Filter panel opened => FILTER
  void panelOpened() async {
    // TODO: Load near by book places and keep it in the state object
    emit(state.copyWith(
      panel: Panel.open,
    ));
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
    } else {
      emit(state.copyWith(
        view: view,
      ));
    }
  }

  Future<LatLng> currentLatLng() async {
    Position pos = await Geolocator.getCurrentPosition();
    return LatLng(pos.latitude, pos.longitude);
  }
}
