import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class DashboardWidget extends StatefulWidget {
  final int calories;
  final int meals;
  final double water;
  final double goalsProgress;
  final List<double> weeklyCaloriesData;
  final List<double> weeklyWaterData;
  final List<double> weeklyMealsData;
  final List<double> monthlyData;
  final int goalCalories;
  final double goalWater;
  final int goalMeals;

  const DashboardWidget({
    super.key,
    required this.calories,
    required this.meals,
    required this.water,
    required this.goalsProgress,
    required this.weeklyCaloriesData,
    required this.weeklyWaterData,
    required this.weeklyMealsData,
    required this.monthlyData,
    this.goalCalories = 2000,
    this.goalWater = 8.0,
    this.goalMeals = 3,
  });

  @override
  State<DashboardWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  String selectedMetric = "calorias";

  void _exportPdfMock() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Exportando PDF...")));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final bool aguaBaja = widget.water < (widget.goalWater / 2);
    final bool comidasBajas = widget.meals < (widget.goalMeals - 1);
    final bool caloriasBajas = widget.calories < (widget.goalCalories * 0.6);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(context, cs, tt),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _statCard(
                context,
                Icons.local_fire_department,
                'Calorías',
                '${widget.calories} kcal',
                alerta: caloriasBajas ? 'Calorías bajas' : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _statCard(
                context,
                Icons.restaurant,
                'Comidas',
                '${widget.meals}',
                alerta: comidasBajas ? 'Pocas comidas' : null,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _statCard(
                context,
                Icons.water_drop,
                'Agua',
                '${widget.water.toInt()} vasos',
                alerta: aguaBaja ? 'Hidratación insuficiente' : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(child: _goalsCard(context)),
          ],
        ),

        const SizedBox(height: 16),

        _chartCard(
          context,
          title: _chartTitle(),
          chart: _selectedChart(context),
          hasData: _hasChartData(),
        ),
      ],
    );
  }

  Widget _header(BuildContext context, ColorScheme cs, TextTheme tt) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: cs.onSurface.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _exportPdfMock,
                icon: const Icon(Icons.picture_as_pdf),
                iconSize: 40,
                color: cs.primary,
                tooltip: "Exportar estadísticas en PDF",
              ),
            ],
          ),
          const SizedBox(height: 12),
          _metricSelector(cs),
        ],
      ),
    );
  }

  Widget _metricSelector(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: cs.secondary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _metricButton("Calorías", "calorias"),
          _metricButton("Comidas", "comidas"),
          _metricButton("Agua", "agua"),
        ],
      ),
    );
  }

  Widget _metricButton(String label, String key) {
    final cs = Theme.of(context).colorScheme;
    final bool selected = selectedMetric == key;

    return GestureDetector(
      onTap: () => setState(() => selectedMetric = key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? cs.secondary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? cs.onSecondary : cs.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _statCard(
    BuildContext context,
    IconData icon,
    String title,
    String value, {
    String? alerta,
  }) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: cs.onSurface.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: cs.primary.withOpacity(0.15),
            radius: 22,
            child: Icon(icon, color: cs.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: tt.labelMedium?.copyWith(
                    color: cs.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (alerta != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      alerta,
                      style: tt.labelSmall?.copyWith(color: cs.error),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _goalsCard(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: cs.onSurface.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Objetivos',
            style: tt.labelMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: widget.goalsProgress.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: cs.primary.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation(cs.primary),
            ),
          ),
          if (widget.goalsProgress < 0.4)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Cumplimiento bajo',
                style: tt.labelSmall?.copyWith(color: cs.error),
              ),
            ),
        ],
      ),
    );
  }

  Widget _chartCard(
    BuildContext context, {
    required String title,
    required Widget chart,
    required bool hasData,
  }) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: cs.onSurface.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 240,
            child: hasData
                ? chart
                : const Center(child: Text("No hay datos aún")),
          ),
        ],
      ),
    );
  }

  String _chartTitle() {
    switch (selectedMetric) {
      case "calorias":
        return "Calorías (Últimos 7 días)";
      case "comidas":
        return "Comidas (Últimos 7 días)";
      case "agua":
        return "Agua (Últimos 7 días)";
      default:
        return "Estadísticas (Últimos 7 días)";
    }
  }

  bool _hasChartData() {
    return _getDataForMetric().isNotEmpty;
  }

  Map<String, dynamic> _getGoalForMetric() {
    switch (selectedMetric) {
      case "calorias":
        return {'value': widget.goalCalories.toDouble(), 'color': Colors.red};
      case "agua":
        return {'value': widget.goalWater, 'color': Colors.blue};
      case "comidas":
        return {'value': widget.goalMeals.toDouble(), 'color': Colors.amber};
      default:
        return {'value': 0.0, 'color': Colors.grey};
    }
  }

  List<double> _getDataForMetric() {
    switch (selectedMetric) {
      case "calorias":
        return widget.weeklyCaloriesData;
      case "agua":
        return widget.weeklyWaterData;
      case "comidas":
        return widget.weeklyMealsData;
      default:
        return [];
    }
  }

  double _calculateMaxY(List<double> data, double goalValue) {
    if (data.isEmpty) return goalValue * 1.2;
    final maxData = data.reduce((a, b) => a > b ? a : b);
    final maxVal = maxData > goalValue ? maxData : goalValue;
    return maxVal * 1.2; // 20% más que el máximo para dar espacio
  }

  List<BarChartGroupData> _buildBarGroups(List<double> data, Color barColor) {
    return data.asMap().entries.map((entry) {
      final value = entry.value;
      final hasData = value > 0;

      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: hasData
                ? value
                : 0, // Altura mínima visible para días sin datos
            color: hasData ? barColor : barColor.withOpacity(0.2),
            width: 16,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
          ),
        ],
      );
    }).toList();
  }

  Widget _selectedChart(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final goal = _getGoalForMetric();
    var data = _getDataForMetric();
    final barColor = goal['color'] as Color;
    final goalValue = goal['value'] as double;

    // Si no hay datos, mostrar mensaje amigable
    if (data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 48,
              color: cs.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Aún no hay registros esta semana',
              style: TextStyle(color: cs.onSurface.withOpacity(0.6)),
            ),
            const SizedBox(height: 8),
            Text(
              'Empieza a registrar tus hábitos',
              style: TextStyle(
                fontSize: 12,
                color: cs.onSurface.withOpacity(0.4),
              ),
            ),
          ],
        ),
      );
    }

    // Asegurar que siempre hay 7 elementos (completar con 0s si faltan)
    while (data.length < 7) {
      data.add(0.0);
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _calculateMaxY(data, goalValue),
        barGroups: _buildBarGroups(data, barColor),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: goalValue / 2,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: cs.onSurface.withOpacity(0.1), strokeWidth: 1);
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: selectedMetric == 'comidas' ? 1 : null,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    fontSize: 10,
                    color: cs.onSurface.withOpacity(0.6),
                  ),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < 7) {
                  final date = DateTime.now().subtract(
                    Duration(days: 6 - index),
                  );
                  final dayName = DateFormat('E', 'es_ES').format(date);
                  final label = dayName.substring(0, 1).toUpperCase();

                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: goalValue,
              color: cs.primary,
              strokeWidth: 2,
              dashArray: [5, 5],
              label: HorizontalLineLabel(
                show: true,
                alignment: Alignment.topLeft,
                padding: const EdgeInsets.only(left: 4, bottom: 4),
                style: TextStyle(
                  color: cs.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
                labelResolver: (line) => 'Objetivo: ${line.y.toInt()}',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
