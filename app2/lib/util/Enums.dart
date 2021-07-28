enum LoginStatus {
  unknown, // Initial status
  unauthorized, // User not yet authorized
  phoneVerifying, // Button "Signin" pressed
  codeRequired, // Confirmation code required to be entered
  signInInProgress, // Sign-in with credential requested
  signedIn, // Confirmation code entered
  subscriptionInProgress, // Waiting for successful subscription
  subscribed // Subscribed
}

enum QueryType { books, places, photos }

enum FilterType { wish, title, author, contacts, place, genre, language }

enum FilterGroup { book, genre, language, place }

enum PlaceType { me, place, contact }
