import 'dart:math';
import 'package:flutter/material.dart';

import '../../../utils/constants.dart';

/// Widget de carte retournable avec animation 3D.
/// Flippable card widget with 3D animation.
class FlipCard extends StatefulWidget {
  final String front;
  final String back;
  final bool isFlipped;

  const FlipCard({
    super.key,
    required this.front,
    required this.back,
    required this.isFlipped,
  });

  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(FlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFlipped && !oldWidget.isFlipped) {
      _controller.forward();
    } else if (!widget.isFlipped && oldWidget.isFlipped) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final angle = _animation.value * pi;
        final isFront = angle < pi / 2;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // Perspective
            ..rotateY(angle),
          child: isFront
              ? _buildFace(
                  context,
                  text: widget.front,
                  isFront: true,
                )
              : Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(pi),
                  child: _buildFace(
                    context,
                    text: widget.back,
                    isFront: false,
                  ),
                ),
        );
      },
    );
  }

  Widget _buildFace(
    BuildContext context, {
    required String text,
    required bool isFront,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isFront
              ? [
                  theme.colorScheme.primaryContainer,
                  theme.colorScheme.primaryContainer.withOpacity(0.7),
                ]
              : [
                  theme.colorScheme.secondaryContainer,
                  theme.colorScheme.secondaryContainer.withOpacity(0.7),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Label (recto/verso)
            Text(
              isFront ? '表 Recto' : '裏 Verso',
              style: theme.textTheme.labelMedium?.copyWith(
                color: isFront
                    ? theme.colorScheme.onPrimaryContainer.withOpacity(0.6)
                    : theme.colorScheme.onSecondaryContainer.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 16),

            // Contenu principal / Main content
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isFront ? 36 : 22,
                      fontWeight:
                          isFront ? FontWeight.bold : FontWeight.normal,
                      color: isFront
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onSecondaryContainer,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ),

            if (isFront) ...[
              const SizedBox(height: 16),
              Text(
                'Tapez pour retourner',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer.withOpacity(0.5),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
