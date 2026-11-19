import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/estadisticas.dart';
import '../../core/formato.dart';
import '../../providers/gasto_provider.dart';

class EstadisticasScreen extends StatelessWidget {
  const EstadisticasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gp = context.watch<GastoProvider>();
    final porCat = Estadisticas.porCategoriaDelMes(gp.gastos, gp.categorias);
    final dias = Estadisticas.ultimosSieteDias(gp.gastos);
    final totalMes = porCat.fold<double>(0, (s, e) => s + e.total);

    final hoy = DateTime.now();
    final etiquetas = List.generate(7, (i) {
      final d = hoy.subtract(Duration(days: 6 - i));
      return DateFormat('E', 'es_MX').format(d).substring(0, 1).toUpperCase();
    });
    final maxDia = dias.reduce((a, b) => a > b ? a : b);

    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Gasto del mes por categoría',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          if (porCat.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: Text('Sin gastos este mes')),
            )
          else ...[
            SizedBox(
              height: 220,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: porCat.map((e) {
                    final pct = e.total / totalMes * 100;
                    return PieChartSectionData(
                      value: e.total,
                      color: Color(e.categoria?.colorValue ?? 0xFF90A4AE),
                      radius: 60,
                      title: '${pct.toStringAsFixed(0)}%',
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ...porCat.map(
              (e) => ListTile(
                dense: true,
                leading: CircleAvatar(
                  radius: 8,
                  backgroundColor: Color(e.categoria?.colorValue ?? 0xFF90A4AE),
                ),
                title: Text(e.categoria?.nombre ?? 'Sin categoría'),
                trailing: Text(Formato.moneda(e.total)),
              ),
            ),
          ],
          const SizedBox(height: 32),
          Text(
            'Últimos 7 días',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                maxY: maxDia == 0 ? 100 : maxDia * 1.2,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(),
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) => Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(etiquetas[v.toInt()]),
                      ),
                    ),
                  ),
                ),
                barGroups: List.generate(
                  7,
                  (i) => BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: dias[i],
                        width: 18,
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
