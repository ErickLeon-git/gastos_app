# Gastos App

App móvil de gestión de gastos personales hecha con **Flutter/Dart**. Funciona sin internet (SQLite local) y sincroniza con Supabase.

## Funciones

- CRUD completo de gastos, con validación de entradas
- Categorías y presupuestos semanales/mensuales con barra de progreso
- Autenticación con Supabase Auth (registro, login, logout)
- Foto del ticket con cámara o galería (`image_picker`)
- Notificación local al llegar al 80 % y 100 % del presupuesto, y recordatorio semanal
- Sincronización con Supabase (con estados de carga y error)
- Cifrado AES-256-GCM de datos sensibles en la base local
- Gráficos de pastel y barras (`fl_chart`)

## Stack

Flutter · Dart · SQLite (`sqflite`) · Provider · Supabase

Librerías de terceros: `intl`, `uuid`, `fl_chart`, `image_picker`, `encrypt`, `flutter_local_notifications`, `flutter_secure_storage`, `supabase_flutter`.

## Requisitos

- Flutter 3.x y Dart (verifica con `flutter doctor`)
- Android SDK (compileSdk 37) y JDK 17
- Una cuenta de Supabase

## Instalación

1. Clona el repositorio:
   ```bash
   git clone https://github.com/ErickLeon-git/gastos_app.git
   cd gastos_app
   flutter pub get
   ```
2. En Supabase, ejecuta en **SQL Editor** el script de `docs/supabase.sql` (tabla `gastos` con Row Level Security) y, en **Authentication → Providers**, activa Email.
3. Crea `env.json` en la raíz (no se versiona):
   ```json
   {
     "SUPABASE_URL": "https://rqtebowymxuszctcmupj.supabase.co",
     "SUPABASE_ANON_KEY": "sb_publishable_EdD8HTHQ1JxVaAt5jQXRbg_L3lEXVU5S"
   }
   ```
   Usa solo la clave **anon/publishable**, nunca la secret ni la service_role.
4. Ejecuta:
   ```bash
   flutter run --dart-define-from-file=env.json
   ```

## Estructura

```
lib/
├── core/        validadores, formato, cifrado, estadísticas
├── data/        SQLite, Supabase y repositorios
├── models/      Gasto, Categoria, Presupuesto
├── providers/   estado (Provider)
├── services/    notificaciones, fotos, sync, alertas
└── ui/          pantallas y widgets
```

## Flujo de ramas

`main` (estable) · `develop` (integración) · `feature/*` · `hotfix/*`. Los cambios entran por Pull Request.

## Seguridad

- Sesión en `flutter_secure_storage` (Android Keystore)
- Datos sensibles cifrados con AES-256-GCM, clave generada en el dispositivo
- Claves de API fuera del repositorio
- Row Level Security en Supabase
- Validación de montos, textos, correo y contraseña
- `allowBackup=false`

## Limitaciones del MVP

- La foto del ticket no se sube a la nube
- Categorías fijas (5 por defecto)
- Sin recuperación de contraseña ni confirmación de correo
- Probado en Android; iOS sin verificar
