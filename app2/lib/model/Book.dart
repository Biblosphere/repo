import 'dart:ui';

import 'package:biblosphere/model/Point.dart';
import 'package:biblosphere/util/Consts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Book extends Point {
  final String id;
  final String isbn;
  final String title;
  final List<String> authors;
  final String genre;
  final String language;
  final String description;
  final List<String> tags;
  final String cover;
  final String photo;
  final String photoId;
  final String ownerId;

  // Book outline on the bookshelf image
  final List<Offset> outline;
  final List<Offset> bookspine;
  final List<Offset> coverPlace;
  final int photoHeight;
  final int photoWidth;

  // Book location
  final String bookplaceId;
  final String bookplaceName;
  final String bookplaceContact;

  const Book({
    this.id,
    this.isbn,
    this.title,
    this.authors,
    this.genre,
    this.language,
    this.description,
    this.tags = const <String>[],
    this.cover,
    this.photo,
    this.photoId,
    this.ownerId,
    this.outline,
    this.bookspine,
    this.coverPlace,
    this.photoHeight,
    this.photoWidth,
    location,
    geohash,
    this.bookplaceId,
    this.bookplaceName,
    this.bookplaceContact,
  }) : super(location: location, geohash: geohash);

  Book.fromJson(this.id, Map json)
      : isbn = json['isbn'],
        title = json['title'],
        authors = List<String>.from(json['authors'] ?? []),
        genre = json['genre'],
        language = json['language'],
        cover = json['cover'],
        description = json['description'],
        tags = List<String>.from(json['tags'] ?? []),
        photo = json['photo'],
        photoId = json['photo_id'],
        ownerId = json['owner_id'],
        bookplaceId = json['bookplace'],
        bookplaceName = json['place_name'],
        bookplaceContact = json['place_contact'],
        outline = json['outline'] == null
            ? []
            : List<Offset>.from((json['outline'] as List)
                .map((e) => Offset(e['x'].toDouble(), e['y'].toDouble()))),
        bookspine = json['spine'] == null
            ? []
            : List<Offset>.from((json['spine'] as List)
                .map((e) => Offset(e['x'].toDouble(), e['y'].toDouble()))),
        coverPlace = json['place_for_cover'] == null
            ? []
            : List<Offset>.from((json['place_for_cover'] as List)
                .map((e) => Offset(e['x'].toDouble(), e['y'].toDouble()))),
        photoHeight = json['photo_height'],
        photoWidth = json['photo_width'],
        super(
            location: LatLng(
                (json['location']['geopoint'] as GeoPoint).latitude,
                (json['location']['geopoint'] as GeoPoint).longitude),
            geohash: json['location']['geohash']);

  @override
  List<Object> get props => [id];

  String get place => bookplaceName != null ? bookplaceName : bookplaceId;

  String get phone =>
      bookplaceContact != null && bookplaceContact.startsWith('+')
          ? bookplaceContact
          : null;

  String get email => bookplaceContact != null && bookplaceContact.contains('@')
      ? bookplaceContact
      : null;

  String get web =>
      bookplaceContact != null && bookplaceContact.startsWith('http')
          ? bookplaceContact
          : null;

  String get genreText =>
      genre != null && genres.containsKey(genre) ? genres[genre] : '  ...  ';

  String get languageText => language != null && languages.containsKey(language)
      ? languages[language]
      : '  ...  ';
}
