import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

/// Persists the user's theme choice across launches (hydrated_bloc).
class ThemeCubit extends HydratedCubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system);

  void setThemeMode(ThemeMode mode) => emit(mode);

  void toggle() =>
      emit(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);

  @override
  ThemeMode? fromJson(Map<String, dynamic> json) =>
      ThemeMode.values.asNameMap()[json['themeMode'] as String?];

  @override
  Map<String, dynamic>? toJson(ThemeMode state) => {'themeMode': state.name};
}
