import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../../../features/profile/presentation/pages/profile_page.dart';
import '../../../../features/profile/presentation/cubit/profile_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider(
                    create: (context) => ProfileCubit(
                      firestore: FirebaseFirestore.instance,
                      auth: FirebaseAuth.instance,
                    ),
                    child: const ProfilePage(),
                  ),
                ),
              );
            },
          ),

          BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, state) {
              return ExpansionTile(
                leading: const Icon(Icons.palette),
                title: const Text('Theme'),
                children: [
                  RadioListTile<ThemeMode>(
                    title: const Text('System'),
                    value: ThemeMode.system,
                    groupValue: state.themeMode,
                    onChanged: (ThemeMode? value) {
                      if (value != null) {
                        context.read<ThemeCubit>().setTheme(value);
                      }
                    },
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text('Light'),
                    value: ThemeMode.light,
                    groupValue: state.themeMode,
                    onChanged: (ThemeMode? value) {
                      if (value != null) {
                        context.read<ThemeCubit>().setTheme(value);
                      }
                    },
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text('Dark'),
                    value: ThemeMode.dark,
                    groupValue: state.themeMode,
                    onChanged: (ThemeMode? value) {
                      if (value != null) {
                        context.read<ThemeCubit>().setTheme(value);
                      }
                    },
                  ),
                ],
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              context.read<AuthCubit>().signOut();
              Navigator.pushNamedAndRemoveUntil(context, AppRouter.login, (route) => false);
            },
          ),
        ],
      ),
    );
  }
} 