import 'package:logger/logger.dart';

T? safeParse<T>(dynamic value, String fieldName) {
  try {
    // Return immediately if value is already of type T
    if (value is T) return value;

    // Handle specific type conversions
    if (T == int) {
      final parsed = int.tryParse(value.toString());
      if (parsed != null) return parsed as T;
    } else if (T == double) {
      final parsed = double.tryParse(value.toString());
      if (parsed != null) return parsed as T;
    } else if (T == bool) {
      final str = value.toString().toLowerCase();
      if (str == 'true') return true as T;
      if (str == 'false') return false as T;
    } else if (T == String) {
      return value.toString() as T;
    }
  } catch (e) {
    Logger().e('[safeParse] ▲ Field "$fieldName": $e');
  }

  // Handle null values and type errors
  final valueType = value != null ? value.runtimeType.toString() : 'null';
  Logger().e(
      '[safeParse] X Type mismatch in "$fieldName": expected $T, got $valueType');
  return null;
}