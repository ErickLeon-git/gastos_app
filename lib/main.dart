import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/env.dart';
import 'data/repositories/categoria_repository.dart';
import 'data/repositories/gasto_repository.dart';
import 'providers/auth_provider.dart';
import 'providers/gasto_provider.dart';
import 'services/secure_local_storage.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/login_screen.dart';
import 'data/repositories/presupuesto_repository.dart';
import 'providers/presupuesto_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_MX');

  assert(
    Env.supabaseUrl.isNotEmpty && Env.supabaseAnonKey.isNotEmpty,
    'Faltan SUPABASE_URL o SUPABASE_ANON_KEY. Ejecuta con --dart-define-from-file=env.json',
  );

  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
    authOptions: FlutterAuthClientOptions(localStorage: SecureLocalStorage()),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
          create: (_) =>
              GastoProvider(GastoRepository(), CategoriaRepository())..cargar(),
        ),
        ChangeNotifierProvider(
          create: (_) => PresupuestoProvider(PresupuestoRepository())..cargar(),
        ),
      ],
      child: const GastosApp(),
    ),
  );
}

class GastosApp extends StatelessWidget {
  const GastosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gastos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return auth.autenticado ? const HomeScreen() : const LoginScreen();
  }
}
