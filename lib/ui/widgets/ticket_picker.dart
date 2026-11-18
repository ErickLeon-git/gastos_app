import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/foto_service.dart';

class TicketPicker extends StatefulWidget {
  const TicketPicker({super.key, required this.ruta, required this.onChanged});
  final String? ruta;
  final ValueChanged<String?> onChanged;

  @override
  State<TicketPicker> createState() => _TicketPickerState();
}

class _TicketPickerState extends State<TicketPicker> {
  final _servicio = FotoService();
  bool _cargando = false;

  Future<void> _elegir() async {
    final origen = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Tomar foto'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Elegir de la galería'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (origen == null) return;

    setState(() => _cargando = true);
    try {
      final ruta = await _servicio.capturar(origen);
      if (ruta != null) widget.onChanged(ruta);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo obtener la foto')),
        );
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (widget.ruta == null) {
      return OutlinedButton.icon(
        onPressed: _elegir,
        icon: const Icon(Icons.receipt_long),
        label: const Text('Agregar foto del ticket'),
      );
    }

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(widget.ruta!),
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox(
              height: 120,
              child: Center(child: Text('No se pudo cargar la imagen')),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              onPressed: _elegir,
              icon: const Icon(Icons.refresh),
              label: const Text('Cambiar'),
            ),
            TextButton.icon(
              onPressed: () => widget.onChanged(null),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Quitar'),
            ),
          ],
        ),
      ],
    );
  }
}
