import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StreakProvider with ChangeNotifier {
  int _currentStreak = 0;
  int _highestStreak = 0;

  int get currentStreak => _currentStreak;
  int get highestStreak => _highestStreak;

  Future<void> loadStreak() async {
    final prefs = await SharedPreferences.getInstance();
    _currentStreak = prefs.getInt('currentStreak') ?? 0;
    _highestStreak = prefs.getInt('highestStreak') ?? 0;
    notifyListeners();
  }

  Future<void> updateStreak() async {
    _currentStreak++;
    if (_currentStreak > _highestStreak) {
      _highestStreak = _currentStreak;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentStreak', _currentStreak);
    await prefs.setInt('highestStreak', _highestStreak);
    notifyListeners();
  }
}
