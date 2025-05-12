import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'core/routes/app_router.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/folder/data/repositories/folder_repository_impl.dart';
import 'features/folder/domain/repositories/folder_repository.dart';
import 'features/folder/presentation/cubit/folder_cubit.dart';
import 'features/folder/presentation/pages/folder_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => AuthRepositoryImpl(
            firebaseAuth: FirebaseAuth.instance,
            googleSignIn: GoogleSignIn(),
          ),
        ),
        RepositoryProvider(
          create: (context) => FolderRepositoryImpl(
            firestore: FirebaseFirestore.instance,
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthCubit(
              authRepository: context.read<AuthRepositoryImpl>(),
            ),
          ),
          BlocProvider(
            create: (context) {
              final authState = context.read<AuthCubit>().state;
              if (authState is AuthAuthenticated) {
                return FolderCubit(
                  folderRepository: context.read<FolderRepositoryImpl>(),
                  userId: authState.user.id,
                );
              }
              return FolderCubit(
                folderRepository: context.read<FolderRepositoryImpl>(),
                userId: '', // This will be updated when user logs in
              );
            },
          ),
        ],
        child: MaterialApp(
          title: 'ERP Task',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            useMaterial3: true,
          ),
          onGenerateRoute: AppRouter.generateRoute,
          home: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated) {
                // Update FolderCubit with new user ID when authenticated
                context.read<FolderCubit>().loadFolders();
                return const FolderPage();
              }
              return const LoginPage();
            },
          ),
        ),
      ),
    );
  }
}
