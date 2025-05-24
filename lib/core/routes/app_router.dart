import 'package:erp_tassk/core/di/di.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/folder/data/repositories/folder_repository_impl.dart';
import '../../features/folder/domain/repositories/folder_repository.dart';
import '../../features/folder/presentation/cubit/folder_cubit.dart';
import '../../features/file/data/repositories/file_repository_impl.dart';
import '../../features/file/domain/repositories/file_repository.dart';
import '../../features/file/presentation/cubit/file_cubit.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/folder/presentation/pages/folder_page.dart';

class AppRouter {
  static const String login = '/';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => AuthCubit(
              authRepository: AuthRepositoryImpl(
                firebaseAuth: FirebaseAuth.instance,
                googleSignIn: GoogleSignIn(),
              ),
            ),
            child: const LoginPage(),
          ),
        );

      case signup:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => AuthCubit(
              authRepository: AuthRepositoryImpl(
                firebaseAuth: FirebaseAuth.instance,
                googleSignIn: GoogleSignIn(),
              ),
            ),
            child: const SignUpPage(),
          ),
        );

      case forgotPassword:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => AuthCubit(
              authRepository: AuthRepositoryImpl(
                firebaseAuth: FirebaseAuth.instance,
                googleSignIn: GoogleSignIn(),
              ),
            ),
            child: const ForgotPasswordPage(),
          ),
        );

      case home:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => FolderCubit(
              folderRepository: FolderRepositoryImpl(
                firestore: FirebaseFirestore.instance,
              ),
              userId: FirebaseAuth.instance.currentUser?.uid ?? '',
            ),
            child: const FolderPage(),
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
          settings: settings,
        );
    }
  }
}
