import 'package:erp_tassk/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/routes/app_router.dart';
import 'core/di/di.dart';
import 'core/theme/theme_cubit.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/folder/data/repositories/folder_repository_impl.dart';
import 'features/folder/presentation/cubit/folder_cubit.dart';
import 'features/auth/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  configureDependencies(); // Initialize dependency injection
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ThemeCubit(),
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            title: 'ERP Task',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: state.themeMode,
            onGenerateRoute: AppRouter.generateRoute,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
