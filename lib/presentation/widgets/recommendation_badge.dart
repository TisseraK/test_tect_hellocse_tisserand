import 'package:flutter/material.dart';

import '../../domain/entities/recommendation_level.dart';

/// Recommandée/Possible/Déconseillée sont des indicateurs de statut : ils
/// utilisent des couleurs sémantiques fixes (vert/orange/rouge), lisibles
/// de la même façon en thème clair et sombre, plutôt que le `ColorScheme`
/// du thème (qui n'a pas de rôle "succès"/"avertissement").
class RecommendationBadge extends StatelessWidget {
  const RecommendationBadge({super.key, required this.level});

  final RecommendationLevel level;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (level) {
      RecommendationLevel.recommended => (
        Colors.green.shade600,
        Icons.check_circle,
      ),
      RecommendationLevel.possible => (
        Colors.orange.shade700,
        Icons.remove_circle_outline,
      ),
      RecommendationLevel.notRecommended => (
        Theme.of(context).colorScheme.error,
        Icons.cancel_outlined,
      ),
    };

    return Chip(
      avatar: Icon(icon, color: color, size: 18),
      label: Text(level.label),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w600),
      backgroundColor: color.withValues(alpha: 0.12),
      side: BorderSide(color: color.withValues(alpha: 0.4)),
      visualDensity: VisualDensity.compact,
    );
  }
}
