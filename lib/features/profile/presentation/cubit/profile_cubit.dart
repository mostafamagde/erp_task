import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../features/auth/data/models/user_model.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ProfileCubit({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth,
        super(ProfileInitial());

  Future<void> loadProfile() async {
    try {
      emit(ProfileLoading());
      final user = _auth.currentUser;
      if (user == null) {
        emit(ProfileError('User not found'));
        return;
      }

      // Use the singleton instance
      final profile = UserModel.instance;
      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> updateProfile({
    String? name,
    String? phoneNumber,
  }) async {
    try {
      emit(ProfileLoading());
      final user = _auth.currentUser;
      if (user == null) {
        emit(ProfileError('User not found'));
        return;
      }

      final updates = <String, dynamic>{};
      if (name != null) {
        updates['name'] = name;
        UserModel.instance.name = name;
      }
      if (phoneNumber != null) {
        updates['phoneNumber'] = phoneNumber;
        UserModel.instance.phoneNumber = phoneNumber;
      }

      await _firestore.collection('users').doc(user.uid).update(updates);
      emit(ProfileLoaded(UserModel.instance));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
} 