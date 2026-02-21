import 'package:flutter/material.dart';

/// Constantes globales de l'application / Global app constants
class AppConstants {
  // SRS defaults
  static const double defaultEaseFactor = 2.5;
  static const int knownCardIntervalDays = 30;
  static const int newCardIntervalDays = 1;

  // Gamification points
  static const int pointsAgain = 5;
  static const int pointsHard = 10;
  static const int pointsGood = 15;
  static const int pointsEasy = 25;
  static const int streakBonus = 50;

  // Badge thresholds
  static const int badgeDebutantPoints = 500;
  static const int badgeSamouraiPoints = 2000;
  static const int badgeSenseiPoints = 5000;
  static const int badgeStreak7 = 7;
  static const int badgeStreak30 = 30;
  static const int badgeStreak100 = 100;

  // UI
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 12.0;

  // Couleurs des boutons de qualité / Quality button colors
  static const Color againColor = Color(0xFFE53935); // Rouge
  static const Color hardColor = Color(0xFFFF9800);   // Orange
  static const Color goodColor = Color(0xFF4CAF50);   // Vert
  static const Color easyColor = Color(0xFF2196F3);   // Bleu
}
