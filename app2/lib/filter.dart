part of 'main.dart';

Widget chipBuilder(BuildContext context, Filter filter) {
  print('!!!DEBUG chipBuilder ${filter.type}');

  IconData icon;
  Panel position = context.bloc<FilterCubit>().state.panel;

  if (filter.type == FilterType.place) {
    // TODO: Add leading avatar for people from the contact list
    //       with icon Icons.contact_phone
    if (filter.place.type == 'personal')
      icon = Icons.person;
    else if (filter.place.type == 'company')
      icon = Icons.store;
    else
      icon = Icons.location_pin;
  } else if (filter.group == FilterGroup.book) {
    if (filter.type == FilterType.title)
      icon = Icons.book;
    else if (filter.type == FilterType.author) icon = Icons.person;
  } else if (filter.type == FilterType.genre && position == Panel.minimized) {
    icon = Icons.account_tree;
  }

  // Permanent filters
  if (filter.type == FilterType.wish || filter.type == FilterType.contacts) {
    if (filter.type == FilterType.wish)
      icon = Icons.favorite;
    else if (filter.type == FilterType.contacts) icon = Icons.contact_phone;

    return InputChip(
      selected: filter.selected,
      // !!!DEBUG
      label: Icon(icon),
      // TODO: Put book icon here
      // avatar: CircleAvatar(),
      onPressed: () {
        print('!!!DEBUG Trigger onPressed for filter ${filter.type}');
        context.bloc<FilterCubit>().toggleFilter(filter.type, filter);
      },
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
    // Removable filters
  } else {
    Widget label;

    if (filter.type == FilterType.genre)
      label = Text(genres[filter.value]);
    else if (filter.type == FilterType.language && position == Panel.full)
      // Present full name of the language instead of code in FULL view
      label = Text(languages[filter.value]);
    else if (filter.type == FilterType.place && position == Panel.full) {
      // Add distance to location in FULL view
      LatLng location = context.bloc<FilterCubit>().state.center;
      label = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(filter.value),
        Text(distanceString(location, filter.place.location),
            style:
                Theme.of(context).textTheme.subtitle2.copyWith(fontSize: 10.0))
      ]);
    } else
      label = Text(filter.value, overflow: TextOverflow.fade);

    label = Row(
        mainAxisSize: MainAxisSize.min,
        children: [if (icon != null) Icon(icon), Flexible(child: label)]);

    if (position != Panel.full)
      label = ConstrainedBox(
          constraints: new BoxConstraints(
            maxWidth: 100.0,
          ),
          child: label);

    // Only show selection for full level (for suggestions)
    if (position == Panel.full)
      return InputChip(
        selected: filter.selected,
        label: label,
        // TODO: Put book icon here
        // avatar: CircleAvatar(),
        onDeleted: () {
          context.bloc<FilterCubit>().deleteFilter(filter);
        },
        onPressed: () {
          if (!filter.selected)
            print('!!!DEBUG Trigger Adding filter ${filter.type}');
          context
              .bloc<FilterCubit>()
              .addFilter(filter.copyWith(selected: true));
        },
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      );
    else
      return InputChip(
        label: label,
        // TODO: Put book icon here
        // avatar: CircleAvatar(),
        onDeleted: () {
          context.bloc<FilterCubit>().deleteFilter(filter);
        },
        onPressed: () {
          if (!filter.selected)
            print('!!!DEBUG Trigger Adding filter ${filter.type}');
          context
              .bloc<FilterCubit>()
              .addFilter(filter.copyWith(selected: true));
        },
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      );
  }
}

class SearchPanel extends StatefulWidget {
  SearchPanel({Key key}) : super(key: key);

  @override
  _SearchPanelState createState() => _SearchPanelState();
}

class _SearchPanelState extends State<SearchPanel> {
  TextEditingController _controller = TextEditingController();

  _SearchPanelState();

  Widget groupIcon(FilterGroup group) {
    IconData icon;
    if (group == FilterGroup.book)
      icon = Icons.menu_book;
    else if (group == FilterGroup.genre)
      icon = Icons.account_tree;
    else if (group == FilterGroup.place)
      icon = Icons.location_pin;
    else if (group == FilterGroup.language) icon = Icons.language;

    return Icon(icon);
  }

  Widget groupChips(
      BuildContext context, FilterState state, FilterGroup group) {
    double width = MediaQuery.of(context).size.width;
    return Container(
        width: width,
        height: 45.0,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(
            onPressed: () {
              context.bloc<FilterCubit>().groupSelectedForSearch(group);
            },
            icon: groupIcon(group),
          ),
          Flexible(
              child: Container(
                  margin: EdgeInsets.only(right: 10.0),
                  child: ShaderMask(
                      shaderCallback: (Rect rect) {
                        return LinearGradient(
                          begin: Alignment.centerRight,
                          end: Alignment.centerLeft,
                          colors: [
                            Colors.purple,
                            Colors.transparent,
                            Colors.transparent,
                            Colors.purple
                          ],
                          stops: [
                            0.0,
                            0.1,
                            0.985,
                            1.0
                          ], // 10% purple, 80% transparent, 10% purple
                        ).createShader(rect);
                      },
                      blendMode: BlendMode.dstOut,
                      child: ListView(
                          clipBehavior: Clip.antiAlias,
                          scrollDirection: Axis.horizontal,
                          children: state.getFilters(group).map((f) {
                            return chipBuilder(context, f);
                          }).toList()))))
        ]));
  }

  InputDecoration groupInputDecoration(FilterGroup group) {
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

  @override
  void didChangeDependencies() {
    // TODO: Make a code to do it only once at first call afer initState
    context.bloc<FilterCubit>().setSearchController(_controller);

    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant SearchPanel oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterCubit, FilterState>(builder: (context, state) {
      Panel position = state.panel;
      double width = MediaQuery.of(context).size.width;

      if (position == Panel.minimized) {
        // View with single wrap
        return OverflowBox(
            maxHeight: 400.0,
            alignment: Alignment.topLeft,
            child: Container(
                height: 45.0,
                alignment: Alignment.topLeft,
                margin: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                color: Colors.white,
                child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: state.compact.map((f) {
                      return chipBuilder(context, f);
                    }).toList())));
      } else if (position == Panel.open) {
        // View with four wraps
        return OverflowBox(
            maxHeight: 400.0,
            alignment: Alignment.topLeft,
            child: Container(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
              groupChips(context, state, FilterGroup.book),
              groupChips(context, state, FilterGroup.genre),
              groupChips(context, state, FilterGroup.place),
              groupChips(context, state, FilterGroup.language)
            ])));
      } else if (position == Panel.full) {
        // Full view with wrap of values and edit field
        FilterGroup group = state.group;
        List<Filter> suggestions = state.suggestions;

        print('!!!DEBUG build suggestions for $group');
        return Wrap(
            alignment: WrapAlignment.start,
            runAlignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 5.0,
            runSpacing: 5.0,
            children: [
              // Icon
              groupIcon(group),
              // Input field
              Container(
                width: width * 0.9,
                child: TextField(
                  autofocus: true,
                  maxLines: 1,
                  decoration: groupInputDecoration(group),
                  controller: _controller,
                  onEditingComplete: () {
                    FocusScope.of(context).unfocus();
                    context.bloc<FilterCubit>().searchEditComplete();
                  },
                ),
              ),
              // Selected filters
              ...state.getFilters(group).map((f) {
                return chipBuilder(context, f);
              }).toList(),
              if (suggestions != null)
                ...suggestions.take(15).map((f) {
                  return chipBuilder(context, f);
                }).toList()
            ]);
      } else {
        return Container();
      }
    });
  }
}
