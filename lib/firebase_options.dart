// File generated manually for Firebase project: nutrilenspro
// FlutterFire CLI equivalent configuration

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAb8UAwx09WNoeCiUhG6uDIh5_RMx6Vj5A',
    appId: '1:1044231359291:android:0e5c3be68f33ebd73a051e',
    messagingSenderId: '1044231359291',
    projectId: 'nutrilenspro',
    storageBucket: 'nutrilenspro.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA0FCChid68BOL2gT0mbNBWQjD464PGFA4',
    appId: '1:1044231359291:ios:ecbec2dee9bd081e3a051e',
    messagingSenderId: '1044231359291',
    projectId: 'nutrilenspro',
    storageBucket: 'nutrilenspro.firebasestorage.app',
    iosBundleId: 'com.nutrilens.pro',
  );
}
