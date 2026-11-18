import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/formato.dart';
import '../../core/validators.dart';
import '../../models/gasto.dart';
import '../../providers/gasto_provider.dart';
import '../widgets/ticket_picker.dart';

class GastoFormScreen extends StatefulWidget {
  const GastoFormScreen({super.key, this.gasto});
  final Gasto? gasto; // null = nuevo gasto

  @override
  State<GastoFormScreen> createState() => _GastoFormScreenState();
}

class _GastoFormScreenState extends State<GastoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _montoCtrl;
  late final TextEditingController _descCtrl;
  String? _categoriaId;
  String? _rutaFoto;
  late DateTime _fecha;
  bool _guardando = false;

  bool get _esNuevo => widget.gasto == null;

  @override
  void initState() {
    super.initState();
    final g = widget.gasto;
    _montoCtrl = TextEditingController(text: g?.monto.toString() ?? '');
    _descCtrl = TextEditingController(text: g?.descripcion ?? '');
    _categoriaId = g?.categoriaId;
    _rutaFoto = g?.rutaFoto;
    _fecha = g?.fecha ?? DateTime.now();
  }

  @override
  void dispose() {
    _montoCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _elegirFecha() async {
    final elegida = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (elegida != null) setState(() => _fecha = elegida);
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);

    final gasto = Gasto(
      id: widget.gasto?.id ?? const Uuid().v4(),
      monto: Validators.parseMonto(_montoCtrl.text)!,
      descripcion: _descCtrl.text.trim(),
      fecha: _fecha,
      categoriaId: _categoriaId!,
      rutaFoto: _rutaFoto,
    );

    final ok = await context.read<GastoProvider>().guardar(
      gasto,
      esNuevo: _esNuevo,
    );

    if (!mounted) return;
    setState(() => _guardando = false);
    if (ok) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar el gasto')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categorias = context.watch<GastoProvider>().categorias;

    return Scaffold(
      appBar: AppBar(title: Text(_esNuevo ? 'Nuevo gasto' : 'Editar gasto')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _montoCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Monto',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
              validator: Validators.monto,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descCtrl,
              maxLength: 100,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
              ),
              validator: Validators.descripcion,
            ),
            const SizedBox(height: 8),
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
            ListTile(
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              leading: const Icon(Icons.calendar_today),
              title: Text(Formato.fecha(_fecha)),
              onTap: _elegirFecha,
            ),
            const SizedBox(height: 16),
            TicketPicker(
              ruta: _rutaFoto,
              onChanged: (r) => setState(() => _rutaFoto = r),
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
