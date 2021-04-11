import 'package:biblosphere/model/Place.dart';

class MapRepository {
  static final MapRepository _singleton = MapRepository._internal();

  factory MapRepository() {
    return _singleton;
  }

  MapRepository._internal();

  Place place;
}
