import 'package:intl/intl.dart';

class Formato {
  static final _moneda = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
  static final _fecha = DateFormat('dd MMM yyyy', 'es_MX');

  static String moneda(double v) => _moneda.format(v);
  static String fecha(DateTime d) => _fecha.format(d);
}
