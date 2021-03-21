import 'package:biblosphere/model/Filter.dart';
import 'package:biblosphere/model/FilterCubit.dart';
import 'package:biblosphere/model/Panel.dart';
import 'package:biblosphere/util/Colors.dart';
import 'package:biblosphere/util/Consts.dart';
import 'package:biblosphere/util/Enums.dart';

// Gesture detector and URL launcher for PP and TOS
import 'package:flutter/material.dart';

// BLoC patterns
import 'package:flutter_bloc/flutter_bloc.dart';

// Google map
import 'package:google_maps_flutter/google_maps_flutter.dart';

Widget chipBuilder(BuildContext context, Filter filter) {
  IconData icon;
  Panel position = context.watch<FilterCubit>().state.panel;
  Widget chip;

  if (filter.type == FilterType.place) {
    // TODO: Add leading avatar for people from the contact list
    //       with icon Icons.contact_phone
    if (filter.place.type == PlaceType.contact ||
        filter.place.type == PlaceType.me)
      icon = Icons.person;
    else if (filter.place.type == PlaceType.place)
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
      label: Icon(icon,
          color: filter.selected ? chipSelectedText : chipUnselectedText),
      // TODO: Put book icon here
      // avatar: CircleAvatar(),
      onPressed: () {
        context.read<FilterCubit>().toggleFilter(filter.type, filter);
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
      LatLng location = context.watch<FilterCubit>().state.center;
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
          context.read<FilterCubit>().deleteFilter(filter);
        },
        onPressed: () {
          if (!filter.selected)
            context
                .read<FilterCubit>()
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
          context.read<FilterCubit>().deleteFilter(filter);
        },
        onPressed: () {
          if (!filter.selected)
            context
                .read<FilterCubit>()
                .addFilter(filter.copyWith(selected: true));
        },
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      );
  }

  return Container(
      padding: EdgeInsets.only(left: 2.0, right: 2.0), child: chip);
}
