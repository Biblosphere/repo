import 'package:biblosphere/main.dart';
import 'package:biblosphere/model/Place.dart';
import 'package:biblosphere/model/PlaceType.dart';
import 'package:biblosphere/model/Point.dart';
import 'package:biblosphere/model/Privacy.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class Photo extends Point {
  final String id;
  final String url;
  final String thumbnail;
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

  const Photo(
      {this.id,
      this.url,
      this.thumbnail,
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

  Photo.fromJson(this.id, Map json)
      : name = json['name'],
        url = json['url'],
        thumbnail = json['thumbnail'],
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
      'url': url,
      'thumbnail': thumbnail,
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

  Photo copyWith(
      {String id,
      String url,
      String thumbnail,
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
    return Photo(
        id: id ?? this.id,
        url: url ?? this.url,
        thumbnail: thumbnail ?? this.thumbnail,
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

  // Return place object for the photo
  Place get place => Place(
      id: this.id,
      name: this.name,
      contact: this.contact,
      privacy: this.privacy,
      location: this.location,
      geohash: this.geohash,
      type: this.type,
      emails: this.emails,
      phones: this.phones,
      placeId: this.placeId,
      users: this.users,
      count: this.count,
      languages: this.languages,
      genres: this.genres);

  @override
  List<Object> get props => [
        id,
        url,
        thumbnail,
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

  String get phone =>
      contact != null && contact.startsWith('+') ? contact : null;

  String get email => contact != null && contact.contains('@') ? contact : null;

  String get web =>
      contact != null && contact.startsWith('http') ? contact : null;
}

void contactHost(Photo photo) async {
  String url;
  if (photo.phone != null)
    url = 'tel:${photo.phone}';
  else if (photo.email != null)
    url = 'mailto:${photo.email}';
  else if (photo.web != null)
    url = '${photo.email}';
  else {
    print('EXCEPTION: Book does not have none of mobile, email or web');
    // TODO: Log an exception
  }

  if (url != null && await canLaunch(url)) {
    await launch(url);
  } else {
    print('EXCEPTION: Could not launch contact owner action');
    // TODO: Log an exception
  }
}

List<String> PlaceTypeLabels = ['contact', 'place', 'contact'];
