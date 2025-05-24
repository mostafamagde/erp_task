import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/routes/app_router.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/folder/data/repositories/folder_repository_impl.dart';
import 'features/folder/presentation/cubit/folder_cubit.dart';
import 'features/auth/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => FolderCubit(
            folderRepository: FolderRepositoryImpl(
              firestore: FirebaseFirestore.instance,
            ),
            userId: UserModel.instance.id ?? '',
          ),
        ),
      ],
      child: MaterialApp(
        title: 'ERP Task',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        onGenerateRoute: AppRouter.generateRoute,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
