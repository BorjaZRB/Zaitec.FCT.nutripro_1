import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardWidget extends StatefulWidget {
  final int calories;
  final int meals;
  final double water;
  final double goalsProgress;
  final List<double> weeklyData;
  final List<double> monthlyData;

  const DashboardWidget({
    super.key,
    required this.calories,
    required this.meals,
    required this.water,
    required this.goalsProgress,
    required this.weeklyData,
    required this.monthlyData,
  });

  @override
  State<DashboardWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  bool showWeekly = true;

   
  void _exportPdfMock() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Exportando PDF... ",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(context, cs, tt),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(child: _statCard(context, Icons.local_fire_department, 'Calorías', '${widget.calories} kcal')),
            const SizedBox(width: 16),
            Expanded(child: _statCard(context, Icons.restaurant, 'Comidas', '${widget.meals}')),
          ],
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(child: _statCard(context, Icons.water_drop, 'Agua', '${widget.water.toInt()} vasos')),
            const SizedBox(width: 16),
            Expanded(child: _goalsCard(context)),
          ],
        ),
        const SizedBox(height: 16),

        _chartCard(
          context,
          title: showWeekly ? 'Evolución Semanal' : 'Evolución Mensual',
          chart: showWeekly ? _weeklyChart(context) : _monthlyChart(context),
          hasData: showWeekly ? widget.weeklyData.isNotEmpty : widget.monthlyData.isNotEmpty,
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
         
          IconButton(
            onPressed: _exportPdfMock,
            icon: const Icon(Icons.picture_as_pdf),
            iconSize: 40,
            color: cs.primary,
            tooltip: "Exportar estadísticas en PDF",
          ),

          _modeSelector(cs),
        ],
      ),
    );
  }

  Widget _modeSelector(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _modeButton("Semanal", showWeekly, () => setState(() => showWeekly = true)),
          _modeButton("Mensual", !showWeekly, () => setState(() => showWeekly = false)),
        ],
      ),
    );
  }

  Widget _modeButton(String label, bool selected, VoidCallback onTap) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? cs.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? cs.onPrimary : cs.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _statCard(BuildContext context, IconData icon, String title, String value) {
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: tt.labelMedium?.copyWith(color: cs.onSurface.withOpacity(0.7))),
              const SizedBox(height: 4),
              Text(value, style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            ],
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
          Text('Objetivos', style: tt.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
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
        ],
      ),
    );
  }

  Widget _chartCard(BuildContext context,
      {required String title, required Widget chart, required bool hasData}) {
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
          Text(title, style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          SizedBox(
            height: 240,
            child: hasData ? chart : const Center(child: Text("No hay datos aún")),
          ),
        ],
      ),
    );
  }

  Widget _weeklyChart(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final spots = widget.weeklyData.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            barWidth: 3,
            dotData: FlDotData(show: false),
            color: cs.primary,
            belowBarData: BarAreaData(
              show: true,
              color: cs.primary.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _monthlyChart(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BarChart(
      BarChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: widget.monthlyData.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value,
                width: 20,
                color: cs.secondary,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

