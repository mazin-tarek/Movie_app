import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _localeKey = 'app_locale';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit() : super(const Locale('en')) {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString(_localeKey);

    if (savedLocale != null) {
      emit(Locale(savedLocale));
    }
  }

  Future<void> changeLocale(Locale newLocale) async {
    emit(newLocale);

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _localeKey,
      newLocale.languageCode,
    );
  }
}