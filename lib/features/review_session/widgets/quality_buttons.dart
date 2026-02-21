import 'package:flutter/material.dart';

import '../../../features/srs/srs_engine.dart';
import '../../../utils/constants.dart';

/// Boutons de qualité de réponse SRS (Again/Hard/Good/Easy).
/// SRS response quality buttons (Again/Hard/Good/Easy).
class QualityButtons extends StatelessWidget {
  final void Function(ReviewQuality quality) onAnswer;

  const QualityButtons({super.key, required this.onAnswer});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildButton(
          context,
          label: 'Again',
          subtitle: '+5',
          color: AppConstants.againColor,
          quality: ReviewQuality.again,
        ),
        const SizedBox(width: 8),
        _buildButton(
          context,
          label: 'Hard',
          subtitle: '+10',
          color: AppConstants.hardColor,
          quality: ReviewQuality.hard,
        ),
        const SizedBox(width: 8),
        _buildButton(
          context,
          label: 'Good',
          subtitle: '+15',
          color: AppConstants.goodColor,
          quality: ReviewQuality.good,
        ),
        const SizedBox(width: 8),
        _buildButton(
          context,
          label: 'Easy',
          subtitle: '+25',
          color: AppConstants.easyColor,
          quality: ReviewQuality.easy,
        ),
      ],
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required String label,
    required String subtitle,
    required Color color,
    required ReviewQuality quality,
  }) {
    return Expanded(
      child: Material(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
          onTap: () => onAnswer(quality),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: color.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
