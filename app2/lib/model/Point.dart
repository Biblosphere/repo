import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Point extends Equatable {
  final LatLng location;
  final String geohash;

  const Point({this.location, this.geohash});

  @override
  List<Object> get props => [location, geohash];
}
