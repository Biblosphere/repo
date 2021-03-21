import 'package:biblosphere/util/Colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';

Widget bookImagePlaceholder() {
  return Container(
      height: 110.0,
      width: 110.0 * 2 / 3,
      child: Icon(Icons.menu_book, size: 50.0, color: placeholderColor));
}

Widget coverImage(String url, {double width, bool bookmark = false}) {
  Widget image;
  if (url != null && url.isNotEmpty)
    try {
      image = ClipRRect(
          borderRadius: BorderRadius.circular(4.0),
          child: width != null
//              ? Image.network(url, fit: BoxFit.fitWidth, width: width)
//              : Image.network(url));
              ? CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.fitWidth,
                  width: width,
                  placeholder: (context, text) => bookImagePlaceholder(),
                  errorWidget: (context, text, error) => bookImagePlaceholder())
              : CachedNetworkImage(
                  imageUrl: url,
                  placeholder: (context, text) => bookImagePlaceholder(),
                  errorWidget: (context, text, error) =>
                      bookImagePlaceholder()));
    } catch (e) {
      print('Image loading exception: $e');
      // TODO: Report exception to analytics
      image = Container(child: bookImagePlaceholder());
    }
  else
    image = Container(child: bookImagePlaceholder());

  return Stack(children: [
    Container(padding: EdgeInsets.all(4.0), child: image),
    if (bookmark)
      Positioned(
        left: 0.0,
        child: Align(
          alignment: Alignment.topLeft,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.all(
                Radius.circular(8.0),
              ),
            ),
            child: Icon(Icons.bookmark, color: bookmarkListColor),
          ),
        ),
      ),
  ]);
}

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
