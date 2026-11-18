import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class FotoService {
  final _picker = ImagePicker();

  /// Devuelve la ruta de la foto guardada, o null si se cancela.
  Future<String?> capturar(ImageSource origen) async {
    final xfile = await _picker.pickImage(
      source: origen,
      maxWidth: 1600,
      imageQuality: 80,
    );
    if (xfile == null) return null;

    final base = await getApplicationDocumentsDirectory();
    final carpeta = Directory(p.join(base.path, 'tickets'));
    if (!await carpeta.exists()) await carpeta.create(recursive: true);

    final destino = p.join(carpeta.path, '${const Uuid().v4()}.jpg');
    await File(xfile.path).copy(destino);
    return destino;
  }

  Future<void> borrar(String? ruta) async {
    if (ruta == null) return;
    final archivo = File(ruta);
    if (await archivo.exists()) await archivo.delete();
  }
}
