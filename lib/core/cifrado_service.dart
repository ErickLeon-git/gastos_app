import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CifradoService {
  CifradoService._();
  static final CifradoService instance = CifradoService._();

  static const _storage = FlutterSecureStorage();
  static const _claveNombre = 'db_aes_key';
  static const _prefijo = 'enc:';

  late final Encrypter _encrypter;
  bool _listo = false;

  /// Genera la clave la primera vez y la reutiliza después.
  Future<void> init() async {
    if (_listo) return;
    var base64Key = await _storage.read(key: _claveNombre);
    if (base64Key == null) {
      base64Key = Key.fromSecureRandom(32).base64;
      await _storage.write(key: _claveNombre, value: base64Key);
    }
    _encrypter = Encrypter(AES(Key.fromBase64(base64Key), mode: AESMode.gcm));
    _listo = true;
  }

  String cifrar(String texto) {
    final iv = IV.fromSecureRandom(12);
    final cifrado = _encrypter.encrypt(texto, iv: iv);
    return '$_prefijo${iv.base64}:${cifrado.base64}';
  }

  String descifrar(String valor) {
    // Datos antiguos sin cifrar: se devuelven tal cual.
    if (!valor.startsWith(_prefijo)) return valor;
    final partes = valor.substring(_prefijo.length).split(':');
    if (partes.length != 2) return valor;
    try {
      return _encrypter.decrypt(
        Encrypted.fromBase64(partes[1]),
        iv: IV.fromBase64(partes[0]),
      );
    } catch (_) {
      return '[dato no legible]';
    }
  }
}
