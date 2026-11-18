import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../core/formato.dart';
import '../../core/iconos.dart';
import '../../models/gasto.dart';
import '../../providers/gasto_provider.dart';
import 'gasto_form_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _abrirFormulario(BuildContext context, [Gasto? gasto]) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GastoFormScreen(gasto: gasto)),
    );
  }

  Future<bool> _confirmarEliminar(BuildContext context) async {
    final r = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar gasto'),
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

  @override
  Widget build(BuildContext context) {
    final p = context.watch<GastoProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis gastos'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthProvider>().cerrarSesion(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(context),
        child: const Icon(Icons.add),
      ),
      body: switch (p.estado) {
        EstadoCarga.inicial || EstadoCarga.cargando => const Center(
          child: CircularProgressIndicator(),
        ),
        EstadoCarga.error => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(p.mensajeError ?? 'Error desconocido'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: p.cargar,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        EstadoCarga.listo =>
          p.gastos.isEmpty
              ? const Center(
                  child: Text('Aún no hay gastos. Pulsa + para agregar.'),
                )
              : Column(
                  children: [
                    Card(
                      margin: const EdgeInsets.all(12),
                      child: ListTile(
                        title: const Text('Total gastado'),
                        trailing: Text(
                          Formato.moneda(p.total),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: p.gastos.length,
                        itemBuilder: (context, i) {
                          final g = p.gastos[i];
                          final cat = p.categoriaDe(g.categoriaId);
                          return Dismissible(
                            key: ValueKey(g.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            confirmDismiss: (_) => _confirmarEliminar(context),
                            onDismissed: (_) =>
                                context.read<GastoProvider>().eliminar(g.id),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Color(
                                  cat?.colorValue ?? 0xFF90A4AE,
                                ),
                                child: Icon(
                                  iconoDe(cat?.icono ?? 'category'),
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(g.descripcion),
                              subtitle: Text(
                                '${cat?.nombre ?? 'Sin categoría'} · ${Formato.fecha(g.fecha)}',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (g.rutaFoto != null)
                                    const Padding(
                                      padding: EdgeInsets.only(right: 8),
                                      child: Icon(Icons.receipt_long, size: 18),
                                    ),
                                  Text(Formato.moneda(g.monto)),
                                ],
                              ),
                              onTap: () => _abrirFormulario(context, g),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
      },
    );
  }
}
