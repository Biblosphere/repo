import 'package:camera/camera.dart';

/*
*******************************************
***************** Events ******************

FILTER PANEL:
\e10 Places filters on focuse => LOCATION (permission for Address Book)

CAMERA PANEL:
e17 Privacy changed => CAMERA
e18 Place/contact on focus => LOCATION (permission for Address Book)
e19 Place/contact changed => CAMERA
e20 Camera panel opened => CAMERA
e21 Filter panel closed => CAMERA

TRIPLE BUTTON
e22 Switch view
e25 Camera button pressed => CAMERA (Permission for Camera)

LIST VIEW
e26 Set favourite button pressed => BOOK
e27 Share button pressed => BOOK
e28 Contact owner button pressed => BOOK
e29 Tap on book card => BOOK

DETAILS
e34 Set favourite button pressed => BOOK
e35 Share button pressed => BOOK
e36 Contact owner button pressed => BOOK

*******************************************
***************** States ******************

BOOK => s04 Book details update (upload shelf image and last scan)

CAMERA => s05 Camera info changed

LOCATION => s06 Location changed

*******************************************
*************** Permissions ***************

- Location: on opening Map/List view for a first time (on start of screens)
- Camera: on opening Camera first time
- Address book: on focus for contact/place in filter panel
                on focus for contact/place in camera panel
                on activation My Contacts chips

*/
