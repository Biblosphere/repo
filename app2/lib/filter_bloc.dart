// Markers - can contain Place or Book
// Keep markers as is, just create navigation by photo/books
// Navigation in list view through Markers sorted by distance
// currentMarker - highlight with RED color
// nextMarker - equal to current unless at the last photo/book
// prevMarker - equal to current unless at the first photo/book
// Markers are connected in the loop after most distant one loop back to closest
// currentPhoto, currentBook - functions in state
// nextBook, nextPhoto, nextPhotoBook - functions in state
// prevBook, prevPhoto, prevPhotoBook - functions in state
// Next and Previous book/photo has to be always ready (fully download)
// Marker could be:
// - List of Books
// - List of Places
// For books:
// - Iterate throug books get the photo of the book and all books for this photo
// For places:
// - Iterate throug photos of the places load all books for the photo
// Apply Language/Genre filters to photos and books (in list view)
// For books show 1/NN to know current position on the photo
// If marker contains books scroll books to THE BOOK

// Keep places (not persons) in the MarkerData - to build a suggestions

// It could be markers with single book and markers with many places

// Use carousel_slider plugin for Photo/Books carousel

import 'dart:math';

import 'package:biblosphere/model/Point.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'model/Book.dart';
import 'model/Place.dart';
import 'util/Enums.dart';


/*
class AppUser extends Equatable {
  final String id;

  // Display name
  final String name;

  // Registration mobile
  final String mobile;

  // Registration email
  final String email;

  // All contacts of the users both phones and e-mails
  // final List<String> contacts;

  // Places where the user is accosiated (contacts, place where he/she contributed)
  // final List<String> places;

  // List of bookmarks (books marked in the app)
  final List<String> bookmarks;

  AppUser(
      {@required this.id,
      @required this.name,
      this.mobile,
      this.email,
      // this.contacts,
      // this.places,
      this.bookmarks});

  @override
  List<Object> get props => [id, name, mobile, bookmarks];

  AppUser.fromJson(String id, Map<String, dynamic> json)
      : id = id ?? json['id'],
        name = json['name'],
        mobile = json['mobile'],
        email = json['email'],
        // contacts = List<String>.from(json['contacts'] ?? []),
        // places = List<String>.from(json['contacts'] ?? []),
        bookmarks = List<String>.from(json['contacts'] ?? []);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mobile': mobile,
      'bookmarks': bookmarks,
      // Not include places, bookmarks as them updated outside app
    };
  }

  AppUser copyWith({
    String id,
    String name,
    String mobile,
    List<String> bookmarks,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      bookmarks: bookmarks ?? this.bookmarks,
    );
  }
}
*/

String up(String geohash) {
  int len = geohash.length;

  if (len >= 1) {
    int lastChar = geohash.codeUnitAt(len - 1);
    return geohash.substring(0, len - 1) + String.fromCharCode(lastChar + 1);
  } else {
    return geohash;
  }
}

typedef Book BookCallback();

typedef LatLngBounds LatLngBoundsCallback();

// Return length of longest common prefix
int lcp(String s1, String s2) {
  for (int i = 0; i <= min(s1.length, s2.length); i++)
    if (s1.codeUnitAt(i) != s2.codeUnitAt(i)) return i;
  return min(s1.length, s2.length);
}
