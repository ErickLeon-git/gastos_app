import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider() {
    _sub = _client.auth.onAuthStateChange.listen((_) => notifyListeners());
  }

  final _client = Supabase.instance.client;
  late final StreamSubscription<AuthState> _sub;

  bool cargando = false;
  String? error;

  User? get usuario => _client.auth.currentUser;
  bool get autenticado => _client.auth.currentSession != null;

  Future<bool> iniciarSesion(String email, String password) => _ejecutar(
    () => _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    ),
  );

  Future<bool> registrarse(String email, String password) => _ejecutar(
    () => _client.auth.signUp(email: email.trim(), password: password),
  );

  Future<void> cerrarSesion() => _client.auth.signOut();

  Future<bool> _ejecutar(Future<void> Function() accion) async {
    cargando = true;
    error = null;
    notifyListeners();
    try {
      await accion();
      return true;
    } on AuthException catch (e) {
      error = _traducir(e.message);
      return false;
    } catch (_) {
      error = 'Sin conexión o error inesperado. Intenta de nuevo.';
      return false;
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  String _traducir(String mensaje) {
    final m = mensaje.toLowerCase();
    if (m.contains('invalid login')) return 'Correo o contraseña incorrectos';
    if (m.contains('already registered'))
      return 'Ese correo ya está registrado';
    if (m.contains('email not confirmed')) return 'Confirma tu correo primero';
    return 'No se pudo completar la operación';
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
