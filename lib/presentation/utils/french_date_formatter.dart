const _weekdayLabels = ['Lun.', 'Mar.', 'Mer.', 'Jeu.', 'Ven.', 'Sam.', 'Dim.'];
const _monthLabels = [
  'janv.',
  'févr.',
  'mars',
  'avr.',
  'mai',
  'juin',
  'juil.',
  'août',
  'sept.',
  'oct.',
  'nov.',
  'déc.',
];

/// Formatage minimal en français, sans dépendance à `intl` pour un besoin
/// limité à quelques libellés (ex. "Mer. 22 juil.").
String formatDayLabel(DateTime date) {
  final weekday = _weekdayLabels[date.weekday - 1];
  final month = _monthLabels[date.month - 1];
  return '$weekday ${date.day} $month';
}
