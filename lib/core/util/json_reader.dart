typedef JsonMap = Map<String, dynamic>;

String readString(JsonMap json, String key, [String defaultValue = '']) {
  final value = json[key];
  if (value == null) {
    return defaultValue;
  }
  return value.toString();
}

int readInt(JsonMap json, String key, [int defaultValue = 0]) {
  final value = json[key];
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '') ?? defaultValue;
}

bool readBool(JsonMap json, String key, [bool defaultValue = false]) {
  final value = json[key];
  if (value is bool) {
    return value;
  }
  final normalized = value?.toString().toLowerCase();
  if (normalized == 'true') {
    return true;
  }
  if (normalized == 'false') {
    return false;
  }
  return defaultValue;
}

DateTime? readDateTime(JsonMap json, String key) {
  final value = json[key];
  if (value is DateTime) {
    return value;
  }
  return DateTime.tryParse(value?.toString() ?? '');
}

JsonMap readMap(JsonMap json, String key) {
  final value = json[key];
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return {};
}

List<JsonMap> readMapList(JsonMap json, String key) {
  final value = json[key];
  if (value is! List) {
    return [];
  }

  return value
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}

List<String> readStringList(JsonMap json, String key) {
  final value = json[key];
  if (value is! List) {
    return [];
  }
  return value.map((item) => item.toString()).toList();
}
