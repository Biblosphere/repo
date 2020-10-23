part of 'main.dart';

class TitleChipsWidget extends StatefulWidget {
  TitleChipsWidget({Key key}) : super(key: key);

  @override
  _TitleChipsState createState() => _TitleChipsState();
}

class _TitleChipsState extends State<TitleChipsWidget> {
  // TODo: Replace mock with real values
  static List<String> titles = <String>[
    'Good to great',
    'Great by choice',
    '8 habits highly effective people',
    'Lord of the ring',
    'Jim Collins',
    'Max Fry'
  ];

  static List<Filter> findTitleSugestions(String query) {
    if (query.length != 0) {
      var lowercaseQuery = query.toLowerCase();
      return titles
          .where((title) {
            return title.toLowerCase().contains(query.toLowerCase());
          })
          .map((g) => Filter(type: FilterType.title, value: g))
          .toList(growable: false)
            ..sort((a, b) => a.value
                .toLowerCase()
                .indexOf(lowercaseQuery)
                .compareTo(b.value.toLowerCase().indexOf(lowercaseQuery)));
    } else {
      return const <Filter>[];
    }
  }

  static Widget titleSugestionBuilder(
      BuildContext context, ChipsInputState<Filter> state, Filter title) {
    return ListTile(
      key: ObjectKey(title),
      // TODO: Add leading avatar with book
      // leading: CircleAvatar(),
      title: Text(title.value),
      subtitle: Text(title.value),
      onTap: () => state.selectSuggestion(title),
    );
  }

  // List of genre filters
  _TitleChipsState();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterCubit, FilterState>(builder: (context, filters) {
      return ChipsInput(
        initialValue: filters.filters[FilterType.title],
        decoration: InputDecoration(labelText: "Title / Author"),
        maxChips: 5,
        findSuggestions: findTitleSugestions,
        onChanged: (data) {
          context.bloc<FilterCubit>().changeFilters(FilterType.title, data);
        },
        chipBuilder: chipBuilder,
        suggestionBuilder: titleSugestionBuilder,
      );
    });
  }
}

class GenreChipsWidget extends StatefulWidget {
  GenreChipsWidget({Key key}) : super(key: key);

  @override
  _GenreChipsState createState() => _GenreChipsState();
}

class _GenreChipsState extends State<GenreChipsWidget> {
  // TODo: Replace mock with real values
  static List<String> genres = <String>[
    'Fiction',
    'Non-fiction',
    'Fantasy',
    'Novel'
  ];

  static List<Filter> findGenreSugestions(String query) {
    if (query.length != 0) {
      var lowercaseQuery = query.toLowerCase();
      return genres
          .where((genre) {
            return genre.toLowerCase().contains(query.toLowerCase());
          })
          .map((g) => Filter(type: FilterType.genre, value: g))
          .toList(growable: false)
            ..sort((a, b) => a.value
                .toLowerCase()
                .indexOf(lowercaseQuery)
                .compareTo(b.value.toLowerCase().indexOf(lowercaseQuery)));
    } else {
      return const <Filter>[];
    }
  }

  static Widget genreSugestionBuilder(
      BuildContext context, ChipsInputState<Filter> state, Filter genre) {
    return ListTile(
      key: ObjectKey(genre),
      // TODO: Add leading avatar with book
      // leading: CircleAvatar(),
      title: Text(genre.value),
      subtitle: Text(genre.value),
      onTap: () => state.selectSuggestion(genre),
    );
  }

  // List of genre filters
  _GenreChipsState();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterCubit, FilterState>(builder: (context, filters) {
      return ChipsInput(
        initialValue: filters.filters[FilterType.genre],
        decoration: InputDecoration(
          labelText: "Genre",
        ),
        maxChips: 5,
        findSuggestions: findGenreSugestions,
        onChanged: (data) {
          context.bloc<FilterCubit>().changeFilters(FilterType.genre, data);
        },
        chipBuilder: chipBuilder,
        suggestionBuilder: genreSugestionBuilder,
      );
    });
  }
}

class PlaceChipsWidget extends StatefulWidget {
  PlaceChipsWidget({Key key}) : super(key: key);

  @override
  _PlaceChipsState createState() => _PlaceChipsState();
}

class _PlaceChipsState extends State<PlaceChipsWidget> {
  // TODo: Replace mock with real values
  static List<String> places = <String>[
    'Bukvoed',
    'Itaka',
    'Denis Stark',
    'Ernesto'
  ];

  static List<Filter> findPlaceSugestions(String query) {
    if (query.length != 0) {
      var lowercaseQuery = query.toLowerCase();
      return places
          .where((place) {
            return place.toLowerCase().contains(query.toLowerCase());
          })
          .map((g) => Filter(type: FilterType.place, value: g))
          .toList(growable: false)
            ..sort((a, b) => a.value
                .toLowerCase()
                .indexOf(lowercaseQuery)
                .compareTo(b.value.toLowerCase().indexOf(lowercaseQuery)));
    } else {
      return const <Filter>[];
    }
  }

  static Widget placeSugestionBuilder(
      BuildContext context, ChipsInputState<Filter> state, Filter place) {
    return ListTile(
      key: ObjectKey(place),
      // TODO: Add leading avatar with book
      // leading: CircleAvatar(),
      title: Text(place.value),
      subtitle: Text(place.value),
      onTap: () => state.selectSuggestion(place),
    );
  }

  // List of genre filters
  _PlaceChipsState();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterCubit, FilterState>(builder: (context, filters) {
      return ChipsInput(
        initialValue: filters.filters[FilterType.place],
        decoration: InputDecoration(
          labelText: "Place / Contact",
        ),
        maxChips: 5,
        findSuggestions: findPlaceSugestions,
        onChanged: (data) {
          context.bloc<FilterCubit>().changeFilters(FilterType.place, data);
        },
        chipBuilder: chipBuilder,
        suggestionBuilder: placeSugestionBuilder,
      );
    });
  }
}

class LanguageChipsWidget extends StatefulWidget {
  LanguageChipsWidget({Key key}) : super(key: key);

  @override
  _LanguageChipsState createState() => _LanguageChipsState();
}

class _LanguageChipsState extends State<LanguageChipsWidget> {
  // TODo: Replace mock with real values
  static List<String> languages = <String>['DEU', 'ENG', 'FRA', 'RUS'];

  static List<Filter> findLanguageSugestions(String query) {
    if (query.length != 0) {
      var lowercaseQuery = query.toLowerCase();
      return languages
          .where((genre) {
            return genre.toLowerCase().contains(query.toLowerCase());
          })
          .map((g) => Filter(type: FilterType.language, value: g))
          .toList(growable: false)
            ..sort((a, b) => a.value
                .toLowerCase()
                .indexOf(lowercaseQuery)
                .compareTo(b.value.toLowerCase().indexOf(lowercaseQuery)));
    } else {
      return const <Filter>[];
    }
  }

  static Widget languageSugestionBuilder(
      BuildContext context, ChipsInputState<Filter> state, Filter language) {
    return ListTile(
      key: ObjectKey(language),
      // TODO: Add leading avatar with book
      // leading: CircleAvatar(),
      title: Text(language.value),
      subtitle: Text(language.value),
      onTap: () => state.selectSuggestion(language),
    );
  }

  _LanguageChipsState();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterCubit, FilterState>(builder: (context, filters) {
      return ChipsInput(
        initialValue: filters.filters[FilterType.language],
        decoration: InputDecoration(
          labelText: "Language",
        ),
        maxChips: 5,
        findSuggestions: findLanguageSugestions,
        onChanged: (data) {
          context.bloc<FilterCubit>().changeFilters(FilterType.language, data);
        },
        chipBuilder: chipBuilder,
        suggestionBuilder: languageSugestionBuilder,
      );
    });
  }
}

Widget chipBuilder(
    BuildContext context, ChipsInputState<Filter> state, Filter filter) {
  Widget label;

  if (filter.type == FilterType.wish)
    label = Icon(Icons.favorite);
  else if (filter.type == FilterType.contacts)
    label = Icon(Icons.contact_phone);
  else
    label = Text(filter.value);

  return InputChip(
    key: ObjectKey(filter),
    //avatar: avatar,
    selected: filter.selected,
    label: label,
    // TODO: Put book icon here
    // avatar: CircleAvatar(),
    onDeleted:
        filter.type == FilterType.contacts || filter.type == FilterType.wish
            ? null
            : () {
                state.deleteChip(filter);
              },
    onPressed: () {
      state.setState(() {
        context.bloc<FilterCubit>().toggleFilter(filter.type, filter);
      });
    },
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );
}

class SearchPanel extends StatefulWidget {
  SearchPanel({Key key, this.collapsed}) : super(key: key);

  @override
  _SearchPanelState createState() => _SearchPanelState(collapsed);

  final bool collapsed;
}

class _SearchPanelState extends State<SearchPanel> {
  bool collapsed;

  _SearchPanelState(this.collapsed);

  @override
  void didUpdateWidget(covariant SearchPanel oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);

    if (oldWidget.collapsed != widget.collapsed) collapsed = widget.collapsed;
  }

  @override
  Widget build(BuildContext context) {
    if (collapsed) {
      return BlocBuilder<FilterCubit, FilterState>(builder: (context, filters) {
        return Container(
            margin: EdgeInsets.all(10.0),
            color: Colors.white,
            child: Wrap(
                spacing: 5.0,
                runSpacing: 5.0,
                children: filters.getSelected().map((f) {
                  Widget label;
                  if (f.type == FilterType.wish)
                    label = Icon(Icons.favorite);
                  else if (f.type == FilterType.contacts)
                    label = Icon(Icons.contact_phone);
                  else
                    label = Text(f.value);
                  return InputChip(
                    label: label,
                    // TODO: Put book icon here
                    // avatar: CircleAvatar(),
                    onDeleted: () {
                      context.bloc<FilterCubit>().toggleFilter(f.type, f);
                      setState(() {});
                    },
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }).toList()));
      });
    } else {
      return BlocBuilder<FilterCubit, FilterState>(builder: (context, filters) {
        return Column(children: [
          TitleChipsWidget(),
          GenreChipsWidget(),
          PlaceChipsWidget(),
          LanguageChipsWidget(),
        ]);
      });
    }
  }
}
