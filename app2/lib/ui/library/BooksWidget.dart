import 'package:biblosphere/model/Book.dart';
import 'package:biblosphere/model/FilterCubit.dart';
import 'package:biblosphere/model/FilterState.dart';
import 'package:biblosphere/model/Photo.dart';
import 'package:biblosphere/model/Shelf.dart';
import 'package:biblosphere/util/Colors.dart';
import 'package:biblosphere/util/TextStyle.dart';
import 'package:biblosphere/ui/library/books_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class BooksWidget extends StatefulWidget {
  BooksWidget({Key key}) : super(key: key);

  @override
  _BooksWidgetState createState() => _BooksWidgetState();
}

class _BooksWidgetState extends State<BooksWidget> {
  BooksBloc _booksBloc;

  _BooksWidgetState();

  @override
  void initState() {
    super.initState();
    _booksBloc = BooksBloc();
  }

  @override
  void didUpdateWidget(covariant BooksWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterCubit, FilterState>(
        // buildWhen: (previous, current) => previous.center != current.center,
        builder: (context, state) {
      // double width = MediaQuery.of(context).size.width;
      // double height = MediaQuery.of(context).size.height;
      // TODO: Add scroll controller to scroll list to selected shelf

      // List view with horizontal scrolling
      return SafeArea(child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        double height = constraints.maxHeight;
        double width = constraints.maxWidth;
        return Container(
            width: width,
            height: height,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: PageScrollPhysics(),
              itemCount: state.maxShelves,
              cacheExtent: 2 * width,
              itemBuilder: (context, item) {
                // If last element is requested then fetch more items
                if (item == state.shelfList.length - 1) {
                  print('!!!DEBUG last shelf fetched $item');
                  BlocProvider.of<FilterCubit>(context).shelvesFetched();
                }

                if (item >= state.shelfList.length) {
                  print(
                      '!!!DEBUG shelf outside range requested $item, ${state.shelfList.length}');
                  return Container();
                }

                Shelf shelf = state.shelfList[item];
                String distance =
                    distanceString(state.center, shelf.photo.location);

                // TODO: Add scroll controller to scroll list to selected item
                print('DEBUG!!! ${shelf.photo.id} ${shelf.photo.thumbnail}');

                // Build a card with a photo and a book list
                return Container(
                    width: width,
                    height: height,
                    child: Column(
                      children: [
                        // Photo card
                        Container(
                            width: width,
                            height: 0.5 * height,
                            padding: EdgeInsets.only(
                                right: 8.0, left: 8.0, top: 2.0, bottom: 4.0),
                            child: Container(
                                padding: EdgeInsets.all(2.0),
                                color: Colors.white.withOpacity(0.85),
                                child: Stack(children: [
                                  Container(
                                      height: 0.5 * height - 10.0,
                                      width: width - 20.0,
                                      child: GestureDetector(
                                          onDoubleTap: () {
                                            Navigator.push(context,
                                                new MaterialPageRoute(
                                                    builder: (context) {
                                              return Scaffold(
                                                  appBar: AppBar(),
                                                  body: PhotoView(
                                                    minScale: 0.1,
                                                    imageProvider:
                                                        CachedNetworkImageProvider(
                                                            shelf.photo.url),
                                                  ));
                                            }));
                                          },
                                          child: CachedNetworkImage(
                                              fit: BoxFit.cover,
                                              imageUrl:
                                                  shelf.photo.thumbnail))),
                                  Positioned.fill(
                                      right: 0.0,
                                      bottom: 0.0,
                                      child: Container(
                                          margin: EdgeInsets.only(bottom: 2.0),
                                          child: photoButtons(
                                              context, state, shelf.photo)))
                                ]))),
                        // Book cards
                        Container(
                            width: width,
                            height: 0.5 * height,
                            child: ListView(
                                scrollDirection: Axis.horizontal,
                                physics: PageScrollPhysics(),
                                children: shelf.books.map((b) {
                                  // Build a card for the book
                                  return Container(
                                      width: width,
                                      height: 0.5 * height,
                                      padding: EdgeInsets.only(
                                          right: 8.0,
                                          left: 8.0,
                                          top: 4.0,
                                          bottom: 8.0),
                                      child: Container(
                                          color: Colors.white.withOpacity(0.85),
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                //CachedNetworkImage(imageUrl: b.cover)
                                                Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      coverImage(b.cover,
                                                          bookmark: state
                                                              .isUserBookmark(
                                                                  b),
                                                          width: 80),
                                                      Expanded(
                                                          child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                            Container(
                                                                margin:
                                                                    EdgeInsets
                                                                        .all(
                                                                            2.0),
                                                                child:
                                                                    bookButtons(
                                                                        context,
                                                                        state,
                                                                        b)),
                                                            Container(
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        top:
                                                                            4.0,
                                                                        bottom:
                                                                            2.0,
                                                                        left:
                                                                            4.0),
                                                                child: Text(
                                                                    'Genre: ' +
                                                                        b.genreText,
                                                                    style: genreDetailsStyle)),
                                                            Container(
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        bottom:
                                                                            2.0,
                                                                        left:
                                                                            4.0),
                                                                child: Text(
                                                                    'Language: ' +
                                                                        b.languageText,
                                                                    style: languageDetailsStyle)),
                                                            Container(
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        left:
                                                                            4.0,
                                                                        bottom:
                                                                            2.0),
                                                                child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Flexible(
                                                                          flex:
                                                                              1,
                                                                          child: Text(
                                                                              distance,
                                                                              style: distanceDetailsStyle)),
                                                                      Icon(Icons
                                                                          .location_pin),
                                                                      Flexible(
                                                                          flex:
                                                                              3,
                                                                          child: Text(
                                                                              b.place,
                                                                              style: placeDetailsStyle))
                                                                    ]))
                                                          ]))
                                                    ]),
                                                Flexible(
                                                    flex: 1,
                                                    child: Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                                bottom: 4.0,
                                                                left: 8.0,
                                                                right: 16.0,
                                                                top: 8.0),
                                                        child: Text(
                                                            b.authors
                                                                .join(', '),
                                                            style:
                                                                authorDetailsStyle))),
                                                Flexible(
                                                    flex: 3,
                                                    child: Container(
                                                        margin: EdgeInsets.only(
                                                            bottom: 8.0,
                                                            left: 8.0,
                                                            right: 16.0,
                                                            top: 4.0),
                                                        child: Text(
                                                            b.title ?? '',
                                                            style:
                                                                titleDetailsStyle))),
                                              ])));
                                }).toList()))
                      ],
                    ));
              },
            ));
      }));
    });
  }

  Widget photoButtons(BuildContext context, FilterState state, Photo photo) {
    return Container(
        alignment: Alignment.bottomRight,
        child: Container(
            child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
              // Problem button
              detailsButton(
                  icon: Icons.report_problem,
                  onPressed: () {},
                  selected: false),
              // Message button
              detailsButton(
                  icon: Icons.phone,
                  // book.phone != null ? Icons.phone : Icons.email,
                  onPressed: () => contactHost(photo),
                  selected: false),
              // Share button
              detailsButton(
                  icon: Icons.share,
                  onPressed: () => sharePhoto(photo),
                  selected: false),
            ])));
  }

  Widget bookButtons(BuildContext context, FilterState state, Book book) {
    return Container(
        alignment: Alignment.topRight,
        child: Container(
            child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
              // Bookmark button
              detailsButton(
                  icon: Icons.bookmark,
                  onPressed: () {
                    if (state.isUserBookmark(book)) {
                      BlocProvider.of<FilterCubit>(context)
                          .removeUserBookmark(book);
                    } else {
                      BlocProvider.of<FilterCubit>(context)
                          .addUserBookmark(book);
                    }
                    // TODO: button state does not refrest without setState
                    setState(() {});
                  },
                  selected: state.isUserBookmark(book)),
/*
                                // Problem button
                                detailsButton(
                                    icon: Icons.report_problem,
                                    onPressed: () {},
                                    selected: false),
*/
              // Search book button
              detailsButton(
                  icon: Icons.search,
                  onPressed: () {
                    context.read<FilterCubit>().searchBookPressed(book);
                  }),
              // Share button
              detailsButton(
                  icon: Icons.share,
                  onPressed: () => shareBook(book),
                  selected: false),
            ])));
  }

  void contactHost(Photo photo) async {
    String url;
    if (photo.phone != null)
      url = 'tel:${photo.phone}';
    else if (photo.email != null)
      url = 'mailto:${photo.email}';
    else if (photo.web != null)
      url = '${photo.email}';
    else {
      print('EXCEPTION: Book does not have none of mobile, email or web');
      // TODO: Log an exception
    }

    if (url != null && await canLaunch(url)) {
      await launch(url);
    } else {
      print('EXCEPTION: Could not launch contact owner action');
      // TODO: Log an exception
    }
  }

  void sharePhoto(Photo photo) async {
    // TODO: include picture into the photo's link
    String link = await _booksBloc.buildLink('photo?id=${photo.id}&name=${photo.name}',
        image: photo.thumbnail,
        title: 'Biblosphere',
        description: 'Look at these books');

    Share.share(link, subject: '"${photo.name}" on Biblosphere');
  }

  void shareBook(Book book) async {
    String link = await _booksBloc.buildLink('book?isbn=${book.isbn}&title=${book.title}');

    Share.share(link, subject: '"${book.title}" on Biblosphere');
  }
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

Widget bookImagePlaceholder() {
  return Container(
      height: 110.0,
      width: 110.0 * 2 / 3,
      child: Icon(Icons.menu_book, size: 50.0, color: placeholderColor));
}

Widget detailsButton(
    {IconData icon, VoidCallback onPressed, bool selected = false}) {
  return Container(
      width: 45.0,
      height: 45.0,
      //margin: EdgeInsets.all(2.0),
      padding: EdgeInsets.all(2.0),
      child: MaterialButton(
        elevation: 0.0,
        onPressed: onPressed,
        color: selected ? buttonSelectedBackground : buttonUnselectedBackground,
        textColor: selected ? buttonSelectedText : buttonUnselectedText,
        child: Icon(
          icon,
          size: 20,
        ),
        padding: EdgeInsets.all(0.0),
        shape: CircleBorder(
            side: BorderSide(
                color: selected ? buttonSelectedBorder : buttonBorder,
                width: 2.0)),
      ));
}
