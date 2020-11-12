part of 'main.dart';

class ChipsListWidget extends StatefulWidget {
  final FilterGroup group;
  final LatLng location;

  ChipsListWidget({key, this.group, this.location}) : super(key: key);

  @override
  _ChipsListState createState() =>
      _ChipsListState(group: group, location: location);
}

class _ChipsListState extends State<ChipsListWidget> {
  final FilterGroup group;
  LatLng location;

  static Future<List<Filter>> findTitleSugestions(String query) async {
    if (query.length < 4) return const <Filter>[];

    var lowercase = query.toLowerCase();

    // Query in database catalog
    List<Book> books = await searchByText(lowercase);

    print('!!!DEBUG: Catalog query return ${books?.length} records');

    if (books == null) return const <Filter>[];

    // If author match use FilterType.author, otherwise FilterType.title
    return books
        //  .where((b) =>
        //      b.title.toLowerCase().contains(lowercase) ||
        //      b.authors.join().toLowerCase().contains(lowercase))
        .map((b) {
          String matchAuthor = b.authors.firstWhere(
              (a) => lowercase
                  .split(' ')
                  .every((word) => a.toLowerCase().contains(word)),
              orElse: () => null);

          if (matchAuthor != null)
            return Filter(
                type: FilterType.author, selected: true, value: matchAuthor);
          else
            return Filter(
                type: FilterType.title,
                selected: true,
                value: b.title,
                book: b);
        })
        .toSet()
        .toList();
  }

  static Widget titleSugestionBuilder(
      BuildContext context, ChipsInputState<Filter> state, Filter filter) {
    if (filter.type == FilterType.title)
      return ListTile(
        key: ObjectKey(filter),
        leading: Icon(Icons.book),
        title: Text(filter.value),
        subtitle: filter.book != null ? Text(filter.book.authors.first) : null,
        onTap: () => state.selectSuggestion(filter),
      );
    else
      return ListTile(
        key: ObjectKey(filter),
        leading: Icon(Icons.person),
        title: Text(filter.value),
        subtitle: null,
        onTap: () => state.selectSuggestion(filter),
      );
  }

  static List<Filter> findGenreSugestions(String query) {
    if (query.length != 0) {
      var lowercaseQuery = query.toLowerCase();
      return genres.keys
          .where((key) {
            return genres[key].toLowerCase().contains(query.toLowerCase());
          })
          .map((key) =>
              Filter(type: FilterType.genre, selected: true, value: key))
          .toList(growable: false)
            ..sort((a, b) => genres[a.value]
                .toLowerCase()
                .indexOf(lowercaseQuery)
                .compareTo(
                    genres[b.value].toLowerCase().indexOf(lowercaseQuery)));
    } else {
      return const <Filter>[];
    }
  }

  static Widget genreSugestionBuilder(
      BuildContext context, ChipsInputState<Filter> state, Filter filter) {
    return ListTile(
      key: ObjectKey(filter),
      // TODO: Add leading avatar with book
      // leading: CircleAvatar(),
      title: Text(genres[filter.value]),
      subtitle: null,
      onTap: () => state.selectSuggestion(filter),
    );
  }

  List<Filter> findPlaceSugestions(String query) {
    // TODO: If access to address book is allowed (contacts is not null)
    //       add all contacts to the list with it's distance.

    // Query bookplaces in a radius of 5 km (same hash length 5) to current
    // location. Sort it by distance ascending (closest places first).

    // TODO: Take care about locations near equator and 0/180 longitude.
    List<Place> places = context.bloc<FilterCubit>().state.places;

    if (places != null) {
      if (query.length == 0) {
        print('!!!DEBUG length 0');
        places = places.sublist(0, min(5, places.length));
      } else if (query.length > 0) {
        places = places.where((p) {
          return p.name.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }

      // No need to sort as places already sorted by distance
      return places
          .map((p) => Filter(
              type: FilterType.place, value: p.name, selected: true, place: p))
          .toList(growable: false);
    } else {
      return const <Filter>[];
    }
  }

  Widget placeSugestionBuilder(
      BuildContext context, ChipsInputState<Filter> state, Filter filter) {
    IconData icon;

    // TODO: Add leading avatar for people from the contact list
    //       with icon Icons.contact_phone
    if (filter.place.type == 'personal')
      icon = Icons.person;
    else if (filter.place.type == 'company')
      icon = Icons.store;
    else
      icon = Icons.location_pin;

    return ListTile(
      key: ObjectKey(filter),
      leading: Icon(icon),
      title: Text(filter.value),
      subtitle: location != null
          ? Text(distanceString(location, filter.place.location))
          : null,
      onTap: () => state.selectSuggestion(filter),
    );
  }

  static List<Filter> findLanguageSugestions(String query) {
    if (query.length != 0) {
      return languages.keys
          .where((key) {
            return key.toLowerCase().contains(query.toLowerCase()) ||
                languages[key].toLowerCase().contains(query.toLowerCase());
          })
          .map((key) =>
              Filter(type: FilterType.language, selected: true, value: key))
          .toList(growable: false);
    } else {
      return const <Filter>[];
    }
  }

  static Widget languageSugestionBuilder(
      BuildContext context, ChipsInputState<Filter> state, Filter filter) {
    return ListTile(
      key: ObjectKey(filter),
      // TODO: Add leading avatar with book
      // leading: CircleAvatar(),
      title: Text(languages[filter.value]),
      subtitle: Text(filter.value),
      onTap: () => state.selectSuggestion(filter),
    );
  }

  // List of genre filters
  _ChipsListState({this.group, this.location});

  @override
  void didUpdateWidget(ChipsListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.location != oldWidget.location) location = widget.location;
  }

  InputDecoration decoration() {
    String label = '';
    if (group == FilterGroup.book)
      label = "Title / Author";
    else if (group == FilterGroup.genre)
      label = "Genre";
    else if (group == FilterGroup.place)
      label = "Place / Contact";
    else if (group == FilterGroup.language) label = "Language";

    return InputDecoration(labelText: label);
  }

  Future<List<Filter>> findSugestions(String query) async {
    if (group == FilterGroup.book)
      return findTitleSugestions(query);
    else if (group == FilterGroup.genre)
      return findGenreSugestions(query);
    else if (group == FilterGroup.place)
      return findPlaceSugestions(query);
    else if (group == FilterGroup.language)
      return findLanguageSugestions(query);
    else
      return [];
  }

  Widget sugestionBuilder(
      BuildContext context, ChipsInputState<Filter> state, Filter filter) {
    if (group == FilterGroup.book)
      return titleSugestionBuilder(context, state, filter);
    else if (group == FilterGroup.genre)
      return genreSugestionBuilder(context, state, filter);
    else if (group == FilterGroup.place)
      return placeSugestionBuilder(context, state, filter);
    else if (group == FilterGroup.language)
      return languageSugestionBuilder(context, state, filter);
    else
      return Container();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterCubit, FilterState>(builder: (context, filters) {
      return ChipsInput(
        initialValue: filters.getFilters(group),
        decoration: decoration(),
        maxChips: 5,
        findSuggestions: findSugestions,
        suggestionBuilder: sugestionBuilder,
        onChanged: (data) {
          context.bloc<FilterCubit>().changeFilters(group, data);
        },
        chipBuilder: chipBuilder,
      );
    });
  }
}

Widget chipBuilder(
    BuildContext context, ChipsInputState<Filter> state, Filter filterInput) {
  print('!!!DEBUG chipBuilder ${filterInput.type}');

  Widget label;

  if (filterInput.type == FilterType.wish)
    label = Icon(Icons.favorite);
  else if (filterInput.type == FilterType.contacts)
    label = Icon(Icons.contact_phone);
  else if (filterInput.type == FilterType.genre)
    label = ConstrainedBox(
        constraints: new BoxConstraints(
          maxWidth: 100.0,
        ),
        child: Text(genres[filterInput.value]));
  else
    label = ConstrainedBox(
        constraints: new BoxConstraints(
          maxWidth: 100.0,
        ),
        child: Text(filterInput.value));

  return BlocBuilder<FilterCubit, FilterState>(builder: (context, filters) {
    Filter filter = filters.filters.firstWhere(
        (f) => f.type == filterInput.type && f.value == filterInput.value,
        orElse: null);
    if (filter == null) {
      print('!!!DEBUG Could not find filter on build ${filter.type}');
      return Container();
    }

    return InputChip(
      key: ObjectKey(filter),
      //avatar: avatar,
      selected: filter.selected ?? false,
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
        print('!!!DEBUG Trigger onPressed for filter ${filter.type}');
        state.setState(() {
          print(
              '!!!DEBUG Trigger setState/onPressed for filter ${filter.type}');

          context.bloc<FilterCubit>().toggleFilter(filter.type, filter);
        });
      },
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  });
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
                  else if (f.type == FilterType.genre)
                    label = ConstrainedBox(
                        constraints: new BoxConstraints(
                          maxWidth: 100.0,
                        ),
                        child: Text(genres[f.value]));
                  else
                    label = ConstrainedBox(
                        constraints: new BoxConstraints(
                          maxWidth: 100.0,
                        ),
                        child: Text(f.value));
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
          ChipsListWidget(
            group: FilterGroup.book,
          ),
          ChipsListWidget(group: FilterGroup.genre),
          ChipsListWidget(group: FilterGroup.place, location: filters.center),
          ChipsListWidget(group: FilterGroup.language),
        ]);
      });
    }
  }
}
