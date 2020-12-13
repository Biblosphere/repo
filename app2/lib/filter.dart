part of 'main.dart';

Widget chipBuilder(BuildContext context, Filter filter) {
  //print('!!!DEBUG chipBuilder ${filter.type}');

  IconData icon;
  Panel position = context.bloc<FilterCubit>().state.panel;
  Widget chip;

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
      icon = Icons.bookmark;
    else if (filter.type == FilterType.contacts) icon = Icons.phone;

    chip = InputChip(
      showCheckmark: false,
      selectedColor: chipSelectedBackground,
      backgroundColor: chipUnselectedBackground,
      shadowColor: chipUnselectedBackground,
      selectedShadowColor: chipSelectedBackground,
      selected: filter.selected,
      // !!!DEBUG
      label: Icon(icon,
          color: filter.selected ? chipSelectedText : chipUnselectedText),
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
      label = Text(genres[filter.value],
          style: filter.selected
              ? chipSelectedTextStyle
              : chipUnselectedTextStyle);
    else if (filter.type == FilterType.language && position == Panel.full)
      // Present full name of the language instead of code in FULL view
      label = Text(languages[filter.value],
          style: filter.selected
              ? chipSelectedTextStyle
              : chipUnselectedTextStyle);
    else if (filter.type == FilterType.place && position == Panel.full) {
      // Add distance to location in FULL view
      LatLng location = context.bloc<FilterCubit>().state.center;
      label = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(filter.value,
            style: filter.selected
                ? chipSelectedTextStyle
                : chipUnselectedTextStyle),
        Text(distanceString(location, filter.place.location),
            style: Theme.of(context).textTheme.subtitle2.copyWith(
                fontSize: 10.0,
                color: filter.selected ? chipSelectedText : chipUnselectedText))
      ]);
    } else
      label = Text(filter.value,
          overflow: TextOverflow.fade,
          style: filter.selected
              ? chipSelectedTextStyle
              : chipUnselectedTextStyle);

    label = Row(mainAxisSize: MainAxisSize.min, children: [
      if (icon != null) Icon(icon, color: chipSelectedText),
      Flexible(child: label)
    ]);

    if (position != Panel.full)
      label = ConstrainedBox(
          constraints: new BoxConstraints(
            maxWidth: 100.0,
          ),
          child: label);

    // Only show selection for full level (for suggestions)
    if (position == Panel.full)
      chip = InputChip(
        showCheckmark: false,
        deleteIconColor:
            filter.selected ? chipSelectedText : chipUnselectedText,
        selectedColor: chipSelectedBackground,
        backgroundColor: chipUnselectedBackground,
        shadowColor: chipUnselectedBackground,
        selectedShadowColor: chipSelectedBackground,
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
      chip = InputChip(
        showCheckmark: false,
        selectedColor: chipSelectedBackground,
        backgroundColor: chipUnselectedBackground,
        shadowColor: chipUnselectedBackground,
        selectedShadowColor: chipSelectedBackground,
        deleteIconColor: chipSelectedText,
        selected: true,
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

  return Container(
      padding: EdgeInsets.only(left: 2.0, right: 2.0), child: chip);
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

    return Icon(icon, color: chipUnselectedText);
  }

  Widget groupChips(
      BuildContext context, FilterState state, FilterGroup group) {
    double width = MediaQuery.of(context).size.width;
    return Container(
        margin: EdgeInsets.only(left: 24.0, right: 24.0, top: 0.0, bottom: 8.0),
        decoration: placeDecoration(),
        width: width,
        height: 48.0,
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
                  child: shaderScroll(ListView(
                      clipBehavior: Clip.antiAlias,
                      scrollDirection: Axis.horizontal,
                      children: state.getFilters(group: group).map((f) {
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

    return inputDecoration(label);
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
    // Dispose editing controller
    print('!!!DEBUG Search panel dispose');
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
            maxHeight: 800.0,
            alignment: Alignment.topLeft,
            child: Container(
                constraints: BoxConstraints(
                  maxHeight: 48.0,
                  minHeight: 48.0,
                ),
                alignment: Alignment.topLeft,
                padding: EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 0.0),
                child: Container(
                    decoration: placeDecoration(),
                    height: 48.0,
                    alignment: Alignment.topLeft,
                    padding: EdgeInsets.only(left: 10.0, right: 10.0),
                    child: shaderScroll(ListView(
                        scrollDirection: Axis.horizontal,
                        children: state.compact.map((f) {
                          return chipBuilder(context, f);
                        }).toList())))));
      } else if (position == Panel.open) {
        // View with four wraps
        return OverflowBox(
            maxHeight: 800.0,
            alignment: Alignment.topLeft,
            child: Container(
//                decoration: boxDecoration(),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
              groupChips(context, state, FilterGroup.book),
              groupChips(context, state, FilterGroup.genre),
              groupChips(context, state, FilterGroup.place),
              groupChips(context, state, FilterGroup.language)
            ])));
      } else if (position == Panel.full) {
        // Full view with wrap of values and edit field
        FilterGroup group = state.group;
        List<Filter> suggestions = state.filterSuggestions;

        print('!!!DEBUG build suggestions for $group');
        return OverflowBox(
            maxHeight: 800.0,
            alignment: Alignment.topLeft,
            child: Container(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                  Container(
                      constraints:
                          BoxConstraints(maxHeight: 48.0, minHeight: 48.0),
                      margin:
                          EdgeInsets.only(left: 24.0, right: 24.0, bottom: 8.0),
                      padding: EdgeInsets.only(left: 10.0),
                      decoration: placeDecoration(),
                      child: Row(children: [
                        // Icon
                        groupIcon(group),
                        // Input field
                        Container(
                          margin: EdgeInsets.only(left: 8.0),
                          width: width - 48.0 - 80.0,
                          child: TextField(
                            cursorColor: cursorColor,
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
                      ])),
                  Container(
                      margin: EdgeInsets.only(left: 24.0, right: 24.0),
                      padding: EdgeInsets.only(
                          top: 10.0, bottom: 10.0, left: 8.0, right: 8.0),
                      decoration: placeDecoration(),
                      child: Container(
                          alignment: Alignment.topLeft,
                          child: Wrap(
                              alignment: WrapAlignment.start,
                              runAlignment: WrapAlignment.start,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 5.0,
                              runSpacing: 5.0,
                              children: [
                                // Selected filters
                                ...state.getFilters(group: group).map((f) {
                                  return chipBuilder(context, f);
                                }).toList(),
                                if (suggestions != null)
                                  ...suggestions.take(15).map((f) {
                                    return chipBuilder(context, f);
                                  }).toList()
                              ])))
                ])));
      } else {
        return Container();
      }
    });
  }
}
