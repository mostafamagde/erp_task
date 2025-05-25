// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:firebase_storage/firebase_storage.dart' as _i457;
import 'package:get_it/get_it.dart' as _i174;
import 'package:google_sign_in/google_sign_in.dart' as _i116;
import 'package:injectable/injectable.dart' as _i526;

import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i153;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/file/data/repositories/file_repository_impl.dart'
    as _i997;
import '../../features/file/domain/repositories/file_repository.dart' as _i49;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.factory<_i787.AuthRepository>(() => _i153.AuthRepositoryImpl(
          firebaseAuth: gh<_i59.FirebaseAuth>(),
          googleSignIn: gh<_i116.GoogleSignIn>(),
        ));
    gh.factory<_i49.FileRepository>(() => _i997.FileRepositoryImpl(
          firestore: gh<_i974.FirebaseFirestore>(),
          storage: gh<_i457.FirebaseStorage>(),
        ));
    return this;
  }
}
