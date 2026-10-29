/// Nhãn trong giao diện v2 (nhãn một cột, giá trị một cột): bỏ ":" ở cuối. Một số key l10n
/// dùng chung với màn v1 có sẵn dấu hai chấm ("Chức danh: ", "Lý do:") → v2 lúc có lúc không.
String labelV2(String label) => label.replaceFirst(RegExp(r'[:：\s]+$'), '');
