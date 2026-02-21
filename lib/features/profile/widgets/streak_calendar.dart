import 'package:flutter/material.dart';

/// Calendrier d'activité simplifié (7 derniers jours).
/// Simplified activity calendar (last 7 days).
class StreakCalendar extends StatelessWidget {
  final Map<String, int> dailyPoints;

  const StreakCalendar({super.key, required this.dailyPoints});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();

    // Générer les 7 derniers jours / Generate last 7 days
    final days = List.generate(7, (i) {
      final date = now.subtract(Duration(days: 6 - i));
      return date;
    });

    final maxPoints = dailyPoints.values.fold<int>(
      1,
      (max, val) => val > max ? val : max,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: days.map((date) {
            final key =
                '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
            final points = dailyPoints[key] ?? 0;
            final intensity = points > 0 ? (points / maxPoints).clamp(0.2, 1.0) : 0.0;

            final isToday = date.day == now.day &&
                date.month == now.month &&
                date.year == now.year;

            return Column(
              children: [
                Text(
                  _weekdayShort(date.weekday),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: points > 0
                        ? theme.colorScheme.primary
                            .withOpacity(intensity.toDouble())
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                    border: isToday
                        ? Border.all(
                            color: theme.colorScheme.primary,
                            width: 2,
                          )
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: isToday ? FontWeight.bold : null,
                        color: points > 0 && intensity > 0.5
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                if (points > 0)
                  Text(
                    '$points',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                else
                  Text(
                    '-',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant
                          .withOpacity(0.3),
                    ),
                  ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  String _weekdayShort(int weekday) {
    const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return days[weekday - 1];
  }
}
