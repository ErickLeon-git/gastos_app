import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/validators.dart';
import '../../models/presupuesto.dart';
import '../../providers/gasto_provider.dart';
import '../../providers/presupuesto_provider.dart';

class PresupuestoFormScreen extends StatefulWidget {
  const PresupuestoFormScreen({super.key, this.presupuesto});
  final Presupuesto? presupuesto;

  @override
  State<PresupuestoFormScreen> createState() => _PresupuestoFormScreenState();
}

class _PresupuestoFormScreenState extends State<PresupuestoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _limiteCtrl;
  String? _categoriaId;
  late PeriodoPresupuesto _periodo;
  bool _guardando = false;

  bool get _esNuevo => widget.presupuesto == null;

  @override
  void initState() {
    super.initState();
    final p = widget.presupuesto;
    _limiteCtrl = TextEditingController(text: p?.montoLimite.toString() ?? '');
    _categoriaId = p?.categoriaId;
    _periodo = p?.periodo ?? PeriodoPresupuesto.semanal;
  }

  @override
  void dispose() {
    _limiteCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);

    final p = Presupuesto(
      id: widget.presupuesto?.id ?? const Uuid().v4(),
      categoriaId: _categoriaId!,
      montoLimite: Validators.parseMonto(_limiteCtrl.text)!,
      periodo: _periodo,
    );

    final ok = await context.read<PresupuestoProvider>().guardar(
      p,
      esNuevo: _esNuevo,
    );

    if (!mounted) return;
    setState(() => _guardando = false);
    if (ok) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar el presupuesto')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categorias = context.watch<GastoProvider>().categorias;

    return Scaffold(
      appBar: AppBar(
        title: Text(_esNuevo ? 'Nuevo presupuesto' : 'Editar presupuesto'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              initialValue: _categoriaId,
              decoration: const InputDecoration(
                labelText: 'Categoría',
                border: OutlineInputBorder(),
              ),
              items: categorias
                  .map(
                    (c) => DropdownMenuItem(value: c.id, child: Text(c.nombre)),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _categoriaId = v),
              validator: (v) => v == null ? 'Elige una categoría' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _limiteCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Límite',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
              validator: Validators.limite,
            ),
            const SizedBox(height: 16),
            SegmentedButton<PeriodoPresupuesto>(
              segments: const [
                ButtonSegment(
                  value: PeriodoPresupuesto.semanal,
                  label: Text('Semanal'),
                ),
                ButtonSegment(
                  value: PeriodoPresupuesto.mensual,
                  label: Text('Mensual'),
                ),
              ],
              selected: {_periodo},
              onSelectionChanged: (s) => setState(() => _periodo = s.first),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _guardando ? null : _guardar,
              child: _guardando
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
