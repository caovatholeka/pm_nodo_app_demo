/// Helper cho các field Odoo trả về `false` khi rỗng, nhưng trả String/số khi có
/// giá trị. Nếu khai kiểu Dart theo đúng một trong hai dạng thì phía còn lại sẽ
/// ném exception lúc parse, nên dùng converter này cho các field kiểu đó.
///
/// `false` / `null` / chuỗi rỗng -> null, còn lại -> chuỗi.
String? odooStringFromJson(dynamic value) {
  if (value == null || value == false) return null;
  if (value is String) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
  return value.toString();
}
