import 'dart:ui' as ui;

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';

class ImagePainter extends CustomPainter {
  ImagePainter({
    this.image,
  });

  ui.Image image;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(image, new Offset(0.0, 0.0), new Paint());
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

Future<String> buildLink(String query,
    {String image, String title, String description}) async {
  SocialMetaTagParameters socialMetaTagParameters;

  if (image != null)
    socialMetaTagParameters = SocialMetaTagParameters(
        title: title, description: description, imageUrl: Uri.parse(image));

  final DynamicLinkParameters parameters = new DynamicLinkParameters(
    uriPrefix: 'https://biblosphere.org/link',
    link: Uri.parse('https://biblosphere.org/$query'),
    androidParameters: AndroidParameters(
      packageName: 'com.biblosphere.biblosphere',
      minimumVersion: 0,
    ),
    dynamicLinkParametersOptions: DynamicLinkParametersOptions(
      shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short,
    ),
    iosParameters: IosParameters(
      bundleId: 'com.biblosphere.biblosphere',
      minimumVersion: '0',
    ),
    // TODO: S.of(context) does not work as it's a top Widget MyApp
    socialMetaTagParameters: socialMetaTagParameters,
    navigationInfoParameters:
        NavigationInfoParameters(forcedRedirectEnabled: true),
  );

  final ShortDynamicLink shortLink = await parameters.buildShortLink();

  return shortLink.shortUrl.toString();
}
