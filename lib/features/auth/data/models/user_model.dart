import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class UserModel {
  String id;
  String email;
  String name;
  String? photoUrl;
  String? phoneNumber;
  bool emailVerified;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    this.phoneNumber,
    this.emailVerified = false,
  });

  static final UserModel _singletonInstance = UserModel(
    id: '',
    email: '',
    name: '',
  );

  static UserModel get instance => _singletonInstance;

  void setFromFirebase(firebase_auth.User firebaseUser) {
    id = firebaseUser.uid;
    email = firebaseUser.email!;
    name = firebaseUser.displayName ?? '';
    photoUrl = firebaseUser.photoURL;
    emailVerified = firebaseUser.emailVerified;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'emailVerified': emailVerified,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      photoUrl: json['photoUrl'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      emailVerified: json['emailVerified'] as bool? ?? false,
    );
  }
}
