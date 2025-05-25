import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeState(ThemeMode.system));

  void setTheme(ThemeMode mode) {
    emit(ThemeState(mode));
  }

  void toggleTheme() {
    final newMode = state.themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    setTheme(newMode);
  }
} 