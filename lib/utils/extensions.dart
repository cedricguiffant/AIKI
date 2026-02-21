import 'package:intl/intl.dart';

/// Extensions utilitaires / Utility extensions

extension DateTimeExt on DateTime {
  /// Formate la date en format lisible / Format date as readable string
  String toReadableDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(year, month, day);
    final diff = today.difference(date).inDays;

    if (diff == 0) return "Aujourd'hui";
    if (diff == 1) return 'Hier';
    if (diff < 7) return 'Il y a $diff jours';
    return DateFormat('dd/MM/yyyy').format(this);
  }

  /// Retourne uniquement la date (sans l'heure) / Date only (no time)
  DateTime get dateOnly => DateTime(year, month, day);
}

extension StringExt on String {
  /// Tronque la chaîne si elle dépasse la longueur max
  /// Truncate string if it exceeds max length
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - suffix.length)}$suffix';
  }

  /// Vérifie si la chaîne contient des caractères japonais
  /// Check if string contains Japanese characters
  bool get containsJapanese {
    return contains(RegExp(r'[\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FFF]'));
  }
}

extension IntExt on int {
  /// Formate un nombre avec séparateur de milliers / Format with thousands separator
  String toFormattedString() {
    return NumberFormat('#,###').format(this);
  }
}
