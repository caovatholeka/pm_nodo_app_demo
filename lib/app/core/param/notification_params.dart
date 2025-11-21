Map<String, dynamic> buildNotiParams(
  String type, {
  int page = 1,
  int limit = 20,
}) {
  return {
    "type": type,
    "page": page,
    "limit": limit,
  };
}
