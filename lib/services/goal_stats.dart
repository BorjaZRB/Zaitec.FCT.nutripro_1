// Servicio para calcular promedios semanales y mensuales de cumplimiento.
// Uso esperado: pasar una lista de GoalCompletion con percent en 0.0..100.0.
// Si tus datos son booleanos (cumplido/no cumplido), convierte true -> 100.0, false -> 0.0
// o usa la función helper `fromBooleansToPercent` más abajo.

import 'dart:collection';

class GoalCompletion {
  final DateTime date;
  final double percent; // 0.0 .. 100.0

  GoalCompletion({required this.date, required this.percent});
}

/// Devuelve el inicio de la semana (lunes) para la fecha dada.
DateTime _startOfWeek(DateTime d) {
  final date = DateTime(d.year, d.month, d.day);
  // weekday: 1 = Monday .. 7 = Sunday (ISO)
  final delta = date.weekday - 1; // 0 si es lunes
  return date.subtract(Duration(days: delta));
}

/// Devuelve el primer día del mes para la fecha dada.
DateTime _startOfMonth(DateTime d) => DateTime(d.year, d.month, 1);

Map<DateTime, double> _averageMapFromGroups(Map<DateTime, List<double>> groups) {
  final keys = groups.keys.toList()..sort();
  final ordered = LinkedHashMap<DateTime, double>();
  for (final k in keys) {
    final list = groups[k]!;
    final avg = list.isEmpty ? 0.0 : list.reduce((a, b) => a + b) / list.length;
    ordered[k] = avg;
  }
  return ordered;
}

/// Calcula promedios semanales (agrupando por semana que empieza el lunes).
/// Devuelve un Map ordenado por fecha (inicio de semana) -> promedio (0..100).
Map<DateTime, double> weeklyAverages(List<GoalCompletion> items) {
  final Map<DateTime, List<double>> groups = {};
  for (final it in items) {
    final key = _startOfWeek(it.date);
    groups.putIfAbsent(key, () => []).add(it.percent);
  }
  return _averageMapFromGroups(groups);
}

/// Calcula promedios mensuales (agrupando por primer día de cada mes).
/// Devuelve un Map ordenado por fecha (inicio de mes) -> promedio (0..100).
Map<DateTime, double> monthlyAverages(List<GoalCompletion> items) {
  final Map<DateTime, List<double>> groups = {};
  for (final it in items) {
    final key = _startOfMonth(it.date);
    groups.putIfAbsent(key, () => []).add(it.percent);
  }
  return _averageMapFromGroups(groups);
}

/// Helper: convierte una lista de pares (fecha, bool cumplido) a GoalCompletion
/// donde true -> 100.0 y false -> 0.0. Útil si tu origen de datos usa booleanos.
List<GoalCompletion> fromBooleansToPercent(List<MapEntry<DateTime, bool>> entries) {
  return entries
      .map((e) => GoalCompletion(date: e.key, percent: e.value ? 100.0 : 0.0))
      .toList();
}

/// Ejemplo de uso:
/// final data = [
///   GoalCompletion(date: DateTime(2025, 10, 13), percent: 100),
///   GoalCompletion(date: DateTime(2025, 10, 14), percent: 50),
///   GoalCompletion(date: DateTime(2025, 10, 20), percent: 75),
/// ];
/// final weeks = weeklyAverages(data);
/// final months = monthlyAverages(data);