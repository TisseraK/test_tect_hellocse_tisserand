enum RecommendationLevel {
  recommended('Recommandée'),
  possible('Possible'),
  notRecommended('Déconseillée');

  const RecommendationLevel(this.label);

  final String label;
}
