
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class UserModel {
  String? id;
  String? email;
  String? displayName;
  String? photoURL;
  bool? emailVerified;

  UserModel._();

  static final UserModel _singletonInstance = UserModel._();

  static UserModel get instance => _singletonInstance;

  void setFromFirebase(firebase_auth.User firebaseUser) {
    id= firebaseUser.uid;
    email= firebaseUser.email!;
    displayName=firebaseUser.displayName;
    photoURL= firebaseUser.photoURL;
    emailVerified=firebaseUser.emailVerified;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'emailVerified': emailVerified,
    };
  }
}
