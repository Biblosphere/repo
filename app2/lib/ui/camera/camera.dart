import 'package:biblosphere/model/FilterState.dart';
import 'package:biblosphere/model/Place.dart';
import 'package:biblosphere/model/Privacy.dart';
import 'package:biblosphere/util/Colors.dart';
import 'package:biblosphere/util/Enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cubit/flutter_cubit.dart';

import 'MapCubit.dart';

Widget chipBuilderCamera(BuildContext context, Place place,
    {bool selected = false}) {
  if (place == null) {
    print('EXCEPTION: Place is null');
    // TODO: Exception handling and report to crashalytic
    return Container();
  }

  if (place.name == null) {
    print('EXCEPTION: Place NAME is null');
    // TODO: Exception handling and report to crashalytic
    return Container();
  }

  Widget chip =
      CubitBuilder<MapCubit, FilterState>(builder: (context, state) {
    IconData icon;

    if (place.type == PlaceType.me || place.type == PlaceType.contact) {
      icon = Icons.person;
    } else {
      if (place.type == PlaceType.place) icon = Icons.store_mall_directory;
    }

    return InputChip(
      showCheckmark: false,
      selectedColor: chipSelectedBackground,
      backgroundColor: chipUnselectedBackground,
      shadowColor: chipUnselectedBackground,
      selectedShadowColor: chipSelectedBackground,
      label: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: selected ? chipSelectedText : chipUnselectedText),
            Text(place.name,
                style:
                    selected ? chipSelectedTextStyle : chipUnselectedTextStyle)
          ]),
      // TODO: Put book icon here
      // avatar: CircleAvatar(),
      selected: selected,
      onPressed: () {
        context.cubit<MapCubit>().setPlace(place);
      },
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  });

  return Container(
      padding: EdgeInsets.only(left: 2.0, right: 2.0), child: chip);
}

Widget chipBuilderPrivacy(BuildContext context, Privacy privacy, bool selected,
    {double width}) {
  String label = '';
  IconData icon;

  if (privacy == Privacy.private) {
    label = 'Only me';
    icon = Icons.lock;
  } else if (privacy == Privacy.contacts) {
    label = 'Contacts';
    icon = Icons.people;
  } else if (privacy == Privacy.all) {
    label = 'Everybody';
    icon = Icons.language;
  }

  Widget chip = InputChip(
    showCheckmark: false,
    selectedColor: chipSelectedBackground,
    backgroundColor: chipUnselectedBackground,
    shadowColor: chipUnselectedBackground,
    selectedShadowColor: chipSelectedBackground,
    selected: selected,
    label: Container(
        width: width,
        //constraints: BoxConstraints(minWidth: width, maxWidth: width),
        child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (icon != null)
                Icon(icon,
                    color: selected ? chipSelectedText : chipUnselectedText),
              Flexible(
                  child: Text(label,
                      style: selected
                          ? chipSelectedTextStyle
                          : chipUnselectedTextStyle))
            ])),
    onPressed: () {
      context.cubit<MapCubit>().setPrivacy(privacy);
    },
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );

  return Container(
      padding: EdgeInsets.only(left: 2.0, right: 2.0), child: chip);
}
