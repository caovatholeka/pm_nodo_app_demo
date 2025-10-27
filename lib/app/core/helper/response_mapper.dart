T? mapObject<T>(
    dynamic data,
    T Function(Map<String, dynamic>) fromJson,
    ) {
  if (data == null) return null;
  if (data is Map<String, dynamic>) return fromJson(data);
  if (data is Map) return fromJson(Map<String, dynamic>.from(data));
  return null;
}

List<T> mapList<T>(
    dynamic data,
    T Function(Map<String, dynamic>) fromJson,
    ) {
  if (data == null) return const [];
  if (data is List) {
    return data
        .where((e) => e is Map || e is Map<String, dynamic>)
        .map((e) => fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
  return const [];
}
