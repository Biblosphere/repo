import 'package:biblosphere/model/Book.dart';
import 'package:biblosphere/util/Enums.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'Place.dart';

class Filter extends Equatable {
  final FilterType type;
  final String value;
  final Book book;
  final Place place;
  final bool selected;

  @override
  List<Object> get props => [type, value, selected];

  const Filter(
      {@required this.type, this.value, this.book, this.place, this.selected});

  FilterGroup get group {
    switch (type) {
      case FilterType.author:
      case FilterType.title:
      case FilterType.wish:
        return FilterGroup.book;

      case FilterType.genre:
        return FilterGroup.genre;

      case FilterType.language:
        return FilterGroup.language;

      case FilterType.place:
      case FilterType.contacts:
        return FilterGroup.place;
    }
    //TODO: report in the crashalytics
    return null;
  }

  Filter copyWith({
    FilterType type,
    String value,
    String book,
    bool selected,
  }) {
    return Filter(
      type: type ?? this.type,
      value: value ?? this.value,
      book: book ?? this.book,
      place: place ?? this.place,
      selected: selected ?? this.selected,
    );
  }
}
