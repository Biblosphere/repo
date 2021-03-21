import 'package:biblosphere/model/Place.dart';
import 'package:biblosphere/model/Point.dart';
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerData extends Equatable {
  final String geohash;
  final LatLng position;
  final List<Point> points;
  final Set<Place> places;
  final int size;
  final LatLngBounds bounds;

  MarkerData(
      {this.geohash,
      this.position,
      this.size,
      this.points,
      this.places,
      this.bounds});

  @override
  List<Object> get props => [geohash, position, size];
}
