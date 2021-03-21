import 'package:biblosphere/model/Book.dart';
import 'package:biblosphere/model/Photo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Shelf {
  // Photo of the shelf
  Photo photo;

  // List of books
  List<Book> books;

  // Keep current book while switching between shelves
  int cursor;

  // Index of the selected book. Used for shelves created from Book record.
  int selected;

  Shelf._({this.photo, this.books, this.cursor, this.selected});

  static Future<Shelf> fromBook(Book book) async {
    if (book.photoId == null || book.photoId.isEmpty) {
      // TODO: Report an exception
      print('EXCEPTION: Book ${book.id} does not refer to the photo');
      return null;
    }

    // Read photo
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('photos')
        .doc(book.photoId)
        .get();

    if (!doc.exists) {
      // TODO: Report an exception
      print('EXCEPTION: No photo for book ${book.id}');
      return null;
    }

    Photo photo = Photo.fromJson(doc.id, doc.data());

    // Read books
    List<Book> books = await getBooks(photo);

    int selected = books.indexWhere((b) => b.isbn == book.isbn);

    if (selected == -1) {
      // TODO: Report an exception
      print('EXCEPTION: Book ${book.id} is not in the book list for its photo');
    }

    return Shelf._(photo: photo, books: books, cursor: 0, selected: selected);
  }

  static Future<Shelf> fromPhoto(Photo photo) async {
    // Read books
    List<Book> books = await getBooks(photo);

    return Shelf._(photo: photo, books: books, cursor: 0, selected: -1);
  }

  static Future<List<Book>> getBooks(Photo photo) async {
    // Read books from Firestore reference to the given photo
    Query query = FirebaseFirestore.instance
        .collection('books')
        .where('photo_id', isEqualTo: photo.id);

    QuerySnapshot snap = await query.get();

    // Group all books for geohash areas one level down
    List<Book> books =
    snap.docs.map((doc) => Book.fromJson(doc.id, doc.data())).toList();

    return books;
  }
}
