/// Build-time config. Override with:
///   flutter build web --dart-define=API_BASE_URL=`https://<worker>.workers.dev/api`
class Env {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8787/api',
  );
}
