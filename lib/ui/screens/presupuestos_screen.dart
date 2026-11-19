import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/formato.dart';
import '../../core/iconos.dart';
import '../../models/presupuesto.dart';
import '../../providers/gasto_provider.dart';
import '../../providers/presupuesto_provider.dart';
import 'presupuesto_form_screen.dart';

class PresupuestosScreen extends StatelessWidget {
  const PresupuestosScreen({super.key});

  void _abrir(BuildContext context, [Presupuesto? p]) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PresupuestoFormScreen(presupuesto: p)),
    );
  }

  Future<bool> _confirmar(BuildContext context) async {
    final r = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar presupuesto'),
        content: const Text('¿Seguro que quieres eliminarlo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    return r ?? false;
  }

  Color _color(double pct) {
    if (pct >= 1) return Colors.red;
    if (pct >= 0.8) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final pp = context.watch<PresupuestoProvider>();
    final gp = context.watch<GastoProvider>();
    final items = pp.calcular(gp.gastos, gp.categorias);

    return Scaffold(
      appBar: AppBar(title: const Text('Presupuestos')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrir(context),
        child: const Icon(Icons.add),
      ),
      body: switch (pp.estado) {
        EstadoCarga.inicial || EstadoCarga.cargando => const Center(
          child: CircularProgressIndicator(),
        ),
        EstadoCarga.error => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(pp.mensajeError ?? 'Error desconocido'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: pp.cargar,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        EstadoCarga.listo =>
          items.isEmpty
              ? const Center(
                  child: Text('Sin presupuestos. Pulsa + para crear uno.'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final e = items[i];
                    final pct = e.porcentaje;
                    final cat = e.categoria;
                    return Dismissible(
                      key: ValueKey(e.presupuesto.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (_) => _confirmar(context),
                      onDismissed: (_) => context
                          .read<PresupuestoProvider>()
                          .eliminar(e.presupuesto.id),
                      child: Card(
                        child: InkWell(
                          onTap: () => _abrir(context, e.presupuesto),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Color(
                                        cat?.colorValue ?? 0xFF90A4AE,
                                      ),
                                      child: Icon(
                                        iconoDe(cat?.icono ?? 'category'),
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            cat?.nombre ?? 'Sin categoría',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                          Text(
                                            e.presupuesto.periodo ==
                                                    PeriodoPresupuesto.semanal
                                                ? 'Semanal'
                                                : 'Mensual',
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text('${(pct * 100).toStringAsFixed(0)}%'),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                LinearProgressIndicator(
                                  value: pct.clamp(0.0, 1.0),
                                  minHeight: 8,
                                  color: _color(pct),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${Formato.moneda(e.gastado)} de ${Formato.moneda(e.presupuesto.montoLimite)}',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
      },
    );
  }
}
