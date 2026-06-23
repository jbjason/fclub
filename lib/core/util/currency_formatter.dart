import 'package:intl/intl.dart';

abstract class CurrencyFormatter {
  static final NumberFormat _format = NumberFormat.currency(
    symbol: '৳',
    decimalDigits: 0,
  );

  static String format(double amount) => _format.format(amount);
}
