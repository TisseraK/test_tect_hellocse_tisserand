import 'package:flutter/material.dart';

/// Libellé et icône associés à un code météo WMO (`daily.weathercode`
/// d'Open-Meteo). Pure présentation : le domaine ne connaît que l'entier
/// brut, c'est ici qu'il est traduit pour l'affichage.
class WeatherCondition {
  const WeatherCondition(this.label, this.icon);

  final String label;
  final IconData icon;
}

WeatherCondition weatherConditionFor(int code) {
  if (code == 0) return const WeatherCondition('Ciel clair', Icons.wb_sunny);
  if (code <= 2) {
    return const WeatherCondition('Peu nuageux', Icons.wb_cloudy_outlined);
  }
  if (code == 3) return const WeatherCondition('Couvert', Icons.cloud);
  if (code == 45 || code == 48) {
    return const WeatherCondition('Brouillard', Icons.foggy);
  }
  if (code >= 51 && code <= 57) {
    return const WeatherCondition('Bruine', Icons.grain);
  }
  if (code >= 61 && code <= 67) {
    return const WeatherCondition('Pluie', Icons.water_drop);
  }
  if (code >= 71 && code <= 77) {
    return const WeatherCondition('Neige', Icons.ac_unit);
  }
  if (code >= 80 && code <= 82) {
    return const WeatherCondition('Averses', Icons.umbrella);
  }
  if (code >= 95) {
    return const WeatherCondition('Orage', Icons.thunderstorm);
  }
  return const WeatherCondition('Météo inconnue', Icons.help_outline);
}
