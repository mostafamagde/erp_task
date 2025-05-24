import 'package:injectable/injectable.dart';

@Singleton()
class UserModel  {
  final String id;
  final String email;
  final String? displayName;
  final String? photoURL;
  final bool emailVerified;

  const UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.photoURL,
    this.emailVerified = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      photoURL: json['photoURL'] as String?,
      emailVerified: json['emailVerified'] as bool? ?? false,
    );
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