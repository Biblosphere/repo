import 'package:biblosphere/model/Photo.dart';
import 'package:biblosphere/model/Point.dart';
import 'package:biblosphere/model/Privacy.dart';
import 'package:biblosphere/util/Consts.dart';
import 'package:biblosphere/util/Enums.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Place extends Point {
  final String id;
  final String name;
  final String contact;
  final Privacy privacy;
  final PlaceType type;

  // Fields for contacts
  final List<String> emails;
  final List<String> phones;

  // Field for Google Places
  final String placeId;

  // Users of this bookplace (contacts for person, contributors for orgs)
  final List<String> users;

  // Books count
  final int count;

  // Books counts per language
  final Map<String, int> languages;

  // Books counts per genre
  final Map<String, int> genres;

  const Place(
      {this.id,
      this.name,
      this.contact,
      this.emails,
      this.phones,
      this.placeId,
      this.privacy = Privacy.contacts,
      this.type,
      location,
      geohash,
      this.users,
      this.count,
      this.languages,
      this.genres})
      : super(location: location, geohash: geohash);

  Place.fromJson(this.id, Map json)
      : name = json['name'],
        contact = json['contact'],
        emails = List<String>.from(json['emails'] ?? []),
        phones = List<String>.from(json['phones'] ?? []),
        placeId = json['placeId'],
        privacy = json['privacy'] == 'private'
            ? Privacy.private
            : json['privacy'] == 'contacts'
                ? Privacy.contacts
                : Privacy.all,
        type = json['type'] == 'contact' ? PlaceType.contact : PlaceType.place,
        users = List<String>.from(json['users'] ?? []),
        count = json['count'],
        languages = Map<String, int>.from(json['languages'] ?? {}),
        genres = Map<String, int>.from(json['genres'] ?? {}),
        super(
            location: LatLng(
                (json['location']['geopoint'] as GeoPoint).latitude,
                (json['location']['geopoint'] as GeoPoint).longitude),
            geohash: json['location']['geohash']);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contact': contact,
      'emails': emails,
      'phones': phones,
      'placeId': placeId,
      'privacy': PrivacyLabels[privacy.index],
      'type': PlaceTypeLabels[type.index],
      'users': users,
      'count': count,
      'languages': languages,
      'genres': genres,
      'location': {
        'geopoint': GeoPoint(location.latitude, location.longitude),
        'geohash': geohash
      }
    };
  }

  Place copyWith(
      {String id,
      String name,
      String contact,
      LatLng location,
      String geohash,
      Privacy privacy,
      PlaceType type,
      List<String> emails,
      List<String> phones,
      String placeId,
      List<String> users,
      int count,
      Map<String, int> languages,
      Map<String, int> genres}) {
    return Place(
        id: id ?? this.id,
        name: name ?? this.name,
        contact: contact ?? this.contact,
        privacy: privacy ?? this.privacy,
        location: location ?? this.location,
        geohash: geohash ?? this.geohash,
        type: type ?? this.type,
        emails: emails ?? this.emails,
        phones: phones ?? this.phones,
        placeId: placeId ?? this.placeId,
        users: users ?? this.users,
        count: count ?? this.count,
        languages: languages ?? this.languages,
        genres: genres ?? this.genres);
  }

  Place merge(Place other) {
    if (other == null) return this;
    return copyWith(
      id: id ?? other.id,
      name: name ?? other.name,
      contact: contact ?? other.contact,
      privacy: privacy ?? other.privacy,
      type: type ?? other.type,
      emails:
          emails?.toSet()?.union(other?.emails?.toSet() ?? Set())?.toList() ??
              other.emails,
      phones:
          phones?.toSet()?.union(other?.phones?.toSet() ?? Set())?.toList() ??
              other.phones,
      placeId: placeId ?? other.placeId,
      users: users?.toSet()?.union(other?.users?.toSet() ?? Set())?.toList() ??
          other.users,
      count: count ?? other.count,
      // TODO: Copy either both or none of location/geohash
      location: location ?? other.location,
      geohash: geohash ?? other.geohash,
      languages: {...languages ?? {}, ...other.languages ?? {}},
      genres: {...genres ?? {}, ...other.genres ?? {}},
    );
  }

  @override
  List<Object> get props => [
        id,
        name,
        contact,
        emails,
        phones,
        placeId,
        privacy,
        type,
        location,
        geohash,
        users,
        count,
        languages,
        genres
      ];
}
